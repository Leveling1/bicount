import 'package:uuid/uuid.dart';

class DeleteAccountRequestEntity {
  DeleteAccountRequestEntity({
    String? requestId,
    required this.reasonCode,
    required this.details,
  }) : requestId = requestId ?? const Uuid().v4(),
       super();

  final String? requestId;
  final String reasonCode;
  final String details;
}
