import 'package:bicount/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'settings_memoji_catalog_state.dart';

class SettingsMemojiCatalogCubit extends Cubit<SettingsMemojiCatalogState> {
  SettingsMemojiCatalogCubit(this._repository)
    : super(const SettingsMemojiCatalogState());

  final SettingsRepositoryImpl _repository;
  static const _pageLimit = 20;

  Future<void> hydrate() async {
    final cachedPage = await _repository.readCachedMemojiPage();
    if (cachedPage != null && cachedPage.items.isNotEmpty) {
      emit(
        state.copyWith(
          status: SettingsMemojiCatalogStatus.success,
          items: cachedPage.items,
          page: cachedPage.page,
          hasNext: cachedPage.hasNext,
          isLoadingMore: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: SettingsMemojiCatalogStatus.loading,
          isLoadingMore: false,
        ),
      );
    }

    try {
      final freshPage = await _repository.fetchMemojiPage(
        page: 1,
        limit: _pageLimit,
      );
      emit(
        state.copyWith(
          status: SettingsMemojiCatalogStatus.success,
          items: freshPage.items,
          page: freshPage.page,
          hasNext: freshPage.hasNext,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      if (state.items.isEmpty) {
        emit(
          state.copyWith(
            status: SettingsMemojiCatalogStatus.failure,
            isLoadingMore: false,
          ),
        );
      }
    }
  }

  Future<void> retry() async {
    emit(
      state.copyWith(
        status: SettingsMemojiCatalogStatus.loading,
        items: const [],
        page: 0,
        hasNext: false,
        isLoadingMore: false,
      ),
    );
    await hydrate();
  }

  Future<void> loadMore() async {
    if (state.status != SettingsMemojiCatalogStatus.success ||
        !state.hasNext ||
        state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));
    try {
      final nextPage = await _repository.fetchMemojiPage(
        page: state.page + 1,
        limit: _pageLimit,
      );
      emit(
        state.copyWith(
          status: SettingsMemojiCatalogStatus.success,
          items: nextPage.items,
          page: nextPage.page,
          hasNext: nextPage.hasNext,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }
}
