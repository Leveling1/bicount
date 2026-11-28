-- Register only new plans. Existing plans and their historical occurrences
-- are never backfilled or selected by the automatic worker.
create table bicount_wallet.automatic_plans (
  recurring_transfert_id uuid primary key
    references public.recurring_transfert(recurring_transfert_id) on delete cascade
);
alter table bicount_wallet.automatic_plans enable row level security;
revoke all on bicount_wallet.automatic_plans from public, anon, authenticated;

create function bicount_wallet.register_automatic_plan()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into bicount_wallet.automatic_plans values (new.recurring_transfert_id);
  return new;
end;
$$;
revoke all on function bicount_wallet.register_automatic_plan()
  from public, anon, authenticated;
create trigger register_automatic_plan
  after insert on public.recurring_transfert
  for each row execute function bicount_wallet.register_automatic_plan();

create function bicount_wallet.generate_due_movements(p_limit integer default 100)
returns integer language plpgsql set search_path = '' as $$
declare
  plan public.recurring_transfert%rowtype;
  quote public.exchange_rate_snapshots%rowtype;
  due_day date;
  advance_by interval;
  rate numeric;
  generated integer := 0;
  inserted integer;
begin
  for plan in
    select r.* from public.recurring_transfert r
    join bicount_wallet.automatic_plans a using (recurring_transfert_id)
    where r.execution_mode = 1 and r.status = 0
      and isfinite(r.next_due_date) and r.next_due_date <= now()
      and (r.end_date is null or r.next_due_date <= r.end_date)
      and r.transaction_type in (2, 3, 4, 5)
      and r.frequency in (0, 1, 2, 3, 4, 5)
    order by r.last_generated_at nulls first, r.next_due_date, r.recurring_transfert_id
    limit least(500, greatest(1, p_limit))
    for update of r skip locked
  loop
    begin
      due_day := (plan.next_due_date at time zone 'UTC')::date;
      advance_by := case plan.frequency
        when 0 then interval '1 week'
        when 1 then interval '1 month'
        when 2 then interval '3 months'
        when 3 then interval '1 year'
        when 4 then interval '3 months'
        when 5 then interval '1 year'
      end;
      if exists (
        select from public.transactions t
        where (t.recurring_transfert_id = plan.recurring_transfert_id
               or t.origin_id = plan.recurring_transfert_id)
          and coalesce(t.recurring_occurrence_date,
             (t.origin_occurrence_date at time zone 'UTC')::date) = due_day
      ) then
        inserted := 0;
      else
        quote := null;
        rate := 1;
        if plan.currency <> 'CDF' then
          select * into quote from public.exchange_rate_snapshots s
            where s.currency_code = plan.currency and s.rate_date <= due_day
              and s.rate_to_cdf > 0
            order by s.rate_date desc, s.is_official desc, s.created_at desc, s.snapshot_id
            limit 1;
          if not found then continue; end if;
          rate := quote.rate_to_cdf;
        end if;
        insert into public.transactions (
          uid, name, type, sender_id, beneficiary_id, date, note, amount, currency,
          frequency, reference_currency_code, converted_amount, amount_cdf,
          rate_to_cdf, fx_rate_date, fx_snapshot_id, recurring_transfert_id,
          recurring_occurrence_date, origin_id, origin_occurrence_date, generation_mode
        ) values (
          plan.uid, plan.title, plan.transaction_type,
          coalesce(nullif(plan.sender_id, '')::uuid, plan.uid),
          coalesce(nullif(plan.beneficiary_id, '')::uuid, plan.uid),
          plan.next_due_date, plan.note, plan.amount, plan.currency,
          4, plan.currency, plan.amount, plan.amount * rate,
          rate, quote.rate_date, quote.snapshot_id, plan.recurring_transfert_id,
          due_day, plan.recurring_transfert_id, plan.next_due_date, 2
        );
        inserted := 1;
      end if;
      update public.recurring_transfert set
        last_generated_at = case when inserted > 0 then now() else last_generated_at end,
        next_due_date = (plan.next_due_date at time zone 'UTC' + advance_by)
          at time zone 'UTC'
      where recurring_transfert_id = plan.recurring_transfert_id;
      generated := generated + inserted;
    exception when data_exception or integrity_constraint_violation then
      -- An invalid plan must neither advance its date nor block other plans.
      raise warning 'Bicount automatic occurrence skipped (%).', sqlstate;
    end;
  end loop;
  return generated;
end;
$$;
revoke all on function bicount_wallet.generate_due_movements(integer)
  from public, anon, authenticated;

select cron.schedule(
  'bicount-wallet-recurring', '*/5 * * * *',
  'select bicount_wallet.generate_due_movements()'
);
