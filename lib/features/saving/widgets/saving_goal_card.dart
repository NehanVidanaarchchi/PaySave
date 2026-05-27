import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/helpers/currency_helper.dart';
import '../../../core/helpers/date_helper.dart';
import '../../../data/models/saving_goal_model.dart';

class SavingGoalCard extends StatelessWidget {
  final SavingGoalModel goal;
  final VoidCallback? onAddMoney;
  final VoidCallback? onRemoveMoney;
  final VoidCallback? onDelete;

  const SavingGoalCard({
    super.key,
    required this.goal,
    this.onAddMoney,
    this.onRemoveMoney,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = (goal.progress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: AppColors.savings.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  color: AppColors.savings,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.goalName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Target: ${CurrencyHelper.format(goal.targetAmount)}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: AppColors.card,
                onSelected: (value) {
                  if (value == 'add') onAddMoney?.call();
                  if (value == 'remove') onRemoveMoney?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(value: 'add', child: Text('Add saved money')),
                    PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove saved money'),
                    ),
                    PopupMenuItem(value: 'delete', child: Text('Delete goal')),
                  ];
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 10,
              backgroundColor: AppColors.softLavender,
              color: goal.isCompleted ? AppColors.success : AppColors.savings,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  color: AppColors.savings,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${CurrencyHelper.format(goal.savedAmount)} saved',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                goal.isCompleted
                    ? 'Completed'
                    : DateHelper.formatShortDate(goal.targetDate),
                style: TextStyle(
                  color: goal.isCompleted
                      ? AppColors.success
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  goal.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.flag_rounded,
                  color: goal.isCompleted
                      ? AppColors.success
                      : AppColors.primary,
                  size: 21,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    goal.isCompleted
                        ? 'Goal completed'
                        : '${CurrencyHelper.format(goal.remainingAmount)} remaining',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${goal.daysLeft < 0 ? 0 : goal.daysLeft} days left',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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
