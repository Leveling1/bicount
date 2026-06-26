import 'package:flutter/material.dart';

class OtherTheme extends ThemeExtension<OtherTheme> {
  final Color? income;
  final Color? expense;
  final Color? personnalIncome;
  final Color? companyIncome;
  final Color? salary;
  final Color? equipment;
  final Color? service;
  final Color? error;
  final Color? success;
  final Color? analysisRevenue;
  final Color? analysisSalary;
  final Color? analysisExpense;
  final Color? analysisSubscription;
  final Color? analysisDebt;
  final Color? analysisRepayment;
  final Color? analysisOther;

  const OtherTheme({
    this.income,
    this.expense,
    this.personnalIncome,
    this.companyIncome,
    this.salary,
    this.equipment,
    this.service,
    this.error,
    this.success,
    this.analysisRevenue,
    this.analysisSalary,
    this.analysisExpense,
    this.analysisSubscription,
    this.analysisDebt,
    this.analysisRepayment,
    this.analysisOther,
  });

  @override
  OtherTheme copyWith({
    Color? income,
    Color? expense,
    Color? personnalIncome,
    Color? companyIncome,
    Color? salary,
    Color? equipment,
    Color? service,
    Color? error,
    Color? success,
    Color? analysisRevenue,
    Color? analysisSalary,
    Color? analysisExpense,
    Color? analysisSubscription,
    Color? analysisDebt,
    Color? analysisRepayment,
    Color? analysisOther,
  }) {
    return OtherTheme(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      personnalIncome: personnalIncome ?? this.personnalIncome,
      companyIncome: companyIncome ?? this.companyIncome,
      salary: salary ?? this.salary,
      equipment: equipment ?? this.equipment,
      service: service ?? this.service,
      error: error ?? this.error,
      success: success ?? this.success,
      analysisRevenue: analysisRevenue ?? this.analysisRevenue,
      analysisSalary: analysisSalary ?? this.analysisSalary,
      analysisExpense: analysisExpense ?? this.analysisExpense,
      analysisSubscription:
          analysisSubscription ?? this.analysisSubscription,
      analysisDebt: analysisDebt ?? this.analysisDebt,
      analysisRepayment: analysisRepayment ?? this.analysisRepayment,
      analysisOther: analysisOther ?? this.analysisOther,
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
      error: Color.lerp(error, other.error, t),
      success: Color.lerp(success, other.success, t),
      analysisRevenue: Color.lerp(
        analysisRevenue,
        other.analysisRevenue,
        t,
      ),
      analysisSalary: Color.lerp(analysisSalary, other.analysisSalary, t),
      analysisExpense: Color.lerp(analysisExpense, other.analysisExpense, t),
      analysisSubscription: Color.lerp(
        analysisSubscription,
        other.analysisSubscription,
        t,
      ),
      analysisDebt: Color.lerp(analysisDebt, other.analysisDebt, t),
      analysisRepayment: Color.lerp(
        analysisRepayment,
        other.analysisRepayment,
        t,
      ),
      analysisOther: Color.lerp(analysisOther, other.analysisOther, t),
    );
  }
}
