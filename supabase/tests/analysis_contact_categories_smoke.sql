-- Isolated local preproduction only. Synthetic fixtures are rolled back.
begin;

insert into auth.users (id, email) values
  ('00000000-0000-4000-8000-000000006601', 'analysis-owner@example.test'),
  ('00000000-0000-4000-8000-000000006602', 'analysis-friend@example.test');

insert into public.friend_type (id) values (0) on conflict do nothing;
insert into public.friends (sid, fid, uid, username, relation_type) values (
  '00000000-0000-4000-8000-000000006611',
  '00000000-0000-4000-8000-000000006601',
  '00000000-0000-4000-8000-000000006602',
  'Analysis contact',
  0
);

set local role authenticated;
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000006601', true);

insert into public.analysis_contact_categories values
  ('00000000-0000-4000-8000-000000006621', '00000000-0000-4000-8000-000000006601',
   '00000000-0000-4000-8000-000000006611', 'income'),
  ('00000000-0000-4000-8000-000000006622', '00000000-0000-4000-8000-000000006601',
   '00000000-0000-4000-8000-000000006611', 'expense')
on conflict (category_id) do update set chart = excluded.chart;

do $$ begin
  if (select count(*) from public.analysis_contact_categories) <> 2 then
    raise exception 'Owner must see both chart preferences';
  end if;
end $$;

select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000006602', true);

do $$ begin
  if exists (select 1 from public.analysis_contact_categories) then
    raise exception 'A linked contact can see another account''s preferences';
  end if;
  delete from public.analysis_contact_categories
    where category_id = '00000000-0000-4000-8000-000000006621';
  if found then
    raise exception 'Another account can delete an owner preference';
  end if;
  begin
    insert into public.analysis_contact_categories values (
      '00000000-0000-4000-8000-000000006623',
      '00000000-0000-4000-8000-000000006602',
      '00000000-0000-4000-8000-000000006611', 'expense'
    );
    raise exception 'A linked contact can reuse somebody else''s friend row';
  exception when insufficient_privilege then
    null;
  end;
end $$;

reset role;
delete from public.friends where sid = '00000000-0000-4000-8000-000000006611';

do $$ begin
  if exists (
    select 1 from public.analysis_contact_categories
    where friend_sid = '00000000-0000-4000-8000-000000006611'
  ) then
    raise exception 'Contact deletion left an orphaned preference';
  end if;
end $$;

rollback;
