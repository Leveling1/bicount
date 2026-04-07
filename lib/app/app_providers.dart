import 'package:app_links/app_links.dart';
import 'package:bicount/app/app_currency_providers.dart';
import 'package:bicount/app/app_settings_providers.dart';
import 'package:bicount/core/localization/data/locale_preferences.dart';
import 'package:bicount/core/localization/presentation/cubit/locale_cubit.dart';
import 'package:bicount/features/authentification/data/data_sources/local_datasource/local_authentification.dart';
import 'package:bicount/features/authentification/data/data_sources/remote_datasource/supabase_authentification.dart';
import 'package:bicount/features/authentification/data/repositories/authentification_repository_impl.dart';
import 'package:bicount/features/authentification/presentation/bloc/authentification_bloc.dart';
import 'package:bicount/features/company/data/data_sources/local_datasource/local_company_data_source_impl.dart';
import 'package:bicount/features/company/data/data_sources/remote_datasource/company_remote_data_source_impl.dart';
import 'package:bicount/features/company/data/repositories/company_repository_impl.dart';
import 'package:bicount/features/company/presentation/bloc/company_bloc.dart';
import 'package:bicount/features/company/presentation/bloc/detail_bloc/detail_bloc.dart';
import 'package:bicount/features/company/presentation/bloc/list_bloc/list_bloc.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/friend/data/data_sources/local_datasource/local_friend_data_source_impl.dart';
import 'package:bicount/features/friend/data/data_sources/remote_datasource/supabase_friend_remote_data_source.dart';
import 'package:bicount/features/friend/data/repositories/friend_repository_impl.dart';
import 'package:bicount/features/friend/presentation/bloc/friend_bloc.dart';
import 'package:bicount/features/graph/presentation/bloc/graph_bloc.dart';
import 'package:bicount/features/group/data/repositories/group_repository_impl.dart';
import 'package:bicount/features/group/presentation/bloc/group_bloc.dart';
import 'package:bicount/features/home/data/data_sources/local_datasource/local_home_data_source_impl.dart';
import 'package:bicount/features/home/data/data_sources/remote_datasource/remote_home_data_source_impl.dart';
import 'package:bicount/features/home/data/repositories/home_repository_impl.dart';
import 'package:bicount/features/home/presentation/bloc/home_bloc.dart';
import 'package:bicount/features/main/data/data_sources/local_datasource/local_main_data_source_impl.dart';
import 'package:bicount/features/main/data/data_sources/remote_datasource/main_remote_data_source_impl.dart';
import 'package:bicount/features/main/data/repositories/main_repository_impl.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/notification/data/data_sources/local_datasource/local_notification_data_source_impl.dart';
import 'package:bicount/features/notification/data/data_sources/remote_datasource/firebase_notification_remote_data_source.dart';
import 'package:bicount/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:bicount/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:bicount/features/project/data/repositories/project_repository_impl.dart';
import 'package:bicount/features/project/presentation/bloc/project_bloc.dart';
import 'package:bicount/features/salary/data/data_sources/local_datasource/local_salary_data_source_impl.dart';
import 'package:bicount/features/salary/data/repositories/salary_repository_impl.dart';
import 'package:bicount/features/salary/presentation/bloc/salary_bloc.dart';
import 'package:bicount/features/add_fund/data/data_sources/local_datasource/local_add_fund_data_source_impl.dart';
import 'package:bicount/features/add_fund/data/repositories/add_fund_repository_impl.dart';
import 'package:bicount/features/add_fund/presentation/bloc/add_fund_bloc.dart';
import 'package:bicount/features/subscription/data/data_sources/local_datasource/local_subscription_data_source_impl.dart';
import 'package:bicount/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:bicount/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/local_transaction_data_source_impl.dart';
import 'package:bicount/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:bicount/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<RepositoryProvider> buildRepositoryProviders(bool enableCompanySurface) {
  return [
    RepositoryProvider<LocalePreferences>(create: (_) => LocalePreferences()),
    ...buildCurrencyRepositoryProviders(),
    RepositoryProvider<AuthentificationRepositoryImpl>(
      create: (_) => AuthentificationRepositoryImpl(
        LocalAuthentification(),
        SupabaseAuthentification(Supabase.instance.client),
      ),
    ),
    ...buildSettingsRepositoryProviders(),
    RepositoryProvider<MainRepositoryImpl>(
      create: (context) => MainRepositoryImpl(
        LocalMainDataSourceImpl(),
        MainRemoteDataSourceImpl(),
        currencyRepository: context.read<CurrencyRepositoryImpl>(),
      ),
    ),
    RepositoryProvider<HomeRepositoryImpl>(
      create: (_) => HomeRepositoryImpl(
        RemoteHomeDataSourceImpl(),
        LocalHomeDataSourceImpl(),
      ),
    ),
    RepositoryProvider<TransactionRepositoryImpl>(
      create: (context) => TransactionRepositoryImpl(
        LocalTransactionDataSourceImpl(
          currencyRepository: context.read<CurrencyRepositoryImpl>(),
        ),
      ),
    ),
    RepositoryProvider<SubscriptionRepositoryImpl>(
      create: (context) => SubscriptionRepositoryImpl(
        localDataSource: LocalSubscriptionDataSourceImpl(
          currencyRepository: context.read<CurrencyRepositoryImpl>(),
        ),
      ),
    ),
    RepositoryProvider<AddFundRepositoryImpl>(
      create: (context) => AddFundRepositoryImpl(
        localDataSource: LocalAddFundDataSourceImpl(
          currencyRepository: context.read<CurrencyRepositoryImpl>(),
        ),
      ),
    ),
    RepositoryProvider<SalaryRepositoryImpl>(
      create: (context) => SalaryRepositoryImpl(
        localDataSource: LocalSalaryDataSourceImpl(
          currencyRepository: context.read<CurrencyRepositoryImpl>(),
        ),
      ),
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
  ];
}

List<BlocProvider> buildBlocProviders(bool enableCompanySurface) {
  return [
    BlocProvider<LocaleCubit>(
      create: (context) =>
          LocaleCubit(context.read<LocalePreferences>())..hydrate(),
    ),
    ...buildCurrencyBlocProviders(),
    ...buildSettingsBlocProviders(),
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
    BlocProvider<SubscriptionBloc>(
      create: (context) =>
          SubscriptionBloc(context.read<SubscriptionRepositoryImpl>()),
    ),
    BlocProvider<AddFundBloc>(
      create: (context) => AddFundBloc(context.read<AddFundRepositoryImpl>()),
    ),
    BlocProvider<SalaryBloc>(
      create: (context) => SalaryBloc(context.read<SalaryRepositoryImpl>()),
    ),
    BlocProvider<GraphBloc>(
      create: (context) => GraphBloc(
        mainBloc: context.read<MainBloc>(),
        currencyRepository: context.read<CurrencyRepositoryImpl>(),
      )..add(const GraphStarted()),
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
        create: (context) => CompanyBloc(context.read<CompanyRepositoryImpl>()),
      ),
    if (enableCompanySurface)
      BlocProvider<ListBloc>(
        create: (context) => ListBloc(context.read<CompanyRepositoryImpl>()),
      ),
    if (enableCompanySurface)
      BlocProvider<DetailBloc>(
        create: (context) => DetailBloc(context.read<CompanyRepositoryImpl>()),
      ),
    if (enableCompanySurface)
      BlocProvider<GroupBloc>(
        create: (context) => GroupBloc(context.read<GroupRepositoryImpl>()),
      ),
    if (enableCompanySurface)
      BlocProvider<ProjectBloc>(
        create: (context) => ProjectBloc(context.read<ProjectRepositoryImpl>()),
      ),
  ];
}
