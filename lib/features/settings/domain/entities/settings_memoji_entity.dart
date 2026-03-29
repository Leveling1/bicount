import 'package:equatable/equatable.dart';

class SettingsMemojiEntity extends Equatable {
  const SettingsMemojiEntity({
    required this.name,
    required this.url,
    required this.size,
    required this.createdAt,
  });

  final String name;
  final String url;
  final int size;
  final String createdAt;

  @override
  List<Object?> get props => [name, url, size, createdAt];
}
