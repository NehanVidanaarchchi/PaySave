import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/summary_card.dart';
import '../../data/models/monthly_plan_model.dart';
import '../../providers/monthly_plan_provider.dart';
import 'widgets/plan_chart_card.dart';

class MonthlyPlanScreen extends StatelessWidget {
  const MonthlyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MonthlyPlanProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          bottom: false,
          child: StreamBuilder<MonthlyPlanModel?>(
            stream: provider.watchCurrentMonthPlan(),
            builder: (context, snapshot) {
              final plan = snapshot.data;

              if (plan == null) {
                return EmptyState(
                  icon: Icons.pie_chart_rounded,
                  title: 'No monthly plan yet',
                  message:
                      'Create your money margin plan with income, rent, bills, savings, and spending limits.',
                  buttonText: 'Create Plan',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.monthlyPlanSetup);
                  },
                );
              }

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 112),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Planner',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Your monthly money margin',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.monthlyPlanSetup,
                          );
                        },
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _PlannerHeroCard(plan: plan),
                  const SizedBox(height: 18),
                  GridView.count(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.48,
                    children: [
                      SummaryCard(
                        title: 'Income',
                        value: CurrencyHelper.format(plan.monthlyIncome),
                        icon: Icons.trending_up_rounded,
                        color: AppColors.info,
                      ),
                      SummaryCard(
                        title: 'Fixed Costs',
                        value: CurrencyHelper.format(plan.fixedCosts),
                        icon: Icons.lock_rounded,
                        color: AppColors.rent,
                      ),
                      SummaryCard(
                        title: 'Savings',
                        value: CurrencyHelper.format(plan.savingTarget),
                        icon: Icons.savings_rounded,
                        color: AppColors.savings,
                      ),
                      SummaryCard(
                        title: 'Spending',
                        value: CurrencyHelper.format(plan.spendingBudget),
                        icon: Icons.shopping_bag_rounded,
                        color: AppColors.expenses,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PlanChartCard(
                    income: plan.monthlyIncome,
                    rent: plan.rentAmount,
                    bills: plan.billsBudget,
                    savings: plan.savingTarget,
                    food: plan.foodBudget,
                    transport: plan.transportBudget,
                    other: plan.otherBudget,
                  ),
                  const SizedBox(height: 22),
                  CustomButton(
                    text: 'Update Monthly Plan',
                    icon: Icons.edit_rounded,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.monthlyPlanSetup);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PlannerHeroCard extends StatelessWidget {
  final MonthlyPlanModel plan;

  const _PlannerHeroCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final remaining = plan.remainingBalance;
    final isOverBudget = plan.isOverBudget;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isOverBudget
            ? const LinearGradient(
                colors: [Color(0xFFFF7676), Color(0xFFFF4F68)],
              )
            : AppColors.cardPurpleGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: (isOverBudget ? AppColors.danger : AppColors.primary)
                .withOpacity(0.23),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Remaining Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyHelper.format(remaining),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isOverBudget
                ? 'Reduce planned money to stay safe'
                : '${CurrencyHelper.format(plan.dailySafeSpending)} safe spending per day',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
