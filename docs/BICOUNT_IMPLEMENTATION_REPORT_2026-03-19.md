# Bicount V1 Mobile - Detailed Implementation Report

## Document Purpose

This document is a full handoff report of the work completed on the Bicount application during the finishing phase that turned the project into a usable V1 candidate without the visible company surface.

It explains:

- what was changed
- why it was changed
- how it was implemented
- what files or layers were touched
- what validations were performed
- what still remains for final release confidence

Reference date:

- 2026-03-19

## Initial Situation

At the beginning of the work, the project already had a strong product direction:

- Flutter mobile app
- feature-based structure
- BLoC state management
- Supabase backend
- Brick offline-first foundation
- rich UI theme and product identity

However, the project was not yet aligned with a focused V1. The main issues were:

- the visible product scope was too wide for first release
- company was still exposed in UI and routing
- some repositories and data sources were being duplicated in bootstrap
- some user flows were incomplete or inconsistent
- backend expectations were not fully documented for the new mobile flows
- notification and social sharing flows were not yet fully implemented
- Brick realtime behavior and delete propagation needed more robustness

## Main Product Decision Applied

The key product decision was:

- keep company, group, and project in source code
- remove them from the visible release surface
- focus the V1 on Home, Graphs, Transaction, and Profile

This preserved future roadmap flexibility while reducing V1 complexity.

## Workstream 1 - Functional Analysis And Prioritization

The first phase of work was a static analysis of the repository to identify:

- what the app does
- what is already solid
- what blocks a usable V1
- what could be hidden instead of deleted

Findings that shaped the implementation plan:

- the app is primarily a personal and shared finance application
- company expands the product into a heavier business-management scope
- the visible V1 should instead center on personal balance tracking, shared transactions, subscriptions, profile and social connection, and useful analytics

## Workstream 2 - V1 Release Surface Without Company

### Goal

Hide the company surface without deleting the domain code.

### Main changes

The visible navigation was redesigned around:

- Home
- Graphs
- Transaction
- Profile

Company was replaced by Graphs in the visible app shell.

### Implementation details

Files involved:

- lib/core/constants/app_config.dart
- lib/main.dart
- lib/core/routes/app_router.dart
- lib/core/widgets/custom_bottom_navigation_bar.dart
- lib/features/main/presentation/screens/main_screen.dart
- lib/features/home/presentation/screens/home_screen.dart
- lib/features/profile/presentation/screens/profile_screen.dart

Key actions:

- added a release flag to control whether the company surface is exposed
- defaulted that flag to hidden
- prevented company blocs and repositories from being registered when hidden
- removed company routes from the visible release path
- redirected hidden company routes to /graphs
- updated the app shell to show Graphs instead of Company
- rebalanced the visible UX so the app still feels complete with four tabs

### Product impact

This was a major scope simplification that made the application easier to present to prospects while keeping future business features intact in code.

## Workstream 3 - Design Preservation While Refocusing The App

### Goal

Refactor the visible V1 design without breaking the existing product identity.

### Approach

The design was intentionally not replaced with a generic redesign. Instead, the work kept:

- the existing theme
- the card language
- the spacing rhythm
- the visual density
- the transition style
- the UI atmosphere

### Main UI outcomes

- the main shell still feels native to the existing app
- Graphs fits naturally where Company used to sit in navigation
- friend sharing, analytics, and profile actions were added with consistent visual treatment
- micro animations were used where helpful, including animated title switching, chart metrics, FAB switching, and search visibility

## Workstream 4 - Better Separation Between Business Logic And UI

### Goal

Respect the existing BLoC architecture more consistently and reduce business logic inside screens.

### Main improvements

- visible V1 flows now rely more clearly on repositories, blocs, and domain services
- typed request entities were introduced for complex transaction creation
- graph aggregation logic lives in repository or domain-style logic rather than widget code
- invite state and notification orchestration are handled through dedicated feature layers

### Concrete examples

Transactions:

- transaction creation is now expressed through CreateTransactionRequestEntity
- split calculation is handled by TransactionSplitResolver
- repository persistence receives a resolved business request

Graphs:

- analytics aggregation is centralized in GraphRepositoryImpl
- widgets receive already prepared dashboard data

## Workstream 5 - Graph Feature Creation And Integration

### Goal

Create a useful analytics feature for the visible V1.

### Tooling

The feature skeleton was generated with clean_structure, then corrected and integrated manually.

### Main files

- lib/features/graph/presentation/screens/graph_screen.dart
- lib/features/graph/presentation/bloc/graph_bloc.dart
- lib/features/graph/data/repositories/graph_repository_impl.dart
- lib/features/graph/data/data_sources/local_datasource/local_graph_data_source_impl.dart
- test/features/graph/data/repositories/graph_repository_impl_test.dart

### Functional result

The app now exposes analytics that are useful for daily usage:

- net flow
- total income
- total expenses
- cumulative cashflow trend
- expense breakdown
- subscription insights
- next due subscriptions

### Data model and behavior

The graph dashboard is built from:

- transactions
- subscriptions
- account_funding

Supported periods:

- 7 days
- 30 days
- 90 days
- all

### Technical implementation

GraphRepositoryImpl combines multiple local realtime streams and derives:

- inflow
- outflow
- net flow
- breakdown buckets
- subscription load estimates
- upcoming charges
- cumulative cashflow points

This keeps graph rendering reactive and offline friendly.

## Workstream 6 - Friend Sharing And Social Connection

### Goal

Implement a complete profile-sharing flow through QR code, invite link, invite landing page, and accept or reject flow.

### Tooling

The feature skeleton was generated with clean_structure, then integrated manually.

### Main files

- lib/features/friend/presentation/screens/friend_screen.dart
- lib/features/friend/presentation/screens/friend_invite_landing_screen.dart
- lib/features/friend/presentation/bloc/friend_bloc.dart
- lib/features/friend/data/repositories/friend_repository_impl.dart
- lib/features/friend/data/data_sources/local_datasource/local_friend_data_source_impl.dart
- lib/features/friend/data/data_sources/remote_datasource/supabase_friend_remote_data_source.dart
- test/features/friend/data/repositories/friend_repository_impl_test.dart

### Functional result

The user can now:

- generate an invite
- share the invite as an HTTPS link
- copy the link
- display the invite as a QR code
- scan a QR code
- open an invite link
- preview the invite
- accept or reject the invite
- see sent and received invites update in realtime
- see accepted friends from live app data

### Backend alignment

This feature introduced explicit backend expectations:

- table friend_invites
- realtime on friend_invites
- optional RPC accept_friend_invite

The mobile code also contains a safe fallback if the RPC is not present.

## Workstream 7 - Notification System

### Goal

Implement a complete notification base for both active and inactive app states.

### Tooling

The feature skeleton was generated with clean_structure, then integrated manually.

### Main files

- lib/features/notification/presentation/bloc/notification_bloc.dart
- lib/features/notification/data/repositories/notification_repository_impl.dart
- lib/features/notification/data/data_sources/local_datasource/local_notification_data_source_impl.dart
- lib/features/notification/data/data_sources/remote_datasource/firebase_notification_remote_data_source.dart
- test/features/notification/domain/entities/app_notification_entity_test.dart

### Functional result

The app now has a strong notifications foundation:

- notification permission request
- FCM token retrieval
- token sync attempt to Supabase
- foreground message handling
- opened-app message handling
- app-link handling
- route redirection from notification payload
- local subscription reminders

### App behavior by state

When the app is open:

- incoming push notifications can trigger local presentation
- foreground messages are surfaced to the user

When the app is backgrounded or reopened:

- opened notification payloads can route to the correct page

When the app is closed:

- initial push or deep link event can still be resolved on startup

### Backend alignment

This feature introduced explicit backend expectations:

- device_tokens
- notification_events
- Edge Function for push dispatch
- app links on a real HTTPS domain

## Workstream 8 - Backend Handoff Documentation

### Goal

Give the backend team a precise implementation contract.

### Documents produced

- docs/SUPABASE_V1_HANDOFF.md
- docs/BICOUNT_V1_BACKEND_ALIGNMENT_FR.md
- docs/BICOUNT_V1_BACKEND_ALIGNMENT_FR_PDF.md

### Covered topics

- new tables
- recommended SQL
- RLS
- RPC expectations
- push notification flow
- app links
- realtime requirements
- order of implementation
- minimum backend test cases

### Additional delivery

A PDF version of the backend alignment document was generated and placed in the Bicount documents folder.

## Workstream 9 - Android Build Fix For Notifications

### Problem

Launching the app failed on Android with app checkDebugAarMetadata because flutter_local_notifications required core library desugaring.

### Fix

Core library desugaring was enabled in the Android app Gradle configuration.

Main file involved:

- android/app/build.gradle.kts

### Result

The Android debug build could proceed again and app assembleDebug completed successfully.

## Workstream 10 - Realtime Stream Stability And Graph Loading Fix

### Problem

During runtime navigation, the app produced the error Bad state: Stream has already been listened to.
The graph screen also remained stuck on a loading state.

### Root cause

Multiple features were consuming the same Brick realtime streams in a way that reused single-subscription sources.

### Fix

The repository layer was upgraded so shared realtime requests are cached and exposed through BehaviorSubject streams that safely support multiple listeners.

Main file:

- lib/brick/repository.dart

Supporting changes:

- lib/features/main/data/data_sources/local_datasource/local_main_data_source_impl.dart
- lib/features/graph/data/data_sources/local_datasource/local_graph_data_source_impl.dart

### Result

- the graph feature receives stable live data
- multiple visible V1 features can listen to the same underlying data without crashing

## Workstream 11 - Brick Remote Delete Reconciliation

### Problem

Brick in this project setup did not automatically reflect remote deletions into local state.

This can lead to:

- stale local data
- deleted rows still visible offline
- divergence between remote truth and local cache

### Reference

The implementation approach was studied from the campus_apc project without modifying that project.

### Bicount adaptation

The logic was adapted inside Bicount only.

Main file:

- lib/brick/repository.dart

Main mechanisms added:

- fetch remote unique identifiers
- compare them with local cached rows
- delete local rows that no longer exist remotely
- notify subscriptions after reconciliation

### Trigger point

Delete reconciliation is initiated during startup through lib/features/main/presentation/bloc/main_bloc.dart.

### Covered model families

- user
- friends
- transactions
- subscriptions
- account funding
- company
- company-user link
- project
- group

## Workstream 12 - Grouped Transaction Split Feature

### Goal

Let a payer distribute a single transaction across multiple beneficiaries.

### Functional requirement implemented

Example:

- one payer gives 100
- the amount can be split across ten people
- either equally
- or by percentage
- or by manually entered individual amounts

### Main files

- lib/features/transaction/presentation/widgets/transfer_form.dart
- lib/features/transaction/domain/entities/create_transaction_request_entity.dart
- lib/features/transaction/domain/services/transaction_split_resolver.dart
- lib/features/transaction/data/repositories/transaction_repository_impl.dart
- lib/features/transaction/data/data_sources/local_datasource/local_transaction_data_source_impl.dart
- test/features/transaction/domain/services/transaction_split_resolver_test.dart

### Business design

- the new typed request model captures title, date, total amount, currency, sender, note, split mode, and split inputs
- the resolver supports equal, percentage, and custom amount split modes

### UX result

The user can now:

- add multiple beneficiaries
- choose a split mode
- let the app split equally
- enter percentages
- enter individual amounts
- preview the split before saving

### Persistence contract

The repository persists one transaction row per beneficiary while keeping a shared gtid for the grouped operation.

This keeps the data model simple while preserving group identity for future aggregation.

## Workstream 13 - Targeted Runtime And Codebase Cleanups

Additional cleanup work was applied along the way:

- removed dead or misleading visible company entry points from the V1 flow
- corrected mutation-prone sorting behavior in some visible screens by copying lists before sorting
- improved live friend rendering from MainBloc state
- corrected transaction form issues around selected date and chosen currency
- removed user-facing dead Google auth buttons from visible screens when they were not actually implemented

These changes were aimed at turning the app from a promising prototype into a more reliable prospect-facing build.

## Files And Areas Most Impacted

App shell and release surface:

- lib/main.dart
- lib/core/routes/app_router.dart
- lib/core/constants/app_config.dart
- lib/core/widgets/custom_bottom_navigation_bar.dart
- lib/features/main/presentation/screens/main_screen.dart

Offline-first and sync:

- lib/brick/repository.dart
- lib/features/main/data/data_sources/local_datasource/local_main_data_source_impl.dart
- lib/features/graph/data/data_sources/local_datasource/local_graph_data_source_impl.dart
- lib/features/main/presentation/bloc/main_bloc.dart

Graphs:

- lib/features/graph

Friends:

- lib/features/friend

Notifications:

- lib/features/notification
- Android notification-related configuration
- iOS and Android deep link alignment where needed

Transactions:

- lib/features/transaction

## Validation Performed

The following validations were performed during the implementation work:

- targeted dart analyze on changed files
- flutter pub get --offline
- flutter test on the transaction split resolver test
- Android app checkDebugAarMetadata
- Android app assembleDebug

### Known validation note

Full end-to-end validation on real devices is still the next critical step, especially for:

- invite links
- QR flow
- push notifications
- background notification routing
- local reminders
- realtime consistency across multiple devices

## Current Functional State

As of this report, the application state is:

- visible V1 no longer depends on the company surface
- analytics exist and are product-meaningful
- friend sharing exists through link and QR
- notification architecture is in place
- grouped split transactions exist
- Android build issue related to desugaring is fixed
- Brick realtime listener crash has been addressed
- remote deletions have a reconciliation strategy

## Remaining Recommended Steps Before Broad Prospect Distribution

1. Validate full flows on at least two real devices.
2. Confirm backend tables, RPC, and push function match the handoff document.
3. Validate app links on the final production domain.
4. Run broader QA on offline-create, reconnect, and realtime-merge cases.
5. Decide whether grouped transactions should later render as one grouped list item by gtid.
6. Review legacy warnings and non-V1 dormant modules before a larger release.

## Executive Conclusion

The work completed on Bicount transformed the app in four major ways:

1. It focused the product around a realistic V1 release.
2. It added missing user-facing value through graphs, friend sharing, notifications, and grouped splits.
3. It improved technical robustness around offline-first, realtime, and Android build reliability.
4. It produced backend handoff material so the mobile and Supabase sides can converge cleanly.

The app is now significantly closer to a prospect-ready mobile product than it was at the start of the work.
