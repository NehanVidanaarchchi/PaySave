import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/currency_helper.dart';
import '../../../core/widgets/summary_card.dart';

class MoneySummaryGrid extends StatelessWidget {
  final double income;
  final double rent;
  final double bills;
  final double savings;

  const MoneySummaryGrid({
    super.key,
    required this.income,
    required this.rent,
    required this.bills,
    required this.savings,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.65,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      children: [
        SummaryCard(
          title: 'Income',
          value: CurrencyHelper.format(income),
          subtitle: 'Monthly income',
          icon: Icons.trending_up_rounded,
          color: AppColors.info,
        ),
        SummaryCard(
          title: 'Rent',
          value: CurrencyHelper.format(rent),
          subtitle: 'Fixed cost',
          icon: Icons.home_rounded,
          color: AppColors.rent,
        ),
        SummaryCard(
          title: 'Bills',
          value: CurrencyHelper.format(bills),
          subtitle: 'Budgeted bills',
          icon: Icons.receipt_long_rounded,
          color: AppColors.bills,
        ),
        SummaryCard(
          title: 'Savings',
          value: CurrencyHelper.format(savings),
          subtitle: 'Monthly target',
          icon: Icons.savings_rounded,
          color: AppColors.savings,
        ),
      ],
    );
  }
}
