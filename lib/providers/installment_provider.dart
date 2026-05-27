import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/models/installment_model.dart';
import '../data/repositories/installment_repository.dart';

class InstallmentProvider extends ChangeNotifier {
  final InstallmentRepository _repository = InstallmentRepository();
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

  Stream<List<InstallmentModel>> watchInstallments() {
    return _repository.watchInstallments();
  }

  Stream<List<InstallmentModel>> watchActiveInstallments() {
    return _repository.watchActiveInstallments();
  }

  Future<InstallmentModel?> getInstallmentById(String installmentId) async {
    try {
      return await _repository.getInstallmentById(installmentId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<bool> addInstallment({
    required String purchaseName,
    required String provider,
    required double totalAmount,
    required int installmentCount,
    required DateTime firstPaymentDate,
    required DateTime reminderTime,
    String note = '',
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final installment = InstallmentModel.createWithPayments(
        id: _uuid.v4(),
        userId: _currentUserId,
        purchaseName: purchaseName.trim(),
        provider: provider.trim(),
        totalAmount: totalAmount,
        installmentCount: installmentCount,
        firstPaymentDate: firstPaymentDate,
        reminderTime: reminderTime,
        note: note.trim(),
      );

      await _repository.addInstallment(installment);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateInstallment(InstallmentModel installment) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.updateInstallment(
        installment.copyWith(updatedAt: DateTime.now()),
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> markPaymentPaid({
    required InstallmentModel installment,
    required String paymentId,
    required bool isPaid,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final updatedPayments = installment.payments.map((payment) {
        if (payment.id == paymentId) {
          return payment.copyWith(isPaid: isPaid);
        }

        return payment;
      }).toList();

      final updatedInstallment = installment.copyWith(
        payments: updatedPayments,
        updatedAt: DateTime.now(),
      );

      await _repository.updateInstallment(updatedInstallment);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteInstallment(InstallmentModel installment) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.deleteInstallment(installment);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  double calculateUpcomingInstallmentTotal(
    List<InstallmentModel> installments,
  ) {
    double total = 0;

    for (final installment in installments) {
      final nextPayment = installment.nextPayment;
      if (nextPayment != null) {
        total += nextPayment.amount;
      }
    }

    return total;
  }

  void clearError() {
    _setError(null);
  }
}
