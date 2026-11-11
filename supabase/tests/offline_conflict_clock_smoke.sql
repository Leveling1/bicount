-- Execute only in the local preproduction container. Everything is rolled back.
begin;
do $$
declare
  test_user uuid := gen_random_uuid();
  test_id uuid := gen_random_uuid();
  first_time timestamptz;
  second_time timestamptz;
begin
  insert into auth.users (id, email)
    values (test_user, test_user::text || '@example.test');
  update bicount_sync.capture_config set enabled_for_all = true where singleton;
  insert into public.transactions
    (tid, uid, name, type, sender_id, beneficiary_id, date, amount, currency)
  values (test_id, test_user, 'Local clock test', 0, test_user, test_user,
    now(), 10, 'CDF');
  select observed_at into strict first_time from bicount_sync.record_clock
    where table_name = 'transactions' and record_id = test_id and not deleted;
  update public.transactions set amount = 20 where tid = test_id;
  select observed_at into strict second_time from bicount_sync.record_clock
    where table_name = 'transactions' and record_id = test_id and not deleted;
  if second_time < first_time then raise exception 'Clock moved backward'; end if;
  delete from public.transactions where tid = test_id;
  if not exists (select 1 from bicount_sync.record_clock
      where table_name = 'transactions' and record_id = test_id and deleted) then
    raise exception 'Missing deletion marker';
  end if;
end;
$$;
insert into auth.users (id, email) values
  ('00000000-0000-4000-8000-000000000987', 'clock-v1@example.test');
update bicount_sync.capture_config set enabled_for_all = false, pilot_user_uids = array[
  '00000000-0000-4000-8000-000000000987'::uuid
] where singleton;
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000987', true);
set local role authenticated;
insert into public.transactions
  (tid, uid, name, type, sender_id, beneficiary_id, date, amount, currency)
values ('00000000-0000-4000-8000-000000000988',
  '00000000-0000-4000-8000-000000000987', 'V1 clock test', 0,
  '00000000-0000-4000-8000-000000000987',
  '00000000-0000-4000-8000-000000000987', now(), 10, 'CDF');
update public.transactions set amount = 20
  where tid = '00000000-0000-4000-8000-000000000988';
delete from public.transactions
  where tid = '00000000-0000-4000-8000-000000000988';
reset role;
do $$ begin
  if not exists (select 1 from bicount_sync.record_clock where
    table_name = 'transactions' and
    record_id = '00000000-0000-4000-8000-000000000988' and deleted) then
    raise exception 'V1 deletion was not recorded';
  end if;
  if has_table_privilege('authenticated', 'bicount_sync.record_clock', 'select') then
    raise exception 'Private clock is accessible to authenticated users';
  end if;
end $$;
rollback;
