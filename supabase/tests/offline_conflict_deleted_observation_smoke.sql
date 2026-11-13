-- Runs inside a caller-owned transaction and is rolled back.
insert into auth.users (id, email) values
  ('00000000-0000-4000-8000-000000000941', 'delete-observe-a@example.test'),
  ('00000000-0000-4000-8000-000000000942', 'delete-observe-b@example.test');
update bicount_sync.capture_config set enabled_for_all = false,
  pilot_user_uids = array['00000000-0000-4000-8000-000000000941'::uuid] where singleton;
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000941', true);
set local role authenticated;
insert into public.transactions (tid, uid, name, type, sender_id, beneficiary_id, date, amount, currency)
values ('00000000-0000-4000-8000-000000000943', '00000000-0000-4000-8000-000000000941',
  'deletion', 0, '00000000-0000-4000-8000-000000000941',
  '00000000-0000-4000-8000-000000000941', now(), 10, 'CDF');
do $$
declare marker jsonb; result jsonb; target uuid := '00000000-0000-4000-8000-000000000943';
begin
  marker := public.bicount_sync_status();
  delete from public.transactions where tid = target;
  result := public.bicount_observe_deleted_conflict('transactions', target,
    (marker->>'latest_sequence')::bigint, (marker->>'generation')::bigint);
  if result->>'status' <> 'deleted' or result->>'remote_time' is null then
    raise exception 'Genuine deletion was not observed: %', result;
  end if;
  result := public.bicount_observe_deleted_conflict('transactions', target,
    (marker->>'latest_sequence')::bigint, (marker->>'generation')::bigint + 1);
  if result->>'status' <> 'unavailable' then raise exception 'Wrong generation accepted'; end if;
end $$;
insert into public.transactions (tid, uid, name, type, sender_id, beneficiary_id, date, amount, currency)
values ('00000000-0000-4000-8000-000000000944', '00000000-0000-4000-8000-000000000941',
  'access loss', 0, '00000000-0000-4000-8000-000000000941',
  '00000000-0000-4000-8000-000000000941', now(), 10, 'CDF');
reset role;
update public.transactions set uid = '00000000-0000-4000-8000-000000000942',
  sender_id = '00000000-0000-4000-8000-000000000942',
  beneficiary_id = '00000000-0000-4000-8000-000000000942'
  where tid = '00000000-0000-4000-8000-000000000944';
set local role authenticated;
do $$
declare result jsonb; marker jsonb;
begin
  marker := public.bicount_sync_status();
  result := public.bicount_observe_deleted_conflict('transactions',
    '00000000-0000-4000-8000-000000000944', 0, (marker->>'generation')::bigint);
  if result->>'status' <> 'unavailable' then raise exception 'Access loss was mistaken for deletion'; end if;
end $$;
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000942', true);
do $$
declare result jsonb;
begin
  result := public.bicount_observe_deleted_conflict('transactions',
    '00000000-0000-4000-8000-000000000943', 0, 1);
  if result->>'status' <> 'unavailable' then raise exception 'Deletion leaked across users'; end if;
end $$;
reset role;
