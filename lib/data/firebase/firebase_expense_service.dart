import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firebase_collections.dart';
import 'firestore_service.dart';
import '../models/expense_model.dart';

class FirebaseExpenseService {
  final FirestoreService _firestoreService = FirestoreService();

  CollectionReference<Map<String, dynamic>> get _expensesRef {
    return _firestoreService.userCollection(FirebaseCollections.expenses);
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _expensesRef.doc(expense.id).set(expense.toMap());
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _expensesRef
        .doc(expense.id)
        .set(
          expense.copyWith(updatedAt: DateTime.now()).toMap(),
          SetOptions(merge: true),
        );
  }

  Future<ExpenseModel?> getExpenseById(String expenseId) async {
    final snapshot = await _expensesRef.doc(expenseId).get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return ExpenseModel.fromMap(snapshot.data()!);
  }

  Stream<List<ExpenseModel>> watchExpenses() {
    return _expensesRef.orderBy('date', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return ExpenseModel.fromMap(doc.data());
      }).toList();
    });
  }

  Stream<List<ExpenseModel>> watchExpensesByMonth({required DateTime month}) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    return _expensesRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ExpenseModel.fromMap(doc.data());
          }).toList();
        });
  }

  Future<void> deleteExpense(String expenseId) async {
    await _expensesRef.doc(expenseId).delete();
  }
}
