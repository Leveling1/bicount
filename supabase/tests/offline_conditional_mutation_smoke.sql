-- Local preproduction only. Synthetic users and rows are rolled back.
begin;
insert into auth.users (id, email) values
  ('00000000-0000-4000-8000-000000000991', 'cas-a@example.test'),
  ('00000000-0000-4000-8000-000000000992', 'cas-b@example.test');
insert into public.transactions
  (tid, uid, name, type, sender_id, beneficiary_id, date, amount, currency)
values
  ('00000000-0000-4000-8000-000000000993', '00000000-0000-4000-8000-000000000991',
   'CAS A', 0, '00000000-0000-4000-8000-000000000991',
   '00000000-0000-4000-8000-000000000991', now(), 10, 'CDF'),
  ('00000000-0000-4000-8000-000000000994', '00000000-0000-4000-8000-000000000992',
   'CAS B', 0, '00000000-0000-4000-8000-000000000992',
   '00000000-0000-4000-8000-000000000992', now(), 50, 'CDF');
insert into public.friends (sid, fid, username) values
  ('00000000-0000-4000-8000-000000000995', '00000000-0000-4000-8000-000000000991', 'CAS friend');
insert into public.recurring_transfert (recurring_transfert_id, uid, transaction_type,
  title, amount, currency, sender_id, beneficiary_id, frequency, start_date, next_due_date)
values ('00000000-0000-4000-8000-000000000996', '00000000-0000-4000-8000-000000000991',
  3, 'CAS recurring', 10, 'CDF', '00000000-0000-4000-8000-000000000991',
  '00000000-0000-4000-8000-000000000995', 1, now(), now());
insert into public.debts (debt_id, created_by, lender_id, borrower_id,
  principal_transaction_id, title, currency, principal_amount,
  expected_repayment_amount, remaining_amount, due_date)
values ('00000000-0000-4000-8000-000000000997', '00000000-0000-4000-8000-000000000991',
  '00000000-0000-4000-8000-000000000991', '00000000-0000-4000-8000-000000000995',
  '00000000-0000-4000-8000-000000000993', 'CAS debt', 'CDF', 10, 10, 10, now());
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000991', true);
set local role authenticated;
do $$
declare baseline jsonb; current_row jsonb; result jsonb; denied boolean := false;
  own_id uuid := '00000000-0000-4000-8000-000000000993';
  other_id uuid := '00000000-0000-4000-8000-000000000994';
begin
  select to_jsonb(t) into strict current_row from public.users t
    where uid = '00000000-0000-4000-8000-000000000991';
  result := public.bicount_conditional_mutation('users',
    '00000000-0000-4000-8000-000000000991', 'update', current_row,
    jsonb_build_object('username', 'CAS user'));
  if result ->> 'status' <> 'applied' then raise exception 'User update failed'; end if;
  select to_jsonb(t) into strict current_row from public.friends t
    where sid = '00000000-0000-4000-8000-000000000995';
  result := public.bicount_conditional_mutation('friends',
    '00000000-0000-4000-8000-000000000995', 'update', current_row,
    jsonb_build_object('username', 'CAS friend updated'));
  if result ->> 'status' <> 'applied' then raise exception 'Friend update failed'; end if;
  select to_jsonb(t) into strict current_row from public.recurring_transfert t
    where recurring_transfert_id = '00000000-0000-4000-8000-000000000996';
  result := public.bicount_conditional_mutation('recurring_transfert',
    '00000000-0000-4000-8000-000000000996', 'update', current_row,
    jsonb_build_object('amount', 11, 'reminder_enabled', false));
  if result ->> 'status' <> 'applied' then raise exception 'Recurring update failed'; end if;
  select to_jsonb(t) into strict current_row from public.debts t
    where debt_id = '00000000-0000-4000-8000-000000000997';
  result := public.bicount_conditional_mutation('debts',
    '00000000-0000-4000-8000-000000000997', 'update', current_row,
    jsonb_build_object('title', 'CAS debt updated'));
  if result ->> 'status' <> 'applied' then raise exception 'Debt update failed'; end if;
  select to_jsonb(t) into strict baseline from public.transactions t where tid = own_id;
  update public.transactions set amount = 20 where tid = own_id;
  result := public.bicount_conditional_mutation('transactions', own_id, 'update',
    baseline, jsonb_build_object('tid', own_id, 'amount', 15));
  if result ->> 'status' <> 'conflict' or (result -> 'row' ->> 'amount')::numeric <> 20 or
      (select amount from public.transactions where tid = own_id) <> 20 then
    raise exception 'Stale update was not safely rejected';
  end if;
  result := public.bicount_conditional_mutation('transactions', own_id, 'delete', baseline);
  if result ->> 'status' <> 'conflict' then raise exception 'Stale delete was not rejected'; end if;
  select to_jsonb(t) into strict current_row from public.transactions t where tid = own_id;
  result := public.bicount_conditional_mutation('transactions', own_id, 'update',
    current_row, jsonb_build_object('tid', own_id, 'amount', 25));
  if result ->> 'status' <> 'applied' or
      (select amount from public.transactions where tid = own_id) <> 25 then
    raise exception 'Matching update was not applied';
  end if;
  result := public.bicount_conditional_mutation('transactions', own_id, 'update',
    current_row, jsonb_build_object('tid', own_id, 'amount', 25));
  if result ->> 'status' <> 'already_applied' then
    raise exception 'An acknowledged update was not recognized on retry';
  end if;
  select to_jsonb(t) into strict current_row from public.transactions t where tid = own_id;
  begin
    perform public.bicount_conditional_mutation('transactions', own_id, 'update',
      current_row, jsonb_build_object('uid', '00000000-0000-4000-8000-000000000992'));
  exception when insufficient_privilege then
    denied := true;
  end;
  if not denied or (select uid from public.transactions where tid = own_id) <>
      '00000000-0000-4000-8000-000000000991'::uuid then
    raise exception 'Conditional mutation weakened ownership RLS';
  end if;
  result := public.bicount_conditional_mutation('transactions', other_id, 'delete',
    jsonb_build_object('tid', other_id));
  if result ->> 'status' <> 'conflict' or result -> 'row' is distinct from 'null'::jsonb then
    raise exception 'RLS isolation failed';
  end if;
  select to_jsonb(t) into strict current_row from public.transactions t where tid = own_id;
  result := public.bicount_conditional_mutation('transactions', own_id, 'delete', current_row);
  if result ->> 'status' <> 'applied' then raise exception 'Matching delete failed'; end if;
end $$;
reset role;
rollback;
