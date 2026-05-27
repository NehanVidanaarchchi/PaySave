import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/expense_model.dart';
import '../../providers/expense_provider.dart';
import 'widgets/expense_card.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _selectedFilter = 'All';

  List<ExpenseModel> _filterItems(List<ExpenseModel> items) {
    switch (_selectedFilter) {
      case 'Income':
        return items.where((item) => item.isIncome).toList();
      case 'Expenses':
        return items.where((item) => item.isExpense).toList();
      default:
        return items;
    }
  }

  Future<void> _deleteExpense(
    BuildContext context,
    ExpenseModel expense,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete record?'),
          content: const Text('This income or expense record will be removed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    final provider = context.read<ExpenseProvider>();
    final success = await provider.deleteExpense(expense.id);

    if (!context.mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to delete record'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ExpenseProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addExpense);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Record',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          bottom: false,
          child: StreamBuilder<List<ExpenseModel>>(
            stream: provider.watchExpenses(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorView(message: snapshot.error.toString());
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingView(message: 'Loading records...');
              }

              final allItems = snapshot.data ?? [];
              final items = _filterItems(allItems);

              final totalIncome = provider.totalIncome(allItems);
              final totalExpenses = provider.totalExpenses(allItems);
              final balance = totalIncome - totalExpenses;

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
                children: [
                  const Text(
                    'Money Records',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Track income and daily spending manually.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _ExpenseSummaryCard(
                    income: totalIncome,
                    expenses: totalExpenses,
                    balance: balance,
                  ),
                  const SizedBox(height: 18),
                  _FilterChips(
                    selectedFilter: _selectedFilter,
                    onChanged: (filter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  if (items.isEmpty)
                    EmptyState(
                      icon: Icons.payments_rounded,
                      title: 'No records yet',
                      message:
                          'Add income or expense records to see your spending history here.',
                      buttonText: 'Add Record',
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.addExpense);
                      },
                    )
                  else
                    ...items.map(
                      (expense) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: ExpenseCard(
                          expense: expense,
                          onDelete: () {
                            _deleteExpense(context, expense);
                          },
                        ),
                      ),
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

class _ExpenseSummaryCard extends StatelessWidget {
  final double income;
  final double expenses;
  final double balance;

  const _ExpenseSummaryCard({
    required this.income,
    required this.expenses,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardPurpleGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.23),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Record Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyHelper.format(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPositive
                ? 'Income is higher than expenses'
                : 'Expenses are higher than income',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MiniSummary(
                  title: 'Income',
                  value: CurrencyHelper.format(income),
                  icon: Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniSummary(
                  title: 'Expenses',
                  value: CurrencyHelper.format(expenses),
                  icon: Icons.trending_down_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniSummary extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MiniSummary({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
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

class _FilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onChanged;

  const _FilterChips({required this.selectedFilter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Income', 'Expenses'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => onChanged(filter),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.card,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
