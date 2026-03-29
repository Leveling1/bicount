import 'package:bicount/features/settings/domain/entities/settings_memoji_entity.dart';

class SettingsMemojiModel {
  const SettingsMemojiModel({
    required this.name,
    required this.url,
    required this.size,
    required this.createdAt,
  });

  final String name;
  final String url;
  final int size;
  final String createdAt;

  factory SettingsMemojiModel.fromJson(Map<String, dynamic> json) {
    return SettingsMemojiModel(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  factory SettingsMemojiModel.fromEntity(SettingsMemojiEntity entity) {
    return SettingsMemojiModel(
      name: entity.name,
      url: entity.url,
      size: entity.size,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url, 'size': size, 'created_at': createdAt};
  }

  SettingsMemojiEntity toEntity() {
    return SettingsMemojiEntity(
      name: name,
      url: url,
      size: size,
      createdAt: createdAt,
    );
  }
}
