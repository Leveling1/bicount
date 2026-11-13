-- Experimental local preproduction only. Existing journal events remain without
-- a timestamp/fingerprint and cannot be used to pick a conflict winner.
do $$ begin
  if current_setting('bicount.local_preprod', true) is distinct from 'allow' then
    raise exception 'Experimental migration requires an explicitly selected local preproduction';
  end if;
end $$;
alter table public.bicount_sync_events add column observed_at timestamptz;
alter table public.bicount_sync_events add column row_fingerprint text;
alter table public.bicount_sync_events alter column observed_at set default clock_timestamp();

create function public.bicount_server_clock() returns timestamptz
language plpgsql security invoker set search_path = '' as $$
begin
  if auth.uid() is null then raise exception 'Authentication required' using errcode = '42501'; end if;
  return clock_timestamp();
end;
$$;
revoke all on function public.bicount_server_clock() from public, anon;
grant execute on function public.bicount_server_clock() to authenticated;

create function bicount_sync.fingerprint_event_row()
returns trigger language plpgsql security definer set search_path = '' as $$
declare key_name text; row_data jsonb;
begin
  if new.change_kind <> 'upsert' or new.record_id is null then return new; end if;
  key_name := case new.table_name when 'users' then 'uid' when 'friends' then 'sid'
    when 'transactions' then 'tid' when 'debts' then 'debt_id'
    when 'recurring_transfert' then 'recurring_transfert_id' end;
  if key_name is null then return new; end if;
  execute format('select to_jsonb(t) from public.%I t where t.%I = $1',
    new.table_name, key_name) into row_data using new.record_id;
  if row_data is not null then new.row_fingerprint := md5(row_data::text); end if;
  return new;
end;
$$;
revoke all on function bicount_sync.fingerprint_event_row() from public, anon, authenticated;
create trigger bicount_fingerprint_event before insert on public.bicount_sync_events
  for each row execute function bicount_sync.fingerprint_event_row();

-- RLS is enforced by the caller for both the business row and its journal.
create function public.bicount_observe_conflict(
  p_table text, p_id uuid, p_seen_sequence bigint, p_generation bigint
) returns jsonb language plpgsql security invoker set search_path = '' as $$
declare key_name text; current_row jsonb; status jsonb; event_row record;
begin
  if auth.uid() is null then raise exception 'Authentication required' using errcode = '42501'; end if;
  key_name := case p_table when 'users' then 'uid' when 'friends' then 'sid'
    when 'transactions' then 'tid' when 'debts' then 'debt_id'
    when 'recurring_transfert' then 'recurring_transfert_id' end;
  if key_name is null or p_id is null or p_seen_sequence is null or p_generation is null then
    raise exception 'Invalid conflict observation';
  end if;
  execute format('select to_jsonb(t) from public.%I t where t.%I = $1 for update',
    p_table, key_name) into current_row using p_id;
  if current_row is null then return jsonb_build_object('status', 'unavailable'); end if;
  status := public.bicount_sync_status();
  if coalesce((status->>'enabled')::boolean, false) = false
      or p_generation <> (status->>'generation')::bigint
      or p_seen_sequence < (status->>'oldest_available_sequence')::bigint - 1
      or p_seen_sequence > (status->>'latest_sequence')::bigint then
    return jsonb_build_object('status', 'unavailable');
  end if;
  if exists (select 1 from public.bicount_sync_events e where e.user_uid = auth.uid()
      and e.table_name = p_table and e.change_kind = 'invalidate' and e.sequence > p_seen_sequence) then
    return jsonb_build_object('status', 'unavailable');
  end if;
  select e.observed_at, e.row_fingerprint, e.change_kind into event_row
    from public.bicount_sync_events e where e.user_uid = auth.uid()
      and e.table_name = p_table and e.record_id = p_id and e.sequence > p_seen_sequence
    order by e.sequence desc limit 1;
  if not found or event_row.change_kind <> 'upsert' or event_row.observed_at is null
      or event_row.row_fingerprint is distinct from md5(current_row::text) then
    return jsonb_build_object('status', 'unavailable');
  end if;
  return jsonb_build_object('status', 'observed', 'row', current_row,
    'remote_time', event_row.observed_at, 'server_time', clock_timestamp(),
    'journal_sequence', (status->>'latest_sequence')::bigint,
    'journal_generation', (status->>'generation')::bigint);
end;
$$;
revoke all on function public.bicount_observe_conflict(text, uuid, bigint, bigint) from public, anon;
grant execute on function public.bicount_observe_conflict(text, uuid, bigint, bigint) to authenticated;
