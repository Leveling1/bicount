import 'package:bicount/features/currency/data/data_sources/local_datasource/currency_local_datasource.dart';
import 'package:bicount/features/currency/data/data_sources/remote_datasource/currency_remote_datasource.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<RepositoryProvider> buildCurrencyRepositoryProviders() {
  return [
    RepositoryProvider<CurrencyRepositoryImpl>(
      create: (_) => CurrencyRepositoryImpl(
        localDataSource: CurrencyLocalDataSourceImpl(),
        remoteDataSource: CurrencyRemoteDataSourceImpl(
          Supabase.instance.client,
        ),
      ),
      dispose: (repository) => repository.dispose(),
    ),
  ];
}

List<BlocProvider> buildCurrencyBlocProviders() {
  return [
    BlocProvider<CurrencyCubit>(
      create: (context) =>
          CurrencyCubit(context.read<CurrencyRepositoryImpl>())..hydrate(),
    ),
  ];
}
