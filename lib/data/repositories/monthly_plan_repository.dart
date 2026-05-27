import '../firebase/firebase_plan_service.dart';
import '../models/monthly_plan_model.dart';

class MonthlyPlanRepository {
  final FirebasePlanService _planService = FirebasePlanService();

  Future<void> saveMonthlyPlan(MonthlyPlanModel plan) async {
    await _planService.saveMonthlyPlan(plan);
  }

  Future<MonthlyPlanModel?> getPlanByMonth(String monthKey) async {
    return _planService.getPlanByMonth(monthKey);
  }

  Stream<MonthlyPlanModel?> watchPlanByMonth(String monthKey) {
    return _planService.watchPlanByMonth(monthKey);
  }

  Stream<List<MonthlyPlanModel>> watchMonthlyPlans() {
    return _planService.watchMonthlyPlans();
  }

  Future<void> deleteMonthlyPlan(String planId) async {
    await _planService.deleteMonthlyPlan(planId);
  }
}
