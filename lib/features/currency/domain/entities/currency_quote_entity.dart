import 'package:equatable/equatable.dart';

class CurrencyQuoteEntity extends Equatable {
  const CurrencyQuoteEntity({
    required this.referenceCurrencyCode,
    required this.convertedAmount,
    required this.amountCdf,
    required this.rateToCdf,
    required this.fxRateDate,
    this.fxSnapshotId,
  });

  final String referenceCurrencyCode;
  final double convertedAmount;
  final double amountCdf;
  final double rateToCdf;
  final String fxRateDate;
  final String? fxSnapshotId;

  @override
  List<Object?> get props => [
    referenceCurrencyCode,
    convertedAmount,
    amountCdf,
    rateToCdf,
    fxRateDate,
    fxSnapshotId,
  ];
}
