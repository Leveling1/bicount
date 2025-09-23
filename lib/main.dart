import 'package:bicount/core/constants/secrets.dart';
import 'package:bicount/core/routes/app_router.dart';
import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/features/authentification/data/data_sources/remote_datasource/supabase_authentification.dart';
import 'package:bicount/features/authentification/data/repositories/authentification_repository_impl.dart';
import 'package:bicount/features/authentification/presentation/bloc/authentification_bloc.dart';
import 'package:bicount/features/company/data/repositories/company_repository_impl.dart';
import 'package:bicount/features/company/presentation/bloc/company_bloc.dart';
import 'package:bicount/features/home/data/repositories/home_repository_impl.dart';
import 'package:bicount/features/home/presentation/bloc/home_bloc.dart';
import 'package:bicount/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:bicount/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

import 'features/group/data/repositories/group_repository_impl.dart';
import 'features/group/presentation/bloc/group_bloc.dart';
import 'features/project/data/repositories/project_repository_impl.dart';
import 'features/project/presentation/bloc/project_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Secrets.supabaseProjectUrl,
    anonKey: Secrets.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthentificationRepositoryImpl>(
          create: (_) => AuthentificationRepositoryImpl(
            SupabaseAuthentification(Supabase.instance.client),
          ),
        ),
        RepositoryProvider<HomeRepositoryImpl>(
          create: (_) => HomeRepositoryImpl(),
        ),
        RepositoryProvider<CompanyRepositoryImpl>(
          create: (_) => CompanyRepositoryImpl(),
        ),
        RepositoryProvider<TransactionRepositoryImpl>(
          create: (_) => TransactionRepositoryImpl(),
        ),
        RepositoryProvider<GroupRepositoryImpl>(
          create: (_) => GroupRepositoryImpl(),
        ),
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
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(HomeRepositoryImpl())
          ),
          BlocProvider<CompanyBloc>(
            create: (context) => CompanyBloc(CompanyRepositoryImpl())
          ),
          BlocProvider<TransactionBloc>(
            create: (context) =>
                TransactionBloc(context.read<TransactionRepositoryImpl>())
                  ..add(GetAllTransactionsRequested()),
          ),
          BlocProvider<GroupBloc>(
            create: (context) =>
            GroupBloc(context.read<GroupRepositoryImpl>()),
          ),
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
