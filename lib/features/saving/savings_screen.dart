import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/saving_goal_model.dart';
import '../../providers/saving_provider.dart';
import 'widgets/saving_goal_card.dart';
import 'widgets/saving_progress_card.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  Future<void> _showMoneyDialog({
    required BuildContext context,
    required SavingGoalModel goal,
    required bool isAdd,
  }) async {
    final controller = TextEditingController();

    final amount = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isAdd ? 'Add saved money' : 'Remove saved money'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: 'Rs. ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = double.tryParse(controller.text.trim()) ?? 0;
                Navigator.pop(context, value);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (amount == null || amount <= 0) return;
    if (!context.mounted) return;

    final provider = context.read<SavingProvider>();

    final success = isAdd
        ? await provider.addSavedAmount(goalId: goal.id, amount: amount)
        : await provider.removeSavedAmount(goalId: goal.id, amount: amount);

    if (!context.mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Failed to update saving goal',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _deleteGoal({
    required BuildContext context,
    required SavingGoalModel goal,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete saving goal?'),
          content: const Text('This saving goal will be permanently removed.'),
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

    final provider = context.read<SavingProvider>();
    final success = await provider.deleteSavingGoal(goal.id);

    if (!context.mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to delete goal'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SavingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addSavingGoal);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Goal',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          bottom: false,
          child: StreamBuilder<List<SavingGoalModel>>(
            stream: provider.watchSavingGoals(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorView(message: snapshot.error.toString());
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingView(message: 'Loading savings...');
              }

              final goals = snapshot.data ?? [];

              if (goals.isEmpty) {
                return EmptyState(
                  icon: Icons.savings_rounded,
                  title: 'No saving goals yet',
                  message:
                      'Create goals like emergency fund, laptop, phone, course fee, or trip.',
                  buttonText: 'Add Saving Goal',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.addSavingGoal);
                  },
                );
              }

              final totalSaved = provider.calculateTotalSaved(goals);
              final monthlyTarget = provider.calculateMonthlySavingTarget(
                goals,
              );

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
                children: [
                  const Text(
                    'Savings',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Track goals and grow your saved money.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SavingProgressCard(
                    totalSaved: totalSaved,
                    monthlyTarget: monthlyTarget,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Your Goals',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...goals.map(
                    (goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: SavingGoalCard(
                        goal: goal,
                        onAddMoney: () {
                          _showMoneyDialog(
                            context: context,
                            goal: goal,
                            isAdd: true,
                          );
                        },
                        onRemoveMoney: () {
                          _showMoneyDialog(
                            context: context,
                            goal: goal,
                            isAdd: false,
                          );
                        },
                        onDelete: () {
                          _deleteGoal(context: context, goal: goal);
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
