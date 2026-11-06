import 'package:uuid/uuid.dart';

final _uuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
  r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

/// Old releases sometimes used composite IDs; canonical backend keys are UUIDs.
String canonicalLegacyUuid(String source, String oldId) {
  if (_uuidPattern.hasMatch(oldId)) return oldId;
  return const Uuid().v5(Uuid.NAMESPACE_URL, 'bicount:$source:$oldId');
}
