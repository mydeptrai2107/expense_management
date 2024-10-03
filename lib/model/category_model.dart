import 'package:cloud_firestore/cloud_firestore.dart';

import 'enum.dart';

class Category {
  String categoryId;
  String userId;
  String name;
  Type type;
  String icon;
  String color;
  DateTime createdAt;
  bool isDefault;

  Category({
    required this.categoryId,
    required this.userId,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.createdAt,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'userId': userId,
      'name': name,
      'type': type.index,
      'icon': icon,
      'color': color,
      'createdAt': createdAt,
      'isDefault': isDefault,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      categoryId: map['categoryId'],
      userId: map['userId'],
      name: map['name'],
      type: Type.values[map['type']],
      icon: map['icon'],
      color: map['color'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isDefault: map['isDefault'],
    );
  }
}