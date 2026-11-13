begin;

create extension if not exists pg_cron;

create function bicount_wallet.generate_due_movements(p_limit integer default 100)
returns integer
language plpgsql set search_path = '' as $$
declare
  plan public.recurring_transfert%rowtype;
  quote public.exchange_rate_snapshots%rowtype;
  due_day date;
  generated integer := 0;
  inserted integer;
begin
  for plan in
    select r.* from public.recurring_transfert r
    where r.execution_mode = 1 and r.status = 0 and r.next_due_date <= now()
      and (r.end_date is null or r.next_due_date <= r.end_date)
      and r.transaction_type in (2, 3, 4, 5)
    order by r.next_due_date
    limit least(500, greatest(1, p_limit))
    for update skip locked
  loop
    due_day := (plan.next_due_date at time zone 'UTC')::date;
    select * into quote from public.exchange_rate_snapshots s
      where s.currency_code = plan.currency and s.rate_date <= due_day
      order by s.rate_date desc, s.is_official desc, s.created_at desc, s.snapshot_id
      limit 1;

    insert into public.transactions (
      uid, name, type, sender_id, beneficiary_id, date, note, amount, currency,
      frequency, reference_currency_code, converted_amount, amount_cdf,
      rate_to_cdf, fx_rate_date, fx_snapshot_id, recurring_transfert_id,
      recurring_occurrence_date, origin_id, origin_occurrence_date, generation_mode
    )
    select plan.uid, plan.title, plan.transaction_type,
      coalesce(nullif(plan.sender_id, '')::uuid, plan.uid),
      coalesce(nullif(plan.beneficiary_id, '')::uuid, plan.uid),
      plan.next_due_date, plan.note, plan.amount, plan.currency, 4, plan.currency,
      plan.amount, plan.amount * coalesce(quote.rate_to_cdf,
        case when plan.currency = 'CDF' then 1 end),
      coalesce(quote.rate_to_cdf, case when plan.currency = 'CDF' then 1 end),
      quote.rate_date, quote.snapshot_id, plan.recurring_transfert_id, due_day,
      plan.recurring_transfert_id, plan.next_due_date, 2
    where not exists (
      select from public.transactions t
      where (t.recurring_transfert_id = plan.recurring_transfert_id or
             t.origin_id = plan.recurring_transfert_id)
        and coalesce(t.recurring_occurrence_date,
            (t.origin_occurrence_date at time zone 'UTC')::date) = due_day
    );
    get diagnostics inserted = row_count;
    generated := generated + inserted;

    update public.recurring_transfert set
      last_generated_at = case when inserted > 0 then now() else last_generated_at end,
      next_due_date = (plan.next_due_date at time zone 'UTC' + case plan.frequency
        when 0 then interval '1 week'
        when 1 then interval '1 month'
        when 2 then interval '3 months'
        when 3 then interval '1 year'
      end) at time zone 'UTC'
    where recurring_transfert_id = plan.recurring_transfert_id;
  end loop;
  return generated;
end;
$$;
revoke all on function bicount_wallet.generate_due_movements(integer) from public, anon, authenticated;

-- This migration is exercised only on the isolated local preproduction stack.
select cron.schedule('bicount-wallet-recurring', '*/5 * * * *',
  'select bicount_wallet.generate_due_movements()');

commit;
