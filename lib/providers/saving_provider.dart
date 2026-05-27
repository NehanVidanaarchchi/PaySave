import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/models/saving_goal_model.dart';
import '../data/repositories/saving_repository.dart';

class SavingProvider extends ChangeNotifier {
  final SavingRepository _repository = SavingRepository();
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

  Stream<List<SavingGoalModel>> watchSavingGoals() {
    return _repository.watchSavingGoals();
  }

  Future<SavingGoalModel?> getSavingGoalById(String goalId) async {
    try {
      return await _repository.getSavingGoalById(goalId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<bool> addSavingGoal({
    required String goalName,
    required double targetAmount,
    required double savedAmount,
    required double monthlyTarget,
    required DateTime targetDate,
    String note = '',
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final now = DateTime.now();

      final goal = SavingGoalModel(
        id: _uuid.v4(),
        userId: _currentUserId,
        goalName: goalName.trim(),
        targetAmount: targetAmount,
        savedAmount: savedAmount,
        monthlyTarget: monthlyTarget,
        targetDate: targetDate,
        note: note.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _repository.addSavingGoal(goal);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateSavingGoal(SavingGoalModel goal) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.updateSavingGoal(
        goal.copyWith(updatedAt: DateTime.now()),
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> addSavedAmount({
    required String goalId,
    required double amount,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.addSavedAmount(goalId: goalId, amount: amount);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> removeSavedAmount({
    required String goalId,
    required double amount,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.removeSavedAmount(goalId: goalId, amount: amount);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteSavingGoal(String goalId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.deleteSavingGoal(goalId);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  double calculateTotalSaved(List<SavingGoalModel> goals) {
    return goals.fold<double>(0, (total, goal) => total + goal.savedAmount);
  }

  double calculateMonthlySavingTarget(List<SavingGoalModel> goals) {
    return goals.fold<double>(0, (total, goal) => total + goal.monthlyTarget);
  }

  void clearError() {
    _setError(null);
  }
}
