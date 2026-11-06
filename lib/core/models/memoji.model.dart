import 'package:bicount/core/offline/offline_model.dart';
import 'package:uuid/uuid.dart';

class MemojiModel extends OfflineModel {
  final String name;
  final String link;
  final String sexe;

  final String? mid;

  MemojiModel({
    String? mid,
    required this.name,
    required this.link,
    required this.sexe,
  }) : mid = mid ?? const Uuid().v4(),
       super();
}
