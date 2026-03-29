import 'package:bicount/features/settings/data/models/settings_memoji_model.dart';
import 'package:bicount/features/settings/domain/entities/settings_memoji_page_entity.dart';

class SettingsMemojiPageModel {
  const SettingsMemojiPageModel({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  final List<SettingsMemojiModel> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  factory SettingsMemojiPageModel.fromJson(Map<String, dynamic> json) {
    final pagination = (json['pagination'] as Map<String, dynamic>?) ?? {};
    final data = (json['data'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    return SettingsMemojiPageModel(
      items: data.map(SettingsMemojiModel.fromJson).toList(),
      page: (pagination['page'] as num?)?.toInt() ?? 1,
      limit: (pagination['limit'] as num?)?.toInt() ?? 20,
      total: (pagination['total'] as num?)?.toInt() ?? 0,
      totalPages: (pagination['total_pages'] as num?)?.toInt() ?? 1,
      hasNext: pagination['has_next'] as bool? ?? false,
      hasPrev: pagination['has_prev'] as bool? ?? false,
    );
  }

  factory SettingsMemojiPageModel.fromEntity(SettingsMemojiPageEntity entity) {
    return SettingsMemojiPageModel(
      items: entity.items.map(SettingsMemojiModel.fromEntity).toList(),
      page: entity.page,
      limit: entity.limit,
      total: entity.total,
      totalPages: entity.totalPages,
      hasNext: entity.hasNext,
      hasPrev: entity.hasPrev,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': items.map((item) => item.toJson()).toList(),
      'pagination': {
        'page': page,
        'limit': limit,
        'total': total,
        'total_pages': totalPages,
        'has_next': hasNext,
        'has_prev': hasPrev,
      },
    };
  }

  SettingsMemojiPageEntity toEntity() {
    return SettingsMemojiPageEntity(
      items: items.map((item) => item.toEntity()).toList(),
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages,
      hasNext: hasNext,
      hasPrev: hasPrev,
    );
  }
}
