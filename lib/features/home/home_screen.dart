import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../data/models/money_record_model.dart';
import '../../providers/money_record_provider.dart';

import '../bills/bills_screen.dart';
import '../records/add_money_record_screen.dart';
import '../saving/savings_screen.dart';
import '../settings/settings_screen.dart';

import 'widgets/balance_card.dart';
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
    const AddMoneyRecordScreen(),
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
    final int safeIndex = _currentIndex.clamp(0, _pages.length - 1).toInt();

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
        height: 96,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 76,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.card.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.95),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    blurRadius: 32,
                    offset: const Offset(0, 18),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _BottomNavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isSelected: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                  ),
                  Expanded(
                    child: _BottomNavItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'Bills',
                      isSelected: currentIndex == 2,
                      onTap: () => onTap(2),
                    ),
                  ),
                  const SizedBox(width: 74),
                  Expanded(
                    child: _BottomNavItem(
                      icon: Icons.savings_rounded,
                      label: 'Savings',
                      isSelected: currentIndex == 3,
                      onTap: () => onTap(3),
                    ),
                  ),
                  Expanded(
                    child: _BottomNavItem(
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      isSelected: currentIndex == 4,
                      onTap: () => onTap(4),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () => onTap(1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  height: 74,
                  width: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.32),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.42),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: AnimatedScale(
                    scale: currentIndex == 1 ? 1.08 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 7,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: currentIndex == 1 ? 1 : 0.75,
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: currentIndex == 1
                        ? AppColors.primary
                        : AppColors.textLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 58,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.20)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  icon,
                  size: 23,
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

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
    final provider = context.read<MoneyRecordProvider>();
    final user = FirebaseAuth.instance.currentUser;
    final userName = _getUserName(user);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.softGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<List<MoneyRecordModel>>(
          stream: provider.watchCurrentMonthRecords(),
          builder: (context, snapshot) {
            final records = snapshot.data ?? [];
            final summary = provider.summaryFromRecords(records);
            final reminders = provider.upcomingReminders(records);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 150),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(userName: userName),
                        const SizedBox(height: 24),
                        BalanceCard(
                          remainingBalance: summary.remainingBalance,
                          dailySafeSpending: summary.dailySafeSpending,
                          isOverBudget: summary.isOverBudget,
                        ),
                        const SizedBox(height: 18),
                        _MoneyRecordSummaryGrid(summary: summary),
                        const SizedBox(height: 26),
                        const _SectionTitle(
                          title: 'Quick Actions',
                          subtitle:
                              'Add salary, bills, expenses, and Koko payments',
                        ),
                        const SizedBox(height: 14),
                        const _QuickActions(),
                        const SizedBox(height: 28),
                        const _SectionTitle(
                          title: 'Upcoming Reminders',
                          subtitle: 'Bill and installment payment dates',
                        ),
                        const SizedBox(height: 14),
                        if (reminders.isEmpty)
                          const _NoReminderView()
                        else
                          Column(
                            children: reminders.map((record) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: UpcomingPaymentCard(
                                  title: record.title,
                                  amount: CurrencyHelper.format(record.amount),
                                  dueText: DateHelper.dueText(record.date),
                                  statusText: record.displayType,
                                  icon: record.isInstallment
                                      ? Icons.calendar_month_rounded
                                      : Icons.receipt_long_rounded,
                                  color: record.isInstallment
                                      ? AppColors.primary
                                      : AppColors.warning,
                                ),
                              );
                            }).toList(),
                          ),
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

class _Header extends StatelessWidget {
  final String userName;

  const _Header({
    required this.userName,
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
                'Hi, $userName 👋',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Money Overview',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                DateHelper.formatMonthYear(DateTime.now()),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
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
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _MoneyRecordSummaryGrid extends StatelessWidget {
  final MoneySummary summary;

  const _MoneyRecordSummaryGrid({
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.55,
      children: [
        _SummaryBox(
          title: 'Income',
          amount: summary.income,
          icon: Icons.arrow_downward_rounded,
          color: AppColors.success,
        ),
        _SummaryBox(
          title: 'Bills',
          amount: summary.bills,
          icon: Icons.receipt_long_rounded,
          color: AppColors.warning,
        ),
        _SummaryBox(
          title: 'Expenses',
          amount: summary.expenses,
          icon: Icons.shopping_bag_rounded,
          color: AppColors.danger,
        ),
        _SummaryBox(
          title: 'Koko / Installments',
          amount: summary.installments,
          icon: Icons.calendar_month_rounded,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryBox({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  CurrencyHelper.format(amount),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  void _openAdd(BuildContext context, String type) {
    Navigator.pushNamed(
      context,
      AppRoutes.addMoneyRecord,
      arguments: type,
    );
  }

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
          title: 'Add Salary',
          subtitle: 'Monthly income',
          icon: Icons.payments_rounded,
          color: AppColors.success,
          onTap: () => _openAdd(context, MoneyRecordModel.typeSalary),
        ),
        QuickActionCard(
          title: 'Add Bill',
          subtitle: 'WiFi, GPT, phone',
          icon: Icons.receipt_long_rounded,
          color: AppColors.warning,
          onTap: () => _openAdd(context, MoneyRecordModel.typeBill),
        ),
        QuickActionCard(
          title: 'Add Expense',
          subtitle: 'Food, transport',
          icon: Icons.shopping_bag_rounded,
          color: AppColors.danger,
          onTap: () => _openAdd(context, MoneyRecordModel.typeExpense),
        ),
        QuickActionCard(
          title: 'Koko Payment',
          subtitle: '3 or 6 months',
          icon: Icons.calendar_month_rounded,
          color: AppColors.primary,
          onTap: () => _openAdd(context, MoneyRecordModel.typeInstallment),
        ),
      ],
    );
  }
}

class _NoReminderView extends StatelessWidget {
  const _NoReminderView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 34, 18, 34),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primary,
            size: 36,
          ),
          SizedBox(height: 14),
          Text(
            'No upcoming reminders',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add bills or Koko payments to see reminders here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.4,
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