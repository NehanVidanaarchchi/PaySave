import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/models/monthly_plan_model.dart';
import '../data/repositories/monthly_plan_repository.dart';

class MonthlyPlanProvider extends ChangeNotifier {
  final MonthlyPlanRepository _repository = MonthlyPlanRepository();
  final Uuid _uuid = const Uuid();

  MonthlyPlanModel? currentPlan;
  bool isLoading = false;
  String? errorMessage;

  String get _currentUserId {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    return user.uid;
  }

  String monthKeyFromDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  String get currentMonthKey {
    return monthKeyFromDate(DateTime.now());
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  Stream<MonthlyPlanModel?> watchCurrentMonthPlan() {
    return _repository.watchPlanByMonth(currentMonthKey);
  }

  Stream<List<MonthlyPlanModel>> watchMonthlyPlans() {
    return _repository.watchMonthlyPlans();
  }

  Future<void> loadCurrentMonthPlan() async {
    try {
      _setLoading(true);
      _setError(null);

      currentPlan = await _repository.getPlanByMonth(currentMonthKey);

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
    }
  }

  Future<bool> saveMonthlyPlan({
    required double monthlyIncome,
    required double rentAmount,
    required double billsBudget,
    required double savingTarget,
    required double foodBudget,
    required double transportBudget,
    required double otherBudget,
    DateTime? month,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final now = DateTime.now();
      final selectedMonth = month ?? now;
      final monthKey = monthKeyFromDate(selectedMonth);

      final existingPlan = await _repository.getPlanByMonth(monthKey);

      final plan = MonthlyPlanModel(
        id: existingPlan?.id ?? _uuid.v4(),
        userId: _currentUserId,
        monthKey: monthKey,
        monthlyIncome: monthlyIncome,
        rentAmount: rentAmount,
        billsBudget: billsBudget,
        savingTarget: savingTarget,
        foodBudget: foodBudget,
        transportBudget: transportBudget,
        otherBudget: otherBudget,
        createdAt: existingPlan?.createdAt ?? now,
        updatedAt: now,
      );

      await _repository.saveMonthlyPlan(plan);

      currentPlan = plan;

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteMonthlyPlan(String planId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.deleteMonthlyPlan(planId);

      if (currentPlan?.id == planId) {
        currentPlan = null;
      }

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
