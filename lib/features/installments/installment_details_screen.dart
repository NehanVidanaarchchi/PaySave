import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/installment_model.dart';
import '../../providers/installment_provider.dart';

class InstallmentDetailsScreen extends StatelessWidget {
  final String? installmentId;

  const InstallmentDetailsScreen({super.key, required this.installmentId});

  @override
  Widget build(BuildContext context) {
    if (installmentId == null) {
      return const Scaffold(
        body: ErrorView(message: 'Installment ID not found'),
      );
    }

    final provider = context.read<InstallmentProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Installment Details')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          top: false,
          child: StreamBuilder<List<InstallmentModel>>(
            stream: provider.watchInstallments(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorView(message: snapshot.error.toString());
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingView(message: 'Loading details...');
              }

              final installments = snapshot.data ?? [];
              final installment = installments
                  .where((item) => item.id == installmentId)
                  .cast<InstallmentModel?>()
                  .firstOrNull;

              if (installment == null) {
                return const ErrorView(message: 'Installment not found');
              }

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                children: [
                  _HeroCard(installment: installment),
                  const SizedBox(height: 22),
                  const Text(
                    'Payment Schedule',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...installment.payments.map(
                    (payment) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PaymentCard(
                        installment: installment,
                        payment: payment,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _DeleteButton(installment: installment),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }
}

class _HeroCard extends StatelessWidget {
  final InstallmentModel installment;

  const _HeroCard({required this.installment});

  @override
  Widget build(BuildContext context) {
    final nextPayment = installment.nextPayment;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
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
          Text(
            installment.purchaseName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Provider: ${installment.provider}',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _HeroItem(
                  title: 'Total',
                  value: CurrencyHelper.format(installment.totalAmount),
                ),
              ),
              Expanded(
                child: _HeroItem(
                  title: 'Remaining',
                  value: CurrencyHelper.format(installment.remainingAmount),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: installment.progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.2),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            installment.isCompleted
                ? 'All installments are paid'
                : nextPayment == null
                ? 'No upcoming payment'
                : 'Next payment ${CurrencyHelper.format(nextPayment.amount)} on ${DateHelper.formatShortDate(nextPayment.dueDate)}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroItem extends StatelessWidget {
  final String title;
  final String value;

  const _HeroItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final InstallmentModel installment;
  final InstallmentPaymentModel payment;

  const _PaymentCard({required this.installment, required this.payment});

  @override
  Widget build(BuildContext context) {
    final color = payment.isPaid ? AppColors.success : AppColors.warning;

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
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              payment.isPaid
                  ? Icons.check_circle_rounded
                  : Icons.notifications_active_rounded,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment ${payment.installmentNumber}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${DateHelper.formatDate(payment.dueDate)} • ${DateHelper.formatTime(payment.reminderDateTime)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyHelper.format(payment.amount),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Switch(
                value: payment.isPaid,
                activeColor: AppColors.success,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (value) async {
                  await context.read<InstallmentProvider>().markPaymentPaid(
                    installment: installment,
                    paymentId: payment.id,
                    isPaid: value,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final InstallmentModel installment;

  const _DeleteButton({required this.installment});

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete installment?'),
          content: const Text(
            'This will remove all future reminders for this installment plan.',
          ),
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

    final provider = context.read<InstallmentProvider>();
    final success = await provider.deleteInstallment(installment);

    if (!context.mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Failed to delete installment',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _delete(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.danger,
        side: const BorderSide(color: AppColors.danger),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      icon: const Icon(Icons.delete_outline_rounded),
      label: const Text(
        'Delete Installment Plan',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}
