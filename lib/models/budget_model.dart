import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String id;
  final double monthlyLimit;
  final String month;
  final Timestamp createdAt;

  BudgetModel({
    required this.id,
    required this.monthlyLimit,
    required this.month,
    required this.createdAt,
  });

  factory BudgetModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return BudgetModel(
      id: doc.id,
      monthlyLimit: (data['monthlyLimit'] ?? 0).toDouble(),
      month: data['month'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monthlyLimit': monthlyLimit,
      'month': month,
      'createdAt': createdAt,
    };
  }
}