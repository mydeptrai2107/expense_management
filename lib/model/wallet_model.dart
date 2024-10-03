import 'package:cloud_firestore/cloud_firestore.dart';
import 'enum.dart';

class Wallet {
  final String walletId;
  final String userId;
  final double initialBalance;
  final double currentBalance;
  final String name;
  final String icon;
  final String color;
  final bool excludeFromTotal;
  final DateTime createdAt;
  final bool isDefault;

  Wallet({
    required this.walletId,
    required this.userId,
    required this.initialBalance,
    required this.currentBalance,
    required this.name,
    required this.icon,
    required this.color,
    this.excludeFromTotal = false,
    required this.createdAt,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'walletId': walletId,
      'userId': userId,
      'initialBalance': initialBalance,
      'currentBalance': currentBalance,
      'name': name,
      'icon': icon,
      'color': color,
      'excludeFromTotal': excludeFromTotal,
      'createdAt': createdAt,
      'isDefault': isDefault,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      walletId: map['walletId'],
      userId: map['userId'],
      initialBalance: map['initialBalance'],
      currentBalance: map['currentBalance'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
      excludeFromTotal: map['excludeFromTotal'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isDefault: map['isDefault'],
    );
  }
}
