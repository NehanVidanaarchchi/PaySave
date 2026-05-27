import '../firebase/firebase_saving_service.dart';
import '../models/saving_goal_model.dart';

class SavingRepository {
  final FirebaseSavingService _savingService = FirebaseSavingService();

  Future<void> addSavingGoal(SavingGoalModel goal) async {
    await _savingService.addSavingGoal(goal);
  }

  Future<void> updateSavingGoal(SavingGoalModel goal) async {
    await _savingService.updateSavingGoal(goal);
  }

  Future<SavingGoalModel?> getSavingGoalById(String goalId) async {
    return _savingService.getSavingGoalById(goalId);
  }

  Stream<List<SavingGoalModel>> watchSavingGoals() {
    return _savingService.watchSavingGoals();
  }

  Future<void> addSavedAmount({
    required String goalId,
    required double amount,
  }) async {
    await _savingService.addSavedAmount(goalId: goalId, amount: amount);
  }

  Future<void> removeSavedAmount({
    required String goalId,
    required double amount,
  }) async {
    await _savingService.removeSavedAmount(goalId: goalId, amount: amount);
  }

  Future<void> deleteSavingGoal(String goalId) async {
    await _savingService.deleteSavingGoal(goalId);
  }
}
