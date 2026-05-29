import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/monthly_plan_model.dart';
import '../../data/models/saving_goal_model.dart';
import '../../providers/bill_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/monthly_plan_provider.dart';
import '../../providers/saving_provider.dart';
import '../reports/widgets/monthly_summary_chart.dart';
import '../reports/widgets/report_card.dart';
import '../reports/widgets/spending_pie_chart.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  double _totalPaidBills(List<BillModel> bills) {
    return bills
        .where((bill) => bill.isPaid)
        .fold<double>(0, (total, bill) => total + bill.amount);
  }

  double _totalUnpaidBills(List<BillModel> bills) {
    return bills
        .where((bill) => !bill.isPaid)
        .fold<double>(0, (total, bill) => total + bill.amount);
  }

  double _totalSaved(List<SavingGoalModel> goals) {
    return goals.fold<double>(0, (total, goal) => total + goal.savedAmount);
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = context.read<MonthlyPlanProvider>();
    final expenseProvider = context.read<ExpenseProvider>();
    final billProvider = context.read<BillProvider>();
    final savingProvider = context.read<SavingProvider>();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<MonthlyPlanModel?>(
          stream: planProvider.watchCurrentMonthPlan(),
          builder: (context, planSnapshot) {
            final plan = planSnapshot.data;

            return StreamBuilder<List<ExpenseModel>>(
              stream: expenseProvider.watchExpensesByMonth(DateTime.now()),
              builder: (context, expenseSnapshot) {
                if (expenseSnapshot.hasError) {
                  return ErrorView(message: expenseSnapshot.error.toString());
                }

                if (expenseSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const LoadingView(message: 'Loading reports...');
                }

                final expenses = expenseSnapshot.data ?? [];
                final totalIncomeRecords = expenseProvider.totalIncome(
                  expenses,
                );
                final totalExpenseRecords = expenseProvider.totalExpenses(
                  expenses,
                );
                final categoryTotals = expenseProvider.categoryTotals(expenses);

                return StreamBuilder<List<BillModel>>(
                  stream: billProvider.watchBills(),
                  builder: (context, billSnapshot) {
                    final bills = billSnapshot.data ?? [];

                    return StreamBuilder<List<SavingGoalModel>>(
                      stream: savingProvider.watchSavingGoals(),
                      builder: (context, savingSnapshot) {
                        final goals = savingSnapshot.data ?? [];

                        final income =
                            plan?.monthlyIncome ?? totalIncomeRecords;
                        final plannedBills = plan?.billsBudget ?? 0;
                        final plannedSavings = plan?.savingTarget ?? 0;
                        final paidBills = _totalPaidBills(bills);
                        final unpaidBills = _totalUnpaidBills(bills);
                        final savedAmount = _totalSaved(goals);

                        return ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
                          children: [
                            const _ReportHeader(),
                            const SizedBox(height: 24),
                            _DarkHeroCard(
                              income: income,
                              expenses: totalExpenseRecords,
                              saved: savedAmount,
                            ),
                            const SizedBox(height: 22),
                            GridView.count(
                              padding: EdgeInsets.zero,
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 1.45,
                              children: [
                                ReportCard(
                                  title: 'Income',
                                  value: CurrencyHelper.format(income),
                                  subtitle: 'Monthly income',
                                  icon: Icons.trending_up_rounded,
                                  color: AppColors.info,
                                  isDark: true,
                                ),
                                ReportCard(
                                  title: 'Expenses',
                                  value: CurrencyHelper.format(
                                    totalExpenseRecords,
                                  ),
                                  subtitle: 'Recorded spending',
                                  icon: Icons.trending_down_rounded,
                                  color: AppColors.danger,
                                  isDark: true,
                                ),
                                ReportCard(
                                  title: 'Paid Bills',
                                  value: CurrencyHelper.format(paidBills),
                                  subtitle: 'Already paid',
                                  icon: Icons.check_circle_rounded,
                                  color: AppColors.success,
                                  isDark: true,
                                ),
                                ReportCard(
                                  title: 'Unpaid Bills',
                                  value: CurrencyHelper.format(unpaidBills),
                                  subtitle: 'Still pending',
                                  icon: Icons.pending_actions_rounded,
                                  color: AppColors.warning,
                                  isDark: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            MonthlySummaryChart(
                              income: income,
                              expenses: totalExpenseRecords,
                              bills: plannedBills,
                              savings: plannedSavings,
                            ),
                            const SizedBox(height: 22),
                            SpendingPieChart(categoryTotals: categoryTotals),
                            const SizedBox(height: 22),
                            _BillsProgressCard(
                              paidBills: paidBills,
                              unpaidBills: unpaidBills,
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Premium monthly money report',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: const Icon(Icons.insights_rounded, color: AppColors.warning),
        ),
      ],
    );
  }
}

class _DarkHeroCard extends StatelessWidget {
  final double income;
  final double expenses;
  final double saved;

  const _DarkHeroCard({
    required this.income,
    required this.expenses,
    required this.saved,
  });

  @override
  Widget build(BuildContext context) {
    final available = income - expenses - saved;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: AppColors.darkBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 34,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -42,
            right: -32,
            child: Container(
              height: 128,
              width: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -30,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warning.withOpacity(0.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available After Records',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                CurrencyHelper.format(available),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                available >= 0
                    ? 'You are still within a safe money range'
                    : 'Your records show overspending',
                style: TextStyle(
                  color: available >= 0 ? Colors.white54 : AppColors.warning,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _HeroMiniItem(
                      title: 'Spent',
                      value: CurrencyHelper.format(expenses),
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HeroMiniItem(
                      title: 'Saved',
                      value: CurrencyHelper.format(saved),
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMiniItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _HeroMiniItem({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            title == 'Spent'
                ? Icons.trending_down_rounded
                : Icons.savings_rounded,
            color: color,
            size: 22,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BillsProgressCard extends StatelessWidget {
  final double paidBills;
  final double unpaidBills;

  const _BillsProgressCard({
    required this.paidBills,
    required this.unpaidBills,
  });

  @override
  Widget build(BuildContext context) {
    final total = paidBills + unpaidBills;
    final progress = total <= 0 ? 0.0 : paidBills / total;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bills Paid vs Unpaid',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Payment completion progress',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.warning.withOpacity(0.22),
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _BillProgressItem(
                  title: 'Paid',
                  value: CurrencyHelper.format(paidBills),
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _BillProgressItem(
                  title: 'Unpaid',
                  value: CurrencyHelper.format(unpaidBills),
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BillProgressItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _BillProgressItem({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            title == 'Paid'
                ? Icons.check_circle_rounded
                : Icons.pending_actions_rounded,
            color: color,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
