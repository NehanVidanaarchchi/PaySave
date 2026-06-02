import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/helpers/currency_helper.dart';

class SpendingPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const SpendingPieChart({
    super.key,
    required this.categoryTotals,
  });

  @override
  Widget build(BuildContext context) {
    final entries = categoryTotals.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: const Center(
          child: Text(
            'No spending categories recorded yet.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final displayedEntries = entries.take(5).toList();
    final additionalValue =
        entries.skip(5).fold<double>(0, (sum, entry) => sum + entry.value);

    if (additionalValue > 0) {
      displayedEntries.add(MapEntry('Other', additionalValue));
    }

    final totalValue =
        displayedEntries.fold<double>(0, (sum, entry) => sum + entry.value);
    final colors = [
      AppColors.info,
      AppColors.danger,
      AppColors.warning,
      AppColors.success,
      AppColors.primary,
      Colors.purple,
      Colors.cyan,
    ];

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Expense share by category',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                borderData: FlBorderData(show: false),
                sections: displayedEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value.value;
                  final color = colors[index % colors.length];
                  final percentage =
                      totalValue <= 0 ? 0 : value / totalValue * 100;

                  return PieChartSectionData(
                    value: value,
                    color: color,
                    radius: 60,
                    title: '${percentage.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: displayedEntries.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value.key;
              final value = entry.value.value;
              final color = colors[index % colors.length];

              return _CategoryLegendItem(
                color: color,
                label: category,
                amount: CurrencyHelper.format(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String amount;

  const _CategoryLegendItem({
    required this.color,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
