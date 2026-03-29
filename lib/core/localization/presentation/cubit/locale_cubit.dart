import 'package:bicount/core/localization/data/locale_preferences.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppLocalePreference { system, english, french }

class LocaleState extends Equatable {
  const LocaleState({required this.preference});

  const LocaleState.system() : preference = AppLocalePreference.system;

  final AppLocalePreference preference;

  Locale? get locale {
    switch (preference) {
      case AppLocalePreference.system:
        return null;
      case AppLocalePreference.english:
        return const Locale('en');
      case AppLocalePreference.french:
        return const Locale('fr');
    }
  }

  @override
  List<Object?> get props => [preference, locale?.languageCode];
}

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit(this._preferences) : super(const LocaleState.system());

  final LocalePreferences _preferences;

  Future<void> hydrate() async {
    final localeCode = await _preferences.readLocaleCode();
    emit(LocaleState(preference: _fromCode(localeCode)));
  }

  Future<void> selectPreference(AppLocalePreference preference) async {
    await _preferences.saveLocaleCode(_toCode(preference));
    emit(LocaleState(preference: preference));
  }

  AppLocalePreference _fromCode(String? localeCode) {
    switch (localeCode) {
      case 'en':
        return AppLocalePreference.english;
      case 'fr':
        return AppLocalePreference.french;
      default:
        return AppLocalePreference.system;
    }
  }

  String? _toCode(AppLocalePreference preference) {
    switch (preference) {
      case AppLocalePreference.system:
        return null;
      case AppLocalePreference.english:
        return 'en';
      case AppLocalePreference.french:
        return 'fr';
    }
  }
}
