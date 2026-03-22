import 'package:bicount/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:bicount/features/settings/domain/entities/theme_preference.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeState extends Equatable {
  const ThemeState({required this.preference});

  const ThemeState.system() : preference = AppThemePreference.system;

  final AppThemePreference preference;

  @override
  List<Object?> get props => [preference];
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._repository) : super(const ThemeState.system());

  final SettingsRepositoryImpl _repository;

  Future<void> hydrate() async {
    emit(ThemeState(preference: await _repository.readThemePreference()));
  }

  Future<void> selectPreference(AppThemePreference preference) async {
    await _repository.saveThemePreference(preference);
    emit(ThemeState(preference: preference));
  }
}
