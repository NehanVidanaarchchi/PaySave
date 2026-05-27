import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/helpers/currency_helper.dart';

class PlanPreviewCard extends StatelessWidget {
  final double income;
  final double fixedCosts;
  final double savings;
  final double spendingBudget;
  final double remainingBalance;

  const PlanPreviewCard({
    super.key,
    required this.income,
    required this.fixedCosts,
    required this.savings,
    required this.spendingBudget,
    required this.remainingBalance,
  });

  @override
  Widget build(BuildContext context) {
    final isOverBudget = remainingBalance < 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: isOverBudget
            ? const LinearGradient(
                colors: [Color(0xFFFF7676), Color(0xFFFF4F68)],
              )
            : AppColors.cardPurpleGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: (isOverBudget ? AppColors.danger : AppColors.primary)
                .withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Preview',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyHelper.format(remainingBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isOverBudget
                ? 'Your plan is over budget'
                : 'Remaining after planned money',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          _PreviewRow(label: 'Income', value: CurrencyHelper.format(income)),
          _PreviewRow(
            label: 'Fixed Costs',
            value: CurrencyHelper.format(fixedCosts),
          ),
          _PreviewRow(label: 'Savings', value: CurrencyHelper.format(savings)),
          _PreviewRow(
            label: 'Spending Budget',
            value: CurrencyHelper.format(spendingBudget),
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
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
