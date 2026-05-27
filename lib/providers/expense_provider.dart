import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/models/expense_model.dart';
import '../data/repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepository();
  final Uuid _uuid = const Uuid();

  bool isLoading = false;
  String? errorMessage;

  String get _currentUserId {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    return user.uid;
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  Stream<List<ExpenseModel>> watchExpenses() {
    return _repository.watchExpenses();
  }

  Stream<List<ExpenseModel>> watchExpensesByMonth(DateTime month) {
    return _repository.watchExpensesByMonth(month: month);
  }

  Future<ExpenseModel?> getExpenseById(String expenseId) async {
    try {
      return await _repository.getExpenseById(expenseId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<bool> addExpense({
    required String title,
    required double amount,
    required String type,
    required String category,
    required DateTime date,
    String note = '',
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final now = DateTime.now();

      final expense = ExpenseModel(
        id: _uuid.v4(),
        userId: _currentUserId,
        title: title.trim(),
        amount: amount,
        type: type,
        category: category.trim(),
        date: date,
        note: note.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _repository.addExpense(expense);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateExpense(ExpenseModel expense) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.updateExpense(
        expense.copyWith(updatedAt: DateTime.now()),
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.deleteExpense(expenseId);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  double totalIncome(List<ExpenseModel> expenses) {
    return expenses
        .where((item) => item.isIncome)
        .fold<double>(0, (total, item) => total + item.amount);
  }

  double totalExpenses(List<ExpenseModel> expenses) {
    return expenses
        .where((item) => item.isExpense)
        .fold<double>(0, (total, item) => total + item.amount);
  }

  Map<String, double> categoryTotals(List<ExpenseModel> expenses) {
    final Map<String, double> totals = {};

    for (final expense in expenses.where((item) => item.isExpense)) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }

    return totals;
  }

  void clearError() {
    _setError(null);
  }
}
