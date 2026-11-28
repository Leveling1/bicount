create table public.recurring_plan_pauses (
  pause_id uuid primary key,
  recurring_transfert_id uuid not null
    references public.recurring_transfert(recurring_transfert_id) on delete cascade,
  paused_at timestamptz not null,
  paused_on date not null,
  resumed_at timestamptz,
  resumed_on date,
  next_due_date_override date,
  check ((resumed_at is null) = (resumed_on is null)),
  check (resumed_at is null or (resumed_at >= paused_at and resumed_on >= paused_on)),
  check (next_due_date_override is null or
    (resumed_on is not null and next_due_date_override >= resumed_on))
);

create index recurring_plan_pauses_plan_history
  on public.recurring_plan_pauses (recurring_transfert_id, paused_at);

create unique index recurring_plan_pauses_one_open
  on public.recurring_plan_pauses (recurring_transfert_id) where resumed_at is null;

alter table public.recurring_plan_pauses enable row level security;
revoke all on public.recurring_plan_pauses from public, anon, authenticated;
grant select, insert, update on public.recurring_plan_pauses to authenticated;

create policy recurring_plan_pauses_owner on public.recurring_plan_pauses
  for all to authenticated
  using (exists (select from public.recurring_transfert r
    where r.recurring_transfert_id = recurring_plan_pauses.recurring_transfert_id
      and r.uid = (select auth.uid())))
  with check (exists (select from public.recurring_transfert r
    where r.recurring_transfert_id = recurring_plan_pauses.recurring_transfert_id
      and r.uid = (select auth.uid())));

create schema if not exists bicount_recurring_private;
revoke all on schema bicount_recurring_private from public, anon, authenticated;

create function bicount_recurring_private.apply_pause()
returns trigger language plpgsql set search_path = '' security definer as $$
declare
  plan public.recurring_transfert%rowtype;
  next_due timestamp;
  step interval;
begin
  if tg_op = 'UPDATE' then
    if new is not distinct from old then return new; end if;
    if old.resumed_at is not null
      or new.pause_id is distinct from old.pause_id
      or new.recurring_transfert_id is distinct from old.recurring_transfert_id
      or new.paused_at is distinct from old.paused_at
      or new.paused_on is distinct from old.paused_on then
      raise exception 'Recurring pause history cannot be rewritten' using errcode = '23514';
    end if;
  end if;

  select r.* into plan from public.recurring_transfert r
    where r.recurring_transfert_id = new.recurring_transfert_id for update;
  if not found or plan.status not in (0, 3)
    or (auth.uid() is not null and plan.uid <> auth.uid()) then
    raise exception 'Recurring plan is unavailable' using errcode = '23514';
  end if;

  if exists (
    select from public.recurring_plan_pauses p
    where p.recurring_transfert_id = new.recurring_transfert_id
      and p.pause_id <> new.pause_id
      and (p.resumed_at is null or p.resumed_at > new.paused_at)
      and (new.resumed_at is null or new.resumed_at > p.paused_at)
  ) then
    raise exception 'Recurring pause overlaps another pause' using errcode = '23514';
  end if;

  if new.resumed_at is null then
    update public.recurring_transfert set status = 3
      where recurring_transfert_id = plan.recurring_transfert_id;
    return new;
  end if;
  if exists (select from public.recurring_plan_pauses p
    where p.recurring_transfert_id = new.recurring_transfert_id
      and p.paused_at >= new.resumed_at and p.pause_id <> new.pause_id) then
    return new;
  end if;
  if new.next_due_date_override is not null and plan.end_date is not null
    and new.next_due_date_override > (plan.end_date at time zone 'UTC')::date then
    raise exception 'Recurring due date is past the end of the plan' using errcode = '23514';
  end if;

  next_due := plan.next_due_date at time zone 'UTC';
  if new.next_due_date_override is not null then
    next_due := new.next_due_date_override::timestamp;
  else
    step := case plan.frequency
      when 0 then interval '1 week' when 1 then interval '1 month'
      when 2 then interval '3 months' when 3 then interval '1 year'
      when 4 then interval '3 months' when 5 then interval '1 year'
    end;
    if step is null then
      raise exception 'Unsupported recurring frequency' using errcode = '23514';
    end if;
    while next_due::date < new.resumed_on loop
      next_due := next_due + step;
    end loop;
  end if;

  update public.recurring_transfert
    set status = 0, next_due_date = next_due at time zone 'UTC'
    where recurring_transfert_id = plan.recurring_transfert_id;
  return new;
end;
$$;

revoke all on function bicount_recurring_private.apply_pause() from public, anon, authenticated;
create trigger apply_recurring_plan_pause
  after insert or update on public.recurring_plan_pauses
  for each row execute function bicount_recurring_private.apply_pause();

-- Preserve the projection when an older client sends a full plan update.
-- Status 3 is reserved for an open pause. Existing workers only read status 0.
create function bicount_recurring_private.preserve_pause_status()
returns trigger language plpgsql set search_path = '' security definer as $$
begin
  if exists (select from public.recurring_plan_pauses p
    where p.recurring_transfert_id = old.recurring_transfert_id
      and p.resumed_at is null) then
    new.status := 3;
  elsif new.status = 3 then
    new.status := 0;
  end if;
  if pg_trigger_depth() = 1 and auth.uid() is not null
    and new.start_date is not distinct from old.start_date
    and new.frequency is not distinct from old.frequency
    and exists (select from public.recurring_plan_pauses p
      where p.recurring_transfert_id = old.recurring_transfert_id) then
    new.next_due_date := old.next_due_date;
  end if;
  return new;
end;
$$;

revoke all on function bicount_recurring_private.preserve_pause_status() from public, anon, authenticated;
create trigger preserve_recurring_plan_pause_status
  before update on public.recurring_transfert
  for each row execute function bicount_recurring_private.preserve_pause_status();

create function bicount_recurring_private.prevent_paused_occurrence()
returns trigger language plpgsql set search_path = '' security definer as $$
declare
  plan_id uuid := coalesce(new.recurring_transfert_id, new.origin_id);
  occurrence_day date := coalesce(new.recurring_occurrence_date,
    (new.origin_occurrence_date at time zone 'UTC')::date);
begin
  if plan_id is null or occurrence_day is null then return new; end if;
  -- PostgREST executes the insert trigger even for existing rows on upsert.
  if exists (select from public.transactions t where t.tid = new.tid) then
    return new;
  end if;
  perform 1 from public.recurring_transfert r
    where r.recurring_transfert_id = plan_id for update;
  if exists (select from public.recurring_plan_pauses p
    where p.recurring_transfert_id = plan_id
      and (p.resumed_at is null or
        (occurrence_day >= p.paused_on
          and occurrence_day < coalesce(p.next_due_date_override, p.resumed_on)
          and not exists (select from public.recurring_plan_pauses later
            where later.recurring_transfert_id = p.recurring_transfert_id
              and later.paused_at > p.paused_at
              and later.paused_on <= occurrence_day)))) then
    raise exception 'Recurring occurrence is paused' using errcode = '23514';
  end if;
  return new;
end;
$$;

revoke all on function bicount_recurring_private.prevent_paused_occurrence() from public, anon, authenticated;
create trigger prevent_paused_recurring_occurrence
  before insert on public.transactions
  for each row execute function bicount_recurring_private.prevent_paused_occurrence();

-- A scheduled invocation can already have read a plan when the pause arrives.
create function bicount_recurring_private.prevent_stale_recurring_notification()
returns trigger language plpgsql set search_path = '' security definer as $$
declare
  plan public.recurring_transfert%rowtype;
  plan_id text := new.payload ->> 'recurring_transfert_id';
begin
  if new.category not in ('recurring_reminder', 'recurring_due') or plan_id is null
    or plan_id !~ '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$' then
    return new;
  end if;
  select r.* into plan from public.recurring_transfert r
    where r.recurring_transfert_id = plan_id::uuid and r.uid = new.user_uid for share;
  if not found or plan.status <> 0
    or (plan.next_due_date at time zone 'UTC')::date::text
      is distinct from (new.payload ->> 'expectedDate') then
    return null;
  end if;
  return new;
end;
$$;

revoke all on function bicount_recurring_private.prevent_stale_recurring_notification() from public, anon, authenticated;
create trigger prevent_stale_recurring_notification
  before insert on public.notifications
  for each row execute function bicount_recurring_private.prevent_stale_recurring_notification();
