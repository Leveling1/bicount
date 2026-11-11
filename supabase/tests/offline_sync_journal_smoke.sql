-- Isolated PostgreSQL smoke test. Changes are rolled back after assertions.
begin;

insert into public.users (uid, email) values
  ('00000000-0000-4000-8000-000000000001', 'a@example.test'),
  ('00000000-0000-4000-8000-000000000002', 'b@example.test');

do $$ begin
  if (select count(*) from public.bicount_sync_events) <> 0 then
    raise exception 'Capture ran while disabled';
  end if;
end $$;

update bicount_sync.capture_config
set pilot_user_uids = array[
  '00000000-0000-4000-8000-000000000001'::uuid,
  '00000000-0000-4000-8000-000000000002'::uuid
]
where singleton;

insert into public.friends (sid, fid, uid) values (
  '00000000-0000-4000-8000-000000000101',
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000002'
);
insert into public.transactions (tid, uid, sender_id, beneficiary_id)
values (
  '00000000-0000-4000-8000-000000000201',
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000101',
  '00000000-0000-4000-8000-000000000001'
);
insert into public.debts (debt_id, created_by, lender_id, borrower_id)
values (
  '00000000-0000-4000-8000-000000000301',
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000101',
  '00000000-0000-4000-8000-000000000001'
);
insert into public.recurring_transfert (recurring_transfert_id, uid)
values (
  '00000000-0000-4000-8000-000000000401',
  '00000000-0000-4000-8000-000000000001'
);

do $$ begin
  if not exists (
    select 1 from public.bicount_sync_events
    where user_uid = '00000000-0000-4000-8000-000000000002'
      and table_name = 'transactions' and change_kind = 'upsert'
  ) then
    raise exception 'Linked transaction was not delivered to second user';
  end if;
  if not exists (
    select 1 from public.bicount_sync_events
    where user_uid = '00000000-0000-4000-8000-000000000002'
      and table_name = 'debts' and change_kind = 'upsert'
  ) then
    raise exception 'Linked debt was not delivered to second user';
  end if;
end $$;

update public.friends set uid = null
where sid = '00000000-0000-4000-8000-000000000101';
delete from public.transactions
where tid = '00000000-0000-4000-8000-000000000201';
delete from public.recurring_transfert
where recurring_transfert_id = '00000000-0000-4000-8000-000000000401';

do $$ begin
  if not exists (
    select 1 from public.bicount_sync_events
    where user_uid = '00000000-0000-4000-8000-000000000002'
      and table_name = 'friends' and change_kind = 'delete'
  ) then
    raise exception 'Former friend did not receive loss of access';
  end if;
  if not exists (
    select 1 from public.bicount_sync_events
    where user_uid = '00000000-0000-4000-8000-000000000002'
      and table_name = 'transactions' and change_kind = 'invalidate'
  ) then
    raise exception 'Former friend did not receive transaction invalidation';
  end if;
  if exists (
    select 1 from public.bicount_sync_events
    group by user_uid having max(sequence) <> count(*)
  ) then
    raise exception 'Per-user sequences have a gap';
  end if;
  if exists (
    select 1 from public.bicount_sync_clock c
    join (
      select user_uid, max(sequence) as last_sequence
      from public.bicount_sync_events group by user_uid
    ) e using (user_uid)
    where c.latest_sequence <> e.last_sequence
  ) then
    raise exception 'Clock and journal disagree';
  end if;
end $$;

select set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;
do $$ begin
  if exists (
    select 1 from public.bicount_sync_events
    where user_uid = '00000000-0000-4000-8000-000000000002'
  ) then
    raise exception 'Journal exposed another user events';
  end if;
  if not exists (
    select 1 from public.bicount_sync_events
    where user_uid = '00000000-0000-4000-8000-000000000001'
  ) then
    raise exception 'Journal owner cannot read events';
  end if;
  if has_table_privilege(
    'authenticated', 'public.bicount_sync_events', 'INSERT'
  ) then
    raise exception 'Authenticated role can write the journal';
  end if;
end $$;
reset role;

rollback;
