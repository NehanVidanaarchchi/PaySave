import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/helpers/calculation_helper.dart';
import '../../../core/helpers/currency_helper.dart';

class PlanChartCard extends StatelessWidget {
  final double income;
  final double rent;
  final double bills;
  final double savings;
  final double food;
  final double transport;
  final double other;

  const PlanChartCard({
    super.key,
    required this.income,
    required this.rent,
    required this.bills,
    required this.savings,
    required this.food,
    required this.transport,
    required this.other,
  });

  @override
  Widget build(BuildContext context) {
    final totalPlanned = rent + bills + savings + food + transport + other;
    final remaining = income - totalPlanned;

    final items = [
      _PlanChartItem('Rent', rent, AppColors.rent),
      _PlanChartItem('Bills', bills, AppColors.bills),
      _PlanChartItem('Savings', savings, AppColors.savings),
      _PlanChartItem('Food', food, AppColors.expenses),
      _PlanChartItem('Transport', transport, AppColors.info),
      _PlanChartItem('Other', other, AppColors.primary),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Money Division',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total planned: ${CurrencyHelper.format(totalPlanned)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Row(
              children: items.map((item) {
                final percent = CalculationHelper.percentage(
                  item.amount,
                  income,
                );

                return Expanded(
                  flex: (percent * 1000).round().clamp(1, 1000),
                  child: Container(height: 16, color: item.color),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          ...items.map(
            (item) => _ChartLegendRow(
              title: item.title,
              value: CurrencyHelper.format(item.amount),
              color: item.color,
              percent: CalculationHelper.percentage(item.amount, income),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: remaining < 0
                  ? AppColors.danger.withOpacity(0.10)
                  : AppColors.success.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  remaining < 0
                      ? Icons.warning_rounded
                      : Icons.check_circle_rounded,
                  color: remaining < 0 ? AppColors.danger : AppColors.success,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    remaining < 0
                        ? 'You are over budget by ${CurrencyHelper.format(remaining.abs())}'
                        : 'Remaining balance is ${CurrencyHelper.format(remaining)}',
                    style: TextStyle(
                      color: remaining < 0
                          ? AppColors.danger
                          : AppColors.success,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
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

class _PlanChartItem {
  final String title;
  final double amount;
  final Color color;

  _PlanChartItem(this.title, this.amount, this.color);
}

class _ChartLegendRow extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final double percent;

  const _ChartLegendRow({
    required this.title,
    required this.value,
    required this.color,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final percentText = '${(percent * 100).toStringAsFixed(0)}%';

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Container(
            height: 11,
            width: 11,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            percentText,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
