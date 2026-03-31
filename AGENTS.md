# AGENTS.md

## Purpose

This file gives any AI agent or developer a practical map of the Bicount project.
It explains the product, the current V1 release scope, the architecture, the data flow, the backend expectations, and the areas that should be handled carefully.

Read this file before modifying the app.

## Product Summary

Bicount is a Flutter mobile application focused on personal finance and shared money flows.

Current visible V1 scope:

- Home
- Graphs
- Transaction
- Profile

Core user value:

- track money in and out
- manage shared transactions between the current user and friends
- follow subscriptions and account funding
- track salary due dates, confirmations, and arrears
- view useful analytics
- share a profile through QR code or invite link
- receive push notifications and local reminders

Important product decision:

- the company domain still exists in source code
- it is intentionally hidden from the visible V1 release flow
- do not delete company, group, or project source files unless explicitly requested

## Current V1 Scope

Release target:

- Android
- iOS

Visible navigation:

- Home
- Graphs
- Transaction
- Profile

Hidden but preserved domains:

- company
- group
- project

This behavior is controlled in lib/core/constants/app_config.dart.

Main feature flag:

- BICOUNT_ENABLE_COMPANY_SURFACE is false by default

When the flag is disabled:

- company repositories and blocs are not wired in main.dart
- company routes are not exposed in app_router.dart
- hidden company URLs redirect to /graphs

## Architecture Overview

The project uses a feature-driven structure with BLoC state management and a mostly clean split between data, domain, and presentation.

Main layout:

- lib/core
- lib/brick
- lib/features/add_fund
- lib/features/authentification
- lib/features/company
- lib/features/friend
- lib/features/graph
- lib/features/group
- lib/features/home
- lib/features/main
- lib/features/notification
- lib/features/profile
- lib/features/project
- lib/features/salary
- lib/features/subscription
- lib/features/transaction

Layer intent:

- data: models, local and remote data sources, repository implementations
- domain: entities, repository contracts, services
- presentation: screens, widgets, blocs, events, states

Important note:

- some older parts of the codebase are still more coupled than ideal
- the visible V1 flows were progressively cleaned up to keep business logic out of widgets where practical

## App Bootstrap

Entry point:

- lib/main.dart

Bootstrap sequence:

1. WidgetsFlutterBinding.ensureInitialized()
2. Firebase.initializeApp(...)
3. Repository.configure(databaseFactory)
4. Repository().initialize()
5. runApp(MyApp())

Dependency wiring:

- repositories are registered with MultiRepositoryProvider
- blocs are registered with MultiBlocProvider
- active visible V1 blocs include AuthentificationBloc, MainBloc, HomeBloc, TransactionBloc, SubscriptionBloc, AddFundBloc, SalaryBloc, GraphBloc, FriendBloc, and NotificationBloc

The router lives in lib/core/routes/app_router.dart.
The app theme lives in lib/core/themes/app_theme.dart.

## Navigation And Release Surface

Visible routes:

- /
- /graphs
- /salary
- /transaction
- /friend/invite
- /auth
- /auth/email-code

Hidden-by-default routes:

- /company
- /companyDetail
- /project
- /group

Guard behavior:

- unauthenticated users are redirected to /auth
- logged-in users trying to access auth routes are redirected to /
- hidden company routes redirect to /graphs
- detail routes without state.extra redirect to /

## Runtime Model

The app is designed as:

- offline first
- realtime when backend capabilities exist

Main technologies:

- flutter_bloc
- go_router
- supabase_flutter
- brick_offline_first_with_supabase
- firebase_messaging
- flutter_local_notifications
- fl_chart
- app_links

## Offline-First Storage

The local repository is implemented in lib/brick/repository.dart.

It:

- configures Supabase and SQLite providers
- uses Brick generated adapters
- keeps memory cache
- exposes shared realtime streams
- reconciles remote deletions into local storage

## Realtime Stream Sharing

Important implementation detail:

- Brick realtime streams were causing the error Bad state: Stream has already been listened to
- this was fixed by caching shared realtime bindings with BehaviorSubject
- multiple features can now listen to the same model and query stream safely

## Remote Deletion Reconciliation

Important implementation detail:

- Brick does not automatically propagate remote deletes into local state in this project setup
- a reconciliation layer was added in lib/brick/repository.dart
- on startup, the app compares local records against remote unique identifiers and deletes stale local rows

Current reconciliation coverage:

- UserModel
- FriendsModel
- TransactionModel
- SubscriptionModel
- AccountFundingModel
- CompanyModel
- CompanyWithUserLinkModel
- ProjectModel
- GroupModel

This sync is triggered from lib/features/main/presentation/bloc/main_bloc.dart.

## Feature Overview

### authentification

Purpose:

- unified auth entry flow
- email OTP verification
- Google auth
- Apple auth on Apple devices
- session-aware app entry

Notes:

- Firebase is initialized for notifications
- Supabase auth remains the session source of truth
- the public auth flow no longer uses separate onboarding, login, and signup screens
- the user-facing public auth flow is now `Auth` then `email code` when email is chosen
- Apple auth returns through the Bicount app link on `/auth`

### main

Purpose:

- aggregate startup data
- expose app shell state
- surface connection state

Main files:

- lib/features/main/presentation/screens/main_screen.dart
- lib/features/main/presentation/bloc/main_bloc.dart
- lib/features/main/data/repositories/main_repository_impl.dart
- lib/features/main/domain/entities/main_entity.dart

### home

Purpose:

- dashboard-like landing page for V1

### graph

Purpose:

- show useful analytics for the visible V1

Feature origin:

- generated with clean_structure, then manually corrected and integrated

Main files:

- lib/features/graph/presentation/screens/graph_screen.dart
- lib/features/graph/presentation/bloc/graph_bloc.dart
- lib/features/graph/data/repositories/graph_repository_impl.dart
- lib/features/graph/data/data_sources/local_datasource/local_graph_data_source_impl.dart

Current graph outputs:

- net flow
- income
- expenses
- cashflow trend
- expense breakdown
- subscription insights

Inputs:

- transactions
- subscriptions
- account fundings

Supported periods:

- 7 days
- 30 days
- 90 days
- all

Interaction rule:

- when the user changes graph period, keep the page shell visually stable
- do not animate or rebuild the whole Graphs screen as if a full page reload happened
- only the data-driven widgets should update, such as metric values, charts, breakdowns, and subscription insights
- the intro copy, overall layout, and section structure should remain fixed during period changes

### transaction

Purpose:

- create and list money flows
- support shared transactions

Main files:

- lib/features/transaction/presentation/widgets/transfer_form.dart
- lib/features/transaction/data/repositories/transaction_repository_impl.dart
- lib/features/transaction/domain/entities/create_transaction_request_entity.dart
- lib/features/transaction/domain/services/transaction_split_resolver.dart

Important V1 work:

- fixed transaction date handling so the chosen date is respected
- fixed currency handling so the form value is used
- added grouped split support

Grouped split modes:

- equal split
- percentage split
- manual amount split

Persistence strategy:

- one transaction row per beneficiary
- all rows of the same grouped operation share the same gtid

Responsive UI note:

- the transaction type segmented control should stay horizontally scrollable on narrow widths instead of overflowing or compressing labels too aggressively
- the selected transaction type should use a lightweight sliding thumb that matches the segment shape instead of snapping only the text background
- the scrollable transaction type selector should keep small masked side insets so clipped labels or thumb edges do not show abruptly at the viewport bounds

### add_fund

Purpose:

- create one-time account funding
- create recurring funding such as salary or other recurring income

Important boundary:

- actual received money stays represented by `AccountFundingModel`
- recurring salary setup starts here, but salary due tracking and confirmation belong to the dedicated `salary` feature

### salary

Purpose:

- dedicated follow-up for recurring salaries
- surface expected salary dates, due-today items, overdue arrears, and confirmed payments
- let the user confirm a salary payment before it affects the balance
- let the user switch a salary back to the old automatic process

Important boundary:

- salary occurrences are derived from `RecurringFundingModel` schedules and deterministic `AccountFundingModel.fundingId`
- a confirmation-mode salary must not create a concrete `account_funding` row until the user confirms receipt
- the salary screen should read from MainBloc aggregated data instead of introducing a duplicate fetch path

### profile

Purpose:

- current user information
- account funding entry point
- friend sharing entry point

### friend

Purpose:

- profile sharing
- invite acceptance flow
- current social graph for shared transactions

Feature origin:

- generated with clean_structure, then manually integrated

Main files:

- lib/features/friend/presentation/screens/friend_screen.dart
- lib/features/friend/presentation/screens/friend_invite_landing_screen.dart
- lib/features/friend/presentation/bloc/friend_bloc.dart
- lib/features/friend/data/repositories/friend_repository_impl.dart
- lib/features/friend/data/data_sources/remote_datasource/supabase_friend_remote_data_source.dart

Supported flows:

- create invite
- generate shareable HTTPS link
- generate QR code
- scan QR code
- open invite deep link
- preview invite
- accept invite
- reject invite
- watch sent and received invites in realtime

Backend expectation:

- table friend_invites
- optional RPC accept_friend_invite

### notification

Purpose:

- push notifications
- app-opened notifications
- deep link routing
- local reminders for subscriptions

Feature origin:

- generated with clean_structure, then manually integrated

Main files:

- lib/features/notification/presentation/bloc/notification_bloc.dart
- lib/features/notification/data/repositories/notification_repository_impl.dart
- lib/features/notification/data/data_sources/remote_datasource/firebase_notification_remote_data_source.dart
- lib/features/notification/data/data_sources/local_datasource/local_notification_data_source_impl.dart

Current behavior:

- asks notification permission
- syncs FCM device token to Supabase when possible
- listens for foreground messages
- listens for opened notifications
- listens for app links
- routes to target screens when payload contains route
- schedules subscription reminders locally

### company, group, project

Purpose:

- business and collaborative finance domain

Current V1 status:

- preserved in source
- hidden from release flow
- not deleted
- should remain untouched unless explicitly requested

## Data And Backend Contracts

Private configuration lives in:

- lib/core/constants/secrets.dart
- lib/core/constants/firebase_options.dart

These files are ignored by Git in normal workflows.
Do not expose real credentials.

Additional backend expectations introduced during V1 finishing work:

- friend_invites
- device_tokens
- notification_events
- recurring_fundings.salary_processing_mode
- recurring_fundings.salary_reminder_status
- RPC accept_friend_invite
- FCM push dispatch function
- realtime enabled for friend and finance tables
- salary payday notifications routed to `/salary`

Reference documents:

- docs/SUPABASE_V1_HANDOFF.md
- docs/BICOUNT_V1_BACKEND_ALIGNMENT_FR.md
- docs/salary_tracking_backend_actions.md

Invite link config lives in lib/core/constants/app_config.dart.
Default invite base URL is https://bicount.levelingcoder.com.
Expected route format is /friend/invite?code=INVITE_CODE.

User identity contract:

- backend `users.sid` has been removed
- `users.uid` is now the only primary identifier for the current user
- visible V1 code must use `UserModel.uid` for current-user identity
- do not reintroduce `sid` on `UserModel`, auth flows, or user-based sync logic
- `FriendsModel.sid` still exists and is still used as the stable local/shared identifier for friend records and friend-linked transactions

## UX And Design Principles

Do not redesign Bicount into a generic template.
The current V1 direction intentionally keeps the existing look and theme language.

When touching UI:

- preserve the established theme
- preserve colors, spacing rhythm, card treatment, typography direction, and overall atmosphere
- keep micro animations light and smooth
- avoid introducing a visually unrelated design system

## Testing And Validation

Current test files:

- test/widget_test.dart
- test/features/graph/data/repositories/graph_repository_impl_test.dart
- test/features/friend/data/repositories/friend_repository_impl_test.dart
- test/features/notification/domain/entities/app_notification_entity_test.dart
- test/features/transaction/domain/services/transaction_split_resolver_test.dart

Validation already performed during V1 finishing work:

- targeted Dart analysis on modified files
- Android app checkDebugAarMetadata
- Android app assembleDebug
- transaction split resolver unit test

Practical note:

- full device validation is still the most important next step before final release confidence

## Important Changes Already Applied

Release surface simplification:

- company flow hidden from visible V1
- visible tabs are now Home, Graphs, Transaction, and Profile
- router redirects hidden company paths away from release flow

New visible V1 capabilities:

- analytics feature
- friend profile sharing with QR, link, and invite landing
- notification bootstrap for push, deep links, and local reminders
- grouped transaction splits

Stability work:

- Android desugaring enabled for flutter_local_notifications
- shared realtime stream protection added to the Brick repository
- remote delete reconciliation added for offline cache consistency
- `transfer_form.dart` was split into dedicated `part` files and presentational sub-widgets to keep transaction UI maintainable and under the 200-line rule
- local sign out now clears SQLite using Brick schema table names instead of hardcoded app table names

## Sensitive Areas

Be careful when editing these areas:

- lib/brick/repository.dart
- lib/main.dart
- lib/core/routes/app_router.dart
- lib/features/main
- lib/features/notification
- lib/features/transaction

## Working Rules For Future Agents

1. Keep company code in source unless the user explicitly asks for permanent removal.
2. Respect the BLoC architecture and keep business rules out of screens when possible.
3. Preserve the established UI language instead of replacing it with a generic redesign.
4. Treat the app as offline first.
5. Treat realtime as an enhancement layered on top of local-first behavior.
6. Do not break invite links, FCM token sync, or subscription reminders.
7. If you add a feature and it fits the existing workflow, prefer generating the skeleton with clean_structure.
8. When changing Brick subscriptions, remember that shared stream safety is already solved in lib/brick/repository.dart.
9. When changing deletes or sync logic, do not remove the remote delete reconciliation unless you replace it with something equivalent.
10. Keep documents in docs updated when backend contracts change.
11. Treat `UserModel.uid` as the only user primary key; if you see current-user logic still using `sid`, migrate it instead of patching around it.
12. Do not remove `FriendsModel.sid` unless the user explicitly confirms a backend change for the friends domain too.
11. Do not hardcode SQLite table names for local cache cleanup; use the generated Brick schema so sign out stays aligned with real local tables.

## Suggested Read Order

1. AGENTS.md
2. lib/main.dart
3. lib/core/routes/app_router.dart
4. lib/brick/repository.dart
5. lib/features/main/presentation/screens/main_screen.dart
6. lib/features/graph/presentation/screens/graph_screen.dart
7. lib/features/friend/presentation/screens/friend_screen.dart
8. lib/features/notification/presentation/bloc/notification_bloc.dart
9. lib/features/transaction/presentation/widgets/transfer_form.dart
10. docs/BICOUNT_V1_BACKEND_ALIGNMENT_FR.md

## Useful Commands

Generate a feature:

- dart pub global activate clean_structure
- clean_structure feature --name your_feature

Typical checks:

- flutter pub get --offline
- flutter analyze lib
- flutter test
- cd android then run gradlew.bat :app:assembleDebug

## Current Status Snapshot

Current state of the codebase:

- V1 visible flow is coherent without company
- graphs, friends, notifications, and grouped splits are implemented
- transaction, subscription, add_fund, and salary now have separate active feature ownership
- offline-first and realtime scaffolding is stronger than at project start
- backend still needs to match the documented contracts for full production behavior
- device-level QA remains important before external prospect distribution

## Settings Feature Update

The app now includes a dedicated `settings` feature.

Main user actions:

- request `Bicount Pro`
- change theme
- change language
- edit visible profile identity
- sign out
- request account deletion after confirmation and a reason form

Access pattern:

- settings is exposed through the profile area with a dedicated icon in the shell app bar
- route path is `/settings`

Architecture notes:

- theme persistence is handled by `ThemeCubit` + `SettingsRepositoryImpl`
- language persistence remains handled by `LocaleCubit`
- settings success/error feedback goes through the shared notification system
- account deletion uses a confirmation dialog first, then a bottom sheet form

## Settings Backend Contract

When changing settings flows that touch Supabase, keep this file updated:

- `docs/settings_backend_actions.md`

Current backend additions expected by settings:

- `pro_upgrade_requests`
- `account_deletion_requests`
- Edge Function `delete-account`

## Localization Rule Update

All new user-visible settings texts must use the localization system.

Mandatory rule:

- do not add hardcoded UI copy for settings, onboarding, profile, auth, or other user-facing flows
- add new strings to `lib/l10n/app_en.arb` and `lib/l10n/app_fr.arb`
- regenerate localizations after ARB changes
- if a runtime/backend message must be translated, map it in `lib/core/localization/runtime_message_localizer.dart`

Fallback rule:

- the app follows the system language by default
- if the system language is unsupported or cannot be resolved, English is the fallback

## Refactor Rule

Manual source files should stay at or below 200 lines whenever the split is reasonable.
If a file starts growing past that limit, prefer splitting it into:

- dedicated widget files
- provider files
- domain service files
- helper or base component files

Do not apply this rule blindly to generated files.
These files are excluded from manual refactor unless the code generation strategy itself changes:

- files ending in .g.dart
- Brick migration files
- other generated artifacts

## Refactor Progress

Recent structural refactors already applied:

- main.dart was reduced by moving app wiring into lib/app/bicount_app.dart
- provider lists were extracted into lib/app/app_providers.dart
- graph_screen.dart was split into dedicated widget files under lib/features/graph/presentation/widgets
- friend_screen.dart was split into dedicated widget files under lib/features/friend/presentation/widgets
- main_screen.dart was split with shell widgets under lib/features/main/presentation/widgets/main_shell
- graph_repository_impl.dart was reduced by moving aggregation logic into graph domain services
- profile info cards were factorized with a shared base widget

When continuing this cleanup, prioritize visible V1 files first, then dormant company or group files, and only then broad theme or infrastructure refactors.

## Friend Linking Update (2026-03-19)

This release adds a true local-friend-to-real-account linking flow.

Important behavior:

- a friend can exist locally before the person has a Bicount account
- new locally created placeholder friends are now stored with `uid = null`
- for backward compatibility, the app also treats `uid == sid` and `fid == owner uid` as an unlinked local friend
- only unlinked friends expose the share action from `lib/features/friend/presentation/screens/detail_friend.dart`
- the dedicated full list screen is `lib/features/friend/presentation/screens/friends_directory_screen.dart`
- friend detail is now realtime and derived from `MainBloc` through `lib/features/friend/domain/services/friend_view_service.dart`

Backend contract delta:

- `friend_invites` must now identify the exact local friend row being shared
- required additional columns are `source_friend_sid`, `source_friend_name`, `source_friend_email`, and `source_friend_image`
- when an invite is accepted, the backend must update `public.friends.uid` for the row identified by `source_friend_sid`
- the visible share flow is no longer a generic profile invite; it is a targeted invite for a specific friend record

## Device Token Policy Update (2026-03-19)

The notification layer now treats `device_tokens` as one active row per `user_uid`.

Behavior:

- if a row already exists for the authenticated user, the app updates it
- if no row exists, the app inserts one
- if duplicate rows already exist for the same `user_uid`, the app keeps one and deletes the extras during the next token sync
- the FCM refresh listener is registered only once per app lifecycle to avoid accidental duplicate writes

Backend note:

- if you want database-level enforcement, add a unique constraint on `device_tokens.user_uid`
- this current mobile behavior matches the requested product rule of one token row per user

## Motion Update (2026-03-19)

A lightweight motion layer is now part of the visible V1 experience.

Rules:

- use `lib/core/widgets/bicount_reveal.dart` for one-shot section reveals
- prefer `AnimatedOpacity`, `AnimatedSlide`, `AnimatedScale`, `AnimatedContainer`, and `AnimatedSwitcher`
- keep durations short, usually between 180ms and 320ms
- animation should support comprehension and hierarchy, not decoration for its own sake
- avoid heavy blur, long-running controllers, parallax, or effects that reanimate large scrolling lists continuously
- when animating lists, only animate the first visible items or section entry, and keep the delays subtle

Current visible motion touchpoints:

- shell tab selection in `custom_bottom_navigation_bar.dart`
- Home screen section reveals
- Graphs screen staged reveals
- Profile and friends flow staged reveals

## Backend Delta Doc Update (2026-03-19)

A short backend action memo was added in `docs/new_action_on_back.md`.

Use it when the need is not a full backend handoff, but a focused list of what still has to be done on Supabase for the current mobile build to work.

Current emphasis in that memo:
- targeted friend linking through `source_friend_sid`
- preserving `friends.sid` while updating `friends.uid`
- secure invite preview and reject flows through backend RPCs
- realtime requirements for the visible V1 friend experience
- `device_tokens` now assumes one active row per `user_uid`, with uniqueness already expected to exist on Supabase

## Friend Share Reliability Update (2026-03-19)

The friend share flow now updates the visible `FriendBloc` state immediately after a local invite is created.

Why:
- invite creation is cached locally first
- remote invite creation or realtime propagation can be delayed or unavailable
- the QR code and share link must still appear instantly in the bottom sheet

Expected behavior now:
- `Generate invite` immediately exposes the QR code and invite URL from local state
- `Share link` and `Copy` become usable without waiting for Supabase realtime
- the existing UI choices remain in place, including `CustomAppBar` and opening `FriendScreen` in `showCustomBottomSheet`

## Unified Auth Refresh (2026-03-29)

The public authentication flow no longer uses onboarding, login, or signup as separate public screens.

Rules:
- default unauthenticated entry must land on `/auth`
- the email auth experience is passwordless and uses `/auth/email-code`
- do not recreate public onboarding, login, or signup routes without an explicit product request
- Google auth is an existing production path and must stay stable
- Apple auth returns through the Bicount app-link on `/auth`
- auth legal links target `https://bicount.levelingcoder.com/consumer-terms`, `/usage-policy`, and `/privacy-policy`

## Auth Layout Stability Update (2026-03-22)

Authentication screens should avoid nested flex layouts inside scrollable areas.

Rules:
- do not place a `Row` with `Expanded` children inside another unconstrained `Row` in auth screens
- avoid combining `SingleChildScrollView` with fragile `Spacer` or unnecessary fixed-height wrappers in auth entry screens
- use simple vertical sections for auth CTA areas when possible to keep layout predictable on smaller devices
- `Separator` now supports a safer compact mode when a bounded width is not guaranteed

## Delivery Discipline Update (2026-03-22)

These instructions apply in addition to all previous rules in this file.
They do not replace or weaken any earlier product, architecture, or UX constraints.

Mandatory execution rules after any meaningful code change:
- verify that the modified flow actually works after implementation
- run the most relevant validation possible for the change, such as targeted analysis, build, tests, or a runtime check
- if errors or regressions are found, fix them before considering the task complete
- do not stop at code edits only when the issue can be validated locally
- after each major update, add or refresh the relevant notes in `AGENTS.md`

Performance protection rules:
- prefer modifications that keep runtime performance stable or improved
- avoid heavy UI effects, unnecessary rebuilds, large always-on animations, and wasteful realtime listeners
- choose the simplest implementation that satisfies the UX goal while preserving fluidity
- when adding motion, keep it lightweight and short, and avoid patterns that can degrade scrolling or navigation smoothness

File size and factorization rules:
- do not create or keep manual source files above 200 lines unless the file is generated or there is an explicit user exception
- when a file grows too much, split it into smaller focused files instead of stacking more logic into one screen or widget
- prefer small reusable widgets, helpers, services, and mappers to keep files readable and maintainable
- keep business rules, UI composition, and integration code separated as much as practical within the existing BLoC architecture

## Localization Update (2026-03-22)

Current app localization status:
- visible V1 flows are localized in English and French
- the app follows the system language by default when no explicit choice is saved
- a manual language override is available from the Profile screen and is persisted with SharedPreferences
- generated localization files live in `lib/l10n`
- source ARB files are `lib/l10n/app_en.arb` and `lib/l10n/app_fr.arb`
- generated imports should use `package:bicount/l10n/app_localizations.dart`

Implementation rules for future agents:
- never hardcode new user-facing strings in visible V1 flows; add them to ARB files first
- after changing ARB files, run `flutter gen-l10n`
- after localization changes, run at least `flutter analyze lib` and a relevant build check
- keep date, time, and number formatting locale-aware; do not reintroduce hardcoded `en_EN`, `en_US`, or similar defaults for user-facing formatting
- if a runtime message comes from repositories, blocs, or backend glue and can surface in UI, localize it through the existing runtime message localizer or replace it with a localized source

Future language expansion:
- Lingala is technically supported by the current architecture
- to add Lingala later, create `lib/l10n/app_ln.arb`, regenerate l10n, and extend the locale selector if the product wants it exposed in settings

## Localization Runtime Completion (2026-03-22)

The i18n pass now covers both visible labels and the main runtime feedback shown to users.

Rules:
- if the device locale is unsupported or cannot be matched cleanly, fall back to English
- keep French and English as the current shipped locales unless the user explicitly asks to add more
- the language selector persists the explicit user choice with SharedPreferences, but `system` remains the default behavior
- runtime messages that can surface in toasts, bloc errors, or repository failures should be mapped through `lib/core/localization/runtime_message_localizer.dart`
- when adding new user-facing failure messages in repositories or blocs, use stable English source strings so the runtime localizer can translate them reliably
- avoid leaking low-level exception text directly into the UI when a cleaner localized message can be shown instead
- validators in reusable form widgets must also use localized strings, not hardcoded English
- Lingala remains feasible with a future `lib/l10n/app_ln.arb`; add it only when product scope explicitly includes it

## Remote Memoji And Skeleton Update (2026-03-22)

The settings profile editor no longer relies on a hardcoded local memoji catalog.

Current contract:
- profile avatar selection loads remote memoji from the Supabase Edge Function `get-memoji`
- the function is called with `GET` query params `page` and `limit`
- the app should progressively load more pages until `has_next` becomes false
- already loaded memoji pages are cached locally so the picker can still show known avatars when the network is unavailable

Implementation rules:
- keep avatar-like URL displays on cached network widgets; `lib/core/widgets/app_avatar.dart` is the preferred entry point for profile and friend avatar rendering
- do not reintroduce hardcoded memoji lists for the visible profile editing flow
- if the memoji request fails and no cache exists yet, show the themed empty state with a retry action instead of a spinner or blank area
- if cached memoji exist, prefer showing cached data first, then refresh page 1 in the background
- keep the settings memoji picker paginated and lightweight; avoid downloading the whole catalog at once

Loading rules:
- visible screen loading states should prefer the shared skeleton components in `lib/core/widgets/bicount_skeleton.dart`
- avoid introducing new `CircularProgressIndicator` screen states in visible V1 flows when a skeleton is more appropriate
- button-level pending states may still use compact inline loading indicators when a skeleton would not fit the interaction
- use `lib/core/themes/app_dimens.dart` for spacing, sizes, and repeated UI measurements in new loading and picker widgets

## Locale And Feedback Stability Update (2026-03-22)

Recent behavior fixes now define the expected UX for locale fallback and transaction feedback.

Rules:
- if the saved locale is absent and the device locale is unsupported or cannot be resolved cleanly, the app must fall back to English
- keep the app locale resolution deterministic; do not leave locale behavior ambiguous when system matching fails
- transaction success and error toasts must have a single owner for each flow; do not listen to the same `TransactionBloc` success state in both the container screen and the form if both can toast
- prefer form-level success handling for create/edit flows when the confirmation belongs to the action the user just submitted
- shared notification helpers must stay localized; do not reintroduce hardcoded English toast titles in visible V1 flows

## Auth Cache Rehydration Update (2026-03-23)

The sign-out flow now clears local finance tables through the shared Brick repository, but reconnection must still be able to rehydrate all data from Supabase cleanly.

Rules:
- use `Repository.clearLocalSessionData()` for local sign-out cleanup instead of duplicating table wipe logic in auth code
- do not cache the authenticated `uid` in a long-lived auth local data source field; always resolve it from the current Supabase session when needed
- after local tables are cleared, an empty first emission for `UserModel` should not be treated as a fatal error while remote hydration is still in progress
- `MainBloc` startup data loading must be restartable across sign-out and sign-in cycles; avoid long-lived `emit.forEach` patterns that make session restarts brittle
- when touching auth or main startup flows, verify the sequence `sign out -> sign in -> start data reappears` before considering the task complete

## Offline Finance Calculation Update (2026-03-23)

Finance aggregates used by the visible V1 app are now expected to be calculated locally in mobile code.

Rules:
- do not rely on Supabase triggers as the primary source of truth for `users.balance`, `users.incomes`, `users.expenses`, `users.personal_income`, `users.company_income`, `friends.give`, `friends.receive`, `friends.personal_income`, `friends.company_income`, or `companies.profit`
- keep the write-side formulas in shared services under `lib/core/services` so transactions, account funding, and subscriptions can apply side effects immediately while offline
- keep the read-side totals in the `main` flow projected from raw rows (`transactions`, `account_funding`, identity rows, and friend rows) so a second device or a fresh local cache still shows correct numbers after sync
- do not trust backend-derived numeric totals directly in the UI when projected local totals are available
- subscription creation must remain locally atomic from the product point of view: save or update the subscription row, ensure the linked friend row exists, create the generated transaction row, then apply the finance deltas
- if backend triggers still exist during transition, they must mirror the exact same formulas and must not be treated as canonical by the mobile UI

Validation rule:
- when touching offline finance logic, verify these paths before considering the task complete:
- create a transaction
- create an account funding
- create a subscription
- sign out then sign in again
- if possible, validate a second-device or fresh-cache sync path too

## Transaction Edit Update (2026-03-24)

The transaction detail flow now supports editing a simple transaction from its detail sheet.

Rules:
- the edit entry point lives in `lib/features/transaction/presentation/screens/detail_transaction_screen.dart`
- reuse the shared `TransferForm` for edit mode instead of introducing a visually different editor
- edit mode is intended for a single transaction row, so keep it limited to one beneficiary
- do not expose the edit action for subscription-generated transaction rows, because subscriptions are managed by a different flow
- after a successful transaction edit from the detail sheet, close the sheet so the updated data can be reopened from the live list state
- keep detail and form files under the 200-line rule by splitting readonly transaction detail widgets and transfer form interactions into focused files
- when the user selects `Me` or `Moi` in the transfer form for sender or beneficiary, the transient current-user party must carry the authenticated `uid` as its resolved identifier so `sender_id` and `beneficiary_id` persist the real user id instead of a generated placeholder id

## Invite Domain Update (2026-03-24)

The active invite domain for Bicount is now `https://bicount.levelingcoder.com`.

Rules:
- keep `lib/core/constants/app_config.dart` aligned with the live invite domain unless the user explicitly switches environments
- Android app-link host in `android/app/src/main/AndroidManifest.xml` must match the same domain
- iOS associated domains entitlement in `ios/Runner/Runner.entitlements` must match the same domain
- keep `docs/invite_domain_hosting_setup.md` updated with the currently valid Android SHA-256 fingerprint and the current iOS Team ID expectation
- the current Android project signs `release` with the debug signing config, so app-link hosting must use that fingerprint until a real release keystore replaces it
- when the invite domain changes, also refresh the hosting instructions and the `.well-known` files served by the website

## Recurring Funding Update (2026-03-25)

The `Add funds` flow now supports recurring personal income such as salary.

Rules:
- keep one-time account funding rows and recurring income templates as separate concepts
- actual credited money must stay in `account_funding`
- recurring income templates must live in `recurring_fundings`
- when a recurring income becomes due, mobile generates a real `account_funding` row locally, then advances `next_funding_date`
- do not count recurring templates directly in balance, graphs, or funding totals before an actual funding row is created
- `funding_type` is now part of `account_funding` and should stay aligned with the mobile contract
- the visible `Add funds` form must support both one-time and recurring income without breaking the existing bottom-sheet flow
- recurring income processing is currently triggered on startup and right after creation; if you change startup flows, preserve this behavior
- subscription placeholder rows created in `friends` for offline projections must keep `uid = null`; never use `subscriptionId` as `friends.uid`, because backend `friends.uid` is a foreign key to real `users.uid`
- backend work for this change is documented in `docs/recurring_funding_backend_actions.md`

Migration rule:
- keep the recurring-funding SQLite repair step in `Repository.repairRecurringFundingMigrationStateIfNeeded()` before `Repository().initialize()`; it protects existing local databases from duplicate-column failures on partially migrated devices
- Brick tracks applied migrations in the `MigrationVersions` table, not only with `PRAGMA user_version`; if you repair a partially migrated local database, also mark the migration version there or Brick may replay the same `ALTER TABLE` commands
- keep the temporary AndroidX forcing block in `android/build.gradle.kts` unless AGP is upgraded; it prevents transitive AndroidX updates from requiring a newer Android Gradle plugin than the project currently uses
- keep Android build paths and `flutter.source` aligned on the canonical project directory; this project may be opened through a Windows junction during AI work, and Flutter assets can disappear from the APK if Gradle builds from one path while Flutter bundles from another

## State And Cross-Device Update (2026-03-30)

Rules:
- persisted business states must be numeric and centralized in `lib/core/constants/state_app.dart`
- avoid introducing new text-based status payloads such as `active`, `inactive`, or `paused` in mobile persistence contracts
- if a backend state contract changes, update the shared backend memo in `docs/backend_followup_actions.md`
- transaction search screens must rebuild from controller changes instead of mutating controllers during build
- startup data recovery on a fresh device must explicitly hydrate user finance tables before relying on realtime streams alone
- subscription unsubscribe must be a real status update with an end date, not a no-op upsert
- notification sync for subscriptions must cancel old reminders before scheduling active subscriptions again

## Salary Tracking Update (2026-03-31)

Rules:
- recurring salaries with confirmation enabled must stay out of `AccountFundingModel` until the user confirms the payment
- only confirmed salary money may impact global balances, graphs, or income totals
- salary due dates and arrears are derived from `RecurringFundingModel` schedules and deterministic `funding_id` values, so do not break that id contract when touching recurring income logic
- the dedicated salary follow-up flow belongs to `lib/features/salary`, not back inside `add_fund`
- backend salary reminders should deep link to `/salary` with `recurringFundingId` and `expectedDate` so the app can open the correct confirmation context
