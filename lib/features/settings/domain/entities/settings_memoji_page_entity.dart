import 'package:equatable/equatable.dart';

import 'settings_memoji_entity.dart';

class SettingsMemojiPageEntity extends Equatable {
  const SettingsMemojiPageEntity({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  final List<SettingsMemojiEntity> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  SettingsMemojiPageEntity copyWith({
    List<SettingsMemojiEntity>? items,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool? hasNext,
    bool? hasPrev,
  }) {
    return SettingsMemojiPageEntity(
      items: items ?? this.items,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      hasNext: hasNext ?? this.hasNext,
      hasPrev: hasPrev ?? this.hasPrev,
    );
  }

  @override
  List<Object?> get props => [
    items,
    page,
    limit,
    total,
    totalPages,
    hasNext,
    hasPrev,
  ];
}
