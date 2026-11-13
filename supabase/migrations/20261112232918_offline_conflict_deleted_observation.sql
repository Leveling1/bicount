-- Local preproduction experiment. Returns no row contents and requires a
-- deletion event already visible to the authenticated user.
do $$ begin
  if current_setting('bicount.local_preprod', true) is distinct from 'allow' then
    raise exception 'Experimental migration requires an explicitly selected local preproduction';
  end if;
end $$;
create function public.bicount_observe_deleted_conflict(
  p_table text, p_id uuid, p_seen_sequence bigint, p_generation bigint
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare key_name text; status jsonb; event_row record; clock_row record; row_exists boolean;
begin
  if auth.uid() is null then raise exception 'Authentication required' using errcode = '42501'; end if;
  key_name := case p_table when 'users' then 'uid' when 'friends' then 'sid'
    when 'transactions' then 'tid' when 'debts' then 'debt_id'
    when 'recurring_transfert' then 'recurring_transfert_id' end;
  if key_name is null or p_id is null or p_seen_sequence is null or p_generation is null then
    raise exception 'Invalid deleted conflict observation';
  end if;
  status := public.bicount_sync_status();
  if not coalesce((status->>'enabled')::boolean, false)
      or p_generation <> (status->>'generation')::bigint
      or p_seen_sequence < (status->>'oldest_available_sequence')::bigint - 1
      or p_seen_sequence > (status->>'latest_sequence')::bigint then
    return jsonb_build_object('status', 'unavailable');
  end if;
  if exists (select 1 from public.bicount_sync_events e where e.user_uid = auth.uid()
      and e.table_name = p_table and e.change_kind = 'invalidate' and e.sequence > p_seen_sequence) then
    return jsonb_build_object('status', 'unavailable');
  end if;
  select e.change_kind, e.observed_at into event_row from public.bicount_sync_events e
    where e.user_uid = auth.uid() and e.table_name = p_table and e.record_id = p_id
      and e.sequence > p_seen_sequence order by e.sequence desc limit 1;
  if not found or event_row.change_kind <> 'delete' or event_row.observed_at is null then
    return jsonb_build_object('status', 'unavailable');
  end if;
  execute format('select exists (select 1 from public.%I where %I = $1)', p_table, key_name)
    into row_exists using p_id;
  if row_exists then return jsonb_build_object('status', 'unavailable'); end if;
  select c.deleted, c.observed_at into clock_row from bicount_sync.record_clock c
    where c.table_name = p_table and c.record_id = p_id;
  if not found or not clock_row.deleted or
      abs(extract(epoch from (clock_row.observed_at - event_row.observed_at))) > 2 then
    return jsonb_build_object('status', 'unavailable');
  end if;
  return jsonb_build_object('status', 'deleted', 'remote_time', event_row.observed_at,
    'server_time', clock_timestamp(), 'journal_sequence', (status->>'latest_sequence')::bigint,
    'journal_generation', (status->>'generation')::bigint);
end;
$$;
revoke all on function public.bicount_observe_deleted_conflict(text, uuid, bigint, bigint) from public, anon;
grant execute on function public.bicount_observe_deleted_conflict(text, uuid, bigint, bigint) to authenticated;
