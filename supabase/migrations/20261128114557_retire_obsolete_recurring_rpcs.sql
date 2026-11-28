-- These jobs call Edge Functions that query tables removed in April 2026.
-- Keep job definitions for rollback and leave unified recurring jobs alone.
do $$
declare
  legacy_job record;
begin
  if to_regclass('public.subscriptions') is not null
      or to_regclass('public.recurring_fundings') is not null
      or to_regclass('public.account_funding') is not null then
    raise exception 'Legacy recurring tables still exist';
  end if;

  for legacy_job in
    select jobid, jobname, command
    from cron.job
    where jobname in ('process_subscriptions', 'process_recurring_fundings')
      and active
  loop
    if strpos(legacy_job.command, '/functions/v1/' || legacy_job.jobname) = 0 then
      raise exception 'Legacy job % no longer targets its historical endpoint',
        legacy_job.jobname;
    end if;
    perform cron.alter_job(legacy_job.jobid, active := false);
  end loop;
end;
$$;

-- RESTRICT prevents dropping any database object that still depends on these RPCs.
drop function if exists public.charge_subscription(uuid) restrict;
drop function if exists public.process_recurring_funding(text) restrict;
