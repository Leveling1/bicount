import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/salary/data/data_sources/local_datasource/salary_local_datasource.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';
import 'package:bicount/features/salary/domain/repositories/salary_repository.dart';

class SalaryRepositoryImpl implements SalaryRepository {
  SalaryRepositoryImpl({required this.localDataSource});

  final SalaryLocalDataSource localDataSource;

  @override
  Future<void> confirmSalaryOccurrence(
    SalaryOccurrenceEntity occurrence,
  ) async {
    try {
      await localDataSource.confirmSalaryOccurrence(occurrence);
    } catch (_) {
      throw MessageFailure(
        message: 'Unable to confirm this salary payment right now.',
      );
    }
  }

  @override
  Future<void> continueSalaryAutomatically(
    SalaryOccurrenceEntity occurrence,
  ) async {
    try {
      await localDataSource.continueSalaryAutomatically(occurrence);
    } catch (_) {
      throw MessageFailure(
        message: 'Unable to update this salary tracking right now.',
      );
    }
  }
}
