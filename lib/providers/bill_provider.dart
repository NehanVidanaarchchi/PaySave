import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/models/bill_model.dart';
import '../data/repositories/bill_repository.dart';

class BillProvider extends ChangeNotifier {
  final BillRepository _repository = BillRepository();
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

  Stream<List<BillModel>> watchBills() {
    return _repository.watchBills();
  }

  Stream<List<BillModel>> watchUpcomingBills() {
    return _repository.watchUpcomingBills();
  }

  Future<BillModel?> getBillById(String billId) async {
    try {
      return await _repository.getBillById(billId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<bool> addBill({
    required String billName,
    required String category,
    required double amount,
    required DateTime dueDate,
    required DateTime reminderDateTime,
    required String repeatType,
    required bool isPaid,
    String note = '',
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final now = DateTime.now();

      final bill = BillModel(
        id: _uuid.v4(),
        userId: _currentUserId,
        billName: billName.trim(),
        category: category.trim(),
        amount: amount,
        dueDate: dueDate,
        reminderDateTime: reminderDateTime,
        repeatType: repeatType,
        isPaid: isPaid,
        note: note.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _repository.addBill(bill);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateBill(BillModel bill) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.updateBill(bill.copyWith(updatedAt: DateTime.now()));

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> markBillPaid(BillModel bill, bool isPaid) async {
    try {
      _setLoading(true);
      _setError(null);

      final updatedBill = bill.copyWith(
        isPaid: isPaid,
        updatedAt: DateTime.now(),
      );

      await _repository.updateBill(updatedBill);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteBill(BillModel bill) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.deleteBill(bill);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  void clearError() {
    _setError(null);
  }
}
