import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _transactions {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("transactions");
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String type,
    required String category,
    required DateTime date,
  }) async {
    await _transactions.add({
      "title": title,
      "amount": amount,
      "type": type,
      "category": category,
      "date": Timestamp.fromDate(date),
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTransactions() {
    return _transactions
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Future<void> updateTransaction({
    required String id,
    required String title,
    required double amount,
    required String type,
    required String category,
    required DateTime date,
  }) async {
    await _transactions.doc(id).update({
      "title": title,
      "amount": amount,
      "type": type,
      "category": category,
      "date": Timestamp.fromDate(date),
    });
  }

  Future<void> deleteTransaction(String id) async {
    await _transactions.doc(id).delete();
  }
}