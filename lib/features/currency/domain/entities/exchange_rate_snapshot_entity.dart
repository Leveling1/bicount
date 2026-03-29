import 'package:equatable/equatable.dart';

class ExchangeRateSnapshotEntity extends Equatable {
  const ExchangeRateSnapshotEntity({
    required this.currencyCode,
    required this.rateDate,
    required this.rateToCdf,
    this.snapshotId,
    this.provider = 'BCC',
    this.sourceUrl,
    this.createdAt,
  });

  final String? snapshotId;
  final String currencyCode;
  final String rateDate;
  final double rateToCdf;
  final String provider;
  final String? sourceUrl;
  final String? createdAt;

  String get cacheKey => '$normalizedRateDate|${currencyCode.toUpperCase()}';

  String get normalizedRateDate {
    if (rateDate.length >= 10) {
      return rateDate.substring(0, 10);
    }
    return rateDate;
  }

  Map<String, dynamic> toJson() {
    return {
      'snapshot_id': snapshotId,
      'currency_code': currencyCode,
      'rate_date': normalizedRateDate,
      'rate_to_cdf': rateToCdf,
      'provider': provider,
      'source_url': sourceUrl,
      'created_at': createdAt,
    };
  }

  factory ExchangeRateSnapshotEntity.fromJson(Map<String, dynamic> json) {
    return ExchangeRateSnapshotEntity(
      snapshotId: json['snapshot_id'] as String?,
      currencyCode: '${json['currency_code'] ?? 'CDF'}'.toUpperCase(),
      rateDate: '${json['rate_date'] ?? ''}',
      rateToCdf: (json['rate_to_cdf'] as num?)?.toDouble() ?? 1,
      provider: '${json['provider'] ?? 'BCC'}',
      sourceUrl: json['source_url'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  static ExchangeRateSnapshotEntity cdf(String rateDate) {
    return ExchangeRateSnapshotEntity(
      snapshotId: 'cdf-$rateDate',
      currencyCode: 'CDF',
      rateDate: rateDate,
      rateToCdf: 1,
      provider: 'SYSTEM',
    );
  }

  @override
  List<Object?> get props => [
    snapshotId,
    currencyCode,
    normalizedRateDate,
    rateToCdf,
    provider,
    sourceUrl,
    createdAt,
  ];
}
