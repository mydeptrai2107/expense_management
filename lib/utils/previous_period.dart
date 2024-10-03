import '../model/transaction_model.dart';

class PreviousPeriod {
  final DateTime startDate;
  final DateTime endDate;
  final double totalExpenditure;
  final List<Transactions> transactions;
  final double remainingBudget;
  final bool isOverBudget;

  PreviousPeriod({
    required this.startDate,
    required this.endDate,
    required this.totalExpenditure,
    required this.transactions,
    required this.remainingBudget,
    required this.isOverBudget,
  });
}