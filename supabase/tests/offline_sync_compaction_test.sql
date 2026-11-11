-- Local test only. The generated journal rows are rolled back.
begin;
insert into public.bicount_sync_clock
  (user_uid, latest_sequence, oldest_available_sequence)
values ('00000000-0000-4000-8000-000000000099', 4, 1);
insert into public.bicount_sync_events
  (user_uid, sequence, table_name, record_id, change_kind, created_at)
select '00000000-0000-4000-8000-000000000099'::uuid, n, 'transactions',
       '00000000-0000-4000-8000-000000000199'::uuid, 'upsert',
       case when n = 3 then now() else now() - interval '120 days' end
from generate_series(1, 4) as n;

do $$
declare removed integer;
begin
  removed := bicount_sync.compact_events(now() - interval '90 days', 10);
  if removed <> 2 then raise exception 'Unexpected compaction count'; end if;
  if (select oldest_available_sequence from public.bicount_sync_clock
      where user_uid = '00000000-0000-4000-8000-000000000099') <> 3 then
    raise exception 'Incorrect retention watermark';
  end if;
  if (select array_agg(sequence order by sequence) from public.bicount_sync_events
      where user_uid = '00000000-0000-4000-8000-000000000099') <> array[3, 4]::bigint[] then
    raise exception 'Compaction deleted a non-contiguous event';
  end if;
  begin
    perform bicount_sync.compact_events(now() - interval '1 day', 10);
    raise exception 'Retention safety check did not run';
  exception when raise_exception then
    if sqlerrm = 'Retention safety check did not run' then raise; end if;
  end;
end $$;
insert into public.bicount_sync_clock
  (user_uid, latest_sequence, oldest_available_sequence)
values ('00000000-0000-4000-8000-000000000200', 1, 1);
insert into public.bicount_sync_events
  (user_uid, sequence, table_name, record_id, change_kind, created_at)
values (
  '00000000-0000-4000-8000-000000000200', 1, 'transactions',
  '00000000-0000-4000-8000-000000000299', 'upsert', now() - interval '120 days'
);
do $$ begin
  if bicount_sync.compact_events(now() - interval '90 days', 1) <> 1 then
    raise exception 'A blocked old prefix starved another user';
  end if;
  if (select oldest_available_sequence from public.bicount_sync_clock
      where user_uid = '00000000-0000-4000-8000-000000000200') <> 2 then
    raise exception 'Second user watermark was not advanced';
  end if;
end $$;
rollback;
