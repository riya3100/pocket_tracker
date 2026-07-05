import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String type,
    required String category,
    required DateTime date,
  }) async {
    await _firestore.collection("transactions").add({
      "title": title,
      "amount": amount,
      "type": type,
      "category": category,
      "date": Timestamp.fromDate(date),
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}