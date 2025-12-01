import 'package:flutter/material.dart';

class OtherTheme extends ThemeExtension<OtherTheme> {
  final Color? income;
  final Color? expense;
  final Color? personnalIncome;
  final Color? companyIncome;
  final Color? salary;
  final Color? equipment;
  final Color? service;

  const OtherTheme({
    this.income,
    this.expense,
    this.personnalIncome,
    this.companyIncome,
    this.salary,
    this.equipment,
    this.service,
  });

  @override
  OtherTheme copyWith({
    LinearGradient? primaryGradient,
    LinearGradient? secondaryGradient,
  }) {
    return OtherTheme(
      income: income ?? income,
      expense: expense ?? expense,
      personnalIncome: personnalIncome ?? personnalIncome,
      companyIncome: companyIncome ?? companyIncome,
      salary: salary ?? salary,
      equipment: equipment ?? equipment,
      service: service ?? service,
    );
  }

  @override
  ThemeExtension<OtherTheme> lerp(
    covariant ThemeExtension<OtherTheme>? other,
    double t,
  ) {
    if (other is! OtherTheme) return this;
    return OtherTheme(
      income: Color.lerp(income, other.income, t),
      expense: Color.lerp(expense, other.expense, t),
      personnalIncome: Color.lerp(personnalIncome, other.personnalIncome, t),
      companyIncome: Color.lerp(companyIncome, other.companyIncome, t),
      salary: Color.lerp(salary, other.salary, t),
      equipment: Color.lerp(equipment, other.equipment, t),
      service: Color.lerp(service, other.service, t),
    );
  }
}
