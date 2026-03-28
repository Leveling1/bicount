import 'package:uuid/uuid.dart';

class DeleteAccountRequestEntity {
  DeleteAccountRequestEntity({
    String? requestId,
    this.reasonCode,
    this.details,
  }) : requestId = requestId ?? const Uuid().v4(),
       super();

  final String? requestId;
  final String? reasonCode;
  final String? details;
}
