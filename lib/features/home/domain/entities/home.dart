class HomeEntity {
  final double? personalIncome;
  final double? companyIncome;
  final double? profit;

  HomeEntity({
    this.personalIncome,
    this.companyIncome,
    this.profit,
  });

  @override
  int get hashCode => personalIncome.hashCode ^ companyIncome.hashCode ^ profit.hashCode;
}