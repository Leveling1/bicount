-- Applied inside a caller-owned transaction, then rolled back.
insert into auth.users (id, email) values
  ('00000000-0000-4000-8000-000000000961', 'observe-a@example.test'),
  ('00000000-0000-4000-8000-000000000962', 'observe-b@example.test');
update bicount_sync.capture_config set enabled_for_all = false,
  pilot_user_uids = array['00000000-0000-4000-8000-000000000961'::uuid] where singleton;
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000961', true);
set local role authenticated;
insert into public.transactions (tid, uid, name, type, sender_id, beneficiary_id, date, amount, currency)
values ('00000000-0000-4000-8000-000000000963', '00000000-0000-4000-8000-000000000961',
  'observation', 0, '00000000-0000-4000-8000-000000000961',
  '00000000-0000-4000-8000-000000000961', now(), 10, 'CDF');
do $$
declare marker jsonb; observed jsonb; target uuid := '00000000-0000-4000-8000-000000000963';
begin
  marker := public.bicount_sync_status();
  update public.transactions set amount = 20 where tid = target;
  observed := public.bicount_observe_conflict('transactions', target,
    (marker->>'latest_sequence')::bigint, (marker->>'generation')::bigint);
  if observed->>'status' <> 'observed' or (observed->'row'->>'amount')::numeric <> 20
      or observed->>'remote_time' is null or observed->>'server_time' is null then
    raise exception 'A recorded remote edit was not observed: %', observed;
  end if;
  observed := public.bicount_observe_conflict('transactions', target,
    (marker->>'latest_sequence')::bigint, (marker->>'generation')::bigint + 1);
  if observed->>'status' <> 'unavailable' then raise exception 'wrong generation accepted'; end if;
end $$;
reset role;
alter table public.transactions disable trigger bicount_sync_capture_transactions;
set local role authenticated;
do $$
declare marker jsonb; observed jsonb; target uuid := '00000000-0000-4000-8000-000000000963';
begin
  marker := public.bicount_sync_status();
  update public.transactions set amount = 30 where tid = target;
  observed := public.bicount_observe_conflict('transactions', target, 0,
    (marker->>'generation')::bigint);
  if observed->>'status' <> 'unavailable' then
    raise exception 'Unrecorded modification passed fingerprint check';
  end if;
end $$;
reset role;
alter table public.transactions enable trigger bicount_sync_capture_transactions;
set local role authenticated;
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000962', true);
do $$
declare observed jsonb;
begin
  observed := public.bicount_observe_conflict('transactions',
    '00000000-0000-4000-8000-000000000963', 0, 1);
  if observed->>'status' <> 'unavailable' then raise exception 'RLS isolation failed'; end if;
end $$;
reset role;
