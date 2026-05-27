import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firebase_collections.dart';
import 'firestore_service.dart';
import '../models/saving_goal_model.dart';

class FirebaseSavingService {
  final FirestoreService _firestoreService = FirestoreService();

  CollectionReference<Map<String, dynamic>> get _savingsRef {
    return _firestoreService.userCollection(FirebaseCollections.savings);
  }

  Future<void> addSavingGoal(SavingGoalModel goal) async {
    await _savingsRef.doc(goal.id).set(goal.toMap());
  }

  Future<void> updateSavingGoal(SavingGoalModel goal) async {
    await _savingsRef
        .doc(goal.id)
        .set(
          goal.copyWith(updatedAt: DateTime.now()).toMap(),
          SetOptions(merge: true),
        );
  }

  Future<SavingGoalModel?> getSavingGoalById(String goalId) async {
    final snapshot = await _savingsRef.doc(goalId).get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return SavingGoalModel.fromMap(snapshot.data()!);
  }

  Stream<List<SavingGoalModel>> watchSavingGoals() {
    return _savingsRef.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return SavingGoalModel.fromMap(doc.data());
      }).toList();
    });
  }

  Future<void> addSavedAmount({
    required String goalId,
    required double amount,
  }) async {
    final goal = await getSavingGoalById(goalId);

    if (goal == null) {
      throw Exception('Saving goal not found');
    }

    await updateSavingGoal(goal.addSaving(amount));
  }

  Future<void> removeSavedAmount({
    required String goalId,
    required double amount,
  }) async {
    final goal = await getSavingGoalById(goalId);

    if (goal == null) {
      throw Exception('Saving goal not found');
    }

    await updateSavingGoal(goal.removeSaving(amount));
  }

  Future<void> deleteSavingGoal(String goalId) async {
    await _savingsRef.doc(goalId).delete();
  }
}
