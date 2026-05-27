import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/helpers/currency_helper.dart';
import '../../../core/helpers/date_helper.dart';
import '../../../data/models/bill_model.dart';

class BillCard extends StatelessWidget {
  final BillModel bill;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onPaidChanged;
  final VoidCallback? onDelete;

  const BillCard({
    super.key,
    required this.bill,
    this.onTap,
    this.onPaidChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = bill.isPaid
        ? AppColors.success
        : bill.isOverdue
        ? AppColors.danger
        : AppColors.warning;

    final statusText = bill.isPaid
        ? 'Paid'
        : bill.isOverdue
        ? 'Overdue'
        : 'Unpaid';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        onTap: onTap,
        child: Container(
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
          child: Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _iconForCategory(bill.category),
                  color: statusColor,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.billName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${DateHelper.dueText(bill.dueDate)} • ${DateHelper.formatTime(bill.reminderDateTime)}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            bill.category,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyHelper.format(bill.amount),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Switch(
                    value: bill.isPaid,
                    activeColor: AppColors.success,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: onPaidChanged,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'rent':
        return Icons.home_rounded;
      case 'electricity':
        return Icons.bolt_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'internet':
        return Icons.wifi_rounded;
      case 'phone':
        return Icons.phone_iphone_rounded;
      case 'subscription':
        return Icons.subscriptions_rounded;
      case 'installment':
        return Icons.calendar_month_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }
}
