-- Additive V2 sync journal. Existing finance tables, policies and rows are not
-- changed. Journal capture stays disabled until a separate rollout decision.

create schema if not exists bicount_sync;
revoke all on schema bicount_sync from public, anon, authenticated;

create table if not exists bicount_sync.capture_config (
  singleton boolean primary key default true check (singleton),
  enabled_for_all boolean not null default false,
  pilot_user_uids uuid[] not null default '{}',
  generation bigint not null default 1 check (generation > 0)
);
insert into bicount_sync.capture_config (singleton)
values (true)
on conflict (singleton) do nothing;
revoke all on bicount_sync.capture_config from public, anon, authenticated;

create function bicount_sync.bump_generation()
returns trigger language plpgsql set search_path = '' as $$
begin
  if old.enabled_for_all is distinct from new.enabled_for_all or
     old.pilot_user_uids is distinct from new.pilot_user_uids then
    new.generation := old.generation + 1;
  end if;
  return new;
end;
$$;
create trigger bicount_sync_config_generation
  before update on bicount_sync.capture_config
  for each row execute function bicount_sync.bump_generation();

create table if not exists public.bicount_sync_clock (
  user_uid uuid primary key,
  latest_sequence bigint not null default 0 check (latest_sequence >= 0),
  oldest_available_sequence bigint not null default 1
    check (oldest_available_sequence > 0)
);

create table if not exists public.bicount_sync_events (
  user_uid uuid not null,
  sequence bigint not null check (sequence > 0),
  table_name text not null check (
    table_name in ('users', 'friends', 'transactions', 'debts',
                   'recurring_transfert')
  ),
  record_id uuid,
  change_kind text not null check (
    change_kind in ('upsert', 'delete', 'invalidate')
  ),
  created_at timestamptz not null default now(),
  primary key (user_uid, sequence),
  check (change_kind = 'invalidate' or record_id is not null)
);
create index if not exists bicount_sync_events_created_at_idx
  on public.bicount_sync_events (created_at);

alter table public.bicount_sync_clock enable row level security;
alter table public.bicount_sync_events enable row level security;
revoke all on public.bicount_sync_clock from public, anon, authenticated;
revoke all on public.bicount_sync_events from public, anon, authenticated;
grant select on public.bicount_sync_clock to authenticated;
grant select on public.bicount_sync_events to authenticated;

create policy bicount_sync_clock_read_own
  on public.bicount_sync_clock for select to authenticated
  using (user_uid = (select auth.uid()));
create policy bicount_sync_events_read_own
  on public.bicount_sync_events for select to authenticated
  using (user_uid = (select auth.uid()));

-- Clients can distinguish an inactive pilot from an empty journal without
-- obtaining access to private rollout configuration.
create function public.bicount_sync_status()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  current_uid uuid := auth.uid();
  capture_enabled boolean;
  capture_generation bigint;
  clock_row public.bicount_sync_clock%rowtype;
begin
  if current_uid is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  select enabled_for_all or current_uid = any(pilot_user_uids), generation
    into capture_enabled, capture_generation
    from bicount_sync.capture_config where singleton;
  select * into clock_row from public.bicount_sync_clock
    where user_uid = current_uid;
  return jsonb_build_object(
    'enabled', coalesce(capture_enabled, false),
    'generation', coalesce(capture_generation, 1),
    'latest_sequence', coalesce(clock_row.latest_sequence, 0),
    'oldest_available_sequence', coalesce(clock_row.oldest_available_sequence, 1)
  );
end;
$$;
revoke all on function public.bicount_sync_status() from public, anon;
grant execute on function public.bicount_sync_status() to authenticated;

-- The clock row is locked until commit. For one user this orders concurrent
-- writers by commit, so a client cursor cannot skip a late commit.
create function bicount_sync.emit(
  p_user_uid uuid,
  p_table_name text,
  p_record_id uuid,
  p_change_kind text
) returns void
language plpgsql security definer set search_path = '' as $$
declare
  next_sequence bigint;
  config bicount_sync.capture_config%rowtype;
begin
  if p_user_uid is null then return; end if;
  select * into config from bicount_sync.capture_config where singleton;
  if not found or not (
    config.enabled_for_all or p_user_uid = any(config.pilot_user_uids)
  ) then
    return;
  end if;

  insert into public.bicount_sync_clock (user_uid, latest_sequence)
  values (p_user_uid, 1)
  on conflict (user_uid) do update
    set latest_sequence = public.bicount_sync_clock.latest_sequence + 1
  returning latest_sequence into next_sequence;

  insert into public.bicount_sync_events
    (user_uid, sequence, table_name, record_id, change_kind)
  values
    (p_user_uid, next_sequence, p_table_name, p_record_id, p_change_kind);
end;
$$;

-- Recipients mirror the existing SELECT policies. Events contain identifiers
-- only; the client fetches row contents through the original table's RLS.
create function bicount_sync.recipients(p_table text, p_row jsonb)
returns table (user_uid uuid)
language plpgsql security definer set search_path = '' as $$
begin
  if p_table = 'users' then
    return query select (p_row->>'uid')::uuid;
  elsif p_table = 'recurring_transfert' then
    return query select (p_row->>'uid')::uuid;
  elsif p_table = 'friends' then
    return query
      select distinct target from (
        select (p_row->>'fid')::uuid as target
        union all select (p_row->>'uid')::uuid
      ) audience where target is not null;
  elsif p_table = 'transactions' then
    return query
      select distinct target from (
        select (p_row->>'uid')::uuid as target
        union all
        select f.uid from public.friends f
        where f.sid in (
          (p_row->>'sender_id')::uuid,
          (p_row->>'beneficiary_id')::uuid
        ) and f.uid is not null
      ) audience where target is not null;
  elsif p_table = 'debts' then
    return query
      select distinct target from (
        select (p_row->>'created_by')::uuid as target
        union all
        select u.id from auth.users u
        where u.id::text in (p_row->>'lender_id', p_row->>'borrower_id')
        union all
        select f.uid from public.friends f
        where f.sid::text in (p_row->>'lender_id', p_row->>'borrower_id')
          and f.uid is not null
      ) audience where target is not null;
  else
    raise exception 'Unsupported sync table: %', p_table;
  end if;
end;
$$;

create function bicount_sync.capture_row()
returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  old_row jsonb;
  new_row jsonb;
  row_id uuid;
  target uuid;
  source_table text := tg_table_name;
  record_key text;
begin
  -- Even after triggers are installed, this is the only path used until an
  -- explicit pilot or general activation changes capture_config.
  if not exists (
    select 1 from bicount_sync.capture_config
    where singleton and
      (enabled_for_all or cardinality(pilot_user_uids) > 0)
  ) then
    if tg_op = 'DELETE' then return old; end if;
    return new;
  end if;

  record_key := case source_table
    when 'users' then 'uid'
    when 'friends' then 'sid'
    when 'transactions' then 'tid'
    when 'debts' then 'debt_id'
    when 'recurring_transfert' then 'recurring_transfert_id'
  end;
  if record_key is null then
    if tg_op = 'DELETE' then return old; end if;
    return new;
  end if;

  if tg_op <> 'INSERT' then old_row := to_jsonb(old); end if;
  if tg_op <> 'DELETE' then new_row := to_jsonb(new); end if;
  row_id := coalesce(new_row->>record_key, old_row->>record_key)::uuid;

  -- Acquire recipient clock locks in UUID order, including on access changes.
  -- Concurrent shared writes therefore cannot lock the same pair backwards.
  for target in
    select user_uid from bicount_sync.recipients(source_table, old_row)
    union
    select user_uid from bicount_sync.recipients(source_table, new_row)
    order by user_uid
  loop
    if tg_op = 'DELETE' or not exists (
      select 1 from bicount_sync.recipients(source_table, new_row)
      where user_uid = target
    ) then
      perform bicount_sync.emit(target, source_table, row_id, 'delete');
    else
      perform bicount_sync.emit(target, source_table, row_id, 'upsert');
    end if;
  end loop;

  -- Linking or unlinking a friend changes visibility of existing money rows
  -- without changing those rows. A targeted snapshot handles that rare case.
  if source_table = 'friends' and (
    tg_op <> 'UPDATE' or
    old_row->>'uid' is distinct from new_row->>'uid' or
    old_row->>'fid' is distinct from new_row->>'fid'
  ) then
    for target in
      select user_uid from bicount_sync.recipients('friends', old_row)
      union
      select user_uid from bicount_sync.recipients('friends', new_row)
      order by user_uid
    loop
      perform bicount_sync.emit(target, 'transactions', null, 'invalidate');
      perform bicount_sync.emit(target, 'debts', null, 'invalidate');
    end loop;
  end if;

  if tg_op = 'DELETE' then return old; end if;
  return new;
exception when others then
  -- Existing production writes take precedence over sync acceleration.
  -- Clients must retain a periodic snapshot fallback for a missed event.
  raise warning 'Bicount sync journal skipped a change on %: %',
    tg_table_name, sqlerrm;
  if tg_op = 'DELETE' then return old; end if;
  return new;
end;
$$;

-- Optional administrative compaction. No job is scheduled by this migration.
-- Only a contiguous old prefix is removed while its user clock is locked.
-- Clients older than the watermark must perform a full snapshot.
create function bicount_sync.compact_events(
  p_before timestamptz,
  p_user_limit integer default 100
) returns integer
language plpgsql security definer set search_path = '' as $$
declare
  item record;
  first_recent bigint;
  boundary bigint;
  removed integer;
  total integer := 0;
begin
  if p_before is null or p_before > now() - interval '90 days' then
    raise exception 'Journal retention must be at least 90 days';
  end if;
  if p_user_limit is null or p_user_limit < 1 or p_user_limit > 1000 then
    raise exception 'Invalid journal compaction batch size';
  end if;
  for item in
    select c.user_uid, c.latest_sequence, c.oldest_available_sequence
    from public.bicount_sync_clock c
    where exists (
      select 1 from public.bicount_sync_events e
      where e.user_uid = c.user_uid
        and e.sequence = c.oldest_available_sequence
        and e.created_at < p_before
    )
    order by c.user_uid
    limit p_user_limit
    for update skip locked
  loop
    select min(e.sequence) into first_recent
    from public.bicount_sync_events e
    where e.user_uid = item.user_uid and e.created_at >= p_before;
    boundary := coalesce(first_recent - 1, item.latest_sequence);
    if boundary >= item.oldest_available_sequence then
      delete from public.bicount_sync_events
      where user_uid = item.user_uid and sequence <= boundary;
      get diagnostics removed = row_count;
      total := total + removed;
      update public.bicount_sync_clock
      set oldest_available_sequence = boundary + 1
      where user_uid = item.user_uid;
    end if;
  end loop;
  return total;
end;
$$;

revoke all on all functions in schema bicount_sync
  from public, anon, authenticated;

create trigger bicount_sync_capture_users
  after insert or update or delete on public.users
  for each row execute function bicount_sync.capture_row();
create trigger bicount_sync_capture_friends
  after insert or update or delete on public.friends
  for each row execute function bicount_sync.capture_row();
create trigger bicount_sync_capture_transactions
  after insert or update or delete on public.transactions
  for each row execute function bicount_sync.capture_row();
create trigger bicount_sync_capture_debts
  after insert or update or delete on public.debts
  for each row execute function bicount_sync.capture_row();
create trigger bicount_sync_capture_recurring_transfert
  after insert or update or delete on public.recurring_transfert
  for each row execute function bicount_sync.capture_row();
