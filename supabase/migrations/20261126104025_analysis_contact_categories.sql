create table public.analysis_contact_categories (
  category_id uuid primary key,
  owner_uid uuid not null references auth.users(id) on delete cascade,
  friend_sid uuid not null references public.friends(sid) on delete cascade,
  chart text not null check (chart in ('income', 'expense')),
  unique (owner_uid, friend_sid, chart)
);

create index analysis_contact_categories_friend_sid_idx
  on public.analysis_contact_categories (friend_sid);

alter table public.analysis_contact_categories enable row level security;
revoke all on public.analysis_contact_categories from anon;
grant select, insert, update, delete on public.analysis_contact_categories
  to authenticated;

create policy "Manage own analysis contact categories"
  on public.analysis_contact_categories for all to authenticated
  using (owner_uid = (select auth.uid()))
  with check (
    owner_uid = (select auth.uid())
    and exists (
      select 1 from public.friends as friend
      where friend.sid = analysis_contact_categories.friend_sid
        and friend.fid = analysis_contact_categories.owner_uid
        and friend.uid is distinct from analysis_contact_categories.owner_uid
        and friend.relation_type = 0
    )
  );
