-- Isolated PostgreSQL fixture only. Never run against the Bicount project.
create table public.users (uid uuid primary key, email text);
create table public.friends (sid uuid primary key, fid uuid, uid uuid);
create table public.transactions (
  tid uuid primary key, uid uuid, sender_id uuid, beneficiary_id uuid
);
create table public.debts (
  debt_id uuid primary key, created_by uuid, lender_id text, borrower_id text
);
create table public.recurring_transfert (
  recurring_transfert_id uuid primary key, uid uuid
);
