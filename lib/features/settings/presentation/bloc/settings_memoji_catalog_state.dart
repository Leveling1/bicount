import 'package:bicount/features/settings/domain/entities/settings_memoji_entity.dart';
import 'package:equatable/equatable.dart';

enum SettingsMemojiCatalogStatus { initial, loading, success, failure }

class SettingsMemojiCatalogState extends Equatable {
  const SettingsMemojiCatalogState({
    this.status = SettingsMemojiCatalogStatus.initial,
    this.items = const [],
    this.page = 0,
    this.hasNext = false,
    this.isLoadingMore = false,
  });

  final SettingsMemojiCatalogStatus status;
  final List<SettingsMemojiEntity> items;
  final int page;
  final bool hasNext;
  final bool isLoadingMore;

  SettingsMemojiCatalogState copyWith({
    SettingsMemojiCatalogStatus? status,
    List<SettingsMemojiEntity>? items,
    int? page,
    bool? hasNext,
    bool? isLoadingMore,
  }) {
    return SettingsMemojiCatalogState(
      status: status ?? this.status,
      items: items ?? this.items,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [status, items, page, hasNext, isLoadingMore];
}
