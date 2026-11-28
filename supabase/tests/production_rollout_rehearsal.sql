-- Use only on the disposable local copy of the production schema.
begin;
do $$
begin
  if current_database() <> 'bicount_guarded_rollout_20261128' then
    raise exception 'This test requires the isolated rollout database';
  end if;
end;
$$;

update bicount_sync.capture_config set enabled_for_all = true;
insert into auth.users values ('00000000-0000-4000-8000-000000008803','rollout@example.test');

set local role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000008803',true);
do $$
declare
  target_id uuid := '00000000-0000-4000-8000-000000008804';
  creation_id uuid := '00000000-0000-4000-8000-000000008810';
  input jsonb;
  marker jsonb;
  baseline jsonb;
  answer jsonb;
  edit_at timestamptz := clock_timestamp() - interval '1 day';
begin
  input := jsonb_build_object('tid',target_id,'uid',auth.uid(),'gtid',target_id,
    'name','Production rehearsal','type',0,'sender_id',auth.uid(),
    'beneficiary_id',auth.uid(),'date',now(),'amount',10,'currency','CDF');
  answer := public.bicount_create_once('transactions',target_id,creation_id,input);
  if answer->>'status' <> 'applied' then raise exception 'Creation failed'; end if;
  answer := public.bicount_create_once('transactions',target_id,creation_id,input);
  if answer->>'status' <> 'already_applied' then raise exception 'Retry created a duplicate'; end if;

  marker := public.bicount_sync_status();
  update public.transactions set amount = 20 where transactions.tid = target_id;
  answer := public.bicount_observe_conflict('transactions',target_id,
    (marker->>'latest_sequence')::bigint,(marker->>'generation')::bigint);
  if answer->>'status' <> 'unavailable' then
    raise exception 'A legacy upload was incorrectly assigned an edit time';
  end if;

  marker := public.bicount_sync_status();
  select to_jsonb(t) into baseline from public.transactions t where t.tid = target_id;
  answer := public.bicount_conditional_journal_guard('transactions',target_id,'update',
    baseline,'{"amount":25}',(marker->>'latest_sequence')::bigint,
    (marker->>'generation')::bigint,edit_at - interval '3 seconds',edit_at + interval '3 seconds');
  if answer->>'status' <> 'applied' then raise exception 'Guarded update failed: %',answer->>'status'; end if;
  answer := public.bicount_observe_conflict('transactions',target_id,
    (marker->>'latest_sequence')::bigint,(marker->>'generation')::bigint);
  if answer->>'status' <> 'observed'
      or (answer->>'remote_time')::timestamptz is distinct from edit_at
      or (answer->>'remote_uncertainty_ms')::numeric is distinct from 3000::numeric then
    raise exception 'Guarded update lost the original edit window';
  end if;
  answer := public.bicount_conditional_journal_guard('transactions',target_id,'update',
    baseline,'{"amount":15}',(marker->>'latest_sequence')::bigint,(marker->>'generation')::bigint);
  if answer->>'status' <> 'conflict' then raise exception 'An older baseline was allowed to overwrite'; end if;
end;
$$;
reset role;
select set_config('request.jwt.claim.sub','',true);

insert into public.recurring_transfert (
  recurring_transfert_id,uid,transaction_type,title,amount,currency,sender_id,
  beneficiary_id,frequency,start_date,next_due_date,status,execution_mode
) values
  ('00000000-0000-4000-8000-000000008805','00000000-0000-4000-8000-000000008803',
   3,'New automatic plan',10,'CDF','','',1,now() - interval '1 day',now() - interval '1 day',0,1),
  ('00000000-0000-4000-8000-000000008806','00000000-0000-4000-8000-000000008803',
   3,'New manual plan',10,'CDF','','',1,now() - interval '1 day',now() - interval '1 day',0,0);

do $$
begin
  if bicount_wallet.generate_due_movements() <> 1 then
    raise exception 'Expected exactly one new automatic occurrence';
  end if;
  if bicount_wallet.generate_due_movements() <> 0 then
    raise exception 'Repeated run produced another occurrence';
  end if;
  if (select count(*) from public.transactions
      where recurring_transfert_id = '00000000-0000-4000-8000-000000008805'
        and generation_mode = 2 and amount_cdf = 10) <> 1 then
    raise exception 'Generated occurrence has incorrect payload';
  end if;
  if exists (select from public.transactions where recurring_transfert_id in
      ('00000000-0000-4000-8000-000000008802','00000000-0000-4000-8000-000000008806'))
      or (select next_due_date from public.recurring_transfert
      where recurring_transfert_id = '00000000-0000-4000-8000-000000008802')
      is distinct from '2026-01-01 00:00:00+00'::timestamptz then
    raise exception 'Historical or manual plan was altered by the worker';
  end if;
end;
$$;
rollback;
