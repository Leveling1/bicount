-- Prepared for local preproduction only. This is NOT a conflict resolver.
-- It records the server-observed time, including V1 writes and deletions.
-- No existing row, policy, or column is changed by this migration.
create table bicount_sync.record_clock (
  table_name text not null check (table_name in
    ('users', 'friends', 'transactions', 'debts', 'recurring_transfert')),
  record_id uuid not null,
  observed_at timestamptz not null,
  deleted boolean not null,
  primary key (table_name, record_id)
);
revoke all on bicount_sync.record_clock from public, anon, authenticated;

create function bicount_sync.record_server_change()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  source_row jsonb;
  config bicount_sync.capture_config%rowtype;
  key_name text;
  row_id uuid;
begin
  select * into config from bicount_sync.capture_config where singleton;
  if not found or not (config.enabled_for_all or cardinality(config.pilot_user_uids) > 0) then
    if tg_op = 'DELETE' then return old; end if;
    return new;
  end if;
  key_name := case tg_table_name
    when 'users' then 'uid'
    when 'friends' then 'sid'
    when 'transactions' then 'tid'
    when 'debts' then 'debt_id'
    when 'recurring_transfert' then 'recurring_transfert_id'
  end;
  source_row := case when tg_op = 'DELETE' then to_jsonb(old) else to_jsonb(new) end;
  if not config.enabled_for_all and not exists (
    select 1 from bicount_sync.recipients(tg_table_name,
      case when tg_op = 'INSERT' then null else to_jsonb(old) end) r
      where r.user_uid = any(config.pilot_user_uids)
    union all
    select 1 from bicount_sync.recipients(tg_table_name,
      case when tg_op = 'DELETE' then null else to_jsonb(new) end) r
      where r.user_uid = any(config.pilot_user_uids)
  ) then
    if tg_op = 'DELETE' then return old; end if;
    return new;
  end if;
  row_id := (source_row ->> key_name)::uuid;
  insert into bicount_sync.record_clock (table_name, record_id, observed_at, deleted)
    values (tg_table_name, row_id, clock_timestamp(), tg_op = 'DELETE')
  on conflict (table_name, record_id) do update
    set observed_at = excluded.observed_at, deleted = excluded.deleted;
  if tg_op = 'DELETE' then return old; end if;
  return new;
exception when others then
  -- Compatibility with V1 takes priority; a missed record means the clock is
  -- not sufficient evidence and must not be used alone for conflict decisions.
  raise warning 'Bicount conflict clock skipped %: %', tg_table_name, sqlerrm;
  if tg_op = 'DELETE' then return old; end if;
  return new;
end;
$$;
revoke all on function bicount_sync.record_server_change() from public, anon, authenticated;

create trigger bicount_conflict_clock_users after insert or update or delete
  on public.users for each row execute function bicount_sync.record_server_change();
create trigger bicount_conflict_clock_friends after insert or update or delete
  on public.friends for each row execute function bicount_sync.record_server_change();
create trigger bicount_conflict_clock_transactions after insert or update or delete
  on public.transactions for each row execute function bicount_sync.record_server_change();
create trigger bicount_conflict_clock_debts after insert or update or delete
  on public.debts for each row execute function bicount_sync.record_server_change();
create trigger bicount_conflict_clock_recurring after insert or update or delete
  on public.recurring_transfert for each row execute function bicount_sync.record_server_change();
