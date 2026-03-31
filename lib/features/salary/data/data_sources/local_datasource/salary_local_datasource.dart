import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';

abstract class SalaryLocalDataSource {
  Future<void> confirmSalaryOccurrence(SalaryOccurrenceEntity occurrence);
  Future<void> continueSalaryAutomatically(SalaryOccurrenceEntity occurrence);
}
