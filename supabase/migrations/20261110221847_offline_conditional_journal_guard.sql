-- Experimental local-preproduction guard. The older primitive remains present;
-- this version adds a per-user journal watermark and detects changed-then-
-- reverted rows while the journal history is complete.
create index if not exists bicount_sync_events_record_sequence_idx
  on public.bicount_sync_events (user_uid, table_name, record_id, sequence)
  where record_id is not null;
create index if not exists bicount_sync_events_invalidation_sequence_idx
  on public.bicount_sync_events (user_uid, table_name, sequence)
  where change_kind = 'invalidate';

create function public.bicount_conditional_journal_guard(
  p_table text, p_id uuid, p_action text, p_expected jsonb, p_patch jsonb,
  p_seen_sequence bigint, p_generation bigint
) returns jsonb language plpgsql security invoker set search_path = '' as $$
declare
  key_name text;
  current_row jsonb;
  status jsonb;
  result jsonb;
  changed boolean;
  recorded boolean;
begin
  if auth.uid() is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  key_name := case p_table
    when 'users' then 'uid'
    when 'friends' then 'sid'
    when 'transactions' then 'tid'
    when 'debts' then 'debt_id'
    when 'recurring_transfert' then 'recurring_transfert_id'
    else null
  end;
  if key_name is null or p_id is null or p_action is null or p_action not in ('update', 'delete')
      or jsonb_typeof(p_expected) is distinct from 'object'
      or p_expected ->> key_name is distinct from p_id::text then
    raise exception 'Invalid target';
  end if;
  if p_action = 'update' and (jsonb_typeof(p_patch) is distinct from 'object'
      or p_patch - key_name = '{}'::jsonb
      or (p_patch ? key_name and p_patch ->> key_name is distinct from p_id::text)) then
    raise exception 'Invalid patch';
  end if;
  execute format('select to_jsonb(t) from public.%I t where t.%I = $1 for update',
    p_table, key_name) into current_row using p_id;
  if current_row is null then return jsonb_build_object('status', 'conflict', 'row', null); end if;
  -- Status and event checks share one SQL statement snapshot, including if a
  -- concurrent compaction advances oldest_available_sequence.
  with s as materialized (select public.bicount_sync_status() as value)
  select s.value,
    exists (select 1 from public.bicount_sync_events e
      where e.user_uid = (select auth.uid()) and e.table_name = p_table
        and e.record_id = p_id and e.sequence > p_seen_sequence)
    or exists (select 1 from public.bicount_sync_events e
      where e.user_uid = (select auth.uid()) and e.table_name = p_table
        and e.change_kind = 'invalidate' and e.sequence > p_seen_sequence)
  into status, changed from s;
  if p_seen_sequence is null or p_generation is null
      or coalesce((status ->> 'enabled')::boolean, false) = false
      or p_generation <> (status ->> 'generation')::bigint
      or p_seen_sequence < (status ->> 'oldest_available_sequence')::bigint - 1
      or p_seen_sequence > (status ->> 'latest_sequence')::bigint then
    return jsonb_build_object('status', 'not_applied');
  end if;
  if changed then
    if p_action = 'update' and not exists (
      select 1 from jsonb_each(p_patch) e(key, value)
      where not (current_row ? e.key) or current_row -> e.key is distinct from e.value
    ) then
      return jsonb_build_object('status', 'already_applied', 'row', current_row,
        'journal_sequence', (status ->> 'latest_sequence')::bigint,
        'journal_generation', (status ->> 'generation')::bigint);
    end if;
    return jsonb_build_object('status', 'conflict', 'row', current_row);
  end if;
  result := public.bicount_conditional_mutation(p_table, p_id, p_action, p_expected, p_patch);
  if result ->> 'status' not in ('applied', 'already_applied') then return result; end if;
  with s as materialized (select public.bicount_sync_status() as value)
  select s.value, exists (select 1 from public.bicount_sync_events e
    where e.user_uid = (select auth.uid()) and e.table_name = p_table
      and e.record_id = p_id and e.sequence > p_seen_sequence)
  into status, recorded from s;
  if coalesce((status ->> 'enabled')::boolean, false) = false
      or p_generation <> (status ->> 'generation')::bigint then
    raise exception 'Journal capture changed during conditional mutation';
  end if;
  if result ->> 'status' = 'applied' and not recorded then
    raise exception 'Conditional mutation was not recorded by the journal';
  end if;
  return result || jsonb_build_object(
    'journal_sequence', (status ->> 'latest_sequence')::bigint,
    'journal_generation', (status ->> 'generation')::bigint);
end;
$$;
revoke all on function public.bicount_conditional_journal_guard(text, uuid, text, jsonb, jsonb, bigint, bigint)
  from public, anon;
grant execute on function public.bicount_conditional_journal_guard(text, uuid, text, jsonb, jsonb, bigint, bigint)
  to authenticated;
