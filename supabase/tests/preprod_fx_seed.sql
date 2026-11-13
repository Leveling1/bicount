-- Synthetic rates for isolated local preproduction only. Never use in production.
-- These values support functional testing and are not real exchange rates.
insert into public.exchange_rate_snapshots
  (currency_code, rate_date, rate_to_cdf, provider, is_official)
values
  ('CDF', date '2026-01-01', 1, 'Bicount local test', false),
  ('USD', date '2026-01-01', 2800, 'Bicount local test', false),
  ('EUR', date '2026-01-01', 3000, 'Bicount local test', false),
  ('CAD', date '2026-01-01', 2000, 'Bicount local test', false)
on conflict (currency_code, rate_date, provider) do nothing;
