import 'package:flutter/material.dart';
import 'enum.dart';

class Transactions {
  final String transactionId;
  final String userId;
  final double amount;
  final Type type;
  final String walletId;
  final String categoryId;
  final DateTime date;
  final TimeOfDay hour;
  final String note;
  final List<String> images;

  Transactions({
    required this.transactionId,
    required this.userId,
    required this.amount,
    required this.type,
    required this.walletId,
    required this.categoryId,
    required this.date,
    required this.hour,
    this.note = '',
    required this.images,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'userId': userId,
      'amount': amount,
      'type': type.index,
      'walletId': walletId,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'hour': '${hour.hour}:${hour.minute.toString().padLeft(2, '0')}',
      'note': note,
      'images': images,
    };
  }

  factory Transactions.fromMap(Map<String, dynamic> map) {
    return Transactions(
      transactionId: map['transactionId'],
      userId: map['userId'],
      amount: map['amount'],
      type: Type.values[map['type']],
      walletId: map['walletId'],
      categoryId: map['categoryId'],
      date: DateTime.parse(map['date']), // Chuyển đổi từ chuỗi ISO 8601 sang DateTime
      hour: TimeOfDay(
          hour: int.parse(map['hour'].split(':')[0]),
          minute: int.parse(map['hour'].split(':')[1])),
      note: map['note'],
      images: List<String>.from(map['images'] ?? []),
    );
  }
}