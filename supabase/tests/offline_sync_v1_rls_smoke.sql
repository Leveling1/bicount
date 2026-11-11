-- Local preproduction only. Synthetic V1-style writes under authenticated RLS.
begin;
insert into auth.users (id, email) values
  ('00000000-0000-4000-8000-000000000011', 'v1@example.test');
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000011', true);
set local role authenticated;
insert into public.friends (sid, fid, username) values (
  '00000000-0000-4000-8000-000000000111',
  '00000000-0000-4000-8000-000000000011', 'V1 contact'
);
insert into public.transactions (tid, uid, name, type, sender_id, beneficiary_id, date, amount, currency)
values (
  '00000000-0000-4000-8000-000000000211',
  '00000000-0000-4000-8000-000000000011', 'V1 payment', 0,
  '00000000-0000-4000-8000-000000000011',
  '00000000-0000-4000-8000-000000000111', now(), 20, 'CDF'
);
update public.transactions set amount = 21
where tid = '00000000-0000-4000-8000-000000000211';
delete from public.transactions where tid = '00000000-0000-4000-8000-000000000211';
delete from public.friends where sid = '00000000-0000-4000-8000-000000000111';
reset role;

update bicount_sync.capture_config set pilot_user_uids = array[
  '00000000-0000-4000-8000-000000000011'::uuid
] where singleton;
set local role authenticated;
insert into public.friends (sid, fid, username) values (
  '00000000-0000-4000-8000-000000000111',
  '00000000-0000-4000-8000-000000000011', 'V1 contact'
);
insert into public.transactions (tid, uid, name, type, sender_id, beneficiary_id, date, amount, currency)
values (
  '00000000-0000-4000-8000-000000000211',
  '00000000-0000-4000-8000-000000000011', 'V1 payment', 0,
  '00000000-0000-4000-8000-000000000011',
  '00000000-0000-4000-8000-000000000111', now(), 20, 'CDF'
);
update public.transactions set amount = 21
where tid = '00000000-0000-4000-8000-000000000211';
delete from public.transactions where tid = '00000000-0000-4000-8000-000000000211';
delete from public.friends where sid = '00000000-0000-4000-8000-000000000111';
reset role;
do $$ begin
  if (select count(*) from public.bicount_sync_events
      where user_uid = '00000000-0000-4000-8000-000000000011'
        and table_name = 'transactions'
        and record_id = '00000000-0000-4000-8000-000000000211') <> 3 then
    raise exception 'Expected transaction insert, update and delete events';
  end if;
end $$;
rollback;
