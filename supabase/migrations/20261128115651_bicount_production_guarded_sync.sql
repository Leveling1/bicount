-- Forward production migration after the compatible journal rollout.
-- Historical journal rows and business rows are not rewritten.

create table bicount_sync.record_clock (
  table_name text not null check (table_name in
    ('users', 'friends', 'transactions', 'debts', 'recurring_transfert')),
  record_id uuid not null,
  observed_at timestamptz not null,
  deleted boolean not null,
  primary key (table_name, record_id)
);
alter table bicount_sync.record_clock enable row level security;
revoke all on bicount_sync.record_clock from public, anon, authenticated;

create function bicount_sync.record_server_change()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  source_row jsonb;
  config bicount_sync.capture_config%rowtype;
  key_name text;
  row_id uuid;
begin
  select * into config from bicount_sync.capture_config where singleton;
  if not found or not (config.enabled_for_all or cardinality(config.pilot_user_uids) > 0) then
    if tg_op = 'DELETE' then return old; end if;
    return new;
  end if;
  key_name := case tg_table_name
    when 'users' then 'uid'
    when 'friends' then 'sid'
    when 'transactions' then 'tid'
    when 'debts' then 'debt_id'
    when 'recurring_transfert' then 'recurring_transfert_id'
  end;
  source_row := case when tg_op = 'DELETE' then to_jsonb(old) else to_jsonb(new) end;
  if not config.enabled_for_all and not exists (
    select 1 from bicount_sync.recipients(tg_table_name,
      case when tg_op = 'INSERT' then null else to_jsonb(old) end) r
      where r.user_uid = any(config.pilot_user_uids)
    union all
    select 1 from bicount_sync.recipients(tg_table_name,
      case when tg_op = 'DELETE' then null else to_jsonb(new) end) r
      where r.user_uid = any(config.pilot_user_uids)
  ) then
    if tg_op = 'DELETE' then return old; end if;
    return new;
  end if;
  row_id := (source_row ->> key_name)::uuid;
  insert into bicount_sync.record_clock (table_name, record_id, observed_at, deleted)
    values (tg_table_name, row_id, clock_timestamp(), tg_op = 'DELETE')
  on conflict (table_name, record_id) do update
    set observed_at = excluded.observed_at, deleted = excluded.deleted;
  if tg_op = 'DELETE' then return old; end if;
  return new;
exception when others then
  -- Compatibility with V1 takes priority; a missed record means the clock is
  -- not sufficient evidence and must not be used alone for conflict decisions.
  raise warning 'Bicount conflict clock skipped %: %', tg_table_name, sqlerrm;
  if tg_op = 'DELETE' then return old; end if;
  return new;
end;
$$;
revoke all on function bicount_sync.record_server_change() from public, anon, authenticated;

create trigger bicount_conflict_clock_users after insert or update or delete
  on public.users for each row execute function bicount_sync.record_server_change();
create trigger bicount_conflict_clock_friends after insert or update or delete
  on public.friends for each row execute function bicount_sync.record_server_change();
create trigger bicount_conflict_clock_transactions after insert or update or delete
  on public.transactions for each row execute function bicount_sync.record_server_change();
create trigger bicount_conflict_clock_debts after insert or update or delete
  on public.debts for each row execute function bicount_sync.record_server_change();
create trigger bicount_conflict_clock_recurring after insert or update or delete
  on public.recurring_transfert for each row execute function bicount_sync.record_server_change();

create function public.bicount_conditional_mutation(
  p_table text, p_id uuid, p_action text, p_expected jsonb, p_patch jsonb default null
) returns jsonb
language plpgsql security invoker set search_path = '' as $$
declare
  key_name text;
  current_row jsonb;
  changed_row jsonb;
  assignments text;
  invalid_columns integer;
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
    raise exception 'Invalid conditional mutation';
  end if;
  if p_action = 'update' and (
    jsonb_typeof(p_patch) is distinct from 'object' or
    p_patch - key_name = '{}'::jsonb or
    (p_patch ? key_name and p_patch ->> key_name is distinct from p_id::text)
  ) then
    raise exception 'Invalid conditional mutation patch';
  end if;
  execute format('select to_jsonb(t) from public.%I t where t.%I = $1 for update',
    p_table, key_name) into current_row using p_id;
  if current_row is null then
    return jsonb_build_object('status', 'conflict', 'row', current_row);
  end if;
  if current_row is distinct from p_expected then
    if p_action = 'update' and not exists (
      select 1 from jsonb_each(p_patch) e(key, value)
      where not (current_row ? e.key) or current_row -> e.key is distinct from e.value
    ) then
      return jsonb_build_object('status', 'already_applied', 'row', current_row);
    end if;
    return jsonb_build_object('status', 'conflict', 'row', current_row);
  end if;
  if p_action = 'delete' then
    execute format('delete from public.%I t where t.%I = $1 returning to_jsonb(t)',
      p_table, key_name) into changed_row using p_id;
  else
    select count(*) into invalid_columns
    from jsonb_object_keys(p_patch) k(name)
    where not exists (
      select 1 from pg_catalog.pg_attribute a
      where a.attrelid = format('public.%I', p_table)::regclass
        and a.attname = k.name and a.attnum > 0 and not a.attisdropped
        and a.attgenerated = '' and a.attidentity = ''
    );
    if invalid_columns > 0 then raise exception 'Unsupported patch column'; end if;
    select string_agg(format('%1$I = (jsonb_populate_record(t, $1)).%1$I', k.name), ', ')
      into assignments from jsonb_object_keys(p_patch) k(name) where k.name <> key_name;
    if assignments is null then raise exception 'Empty update patch'; end if;
    execute format('update public.%I t set %s where t.%I = $2 returning to_jsonb(t)',
      p_table, assignments, key_name) into changed_row using p_patch, p_id;
  end if;
  if changed_row is null then return jsonb_build_object('status', 'not_applied'); end if;
  return jsonb_build_object('status', 'applied', 'row', changed_row);
end;
$$;
revoke all on function public.bicount_conditional_mutation(text, uuid, text, jsonb, jsonb)
  from public, anon;
grant execute on function public.bicount_conditional_mutation(text, uuid, text, jsonb, jsonb)
  to authenticated;

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

create table bicount_sync.creation_receipts (
  user_uid uuid not null,
  creation_id uuid not null,
  table_name text not null,
  record_id uuid not null,
  request_payload jsonb not null,
  inserted_row jsonb not null,
  created_at timestamptz not null default clock_timestamp(),
  primary key (user_uid, creation_id)
);
alter table bicount_sync.creation_receipts enable row level security;
revoke all on bicount_sync.creation_receipts from public, anon, authenticated;

-- The only write to the private receipt table comes from an actual INSERT.
create function bicount_sync.capture_creation_receipt()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  context jsonb;
  row_data jsonb := to_jsonb(new);
begin
  if coalesce(current_setting('bicount.creation_context', true), '') = '' then
    return new;
  end if;
  context := current_setting('bicount.creation_context', true)::jsonb;
  if context ->> 'table' <> tg_table_name
     or context ->> 'record_id' <> row_data ->> (context ->> 'key')
     or context ->> 'user_uid' <> auth.uid()::text then
    return new;
  end if;
  insert into bicount_sync.creation_receipts
    (user_uid, creation_id, table_name, record_id, request_payload, inserted_row)
  values (auth.uid(), (context ->> 'creation_id')::uuid, tg_table_name,
    (context ->> 'record_id')::uuid, context -> 'payload', row_data);
  return new;
end;
$$;
revoke all on function bicount_sync.capture_creation_receipt() from public, anon, authenticated;

create trigger bicount_creation_receipt_friends after insert on public.friends
  for each row execute function bicount_sync.capture_creation_receipt();
create trigger bicount_creation_receipt_transactions after insert on public.transactions
  for each row execute function bicount_sync.capture_creation_receipt();
create trigger bicount_creation_receipt_debts after insert on public.debts
  for each row execute function bicount_sync.capture_creation_receipt();
create trigger bicount_creation_receipt_recurring after insert on public.recurring_transfert
  for each row execute function bicount_sync.capture_creation_receipt();

-- This reader can only access receipts belonging to the authenticated caller.
create function public.bicount_creation_receipt(p_creation_id uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare receipt jsonb;
begin
  if auth.uid() is null then raise exception 'Authentication required' using errcode = '42501'; end if;
  -- The original inserted row can contain server-generated values for data
  -- the caller can no longer access. Do not expose it through this definer.
  select to_jsonb(r) - 'user_uid' - 'inserted_row' into receipt from bicount_sync.creation_receipts r
    where r.user_uid = auth.uid() and r.creation_id = p_creation_id;
  return receipt;
end;
$$;
revoke all on function public.bicount_creation_receipt(uuid) from public, anon;
grant execute on function public.bicount_creation_receipt(uuid) to authenticated;

create function public.bicount_create_once(
  p_table text, p_id uuid, p_creation_id uuid, p_payload jsonb
) returns jsonb language plpgsql security invoker set search_path = '' as $$
declare
  key_name text;
  receipt jsonb;
  invalid_columns integer;
  column_list text;
  value_list text;
  inserted jsonb;
begin
  if auth.uid() is null then raise exception 'Authentication required' using errcode = '42501'; end if;
  key_name := case p_table when 'friends' then 'sid' when 'transactions' then 'tid'
    when 'debts' then 'debt_id' when 'recurring_transfert' then 'recurring_transfert_id' end;
  if key_name is null or p_id is null or p_creation_id is null
      or jsonb_typeof(p_payload) is distinct from 'object'
      or p_payload ->> key_name is distinct from p_id::text then
    raise exception 'Invalid creation request';
  end if;
  -- Serialize retries for the same account/operation before testing its receipt.
  perform pg_advisory_xact_lock(hashtextextended(auth.uid()::text || ':' || p_creation_id::text, 20261128));
  receipt := public.bicount_creation_receipt(p_creation_id);
  if receipt is not null then
    if receipt ->> 'table_name' <> p_table or receipt ->> 'record_id' <> p_id::text
        or receipt -> 'request_payload' is distinct from p_payload then
      return jsonb_build_object('status', 'conflict');
    end if;
    -- A receipt proves an insertion but must not bypass current table RLS.
    return jsonb_build_object('status', 'already_applied');
  end if;
  select count(*) into invalid_columns from jsonb_object_keys(p_payload) k(name)
  where not exists (select 1 from pg_catalog.pg_attribute a
    where a.attrelid = format('public.%I', p_table)::regclass and a.attname = k.name
      and a.attnum > 0 and not a.attisdropped and a.attgenerated = '' and a.attidentity = '');
  if invalid_columns > 0 then raise exception 'Unsupported creation column'; end if;
  select string_agg(format('%I', k.name), ', '),
         string_agg(format('(jsonb_populate_record(null::public.%I, $1)).%I', p_table, k.name), ', ')
    into column_list, value_list from jsonb_object_keys(p_payload) k(name);
  perform set_config('bicount.creation_context', jsonb_build_object(
    'table', p_table, 'key', key_name, 'record_id', p_id, 'creation_id', p_creation_id,
    'user_uid', auth.uid(), 'payload', p_payload)::text, true);
  execute format('insert into public.%I (%s) values (%s) returning to_jsonb(%I.*)',
    p_table, column_list, value_list, p_table) into inserted using p_payload;
  perform set_config('bicount.creation_context', '', true);
  receipt := public.bicount_creation_receipt(p_creation_id);
  if receipt is null or receipt ->> 'table_name' <> p_table
      or receipt ->> 'record_id' <> p_id::text
      or receipt -> 'request_payload' is distinct from p_payload then
    raise exception 'Creation receipt was not captured';
  end if;
  return jsonb_build_object('status', 'applied', 'row', inserted);
end;
$$;
revoke all on function public.bicount_create_once(text, uuid, uuid, jsonb) from public, anon;
grant execute on function public.bicount_create_once(text, uuid, uuid, jsonb) to authenticated;

alter table public.bicount_sync_events add column observed_at timestamptz;
alter table public.bicount_sync_events
  add column row_fingerprint text,
  add column edit_source text,
  add column edited_earliest timestamptz,
  add column edited_latest timestamptz;
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

  -- A legacy authenticated write has an arrival time but no known edit time.
  if auth.uid() is null and coalesce(auth.role(), '') <> 'anon' then
    new.edit_source := 'server';
  elsif nullif(current_setting('bicount.guarded_edit_earliest', true), '') is not null
      and nullif(current_setting('bicount.guarded_edit_latest', true), '') is not null then
    new.edit_source := 'guarded';
    new.edited_earliest := current_setting('bicount.guarded_edit_earliest')::timestamptz;
    new.edited_latest := current_setting('bicount.guarded_edit_latest')::timestamptz;
  end if;
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
  select e.observed_at, e.row_fingerprint, e.change_kind,
    e.edit_source, e.edited_earliest, e.edited_latest into event_row
    from public.bicount_sync_events e where e.user_uid = auth.uid()
      and e.table_name = p_table and e.record_id = p_id and e.sequence > p_seen_sequence
    order by e.sequence desc limit 1;
  if not found or event_row.change_kind <> 'upsert' or event_row.observed_at is null or event_row.edit_source is null
      or event_row.row_fingerprint is distinct from md5(current_row::text) then
    return jsonb_build_object('status', 'unavailable');
  end if;
  return jsonb_build_object('status', 'observed', 'row', current_row,
    'remote_time', case when event_row.edit_source = 'guarded'
      then event_row.edited_earliest + (event_row.edited_latest - event_row.edited_earliest) / 2
      else event_row.observed_at end,
    'remote_uncertainty_ms', case when event_row.edit_source = 'guarded'
      then ceil(extract(epoch from (event_row.edited_latest - event_row.edited_earliest)) * 500)
      else 2000 end,
    'server_time', clock_timestamp(),
    'journal_sequence', (status->>'latest_sequence')::bigint,
    'journal_generation', (status->>'generation')::bigint);
end;
$$;
revoke all on function public.bicount_observe_conflict(text, uuid, bigint, bigint) from public, anon;
grant execute on function public.bicount_observe_conflict(text, uuid, bigint, bigint) to authenticated;

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
  select e.change_kind, e.observed_at, e.edit_source, e.edited_earliest, e.edited_latest
    into event_row from public.bicount_sync_events e
    where e.user_uid = auth.uid() and e.table_name = p_table and e.record_id = p_id
      and e.sequence > p_seen_sequence order by e.sequence desc limit 1;
  if not found or event_row.change_kind <> 'delete' or event_row.observed_at is null or event_row.edit_source is null then
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
  return jsonb_build_object('status', 'deleted', 'remote_time', case when event_row.edit_source = 'guarded'
      then event_row.edited_earliest + (event_row.edited_latest - event_row.edited_earliest) / 2
      else event_row.observed_at end,
    'remote_uncertainty_ms', case when event_row.edit_source = 'guarded'
      then ceil(extract(epoch from (event_row.edited_latest - event_row.edited_earliest)) * 500)
      else 2000 end,
    'server_time', clock_timestamp(), 'journal_sequence', (status->>'latest_sequence')::bigint,
    'journal_generation', (status->>'generation')::bigint);
end;
$$;
revoke all on function public.bicount_observe_deleted_conflict(text, uuid, bigint, bigint) from public, anon;
grant execute on function public.bicount_observe_deleted_conflict(text, uuid, bigint, bigint) to authenticated;

-- Attach the client's calibrated edit window to events for guarded writes only.
-- Both overloads run as the caller and must pass the same row and journal checks.
create function public.bicount_conditional_journal_guard(
  p_table text, p_id uuid, p_action text, p_expected jsonb, p_patch jsonb,
  p_seen_sequence bigint, p_generation bigint,
  p_edited_earliest timestamptz, p_edited_latest timestamptz
) returns jsonb language plpgsql security invoker set search_path = '' as $$
declare
  result jsonb;
  server_now timestamptz := clock_timestamp();
begin
  if auth.uid() is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  if isfinite(p_edited_earliest) and isfinite(p_edited_latest)
      and p_edited_earliest <= p_edited_latest
      and p_edited_earliest >= server_now - interval '1 year'
      and p_edited_latest <= server_now + interval '10 seconds'
      and p_edited_latest - p_edited_earliest <= interval '5 minutes' then
    perform set_config('bicount.guarded_edit_earliest', p_edited_earliest::text, true);
    perform set_config('bicount.guarded_edit_latest', p_edited_latest::text, true);
  end if;
  result := public.bicount_conditional_journal_guard(
    p_table, p_id, p_action, p_expected, p_patch, p_seen_sequence, p_generation);
  perform set_config('bicount.guarded_edit_earliest', '', true);
  perform set_config('bicount.guarded_edit_latest', '', true);
  return result;
end;
$$;
revoke all on function public.bicount_conditional_journal_guard(
  text, uuid, text, jsonb, jsonb, bigint, bigint, timestamptz, timestamptz)
  from public, anon;
grant execute on function public.bicount_conditional_journal_guard(
  text, uuid, text, jsonb, jsonb, bigint, bigint, timestamptz, timestamptz)
  to authenticated;
