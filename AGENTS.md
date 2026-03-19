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
- active visible V1 blocs include AuthentificationBloc, MainBloc, HomeBloc, TransactionBloc, ProfileBloc, GraphBloc, FriendBloc, and NotificationBloc

The router lives in lib/core/routes/app_router.dart.
The app theme lives in lib/core/themes/app_theme.dart.

## Navigation And Release Surface

Visible routes:

- /
- /graphs
- /transaction
- /friend/invite
- /login
- /signUp

Hidden-by-default routes:

- /company
- /companyDetail
- /project
- /group

Guard behavior:

- unauthenticated users are redirected to /login
- logged-in users trying to access login or signUp are redirected to /
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

- email auth flow
- session-aware app entry

Notes:

- Firebase is initialized for notifications
- Supabase auth remains the session source of truth

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
- RPC accept_friend_invite
- FCM push dispatch function
- realtime enabled for friend and finance tables

Reference documents:

- docs/SUPABASE_V1_HANDOFF.md
- docs/BICOUNT_V1_BACKEND_ALIGNMENT_FR.md

Invite link config lives in lib/core/constants/app_config.dart.
Default invite base URL is https://preview.bicount.app.
Expected route format is /friend/invite?code=INVITE_CODE.

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
- offline-first and realtime scaffolding is stronger than at project start
- backend still needs to match the documented contracts for full production behavior
- device-level QA remains important before external prospect distribution

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
