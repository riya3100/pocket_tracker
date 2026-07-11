import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';

class BudgetService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;


  Future<void> addBudget(
      String userId,
      BudgetModel budget) async {

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('budget')
        .doc('current')
        .set(budget.toMap());
  }


  Stream<BudgetModel?> getBudget(
      String userId) {

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budget')
        .doc('current')
        .snapshots()
        .map((doc) {

      if (doc.exists) {
        return BudgetModel.fromFirestore(doc);
      }

      return null;
    });
  }


  Future<void> deleteBudget(
      String userId) async {

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('budget')
        .doc('current')
        .delete();
  }
}