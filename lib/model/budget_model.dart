import 'package:cloud_firestore/cloud_firestore.dart';
import 'enum.dart';

class Budget {
  String budgetId;
  String userId;
  double amount;
  String name;
  List<String> categoryId;
  List<String> walletId;
  Repeat repeat;
  DateTime startDate;
  DateTime endDate;
  DateTime createdAt;

  Budget({
    required this.budgetId,
    required this.userId,
    required this.amount,
    required this.name,
    required this.categoryId,
    required this.walletId,
    required this.repeat,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'budgetId': budgetId,
      'userId': userId,
      'amount': amount,
      'name': name,
      'categoryId': categoryId,
      'walletId': walletId,
      'repeat': repeat.index,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      budgetId: map['budgetId'],
      userId: map['userId'],
      amount: map['amount'],
      name: map['name'],
      categoryId: List<String>.from(map['categoryId']),
      walletId: List<String>.from(map['walletId']),
      repeat: Repeat.values[map['repeat']],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
