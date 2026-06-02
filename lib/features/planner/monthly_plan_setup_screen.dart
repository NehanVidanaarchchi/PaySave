import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/helpers/calculation_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../providers/monthly_plan_provider.dart';
import 'widgets/budget_input_card.dart';
import 'widgets/plan_preview_card.dart';

class MonthlyPlanSetupScreen extends StatefulWidget {
  const MonthlyPlanSetupScreen({super.key});

  @override
  State<MonthlyPlanSetupScreen> createState() => _MonthlyPlanSetupScreenState();
}

class _MonthlyPlanSetupScreenState extends State<MonthlyPlanSetupScreen> {
  final _incomeController = TextEditingController(text: '55000');
  final _rentController = TextEditingController(text: '15000');
  final _billsController = TextEditingController(text: '10670');
  final _savingController = TextEditingController(text: '22000');
  final _foodController = TextEditingController(text: '3000');
  final _transportController = TextEditingController(text: '2000');
  final _otherController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();

    for (final controller in _controllers) {
      controller.addListener(() {
        setState(() {});
      });
    }
  }

  List<TextEditingController> get _controllers {
    return [
      _incomeController,
      _rentController,
      _billsController,
      _savingController,
      _foodController,
      _transportController,
      _otherController,
    ];
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  double _value(TextEditingController controller) {
    return double.tryParse(controller.text.trim()) ?? 0;
  }

  double get _income => _value(_incomeController);
  double get _rent => _value(_rentController);
  double get _bills => _value(_billsController);
  double get _saving => _value(_savingController);
  double get _food => _value(_foodController);
  double get _transport => _value(_transportController);
  double get _other => _value(_otherController);

  double get _fixedCosts => _rent + _bills;
  double get _spendingBudget => _food + _transport + _other;

  double get _remaining {
    return CalculationHelper.calculateRemainingBalance(
      income: _income,
      rent: _rent,
      bills: _bills,
      savings: _saving,
      food: _food,
      transport: _transport,
      other: _other,
    );
  }

  Future<void> _savePlan() async {
    FocusScope.of(context).unfocus();

    if (_income <= 0) {
      _showMessage('Monthly income is required');
      return;
    }

    final provider = context.read<MonthlyPlanProvider>();

    final success = await provider.saveMonthlyPlan(
      monthlyIncome: _income,
      rentAmount: _rent,
      billsBudget: _bills,
      savingTarget: _saving,
      foodBudget: _food,
      transportBudget: _transport,
      otherBudget: _other,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    } else {
      _showMessage(provider.errorMessage ?? 'Failed to save monthly plan');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonthlyPlanProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Monthly Plan')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          top: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            children: [
              const Text(
                'Create your money margin',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Divide your salary into rent, bills, savings, and safe spending before the month starts.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              PlanPreviewCard(
                income: _income,
                fixedCosts: _fixedCosts,
                savings: _saving,
                spendingBudget: _spendingBudget,
                remainingBalance: _remaining,
              ),
              const SizedBox(height: 20),
              BudgetInputCard(
                title: 'Monthly Income',
                subtitle: 'Salary or total income',
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
                controller: _incomeController,
                hint: '55000',
              ),
              const SizedBox(height: 14),
              BudgetInputCard(
                title: 'Rent',
                subtitle: 'Room, house, or apartment rent',
                icon: Icons.home_rounded,
                color: AppColors.rent,
                controller: _rentController,
                hint: '15000',
              ),
              const SizedBox(height: 14),
              BudgetInputCard(
                title: 'Bills Budget',
                subtitle: 'Electricity, internet, phone',
                icon: Icons.receipt_long_rounded,
                color: AppColors.bills,
                controller: _billsController,
                hint: '10670',
              ),
              const SizedBox(height: 14),
              BudgetInputCard(
                title: 'Saving Target',
                subtitle: 'Save first before spending',
                icon: Icons.savings_rounded,
                color: AppColors.savings,
                controller: _savingController,
                hint: '22000',
              ),
              const SizedBox(height: 14),
              BudgetInputCard(
                title: 'Food Budget',
                subtitle: 'Meals and groceries',
                icon: Icons.restaurant_rounded,
                color: AppColors.expenses,
                controller: _foodController,
                hint: '3000',
              ),
              const SizedBox(height: 14),
              BudgetInputCard(
                title: 'Transport Budget',
                subtitle: 'Bus, fuel, taxi, rides',
                icon: Icons.directions_bus_rounded,
                color: AppColors.info,
                controller: _transportController,
                hint: '2000',
              ),
              const SizedBox(height: 14),
              BudgetInputCard(
                title: 'Other Budget',
                subtitle: 'Shopping, health, education',
                icon: Icons.more_horiz_rounded,
                color: AppColors.primary,
                controller: _otherController,
                hint: '0',
              ),
              const SizedBox(height: 26),
              CustomButton(
                text: 'Create Monthly Plan',
                icon: Icons.check_rounded,
                isLoading: provider.isLoading,
                onPressed: _savePlan,
              ),
              const SizedBox(height: 12),
              const Text(
                'This does not transfer money. It only creates your planning record.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
