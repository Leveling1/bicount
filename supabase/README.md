# Bicount backend changes

This directory contains proposed offline sync journal and experimental conflict
primitives. The production Supabase project's older migration history is not
stored in this repository. Do not run `supabase db push` against production from
this partial directory. The migration was tested on an isolated local
PostgreSQL 17 fixture. A Supabase development branch is unavailable on the
project's current plan. Review and apply through the connected migration
workflow only after a production rollout decision, then record the resulting
remote migration version here. A schema-only local preproduction instance is
documented in `docs/offline_sync_backend_rollout.md`.

The capture switch in `bicount_sync.capture_config` defaults to off. The
conditional mutation primitive is not connected to Flutter and is not a
last-write-wins resolver. None of these migrations has been deployed to
production. See `docs/offline_sync_backend_rollout.md` before any rollout.
