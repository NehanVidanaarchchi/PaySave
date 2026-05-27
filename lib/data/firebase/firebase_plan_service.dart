import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firebase_collections.dart';
import 'firestore_service.dart';
import '../models/monthly_plan_model.dart';

class FirebasePlanService {
  final FirestoreService _firestoreService = FirestoreService();

  CollectionReference<Map<String, dynamic>> get _plansRef {
    return _firestoreService.userCollection(FirebaseCollections.monthlyPlans);
  }

  Future<void> saveMonthlyPlan(MonthlyPlanModel plan) async {
    await _plansRef
        .doc(plan.id)
        .set(
          plan.copyWith(updatedAt: DateTime.now()).toMap(),
          SetOptions(merge: true),
        );
  }

  Future<MonthlyPlanModel?> getPlanByMonth(String monthKey) async {
    final snapshot = await _plansRef
        .where('monthKey', isEqualTo: monthKey)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return MonthlyPlanModel.fromMap(snapshot.docs.first.data());
  }

  Stream<MonthlyPlanModel?> watchPlanByMonth(String monthKey) {
    return _plansRef
        .where('monthKey', isEqualTo: monthKey)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return null;
          }

          return MonthlyPlanModel.fromMap(snapshot.docs.first.data());
        });
  }

  Stream<List<MonthlyPlanModel>> watchMonthlyPlans() {
    return _plansRef.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return MonthlyPlanModel.fromMap(doc.data());
      }).toList();
    });
  }

  Future<void> deleteMonthlyPlan(String planId) async {
    await _plansRef.doc(planId).delete();
  }
}
