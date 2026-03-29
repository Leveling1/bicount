import 'package:bicount/brick/repository.dart';
import 'package:bicount/core/bloc/bloc_scope.dart';
import 'package:bicount/core/constants/firebase_options.dart';
import 'package:bicount/core/localization/presentation/cubit/locale_cubit.dart';
import 'package:bicount/core/routes/app_router.dart';
import 'package:bicount/core/themes/app_theme.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:bicount/features/settings/domain/entities/theme_preference.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bicount/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:toastification/toastification.dart';

Future<void> bootstrapBicountApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Repository.configure(databaseFactory);
  await Repository().repairRecurringFundingMigrationStateIfNeeded();
  await Repository().repairCurrencyFxMigrationStateIfNeeded();
  await Repository().repairUserReferenceCurrencyMigrationStateIfNeeded();
  await Repository().initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Locale _fallbackLocale = Locale('en');

  @override
  Widget build(BuildContext context) {
    return BlocScope(
      child: ToastificationWrapper(
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                return BlocBuilder<LocaleCubit, LocaleState>(
                  builder: (context, localeState) {
                    return BlocBuilder<CurrencyCubit, CurrencyState>(
                      builder: (context, _) {
                        final resolvedLocale = _resolveLocale(
                          localeState.locale,
                        );
                        Intl.defaultLocale = resolvedLocale.toLanguageTag();

                        return MaterialApp.router(
                          onGenerateTitle: (context) =>
                              AppLocalizations.of(context)?.appName ??
                              'Bicount',
                          debugShowCheckedModeBanner: false,
                          theme: AppTheme.lightTheme,
                          darkTheme: AppTheme.darkTheme,
                          themeMode: themeState.preference.themeMode,
                          routerConfig: AppRouter().router,
                          locale: resolvedLocale,
                          localizationsDelegates:
                              AppLocalizations.localizationsDelegates,
                          supportedLocales: AppLocalizations.supportedLocales,
                          localeListResolutionCallback:
                              (locales, supportedLocales) {
                                if (localeState.locale != null) {
                                  return localeState.locale;
                                }
                                if (locales != null) {
                                  for (final deviceLocale in locales) {
                                    for (final supportedLocale
                                        in supportedLocales) {
                                      if (supportedLocale.languageCode ==
                                          deviceLocale.languageCode) {
                                        return supportedLocale;
                                      }
                                    }
                                  }
                                }
                                return _fallbackLocale;
                              },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Locale _resolveLocale(Locale? selectedLocale) {
    if (selectedLocale != null) {
      return selectedLocale;
    }

    final deviceLocales = WidgetsBinding.instance.platformDispatcher.locales;
    for (final deviceLocale in deviceLocales) {
      for (final supportedLocale in AppLocalizations.supportedLocales) {
        if (supportedLocale.languageCode == deviceLocale.languageCode) {
          return supportedLocale;
        }
      }
    }

    return _fallbackLocale;
  }
}
