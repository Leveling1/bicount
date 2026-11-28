-- Isolated local preproduction. All fixtures and generated records roll back.
begin;

insert into auth.users (id, email) values
  ('00000000-0000-4000-8000-000000006701', 'pause-owner@example.test'),
  ('00000000-0000-4000-8000-000000006702', 'pause-other@example.test');

insert into public.recurring_transfert (
  recurring_transfert_id, uid, transaction_type, title, amount, currency,
  sender_id, beneficiary_id, frequency, start_date, next_due_date, status,
  execution_mode, reminder_enabled
) values (
  '00000000-0000-4000-8000-000000006710', '00000000-0000-4000-8000-000000006701',
  3, 'Recurring charge', 10, 'CDF', '', '', 0, '2026-01-01', '2026-01-08', 0, 1, true
), (
  '00000000-0000-4000-8000-000000006711', '00000000-0000-4000-8000-000000006701',
  2, 'Recurring income', 10, 'CDF', '', '', 0, '2026-01-01', '2026-01-08', 0, 1, true
);

insert into public.transactions (
  tid, uid, name, type, sender_id, beneficiary_id, date, amount, currency,
  recurring_transfert_id, recurring_occurrence_date
) values (
  '00000000-0000-4000-8000-000000006730', '00000000-0000-4000-8000-000000006701',
  'Existing charge', 3, '00000000-0000-4000-8000-000000006701',
  '00000000-0000-4000-8000-000000006701', '2026-01-08', 10, 'CDF',
  '00000000-0000-4000-8000-000000006710', '2026-01-08'
);

set local role authenticated;
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000006701', true);

insert into public.recurring_plan_pauses (pause_id, recurring_transfert_id, paused_at, paused_on)
values ('00000000-0000-4000-8000-000000006720', '00000000-0000-4000-8000-000000006710',
  '2026-01-08 15:00+00', '2026-01-08'),
 ('00000000-0000-4000-8000-000000006721', '00000000-0000-4000-8000-000000006711',
  '2026-01-08 15:00+00', '2026-01-08');

do $$ begin
  if (select count(*) from public.recurring_transfert where status = 3) <> 2 then
    raise exception 'Both plans must be suspended';
  end if;
  update public.recurring_transfert set status = 0
    where recurring_transfert_id = '00000000-0000-4000-8000-000000006710';
  if (select count(*) from public.recurring_transfert where status = 3) <> 2 then
    raise exception 'A stale full-plan write reopened a pause';
  end if;
  begin
    insert into public.recurring_plan_pauses (pause_id, recurring_transfert_id, paused_at, paused_on)
      values ('00000000-0000-4000-8000-000000006729', '00000000-0000-4000-8000-000000006710',
        '2026-01-09 15:00+00', '2026-01-09');
    raise exception 'A plan accepted two open pauses';
  exception when unique_violation then
    null;
  end;
end $$;

reset role;
select set_config('request.jwt.claim.sub', '', true);
select bicount_wallet.generate_due_movements();

do $$ begin
  if (select count(*) from public.transactions where recurring_transfert_id in
    ('00000000-0000-4000-8000-000000006710', '00000000-0000-4000-8000-000000006711')) <> 1 then
    raise exception 'The worker generated a suspended occurrence';
  end if;
  insert into public.notifications (title, type_id, user_uid, category, payload)
    values ('Pause test', 1, '00000000-0000-4000-8000-000000006701', 'recurring_due',
      '{"recurring_transfert_id":"00000000-0000-4000-8000-000000006710","expectedDate":"2026-01-08"}');
  if found then raise exception 'A stale reminder was inserted'; end if;
end $$;

set local role authenticated;
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000006702', true);
do $$ begin
  if exists (select from public.recurring_plan_pauses) then
    raise exception 'Another account can see the pause history';
  end if;
  update public.recurring_plan_pauses set resumed_at = now(), resumed_on = current_date;
  if found then raise exception 'Another account can resume a plan'; end if;
end $$;
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000006701', true);

-- Resume both plans with independent schedule choices.
insert into public.recurring_plan_pauses values
  ('00000000-0000-4000-8000-000000006720', '00000000-0000-4000-8000-000000006710',
   '2026-01-08 15:00+00', '2026-01-08', '2026-01-20 15:00+00', '2026-01-20', null),
  ('00000000-0000-4000-8000-000000006721', '00000000-0000-4000-8000-000000006711',
   '2026-01-08 15:00+00', '2026-01-08', '2026-01-20 15:00+00', '2026-01-20', '2026-01-25')
on conflict (pause_id) do update set
  resumed_at = excluded.resumed_at, resumed_on = excluded.resumed_on,
  next_due_date_override = excluded.next_due_date_override;

do $$ begin
  if (select count(*) from public.recurring_transfert
    where status = 0 and reminder_enabled and end_date is null
      and (recurring_transfert_id, next_due_date::date) in (
        ('00000000-0000-4000-8000-000000006710'::uuid, '2026-01-22'::date),
        ('00000000-0000-4000-8000-000000006711'::uuid, '2026-01-25'::date)
      )) <> 2 then
    raise exception 'Resumption did not keep or reanchor the expected cadence';
  end if;
  if (select amount from public.transactions where tid = '00000000-0000-4000-8000-000000006730')
    is distinct from 10 then
    raise exception 'A booked transaction changed';
  end if;
  begin
    insert into public.transactions (
      tid, uid, name, type, sender_id, beneficiary_id, date, amount, currency,
      recurring_transfert_id, recurring_occurrence_date
    ) values (
      '00000000-0000-4000-8000-000000006731', '00000000-0000-4000-8000-000000006701',
      'Skipped charge', 3, '00000000-0000-4000-8000-000000006701',
      '00000000-0000-4000-8000-000000006701', '2026-01-15', 10, 'CDF',
      '00000000-0000-4000-8000-000000006710', '2026-01-15'
    );
    raise exception 'A skipped occurrence was booked';
  exception when check_violation then
    null;
  end;
end $$;

reset role;
select set_config('request.jwt.claim.sub', '', true);
select bicount_wallet.generate_due_movements();
do $$ begin
  if (select count(*) from public.transactions
    where (recurring_transfert_id, recurring_occurrence_date) in (
      ('00000000-0000-4000-8000-000000006710'::uuid, '2026-01-22'::date),
      ('00000000-0000-4000-8000-000000006711'::uuid, '2026-01-25'::date)
    )) <> 2 then
    raise exception 'The worker did not start again on the resumed schedule';
  end if;
end $$;

set local role authenticated;
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000006701', true);
insert into public.recurring_plan_pauses values
  ('00000000-0000-4000-8000-000000006721', '00000000-0000-4000-8000-000000006711',
   '2026-01-08 15:00+00', '2026-01-08', '2026-01-20 15:00+00', '2026-01-20', '2026-01-25')
on conflict (pause_id) do update set
  resumed_at = excluded.resumed_at, resumed_on = excluded.resumed_on,
  next_due_date_override = excluded.next_due_date_override;
do $$ begin
  if (select next_due_date::date from public.recurring_transfert
    where recurring_transfert_id = '00000000-0000-4000-8000-000000006711')
    is distinct from '2026-02-01'::date then
    raise exception 'Replaying a resume rewound the worker';
  end if;
end $$;

-- A pause entirely offline can first arrive as a closed interval.
insert into public.recurring_plan_pauses values (
  '00000000-0000-4000-8000-000000006722', '00000000-0000-4000-8000-000000006710',
  '2026-01-24 15:00+00', '2026-01-24', '2026-02-02 15:00+00', '2026-02-02', null
);
do $$ begin
  if (select count(*) from public.recurring_plan_pauses
    where recurring_transfert_id = '00000000-0000-4000-8000-000000006710') <> 2 then
    raise exception 'A second cycle overwrote the first';
  end if;
end $$;

-- A new pause can replace the first due date of an earlier resumption.
insert into public.recurring_plan_pauses values (
  '00000000-0000-4000-8000-000000006723', '00000000-0000-4000-8000-000000006711',
  '2026-01-21 15:00+00', '2026-01-21', '2026-01-22 15:00+00', '2026-01-22', '2026-01-23'
);
insert into public.transactions (
  tid, uid, name, type, sender_id, beneficiary_id, date, amount, currency,
  recurring_transfert_id, recurring_occurrence_date
) values (
  '00000000-0000-4000-8000-000000006732', '00000000-0000-4000-8000-000000006701',
  'Earlier resumed income', 2, '00000000-0000-4000-8000-000000006701',
  '00000000-0000-4000-8000-000000006701', '2026-01-23', 10, 'CDF',
  '00000000-0000-4000-8000-000000006711', '2026-01-23'
);

rollback;
