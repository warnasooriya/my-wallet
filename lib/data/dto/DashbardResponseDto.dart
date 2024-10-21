class DashbardResponseDto {
  final double totalIncome;
  final double totalExpenses;
  final double totalBudget;
  final double totalBalance;
  final String startDate;
  final String endDate;
  final List<Map<String, dynamic>> expensesList;
  final List<Map<String, dynamic>> incomeList;
  final List<Map<String, dynamic>> incomeVsExpensesList;

  DashbardResponseDto(
      {required this.totalIncome,
      required this.totalExpenses,
      required this.totalBudget,
      required this.totalBalance,
      this.startDate = '',
      this.endDate = '',
      required this.expensesList,
      required this.incomeList,
      required this.incomeVsExpensesList});
}
