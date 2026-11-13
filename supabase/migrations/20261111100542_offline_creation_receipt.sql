-- Experimental, local preproduction only. Does not update existing rows.
-- Business inserts always execute with the caller's ordinary RLS privileges.
do $$ begin
  if current_setting('bicount.local_preprod', true) is distinct from 'allow' then
    raise exception 'Experimental migration requires an explicitly selected local preproduction';
  end if;
end $$;
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
