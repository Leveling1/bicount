# Currency And FX Backend Actions

This document describes the backend work needed for Bicount's robust multi-currency flow.

Current mobile expectation:

- reference currency default is `CDF`
- the user's chosen reference currency is also stored on `users.reference_currency_code`
- the allowed currencies come from the backend, not from hardcoded app logic
- forms default to the current reference currency
- transactions, subscriptions, and add-fund entries keep their original amount and original currency
- global totals in `Home` and `Graph` are displayed in the user's current reference currency
- the FX rate used for a record is the rate available at save time
- the app stores enough FX metadata locally to keep historical totals stable

## Official Source

Primary official source for daily rates:

- BCC main site: [https://www.bcc.cd/](https://www.bcc.cd/)
- BCC exchange-rate pages are published under the `cours-de-change` section, for example:
  - [https://www.bcc.cd/operations-et-marches/domaine-operationnel/operations-de-change/cours-de-change/16122025](https://www.bcc.cd/operations-et-marches/domaine-operationnel/operations-de-change/cours-de-change/16122025)

Expected product scope for now:

- `CDF`
- `USD`
- `EUR`

Important:

- mobile should consume backend-managed rates only
- scraping must happen in the backend, not in the Flutter app
- if BCC is unavailable for a day, keep the last successful snapshot and mark the new ingestion as stale/incomplete

## Table: `currencies`

Purpose:

- list the currencies allowed in the app
- drive the settings reference-currency selector
- drive the form dropdowns dynamically

Recommended columns:

- `code text primary key`
- `name text not null`
- `symbol text not null`
- `decimals integer not null default 2`
- `display_order integer not null default 0`
- `is_active boolean not null default true`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Seed now:

- `CDF`, `Congolese franc`, `Fc`
- `USD`, `US dollar`, `$`
- `EUR`, `Euro`, `€`

Rules:

- end users can read this table
- end users must not insert/update/delete this table
- admins/backend jobs manage it

Realtime:

- enable realtime for `currencies`
- the mobile app listens to this table so new active currencies can appear without a release

## Table: `exchange_rate_snapshots`

Purpose:

- keep historical official FX rates
- let the app reconvert old records when the reference currency changes later

Recommended columns:

- `snapshot_id uuid primary key default gen_random_uuid()`
- `currency_code text not null references public.currencies(code)`
- `rate_date date not null`
- `rate_to_cdf numeric(18,6) not null`
- `provider text not null default 'BCC'`
- `source_url text`
- `is_official boolean not null default true`
- `raw_payload jsonb`
- `created_at timestamptz not null default now()`

Recommended constraints:

- unique index on `(currency_code, rate_date, provider)`
- check `rate_to_cdf > 0`

Important normalization rule:

- `rate_to_cdf` means `1 unit of currency_code = X CDF`

Examples:

- `USD`, `2026-03-01`, `2500.000000`
- `USD`, `2026-03-29`, `2320.000000`
- `EUR`, `2026-03-29`, `2612.016000`
- `CDF`, `2026-03-29`, `1.000000`

Recommended indexes:

- `(currency_code, rate_date desc)`
- `(rate_date desc)`

## Financial Tables To Extend

Add the same FX fields to:

- `public.transactions`
- `public.subscriptions`
- `public.account_funding`

Also extend:

- `public.users`

Required new user column:

- `reference_currency_code text references public.currencies(code)`

Meaning:

- this is the persisted user preference used to restore the same reference currency on a new device
- mobile still keeps a local cache for bootstrap and offline fallback, but the user profile is now the cross-device source of truth

Required new columns:

- `reference_currency_code text references public.currencies(code)`
- `converted_amount numeric(18,6)`
- `amount_cdf numeric(18,6)`
- `rate_to_cdf numeric(18,6)`
- `fx_rate_date date`
- `fx_snapshot_id uuid references public.exchange_rate_snapshots(snapshot_id)`

Meaning:

- `amount`: original amount entered by the user
- `currency`: original currency selected by the user
- `reference_currency_code`: the reference currency active in the app when the record was saved
- `converted_amount`: original amount converted into `reference_currency_code` at save time
- `amount_cdf`: robust pivot amount used for future reconversions
- `rate_to_cdf`: the source rate used for the original currency at save time
- `fx_rate_date`: rate date used when the record was saved
- `fx_snapshot_id`: source snapshot used for the original currency

## Save-Time FX Contract

When the app saves a new financial record:

1. user enters `amount` and `currency`
2. app reads the current `reference_currency_code`
3. backend rates provide the latest official snapshot available at save time
4. app persists:
   - original amount
   - original currency
   - `amount_cdf`
   - `converted_amount`
   - `rate_to_cdf`
   - `fx_rate_date`
   - `fx_snapshot_id`
   - `reference_currency_code`

Recommended formula:

- `amount_cdf = amount * rate_to_cdf`
- if `reference_currency_code = 'CDF'`
  - `converted_amount = amount_cdf`
- else
  - `converted_amount = amount_cdf / reference_rate_to_cdf_on_fx_rate_date`

Note:

- the app already stores `amount_cdf` and `rate_to_cdf`
- changing the reference currency later should never overwrite historical source data

## Scraping Job From BCC

Recommended implementation:

- one scheduled backend job per business day
- fetch the BCC exchange-rate page
- parse the published table
- normalize the supported rows into `exchange_rate_snapshots`

Minimum ingestion flow:

1. resolve the current BCC exchange-rate page
2. extract rows like `USD -> 2 271,6801 CDF`
3. normalize decimal separators and spaces
4. upsert snapshots for each supported active currency
5. always insert a synthetic `CDF -> 1`
6. store `source_url`
7. store `raw_payload` for debugging/audit

Parsing rules:

- remove thousands spaces
- convert comma decimals to dot decimals
- ignore inactive or unsupported currencies unless product explicitly enables them in `currencies`

## Suggested Backend Components

Recommended:

- scheduled job or cron-triggered edge function: `sync-bcc-exchange-rates`
- optional helper SQL view or RPC for latest rates by currency

Optional helper view:

- `public.latest_exchange_rate_snapshots`

Possible shape:

- one latest row per `currency_code`

This is optional because the mobile app can also query `exchange_rate_snapshots` ordered by `rate_date desc`, but a dedicated view is cleaner.

## RLS Guidance

`currencies`

- `select`: authenticated users allowed
- writes: denied to end users

`exchange_rate_snapshots`

- `select`: authenticated users allowed
- writes: denied to end users

`transactions`, `subscriptions`, `account_funding`

- keep existing ownership rules
- allow the new FX columns in inserts/updates

## Realtime

Enable realtime for:

- `currencies`

Do not enable realtime for `exchange_rate_snapshots` unless product really needs live intraday rate pushes.
Daily snapshot fetch plus cache is enough for the current mobile architecture.

## Existing Data Backfill

Existing records saved before the FX rollout will miss the new columns.

Recommended backfill:

1. for each old financial row, read:
   - `amount`
   - `currency`
   - `created_at`
2. resolve the nearest snapshot on or before `created_at::date`
3. fill:
   - `rate_to_cdf`
   - `amount_cdf`
   - `fx_rate_date`
   - `fx_snapshot_id`
   - `reference_currency_code`
   - `converted_amount`

Recommended backfill default:

- `reference_currency_code = 'CDF'`

## Mobile Assumptions

The Flutter app now assumes:

- no user write access to `currencies`
- `currencies.code` is stable and unique
- `currencies.symbol` is the display symbol the app should use directly
- `exchange_rate_snapshots` contains one historical row per currency/date
- `CDF` behaves like a normal currency in the catalog, but its rate is always `1`

## SQL Sketch

```sql
create table if not exists public.currencies (
  code text primary key,
  name text not null,
  symbol text not null,
  decimals integer not null default 2,
  display_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.exchange_rate_snapshots (
  snapshot_id uuid primary key default gen_random_uuid(),
  currency_code text not null references public.currencies(code),
  rate_date date not null,
  rate_to_cdf numeric(18,6) not null check (rate_to_cdf > 0),
  provider text not null default 'BCC',
  source_url text,
  is_official boolean not null default true,
  raw_payload jsonb,
  created_at timestamptz not null default now()
);

create unique index if not exists exchange_rate_snapshots_currency_date_provider_uniq
on public.exchange_rate_snapshots(currency_code, rate_date, provider);
```

## Final Note

The mobile app keeps the original currency for line-item display, but totals now depend on robust FX data.
If the backend does not provide the catalog and the historical snapshots above, totals will not stay trustworthy when the user changes the reference currency later.
