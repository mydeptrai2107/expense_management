import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'enum.dart';

class Bill {
  String billId;
  String userId;
  String name;
  Repeat repeat;
  DateTime date;
  TimeOfDay hour;
  String note;
  bool isActive;
  DateTime createdAt;

  Bill({
    required this.billId,
    required this.userId,
    required this.name,
    required this.repeat,
    required this.date,
    required this.hour,
    this.note = '',
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'billId': billId,
      'userId': userId,
      'name': name,
      'repeat': repeat.index,
      'date': date.toIso8601String(),
      'hour': '${hour.hour}:${hour.minute.toString().padLeft(2, '0')}',
      'note': note,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      billId: map['billId'],
      userId: map['userId'],
      name: map['name'],
      repeat: Repeat.values[map['repeat']],
      date: DateTime.parse(map['date']),
      hour: TimeOfDay(
          hour: int.parse(map['hour'].split(':')[0]),
          minute: int.parse(map['hour'].split(':')[1])),
      note: map['note'],
      isActive: map['isActive'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}