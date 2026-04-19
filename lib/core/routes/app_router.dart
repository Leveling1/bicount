import 'dart:async';

import 'package:bicount/core/constants/app_config.dart';
import 'package:bicount/core/routes/friend_invite_route.dart';
import 'package:bicount/features/authentification/presentation/screens/auth_email_code_screen.dart';
import 'package:bicount/features/authentification/presentation/screens/auth_screen.dart';
import 'package:bicount/features/friend/presentation/screens/friend_invite_landing_screen.dart';
import 'package:bicount/features/recurring_fundings/data/repositories/recurring_transfert_repository_impl.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/presentation/screens/recurring_fundings_screen.dart';
import 'package:bicount/features/recurring_fundings/presentation/screens/recurring_plan_screen.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_bloc.dart';
import 'package:bicount/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/company/presentation/screens/detail_company_screen.dart';
import '../../features/group/domain/entities/group_model.dart';
import '../../features/group/presentation/screens/group_screen.dart';
import '../../features/main/presentation/screens/main_screen.dart';
import '../../features/project/domain/entities/project_model.dart';
import '../../features/project/presentation/screens/project_screen.dart';
import '../utils/custom_transition.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

String _widgetLaunchToken(GoRouterState state) {
  return state.uri.queryParameters['widgetLaunch'] ??
      DateTime.now().microsecondsSinceEpoch.toString();
}

String _buildWidgetShellRoute(GoRouterState state) {
  return Uri(
    path: '/',
    queryParameters: {'widgetLaunch': _widgetLaunchToken(state)},
  ).toString();
}

String _buildWidgetRecurringConfirmationRoute(GoRouterState state) {
  return Uri(
    path: '/recurring-fundings',
    queryParameters: {
      'widgetLaunch': _widgetLaunchToken(state),
      if ((state.uri.queryParameters['recurringFundingId'] ?? '').isNotEmpty)
        'recurringFundingId': state.uri.queryParameters['recurringFundingId']!,
      if ((state.uri.queryParameters['expectedDate'] ?? '').isNotEmpty)
        'expectedDate': state.uri.queryParameters['expectedDate']!,
    },
  ).toString();
}

String _buildWidgetRecurringChargesRoute(GoRouterState state) {
  return Uri(
    path: '/recurring-charges',
    queryParameters: {'widgetLaunch': _widgetLaunchToken(state)},
  ).toString();
}

String _buildWidgetRecurringIncomesRoute(GoRouterState state) {
  return Uri(
    path: '/recurring-incomes',
    queryParameters: {'widgetLaunch': _widgetLaunchToken(state)},
  ).toString();
}

String _redirectWidgetAlias(GoRouterState state) {
  final action = state.pathParameters['action'];
  return switch (action) {
    'add-transaction' => _buildWidgetShellRoute(state),
    'recurring-confirmation' => _buildWidgetRecurringConfirmationRoute(state),
    'recurring-charges' => _buildWidgetRecurringChargesRoute(state),
    'recurring-incomes' => _buildWidgetRecurringIncomesRoute(state),
    _ => _buildWidgetShellRoute(state),
  };
}

class AppRouter {
  final GoRouter _router;

  AppRouter()
    : _router = GoRouter(
        navigatorKey: rootNavigatorKey,
        routes: [
          GoRoute(
            path: '/open-home',
            redirect: (context, state) => _buildWidgetShellRoute(state),
          ),
          GoRoute(
            path: '/add-transaction',
            redirect: (context, state) => _buildWidgetShellRoute(state),
          ),
          GoRoute(
            path: '/recurring-confirmation',
            redirect: (context, state) =>
                _buildWidgetRecurringConfirmationRoute(state),
          ),
          GoRoute(
            path: '/widget/:action',
            redirect: (context, state) => _redirectWidgetAlias(state),
          ),
          GoRoute(path: '/', builder: (context, state) => MainScreen()),
          GoRoute(
            path: '/auth',
            pageBuilder: (context, state) => buildFadeSlideTransitionPage(
              child: AuthScreen(
                initialEmail: state.uri.queryParameters['email'],
                initialInviteCode: FriendInviteRoute.inviteCodeFromUri(
                  state.uri,
                ),
              ),
              state: state,
            ),
          ),
          GoRoute(
            path: '/auth/email-code',
            pageBuilder: (context, state) => buildFadeSlideTransitionPage(
              child: AuthEmailCodeScreen(
                email: state.uri.queryParameters['email'] ?? '',
                inviteCode: FriendInviteRoute.inviteCodeFromUri(state.uri),
              ),
              state: state,
            ),
          ),
          GoRoute(path: '/analysis', builder: (context, state) => MainScreen()),
          GoRoute(path: '/graphs', redirect: (context, state) => '/analysis'),
          GoRoute(
            path: '/transaction',
            builder: (context, state) => MainScreen(),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => buildFadeSlideTransitionPage(
              child: const SettingsScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/subscriptions',
            pageBuilder: (context, state) => buildFadeSlideTransitionPage(
              child: BlocProvider(
                create: (context) => RecurringTransfertBloc(
                  context.read<RecurringTransfertRepositoryImpl>(),
                ),
                child: const RecurringPlanScreen(
                  scope: RecurringPlanScope.charge,
                ),
              ),
              state: state,
            ),
          ),
          GoRoute(
            path: '/recurring-charges',
            pageBuilder: (context, state) => buildFadeSlideTransitionPage(
              child: BlocProvider(
                create: (context) => RecurringTransfertBloc(
                  context.read<RecurringTransfertRepositoryImpl>(),
                ),
                child: const RecurringPlanScreen(
                  scope: RecurringPlanScope.charge,
                ),
              ),
              state: state,
            ),
          ),
          GoRoute(
            path: '/recurring-incomes',
            pageBuilder: (context, state) => buildFadeSlideTransitionPage(
              child: BlocProvider(
                create: (context) => RecurringTransfertBloc(
                  context.read<RecurringTransfertRepositoryImpl>(),
                ),
                child: const RecurringPlanScreen(
                  scope: RecurringPlanScope.income,
                ),
              ),
              state: state,
            ),
          ),
          GoRoute(
            path: '/recurring-fundings',
            pageBuilder: (context, state) => buildFadeSlideTransitionPage(
              child: RecurringFundingsScreen(
                focusRecurringFundingId:
                    state.uri.queryParameters['recurringFundingId'],
                focusExpectedDate: state.uri.queryParameters['expectedDate'],
              ),
              state: state,
            ),
          ),
          GoRoute(
            path: '/salary',
            pageBuilder: (context, state) => buildFadeSlideTransitionPage(
              child: RecurringFundingsScreen(
                focusRecurringFundingId:
                    state.uri.queryParameters['recurringFundingId'],
                focusExpectedDate: state.uri.queryParameters['expectedDate'],
              ),
              state: state,
            ),
          ),
          GoRoute(
            path: '/friend/invite',
            pageBuilder: (context, state) => buildFadeSlideTransitionPage(
              child: FriendInviteLandingScreen(
                inviteCode:
                    state.uri.queryParameters[AppConfig.inviteCodeQueryParam] ??
                    state.uri.queryParameters['code'] ??
                    '',
              ),
              state: state,
            ),
          ),
          if (AppConfig.exposeCompanySurface)
            GoRoute(
              path: '/company',
              builder: (context, state) => MainScreen(),
            ),
          if (AppConfig.exposeCompanySurface)
            GoRoute(
              path: '/companyDetail',
              pageBuilder: (context, state) {
                final cid = state.extra as String;
                return buildCustomTransitionPage(
                  childContain: DetailCompanyScreen(cid: cid),
                  state: state,
                  model: String,
                );
              },
            ),
          if (AppConfig.exposeCompanySurface)
            GoRoute(
              path: '/project',
              pageBuilder: (context, state) {
                final projectData = state.extra as ProjectEntity;
                return buildCustomTransitionPage(
                  childContain: ProjectScreen(projectData: projectData),
                  state: state,
                  model: ProjectEntity,
                );
              },
            ),
          if (AppConfig.exposeCompanySurface)
            GoRoute(
              path: '/group',
              pageBuilder: (context, state) {
                final groupData = state.extra as GroupEntity;
                return buildCustomTransitionPage(
                  childContain: GroupScreen(groupData: groupData),
                  state: state,
                  model: GroupEntity,
                );
              },
            ),
        ],
        redirect: (context, state) {
          final session = Supabase.instance.client.auth.currentSession;
          final isLoggedIn = session != null;
          final uri = state.uri;
          final path = uri.path;
          final inviteCode = FriendInviteRoute.inviteCodeFromUri(uri);
          final isInvitePath = FriendInviteRoute.isInvitePath(uri);
          final isEmbeddedInvite = FriendInviteRoute.isEmbedded(uri);
          final isPublicPath =
              path == '/auth' ||
              path == '/auth/email-code' ||
              (isInvitePath && !isEmbeddedInvite);

          if (!AppConfig.exposeCompanySurface &&
              (path == '/company' ||
                  path == '/companyDetail' ||
                  path == '/project' ||
                  path == '/group')) {
            return '/analysis';
          }
          if ((path == '/companyDetail' ||
                  path == '/project' ||
                  path == '/group') &&
              state.extra == null) {
            return '/';
          }

          if (path == '/auth/email-code' &&
              (uri.queryParameters['email'] ?? '').isEmpty) {
            return inviteCode == null
                ? '/auth'
                : FriendInviteRoute.buildAuthRoute(inviteCode: inviteCode);
          }

          if (!isLoggedIn) {
            if (isInvitePath && !isEmbeddedInvite) {
              if (inviteCode == null) {
                return '/auth';
              }
              return FriendInviteRoute.buildAuthRoute(inviteCode: inviteCode);
            }
            if (path == '/') {
              return inviteCode == null
                  ? '/auth'
                  : FriendInviteRoute.buildAuthRoute(inviteCode: inviteCode);
            }
            if (!isPublicPath) {
              return '/auth';
            }
            return null;
          }

          if (isInvitePath && !isEmbeddedInvite) {
            if (inviteCode == null) {
              return '/';
            }
            return FriendInviteRoute.buildShellRoute(inviteCode);
          }

          if (path == '/auth' || path == '/auth/email-code') {
            return inviteCode == null
                ? '/'
                : FriendInviteRoute.buildShellRoute(inviteCode);
          }
          return null;
        },
        refreshListenable: GoRouterRefreshStream(
          Supabase.instance.client.auth.onAuthStateChange,
        ),
      );

  GoRouter get router => _router;
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((event) {
      notifyListeners();
    });
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
