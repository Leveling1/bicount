import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';

abstract class SalaryRepository {
  Future<void> confirmSalaryOccurrence(SalaryOccurrenceEntity occurrence);
  Future<void> continueSalaryAutomatically(SalaryOccurrenceEntity occurrence);
}
