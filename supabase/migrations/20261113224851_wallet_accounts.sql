begin;

create table public.wallets (
  wallet_id uuid primary key default gen_random_uuid(),
  owner_uid uuid not null references public.users(uid) on delete cascade,
  name text not null check (char_length(btrim(name)) between 1 and 60),
  kind smallint not null default 4 check (kind between 0 and 4),
  card_network smallint check (card_network is null or (kind = 2 and card_network between 0 and 2)),
  icon smallint not null default 0 check (icon between 0 and 4),
  color smallint not null default 0 check (color between 0 and 4),
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  archived_at timestamptz,
  check (not is_default or archived_at is null)
);
create unique index wallets_one_principal on public.wallets (owner_uid)
  where is_default;
create index wallets_owner_lookup on public.wallets (owner_uid);
alter table public.wallets enable row level security;
revoke all on public.wallets from public, anon, authenticated;
grant select, insert, update on public.wallets to authenticated;
create policy wallets_owner_read on public.wallets for select to authenticated
  using (owner_uid = (select auth.uid()));
create policy wallets_owner_insert on public.wallets for insert to authenticated
  with check (owner_uid = (select auth.uid()) and not is_default);
create policy wallets_owner_update on public.wallets for update to authenticated
  using (owner_uid = (select auth.uid()))
  with check (owner_uid = (select auth.uid()));

create schema if not exists bicount_wallet;
revoke all on schema bicount_wallet from public, anon, authenticated;

create function bicount_wallet.protect_identity() returns trigger
language plpgsql set search_path = '' as $$
begin
  if row(new.wallet_id, new.owner_uid, new.is_default, new.created_at) is distinct from
     row(old.wallet_id, old.owner_uid, old.is_default, old.created_at) then
    raise exception 'Wallet identity cannot change' using errcode = '23514';
  end if;
  return new;
end;
$$;
create trigger wallet_identity before update on public.wallets
for each row execute function bicount_wallet.protect_identity();

create function bicount_wallet.principal_id(owner_id uuid) returns uuid
language sql immutable strict set search_path = '' as $$
  select extensions.uuid_generate_v5('6ba7b811-9dad-11d1-80b4-00c04fd430c8', owner_id::text);
$$;
create function bicount_wallet.create_principal() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.wallets (wallet_id, owner_uid, name, is_default)
  values (bicount_wallet.principal_id(new.uid), new.uid, 'Principal', true)
  on conflict do nothing;
  return new;
end;
$$;
create trigger wallet_on_profile after insert on public.users
for each row execute function bicount_wallet.create_principal();
insert into public.wallets (wallet_id, owner_uid, name, is_default)
select bicount_wallet.principal_id(uid), uid, 'Principal', true from public.users;

alter table public.transactions
  add sender_wallet_id uuid references public.wallets(wallet_id) on delete set null,
  add beneficiary_wallet_id uuid references public.wallets(wallet_id) on delete set null;
alter table public.recurring_transfert
  add sender_wallet_id uuid references public.wallets(wallet_id) on delete set null,
  add beneficiary_wallet_id uuid references public.wallets(wallet_id) on delete set null;
alter table public.debts
  add lender_wallet_id uuid references public.wallets(wallet_id) on delete set null,
  add borrower_wallet_id uuid references public.wallets(wallet_id) on delete set null;

insert into public.transaction_type (id, name) values (8, 'Wallet transfer');
alter table public.transactions add constraint wallet_transfer_shape check (
  type <> 8 or (
    uid is not null and uid = sender_id and uid = beneficiary_id
    and (sender_wallet_id is null or beneficiary_wallet_id is null
      or sender_wallet_id <> beneficiary_wallet_id)
  )
);

create function bicount_wallet.owns_side(owner_id uuid, party_id text) returns boolean
language sql stable set search_path = '' as $$
  select coalesce(owner_id::text = party_id, false) or exists (
    select from public.friends f where f.sid::text = party_id and f.uid = owner_id
  );
$$;

create function bicount_wallet.check_side(
  wallet_id uuid, party text, previous_wallet uuid, previous_party text
) returns void language plpgsql set search_path = '' as $$
declare wallet_owner uuid;
begin
  if wallet_id is not distinct from previous_wallet and party is not distinct from previous_party then
    return;
  end if;
  if wallet_id is null and pg_trigger_depth() > 1 then return; end if;
  if wallet_id is not null and auth.role() = 'anon' then
    raise exception 'An authenticated participant is required' using errcode = '42501';
  end if;
  if auth.uid() is not null and not bicount_wallet.owns_side(auth.uid(), party) then
    if wallet_id is distinct from previous_wallet then
      raise exception 'Only the participant can set this wallet' using errcode = '42501';
    end if;
  end if;
  if wallet_id is null then return; end if;
  select w.owner_uid into wallet_owner from public.wallets w
    where w.wallet_id = check_side.wallet_id;
  if wallet_owner is null or not bicount_wallet.owns_side(wallet_owner, party) then
    raise exception 'Wallet does not belong to this participant' using errcode = '23514';
  end if;
end;
$$;

create function bicount_wallet.check_operation() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  current_row jsonb := to_jsonb(new);
  previous_row jsonb := case when tg_op = 'UPDATE' then to_jsonb(old) else '{}'::jsonb end;
  side text;
  wallet_column text;
  party_column text;
  current_wallet uuid;
  previous_wallet uuid;
  recurring record;
begin
  if tg_table_name = 'transactions' and tg_op = 'INSERT'
      and current_row ->> 'generation_mode' = '2'
      and current_row ->> 'recurring_transfert_id' is not null
      and auth.uid() is null then
    select r.sender_wallet_id, r.beneficiary_wallet_id into recurring
    from public.recurring_transfert r
    where r.recurring_transfert_id = (current_row ->> 'recurring_transfert_id')::uuid;
    if found then
      new.sender_wallet_id := coalesce(new.sender_wallet_id, recurring.sender_wallet_id);
      new.beneficiary_wallet_id := coalesce(new.beneficiary_wallet_id, recurring.beneficiary_wallet_id);
      current_row := to_jsonb(new);
    end if;
  end if;
  if tg_table_name = 'transactions' and current_row ->> 'type' = '8'
      and pg_trigger_depth() = 1 and (current_row ->> 'sender_wallet_id' is null
      or current_row ->> 'beneficiary_wallet_id' is null) then
    raise exception 'A transfer requires two wallets' using errcode = '23514';
  end if;
  foreach side in array case when tg_table_name = 'debts'
    then array['lender', 'borrower'] else array['sender', 'beneficiary'] end loop
    wallet_column := side || '_wallet_id';
    party_column := side || '_id';
    current_wallet := (current_row ->> wallet_column)::uuid;
    previous_wallet := (previous_row ->> wallet_column)::uuid;
    perform bicount_wallet.check_side(current_wallet, current_row ->> party_column,
       previous_wallet, previous_row ->> party_column);
  end loop;
  return new;
end;
$$;

create trigger wallet_transaction_guard before insert or update on public.transactions
for each row execute function bicount_wallet.check_operation();
create trigger wallet_recurring_guard before insert or update on public.recurring_transfert
for each row execute function bicount_wallet.check_operation();
create trigger wallet_debt_guard before insert or update on public.debts
for each row execute function bicount_wallet.check_operation();

create function public.set_transaction_wallet(p_tid uuid, p_is_sender boolean, p_wallet_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  actor uuid := auth.uid();
  operation public.transactions%rowtype;
begin
  if actor is null or p_is_sender is null then
    raise exception 'An authenticated participant is required' using errcode = '42501';
  end if;
  select * into operation from public.transactions where tid = p_tid for update;
  if not found or operation.type = 8 or not bicount_wallet.owns_side(
      actor, case when p_is_sender then operation.sender_id::text else operation.beneficiary_id::text end
  ) then
    raise exception 'Transaction side is unavailable' using errcode = '42501';
  end if;
  if p_is_sender then
    update public.transactions set sender_wallet_id = p_wallet_id where tid = p_tid;
  else
    update public.transactions set beneficiary_wallet_id = p_wallet_id where tid = p_tid;
  end if;
end;
$$;
revoke all on function public.set_transaction_wallet(uuid, boolean, uuid) from public, anon;
grant execute on function public.set_transaction_wallet(uuid, boolean, uuid) to authenticated;

alter publication supabase_realtime add table public.wallets;

commit;
