-- Local preproduction only. Synthetic records and settings are rolled back.
begin;
insert into auth.users (id, email) values
  ('00000000-0000-4000-8000-000000000981', 'journal-guard@example.test');
update bicount_sync.capture_config set enabled_for_all = false,
  pilot_user_uids = array['00000000-0000-4000-8000-000000000981'::uuid]
  where singleton;
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000981', true);
set local role authenticated;
insert into public.transactions
  (tid, uid, name, type, sender_id, beneficiary_id, date, amount, currency)
values ('00000000-0000-4000-8000-000000000982',
  '00000000-0000-4000-8000-000000000981', 'Journal guard', 0,
  '00000000-0000-4000-8000-000000000981',
  '00000000-0000-4000-8000-000000000981', now(), 10, 'CDF');
do $$
declare baseline jsonb; status jsonb; result jsonb; seen bigint; generation bigint;
  row_id uuid := '00000000-0000-4000-8000-000000000982';
begin
  select to_jsonb(t) into strict baseline from public.transactions t where tid = row_id;
  status := public.bicount_sync_status();
  seen := (status ->> 'latest_sequence')::bigint;
  generation := (status ->> 'generation')::bigint;
  update public.transactions set amount = 20 where tid = row_id;
  update public.transactions set amount = 10 where tid = row_id;
  result := public.bicount_conditional_journal_guard('transactions', row_id,
    'update', baseline, jsonb_build_object('amount', 15), seen, generation);
  if result ->> 'status' <> 'conflict' or
      (select amount from public.transactions where tid = row_id) <> 10 then
    raise exception 'Changed-then-reverted row was not protected';
  end if;
  status := public.bicount_sync_status();
  seen := (status ->> 'latest_sequence')::bigint;
  result := public.bicount_conditional_journal_guard('transactions', row_id,
    'update', baseline, jsonb_build_object('amount', 15), seen, generation);
  if result ->> 'status' <> 'applied' or
      (select amount from public.transactions where tid = row_id) <> 15 or
      (result ->> 'journal_generation')::bigint <> generation or
      (result ->> 'journal_sequence')::bigint <= seen then
    raise exception 'Current journal baseline was not accepted';
  end if;
  result := public.bicount_conditional_journal_guard('transactions', row_id,
    'update', baseline, jsonb_build_object('amount', 15), seen, generation);
  if result ->> 'status' <> 'already_applied' then
    raise exception 'A completed update was not recognized on retry';
  end if;
  result := public.bicount_conditional_journal_guard('transactions', row_id,
    'delete', baseline, null, seen, generation - 1);
  if result ->> 'status' <> 'not_applied' then
    raise exception 'A stale capture generation was accepted';
  end if;
  result := public.bicount_conditional_journal_guard('transactions', row_id,
    'delete', baseline, null, -1, generation);
  if result ->> 'status' <> 'not_applied' then
    raise exception 'An expired journal watermark was accepted';
  end if;
end $$;
reset role;
alter table public.transactions disable trigger bicount_sync_capture_transactions;
set local role authenticated;
do $$
declare baseline jsonb; status jsonb; rejected boolean := false;
  row_id uuid := '00000000-0000-4000-8000-000000000982';
begin
  select to_jsonb(t) into strict baseline from public.transactions t where tid = row_id;
  status := public.bicount_sync_status();
  begin
    perform public.bicount_conditional_journal_guard('transactions', row_id,
      'update', baseline, jsonb_build_object('amount', 16),
      (status ->> 'latest_sequence')::bigint, (status ->> 'generation')::bigint);
  exception when raise_exception then
    if sqlerrm <> 'Conditional mutation was not recorded by the journal' then raise; end if;
    rejected := true;
  end;
  if not rejected or (select amount from public.transactions where tid = row_id) <> 15 then
    raise exception 'A mutation missing its journal event was not rolled back';
  end if;
end $$;
reset role;
alter table public.transactions enable trigger bicount_sync_capture_transactions;
update bicount_sync.capture_config set enabled_for_all = false, pilot_user_uids = '{}'
  where singleton;
set local role authenticated;
do $$
declare baseline jsonb; result jsonb;
  row_id uuid := '00000000-0000-4000-8000-000000000982';
begin
  select to_jsonb(t) into strict baseline from public.transactions t where tid = row_id;
  result := public.bicount_conditional_journal_guard('transactions', row_id,
    'update', baseline, jsonb_build_object('amount', 16), 0, 1);
  if result ->> 'status' <> 'not_applied' or
      (select amount from public.transactions where tid = row_id) <> 15 then
    raise exception 'A mutation was allowed without active capture';
  end if;
end $$;
reset role;
update bicount_sync.capture_config set pilot_user_uids = array[
  '00000000-0000-4000-8000-000000000981'::uuid
] where singleton;
set local role authenticated;
do $$
declare baseline jsonb; status jsonb; result jsonb; seen bigint; generation bigint;
  row_id uuid := '00000000-0000-4000-8000-000000000982';
begin
  select to_jsonb(t) into strict baseline from public.transactions t where tid = row_id;
  status := public.bicount_sync_status();
  seen := (status ->> 'latest_sequence')::bigint;
  generation := (status ->> 'generation')::bigint;
  result := public.bicount_conditional_journal_guard('transactions', row_id,
    'delete', baseline, null, seen, generation);
  if result ->> 'status' <> 'applied' or
      (result ->> 'journal_sequence')::bigint <= seen or
      exists (select 1 from public.transactions where tid = row_id) then
    raise exception 'A valid deletion was not journaled and applied';
  end if;
  result := public.bicount_conditional_journal_guard('transactions', row_id,
    'delete', baseline, null, seen, generation);
  if result ->> 'status' <> 'conflict' then
    raise exception 'A missing row was incorrectly confirmed on retry';
  end if;
end $$;
reset role;
rollback;
