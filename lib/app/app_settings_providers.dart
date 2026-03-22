import 'package:bicount/features/authentification/data/repositories/authentification_repository_impl.dart';
import 'package:bicount/features/settings/data/data_sources/local_datasource/settings_local_datasource.dart';
import 'package:bicount/features/settings/data/data_sources/remote_datasource/settings_remote_datasource.dart';
import 'package:bicount/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:bicount/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<RepositoryProvider> buildSettingsRepositoryProviders() {
  return [
    RepositoryProvider<SettingsRepositoryImpl>(
      create: (context) => SettingsRepositoryImpl(
        localDataSource: SettingsLocalDataSourceImpl(),
        remoteDataSource: SettingsRemoteDataSourceImpl(
          Supabase.instance.client,
        ),
        authentificationRepository: context
            .read<AuthentificationRepositoryImpl>(),
      ),
    ),
  ];
}

List<BlocProvider> buildSettingsBlocProviders() {
  return [
    BlocProvider<ThemeCubit>(
      create: (context) =>
          ThemeCubit(context.read<SettingsRepositoryImpl>())..hydrate(),
    ),
    BlocProvider<SettingsBloc>(
      create: (context) => SettingsBloc(context.read<SettingsRepositoryImpl>()),
    ),
  ];
}
