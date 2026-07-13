import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/models/money_record_model.dart';
import '../data/repositories/money_record_repository.dart';

class MoneySummary {
  final double income;
  final double bills;
  final double expenses;
  final double savings;
  final double installments;
  final double remainingBalance;
  final double dailySafeSpending;

  const MoneySummary({
    required this.income,
    required this.bills,
    required this.expenses,
    required this.savings,
    required this.installments,
    required this.remainingBalance,
    required this.dailySafeSpending,
  });

  bool get isOverBudget => remainingBalance < 0;

  double get totalOut {
    return bills + expenses + savings + installments;
  }
}

class MoneyRecordProvider extends ChangeNotifier {
  final MoneyRecordRepository _repository = MoneyRecordRepository();
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

  Stream<List<MoneyRecordModel>> watchRecords() {
    return _repository.watchRecords();
  }

  Stream<List<MoneyRecordModel>> watchCurrentMonthRecords() {
    return _repository.watchRecordsByMonth(DateTime.now());
  }

  Future<bool> addMoneyRecord({
    required String title,
    required double amount,
    required String type,
    required String category,
    required DateTime date,
    String note = '',
    bool isPaid = false,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final now = DateTime.now();

      final record = MoneyRecordModel(
        id: _uuid.v4(),
        userId: _currentUserId,
        title: title.trim(),
        amount: amount,
        type: type,
        category: category.trim(),
        date: date,
        note: note.trim(),
        isPaid: isPaid,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.addRecord(record);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> addInstallmentPlan({
    required String title,
    required double totalAmount,
    required int months,
    required DateTime firstDueDate,
    String note = '',
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final now = DateTime.now();
      final groupId = _uuid.v4();
      final monthlyAmount = totalAmount / months;

      final records = List.generate(months, (index) {
        final paymentDate = _addMonths(firstDueDate, index);

        return MoneyRecordModel(
          id: _uuid.v4(),
          userId: _currentUserId,
          title: '$title (${index + 1}/$months)',
          amount: monthlyAmount,
          type: MoneyRecordModel.typeInstallment,
          category: 'Installment',
          date: paymentDate,
          note: note.trim(),
          isPaid: false,
          installmentGroupId: groupId,
          installmentIndex: index + 1,
          installmentMonths: months,
          createdAt: now,
          updatedAt: now,
        );
      });

      await _repository.addRecords(records);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  MoneySummary summaryFromRecords(List<MoneyRecordModel> records) {
    double income = 0;
    double bills = 0;
    double expenses = 0;
    double savings = 0;
    double installments = 0;

    for (final record in records) {
      if (record.isIncome) {
        income += record.amount;
      } else if (record.isBill) {
        bills += record.amount;
      } else if (record.isExpense) {
        expenses += record.amount;
      } else if (record.isSaving) {
        savings += record.amount;
      } else if (record.isInstallment) {
        installments += record.amount;
      }
    }

    final remaining = income - bills - expenses - savings - installments;

    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final remainingDays = (lastDay - now.day + 1).clamp(1, 31);
    final dailySafe = remaining / remainingDays;

    return MoneySummary(
      income: income,
      bills: bills,
      expenses: expenses,
      savings: savings,
      installments: installments,
      remainingBalance: remaining,
      dailySafeSpending: dailySafe,
    );
  }

  List<MoneyRecordModel> upcomingReminders(List<MoneyRecordModel> records) {
    final now = DateTime.now();

    final reminders = records.where((record) {
      final isReminderType = record.isBill || record.isInstallment;
      return isReminderType && !record.isPaid && record.date.isAfter(now);
    }).toList();

    reminders.sort((a, b) => a.date.compareTo(b.date));

    return reminders.take(5).toList();
  }

  Future<bool> markPaid(MoneyRecordModel record) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.updateRecord(
        record.copyWith(
          isPaid: true,
          updatedAt: DateTime.now(),
        ),
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteRecord(String recordId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.deleteRecord(recordId);

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

  DateTime _addMonths(DateTime date, int monthsToAdd) {
    return DateTime(
      date.year,
      date.month + monthsToAdd,
      date.day,
      date.hour,
      date.minute,
    );
  }
}