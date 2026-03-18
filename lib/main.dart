import 'package:bicount/core/constants/app_config.dart';
import 'package:bicount/core/routes/app_router.dart';
import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/features/authentification/data/data_sources/remote_datasource/supabase_authentification.dart';
import 'package:bicount/features/authentification/data/repositories/authentification_repository_impl.dart';
import 'package:bicount/features/authentification/presentation/bloc/authentification_bloc.dart';
import 'package:bicount/features/company/data/repositories/company_repository_impl.dart';
import 'package:bicount/features/company/presentation/bloc/company_bloc.dart';
import 'package:bicount/features/friend/data/data_sources/local_datasource/local_friend_data_source_impl.dart';
import 'package:bicount/features/friend/data/data_sources/remote_datasource/supabase_friend_remote_data_source.dart';
import 'package:bicount/features/friend/data/repositories/friend_repository_impl.dart';
import 'package:bicount/features/friend/presentation/bloc/friend_bloc.dart';
import 'package:bicount/features/graph/data/data_sources/local_datasource/local_graph_data_source_impl.dart';
import 'package:bicount/features/graph/data/repositories/graph_repository_impl.dart';
import 'package:bicount/features/graph/presentation/bloc/graph_bloc.dart';
import 'package:bicount/features/home/data/repositories/home_repository_impl.dart';
import 'package:bicount/features/home/presentation/bloc/home_bloc.dart';
import 'package:bicount/features/main/data/data_sources/remote_datasource/main_remote_data_source_impl.dart';
import 'package:bicount/features/notification/data/data_sources/local_datasource/local_notification_data_source_impl.dart';
import 'package:bicount/features/notification/data/data_sources/remote_datasource/firebase_notification_remote_data_source.dart';
import 'package:bicount/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:bicount/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:bicount/features/profile/data/data_sources/local_datasource/profile_local_data_source_impl.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/local_transaction_data_source_impl.dart';
import 'package:bicount/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:bicount/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_links/app_links.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'brick/repository.dart';
import 'features/authentification/data/data_sources/local_datasource/local_authentification.dart';
import 'features/company/data/data_sources/local_datasource/local_company_data_source_impl.dart';
import 'features/company/data/data_sources/remote_datasource/company_remote_data_source_impl.dart';
import 'features/company/presentation/bloc/detail_bloc/detail_bloc.dart';
import 'features/company/presentation/bloc/list_bloc/list_bloc.dart';
import 'features/group/data/repositories/group_repository_impl.dart';
import 'features/group/presentation/bloc/group_bloc.dart';
import 'features/home/data/data_sources/local_datasource/local_home_data_source_impl.dart';
import 'features/home/data/data_sources/remote_datasource/remote_home_data_source_impl.dart';
import 'features/main/data/data_sources/local_datasource/local_main_data_source_impl.dart';
import 'features/main/data/repositories/main_repository_impl.dart';
import 'features/main/presentation/bloc/main_bloc.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/project/data/repositories/project_repository_impl.dart';
import 'features/project/presentation/bloc/project_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Repository.configure(databaseFactory);
  await Repository().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final enableCompanySurface = AppConfig.exposeCompanySurface;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthentificationRepositoryImpl>(
          create: (_) => AuthentificationRepositoryImpl(
            LocalAuthentification(),
            SupabaseAuthentification(Supabase.instance.client),
          ),
        ),
        RepositoryProvider<MainRepositoryImpl>(
          create: (_) => MainRepositoryImpl(
            LocalMainDataSourceImpl(),
            MainRemoteDataSourceImpl(),
          ),
        ),
        RepositoryProvider<HomeRepositoryImpl>(
          create: (_) => HomeRepositoryImpl(
            RemoteHomeDataSourceImpl(),
            LocalHomeDataSourceImpl(),
          ),
        ),
        RepositoryProvider<TransactionRepositoryImpl>(
          create: (_) =>
              TransactionRepositoryImpl(LocalTransactionDataSourceImpl()),
        ),
        RepositoryProvider<ProfileRepositoryImpl>(
          create: (_) => ProfileRepositoryImpl(
            localDataSource: ProfileLocalDataSourceImpl(),
          ),
        ),
        RepositoryProvider<GraphRepositoryImpl>(
          create: (_) => GraphRepositoryImpl(LocalGraphDataSourceImpl()),
        ),
        RepositoryProvider<FriendRepositoryImpl>(
          create: (_) => FriendRepositoryImpl(
            localDataSource: LocalFriendDataSourceImpl(),
            remoteDataSource: SupabaseFriendRemoteDataSource(
              Supabase.instance.client,
            ),
          ),
        ),
        RepositoryProvider<NotificationRepositoryImpl>(
          create: (_) => NotificationRepositoryImpl(
            localDataSource: LocalNotificationDataSourceImpl(
              FlutterLocalNotificationsPlugin(),
            ),
            remoteDataSource: FirebaseNotificationRemoteDataSource(
              messaging: FirebaseMessaging.instance,
              supabase: Supabase.instance.client,
              appLinks: AppLinks(),
            ),
          ),
        ),
        if (enableCompanySurface)
          RepositoryProvider<CompanyRepositoryImpl>(
            create: (_) => CompanyRepositoryImpl(
              CompanyRemoteDataSourceImpl(),
              LocalCompanyDataSourceImpl(),
            ),
          ),
        if (enableCompanySurface)
          RepositoryProvider<GroupRepositoryImpl>(
            create: (_) => GroupRepositoryImpl(),
          ),
        if (enableCompanySurface)
          RepositoryProvider<ProjectRepositoryImpl>(
            create: (_) => ProjectRepositoryImpl(),
          ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthentificationBloc>(
            create: (context) => AuthentificationBloc(
              authentificationRepository: context
                  .read<AuthentificationRepositoryImpl>(),
            ),
          ),
          BlocProvider<MainBloc>(
            create: (context) => MainBloc(context.read<MainRepositoryImpl>()),
          ),
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(context.read<HomeRepositoryImpl>()),
          ),
          BlocProvider<TransactionBloc>(
            create: (context) =>
                TransactionBloc(context.read<TransactionRepositoryImpl>()),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) =>
                ProfileBloc(context.read<ProfileRepositoryImpl>()),
          ),
          BlocProvider<GraphBloc>(
            create: (context) =>
                GraphBloc(context.read<GraphRepositoryImpl>())
                  ..add(const GraphStarted()),
          ),
          BlocProvider<FriendBloc>(
            create: (context) =>
                FriendBloc(context.read<FriendRepositoryImpl>())
                  ..add(const FriendStarted()),
          ),
          BlocProvider<NotificationBloc>(
            create: (context) =>
                NotificationBloc(context.read<NotificationRepositoryImpl>())
                  ..add(const NotificationBootstrapRequested()),
          ),
          if (enableCompanySurface)
            BlocProvider<CompanyBloc>(
              create: (context) =>
                  CompanyBloc(context.read<CompanyRepositoryImpl>()),
            ),
          if (enableCompanySurface)
            BlocProvider<ListBloc>(
              create: (context) =>
                  ListBloc(context.read<CompanyRepositoryImpl>()),
            ),
          if (enableCompanySurface)
            BlocProvider<DetailBloc>(
              create: (context) =>
                  DetailBloc(context.read<CompanyRepositoryImpl>()),
            ),
          if (enableCompanySurface)
            BlocProvider<GroupBloc>(
              create: (context) =>
                  GroupBloc(context.read<GroupRepositoryImpl>()),
            ),
          if (enableCompanySurface)
            BlocProvider<ProjectBloc>(
              create: (context) =>
                  ProjectBloc(context.read<ProjectRepositoryImpl>()),
            ),
        ],
        child: ToastificationWrapper(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) => MaterialApp.router(
              title: 'Bicount',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
              routerConfig: AppRouter().router,
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en', 'US'), Locale('fr', 'FR')],
            ),
          ),
        ),
      ),
    );
  }
}
