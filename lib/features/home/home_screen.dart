import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/installment_model.dart';
import '../../data/models/monthly_plan_model.dart';
import '../../providers/bill_provider.dart';
import '../../providers/installment_provider.dart';
import '../../providers/monthly_plan_provider.dart';

import '../bills/bills_screen.dart';
import '../planner/monthly_plan_screen.dart';
import '../saving/savings_screen.dart';
import '../settings/settings_screen.dart';

import 'widgets/balance_card.dart';
import 'widgets/money_summary_grid.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/upcoming_payment_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const _DashboardView(),
    const MonthlyPlanScreen(),
    const BillsScreen(),
    const SavingsScreen(),
    const SettingsScreen(),
  ];

  void _changePage(int index) {
    if (index < 0 || index >= _pages.length) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = _currentIndex.clamp(0, _pages.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(
        index: safeIndex,
        children: _pages,
      ),
      bottomNavigationBar: _PaySaveBottomNavBar(
        currentIndex: safeIndex,
        onTap: _changePage,
      ),
    );
  }
}

class _PaySaveBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PaySaveBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 78,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _BottomNavItem(
              icon: Icons.pie_chart_rounded,
              label: 'Planner',
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _BottomNavItem(
              icon: Icons.receipt_long_rounded,
              label: 'Bills',
              isSelected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _BottomNavItem(
              icon: Icons.savings_rounded,
              label: 'Savings',
              isSelected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _BottomNavItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              isSelected: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.softLavender : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.textLight,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isSelected ? AppColors.primary : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final planProvider = context.read<MonthlyPlanProvider>();

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.softGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<MonthlyPlanModel?>(
          stream: planProvider.watchCurrentMonthPlan(),
          builder: (context, snapshot) {
            final plan = snapshot.data;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HomeHeader(
                          monthText: DateHelper.formatMonthYear(DateTime.now()),
                        ),
                        const SizedBox(height: 24),
                        if (plan == null)
                          _NoPlanCard(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.monthlyPlanSetup,
                              );
                            },
                          )
                        else ...[
                          BalanceCard(
                            remainingBalance: plan.remainingBalance,
                            dailySafeSpending: plan.dailySafeSpending,
                            isOverBudget: plan.isOverBudget,
                          ),
                          const SizedBox(height: 18),
                          MoneySummaryGrid(
                            income: plan.monthlyIncome,
                            rent: plan.rentAmount,
                            bills: plan.billsBudget,
                            savings: plan.savingTarget,
                          ),
                        ],
                        const SizedBox(height: 26),
                        const _SectionTitle(
                          title: 'Quick Actions',
                          subtitle: 'Add records and reminders',
                        ),
                        const SizedBox(height: 14),
                        const _QuickActions(),
                        const SizedBox(height: 28),
                        const _SectionTitle(
                          title: 'Upcoming Reminders',
                          subtitle: 'Bills and installment payment dates',
                        ),
                        const SizedBox(height: 14),
                        const _UpcomingReminders(),
                        const SizedBox(height: 28),
                        const _SafetyNoteCard(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String monthText;

  const _HomeHeader({
    required this.monthText,
  });

  String _getUserName(User? user) {
    final displayName = user?.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      return displayName.split(' ').first;
    }

    final email = user?.email?.trim();

    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final userName = _getUserName(snapshot.data);

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $userName 👋',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Monthly Overview',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Text(
                      monthText,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NoPlanCard extends StatelessWidget {
  final VoidCallback onPressed;

  const _NoPlanCard({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.pie_chart_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Create your monthly plan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set income, rent, bills, savings, and spending limits before you spend.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Create Monthly Plan',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.45,
      children: [
        QuickActionCard(
          title: 'Add Bill',
          subtitle: 'Payment reminder',
          icon: Icons.receipt_long_rounded,
          color: AppColors.warning,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.addBill);
          },
        ),
        QuickActionCard(
          title: 'Add Expense',
          subtitle: 'Track spending',
          icon: Icons.trending_down_rounded,
          color: AppColors.danger,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.addExpense);
          },
        ),
        QuickActionCard(
          title: 'Add Goal',
          subtitle: 'Save better',
          icon: Icons.savings_rounded,
          color: AppColors.success,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.addSavingGoal);
          },
        ),
        QuickActionCard(
          title: 'Installment',
          subtitle: 'Koko-like reminders',
          icon: Icons.calendar_month_rounded,
          color: AppColors.primary,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.addInstallment);
          },
        ),
      ],
    );
  }
}

class _UpcomingReminders extends StatelessWidget {
  const _UpcomingReminders();

  @override
  Widget build(BuildContext context) {
    final billProvider = context.read<BillProvider>();
    final installmentProvider = context.read<InstallmentProvider>();

    return StreamBuilder<List<BillModel>>(
      stream: billProvider.watchUpcomingBills(),
      builder: (context, billSnapshot) {
        final bills = billSnapshot.data ?? [];

        return StreamBuilder<List<InstallmentModel>>(
          stream: installmentProvider.watchActiveInstallments(),
          builder: (context, installmentSnapshot) {
            final installments = installmentSnapshot.data ?? [];
            final reminderWidgets = <Widget>[];

            for (final bill in bills.take(3)) {
              reminderWidgets.add(
                UpcomingPaymentCard(
                  title: bill.billName,
                  amount: CurrencyHelper.format(bill.amount),
                  dueText: DateHelper.dueText(bill.dueDate),
                  statusText: bill.isPaid ? 'Paid' : 'Unpaid',
                  icon: Icons.receipt_long_rounded,
                  color: bill.isOverdue ? AppColors.danger : AppColors.warning,
                ),
              );
            }

            for (final installment in installments.take(2)) {
              final nextPayment = installment.nextPayment;

              if (nextPayment != null) {
                reminderWidgets.add(
                  UpcomingPaymentCard(
                    title: '${installment.purchaseName} Installment',
                    amount: CurrencyHelper.format(nextPayment.amount),
                    dueText: DateHelper.formatShortDate(nextPayment.dueDate),
                    statusText:
                        '${installment.paidInstallments} of ${installment.installmentCount} paid',
                    icon: Icons.calendar_month_rounded,
                    color: AppColors.primary,
                  ),
                );
              }
            }

            if (reminderWidgets.isEmpty) {
              return EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No upcoming reminders',
                message: 'Add bills or installment reminders to see them here.',
                buttonText: 'Add Bill',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.addBill);
                },
              );
            }

            return Column(
              children: reminderWidgets
                  .map(
                    (widget) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: widget,
                    ),
                  )
                  .toList(),
            );
          },
        );
      },
    );
  }
}

class _SafetyNoteCard extends StatelessWidget {
  const _SafetyNoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            Icons.verified_user_rounded,
            color: Colors.white,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'PaySave does not transfer money or connect to banks. It only helps you plan and remember payments.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
