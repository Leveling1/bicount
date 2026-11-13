-- Run only after installing the experimental migration, in an isolated DB.
-- This file is wrapped in a rollback by the caller.
insert into auth.users (id, email) values
  ('00000000-0000-4000-8000-000000000971', 'receipt-a@example.test'),
  ('00000000-0000-4000-8000-000000000972', 'receipt-b@example.test');
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000971', true);
set local role authenticated;
do $$
declare
  payload jsonb := jsonb_build_object(
    'tid', '00000000-0000-4000-8000-000000000973',
    'uid', '00000000-0000-4000-8000-000000000971',
    'name', 'receipt test', 'type', 0,
    'sender_id', '00000000-0000-4000-8000-000000000971',
    'beneficiary_id', '00000000-0000-4000-8000-000000000971',
    'date', '2026-11-01', 'amount', 10, 'currency', 'CDF');
  result jsonb;
begin
  result := public.bicount_create_once('transactions',
    '00000000-0000-4000-8000-000000000973',
    '00000000-0000-4000-8000-000000000974', payload);
  if result ->> 'status' <> 'applied' then raise exception 'creation failed: %', result; end if;
  result := public.bicount_create_once('transactions',
    '00000000-0000-4000-8000-000000000973',
    '00000000-0000-4000-8000-000000000974', payload);
  if result ->> 'status' <> 'already_applied' then raise exception 'receipt retry failed'; end if;
  if result ? 'row' or public.bicount_creation_receipt(
      '00000000-0000-4000-8000-000000000974') ? 'inserted_row' then
    raise exception 'receipt exposed a server row outside current RLS';
  end if;
  result := public.bicount_create_once('transactions',
    '00000000-0000-4000-8000-000000000973',
    '00000000-0000-4000-8000-000000000974', payload || '{"amount":20}'::jsonb);
  if result ->> 'status' <> 'conflict' then raise exception 'changed payload accepted'; end if;
  if (select count(*) from public.transactions where tid = '00000000-0000-4000-8000-000000000973') <> 1 then
    raise exception 'duplicate creation';
  end if;
end $$;
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000972', true);
do $$
declare denied boolean := false;
begin
  if public.bicount_creation_receipt('00000000-0000-4000-8000-000000000974') is not null then
    raise exception 'receipt crossed user boundary';
  end if;
  begin
    perform public.bicount_create_once('transactions',
      '00000000-0000-4000-8000-000000000975',
      '00000000-0000-4000-8000-000000000976',
      jsonb_build_object('tid', '00000000-0000-4000-8000-000000000975',
        'uid', '00000000-0000-4000-8000-000000000971', 'name', 'forbidden',
        'type', 0, 'sender_id', '00000000-0000-4000-8000-000000000971',
        'beneficiary_id', '00000000-0000-4000-8000-000000000971',
        'date', '2026-11-01', 'amount', 10, 'currency', 'CDF'));
  exception when insufficient_privilege then denied := true;
  end;
  if not denied then raise exception 'RLS allowed another user creation'; end if;
end $$;
-- A V1-style direct insert remains valid without a creation context.
insert into public.transactions
  (tid, uid, name, type, sender_id, beneficiary_id, date, amount, currency)
values ('00000000-0000-4000-8000-000000000977',
  '00000000-0000-4000-8000-000000000972', 'old client', 0,
  '00000000-0000-4000-8000-000000000972',
  '00000000-0000-4000-8000-000000000972', now(), 10, 'CDF');
reset role;
do $$
begin
  if has_function_privilege('anon', 'public.bicount_creation_receipt(uuid)', 'EXECUTE')
      or has_function_privilege('anon', 'public.bicount_create_once(text,uuid,uuid,jsonb)', 'EXECUTE')
      or has_table_privilege('authenticated', 'bicount_sync.creation_receipts', 'SELECT') then
    raise exception 'receipt privileges are too broad';
  end if;
end $$;
alter table public.transactions disable trigger bicount_creation_receipt_transactions;
set local role authenticated;
do $$
declare rejected boolean := false;
begin
  begin
    perform public.bicount_create_once('transactions',
      '00000000-0000-4000-8000-000000000978',
      '00000000-0000-4000-8000-000000000979',
      jsonb_build_object('tid', '00000000-0000-4000-8000-000000000978',
        'uid', '00000000-0000-4000-8000-000000000972', 'name', 'missing receipt',
        'type', 0, 'sender_id', '00000000-0000-4000-8000-000000000972',
        'beneficiary_id', '00000000-0000-4000-8000-000000000972',
        'date', '2026-11-01', 'amount', 10, 'currency', 'CDF'));
  exception when raise_exception then
    if sqlerrm = 'Creation receipt was not captured' then rejected := true; else raise; end if;
  end;
  if not rejected or exists (select 1 from public.transactions
      where tid = '00000000-0000-4000-8000-000000000978') then
    raise exception 'creation survived without a receipt';
  end if;
end $$;
reset role;
