-- Run only against the isolated local preproduction database.
-- All synthetic records and configuration changes are rolled back.
begin;
insert into public.transaction_type (id) values (0), (3) on conflict do nothing;
insert into public.friend_type (id) values (0) on conflict do nothing;
insert into public.recurring_transfert_frequency (id) values (1) on conflict do nothing;
insert into public.debt_state (id, name) values (0, 'test') on conflict do nothing;
insert into auth.users (id, email) values
  ('00000000-0000-4000-8000-000000000001', 'a@example.test'),
  ('00000000-0000-4000-8000-000000000002', 'b@example.test');

do $$ begin
  if exists (select 1 from public.bicount_sync_events) then
    raise exception 'Capture was active before pilot activation';
  end if;
end $$;

update bicount_sync.capture_config set pilot_user_uids = array[
  '00000000-0000-4000-8000-000000000001'::uuid,
  '00000000-0000-4000-8000-000000000002'::uuid
] where singleton;

insert into public.friends (sid, fid, uid, username) values (
  '00000000-0000-4000-8000-000000000101',
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000002', 'Test friend'
);
insert into public.transactions (tid, uid, name, type, sender_id, beneficiary_id, date, amount, currency)
values (
  '00000000-0000-4000-8000-000000000201',
  '00000000-0000-4000-8000-000000000001', 'Test transaction', 0,
  '00000000-0000-4000-8000-000000000101',
  '00000000-0000-4000-8000-000000000001', now(), 42, 'CDF'
);
insert into public.debts (debt_id, created_by, lender_id, borrower_id,
  principal_transaction_id, title, currency, principal_amount,
  expected_repayment_amount, remaining_amount, due_date)
values (
  '00000000-0000-4000-8000-000000000301',
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000101',
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000201',
  'Test debt', 'CDF', 42, 42, 42, now()
);
insert into public.recurring_transfert (recurring_transfert_id, uid,
  transaction_type, title, amount, currency, sender_id, beneficiary_id,
  frequency, start_date, next_due_date)
values (
  '00000000-0000-4000-8000-000000000401',
  '00000000-0000-4000-8000-000000000001', 3, 'Test plan', 42, 'CDF',
  '00000000-0000-4000-8000-000000000101',
  '00000000-0000-4000-8000-000000000001', 1, now(), now()
);

do $$ begin
  if not exists (select 1 from public.bicount_sync_events
    where user_uid = '00000000-0000-4000-8000-000000000002'
      and table_name = 'transactions' and change_kind = 'upsert') then
    raise exception 'Missing shared transaction event';
  end if;
  if not exists (select 1 from public.bicount_sync_events
    where user_uid = '00000000-0000-4000-8000-000000000002'
      and table_name = 'debts' and change_kind = 'upsert') then
    raise exception 'Missing shared debt event';
  end if;
end $$;

update public.friends set uid = null
where sid = '00000000-0000-4000-8000-000000000101';
delete from public.recurring_transfert
where recurring_transfert_id = '00000000-0000-4000-8000-000000000401';
delete from public.transactions
where tid = '00000000-0000-4000-8000-000000000201';

do $$ begin
  if not exists (select 1 from public.bicount_sync_events
    where user_uid = '00000000-0000-4000-8000-000000000002'
      and table_name = 'transactions' and change_kind = 'invalidate') then
    raise exception 'Missing visibility invalidation';
  end if;
  if exists (select 1 from public.bicount_sync_events
    group by user_uid having max(sequence) <> count(*)) then
    raise exception 'Sequence gap';
  end if;
end $$;

select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000001', true);
set local role authenticated;
do $$ begin
  if exists (select 1 from public.bicount_sync_events
    where user_uid = '00000000-0000-4000-8000-000000000002') then
    raise exception 'RLS exposed another user journal';
  end if;
  if not exists (select 1 from public.bicount_sync_events
    where user_uid = '00000000-0000-4000-8000-000000000001') then
    raise exception 'Owner cannot read journal';
  end if;
end $$;
reset role;
rollback;
