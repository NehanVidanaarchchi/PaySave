import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/money_record_model.dart';
import '../../providers/money_record_provider.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  String _selectedFilter = 'All';

  List<MoneyRecordModel> _filterRecords(List<MoneyRecordModel> records) {
    final billsAndInstallments = records.where((record) {
      return record.isBill || record.isInstallment;
    }).toList();

    billsAndInstallments.sort((a, b) => a.date.compareTo(b.date));

    switch (_selectedFilter) {
      case 'Bills':
        return billsAndInstallments.where((record) => record.isBill).toList();

      case 'Koko':
        return billsAndInstallments
            .where((record) => record.isInstallment)
            .toList();

      case 'Upcoming':
        return billsAndInstallments
            .where((record) => !record.isPaid && !record.date.isBefore(_today()))
            .toList();

      case 'Paid':
        return billsAndInstallments.where((record) => record.isPaid).toList();

      case 'Unpaid':
        return billsAndInstallments.where((record) => !record.isPaid).toList();

      case 'All':
      default:
        return billsAndInstallments;
    }
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  double _totalAmount(List<MoneyRecordModel> records) {
    return records.fold<double>(0, (total, item) => total + item.amount);
  }

  int _unpaidCount(List<MoneyRecordModel> records) {
    return records.where((item) => !item.isPaid).length;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MoneyRecordProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,

      // Removed floating Add Bill button from here.

      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.softGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bills & Koko',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Track WiFi, GPT, electricity bills, and 3/6 month Koko payments.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                _RecordFilterChips(
                  selectedFilter: _selectedFilter,
                  onChanged: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: StreamBuilder<List<MoneyRecordModel>>(
                    stream: provider.watchRecords(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return ErrorView(
                          message: snapshot.error.toString(),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingView(
                          message: 'Loading bills and Koko payments...',
                        );
                      }

                      final records = _filterRecords(snapshot.data ?? []);
                      final total = _totalAmount(records);
                      final unpaid = _unpaidCount(records);

                      if (records.isEmpty) {
                        return const _NoBillsView();
                      }

                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 135),
                        children: [
                          _BillsSummaryCard(
                            totalAmount: total,
                            unpaidCount: unpaid,
                            recordCount: records.length,
                          ),
                          const SizedBox(height: 16),
                          ...records.map((record) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _MoneyBillCard(record: record),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onChanged;

  const _RecordFilterChips({
    required this.selectedFilter,
    required this.onChanged,
  });

  static const List<String> filters = [
    'All',
    'Bills',
    'Koko',
    'Upcoming',
    'Unpaid',
    'Paid',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return ChoiceChip(
            selected: isSelected,
            label: Text(filter),
            showCheckmark: false,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.card,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
            onSelected: (_) => onChanged(filter),
          );
        },
      ),
    );
  }
}

class _BillsSummaryCard extends StatelessWidget {
  final double totalAmount;
  final int unpaidCount;
  final int recordCount;

  const _BillsSummaryCard({
    required this.totalAmount,
    required this.unpaidCount,
    required this.recordCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: AppColors.cardPurpleGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Selected Payments',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  CurrencyHelper.format(totalAmount),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$recordCount records • $unpaidCount unpaid',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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

class _MoneyBillCard extends StatelessWidget {
  final MoneyRecordModel record;

  const _MoneyBillCard({
    required this.record,
  });

  Color get _typeColor {
    if (record.isInstallment) return AppColors.primary;
    return AppColors.warning;
  }

  IconData get _typeIcon {
    if (record.isInstallment) return Icons.calendar_month_rounded;
    return Icons.receipt_long_rounded;
  }

  String get _typeTitle {
    if (record.isInstallment) return 'Koko / Installment';
    return 'Bill';
  }

  String get _installmentInfo {
    if (!record.isInstallment) return '';

    final index = record.installmentIndex;
    final months = record.installmentMonths;

    if (index == null || months == null) {
      return 'Installment payment';
    }

    return 'Payment $index of $months';
  }

  @override
  Widget build(BuildContext context) {
    final dueText = DateHelper.dueText(record.date);
    final dateText = DateHelper.formatDate(record.date);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
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
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  _typeIcon,
                  color: _typeColor,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      record.isInstallment
                          ? _installmentInfo
                          : record.category,
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
              Text(
                CurrencyHelper.format(record.amount),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.softLavender.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_rounded,
                  color: _typeColor,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    '$dueText • $dateText',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(
                  isPaid: record.isPaid,
                ),
              ],
            ),
          ),
          if (record.note.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                record.note,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (!record.isPaid) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.read<MoneyRecordProvider>().markPaid(record);
                },
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: const Text('Mark as Paid'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isPaid;

  const _StatusBadge({
    required this.isPaid,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPaid ? AppColors.success : AppColors.warning;
    final text = isPaid ? 'Paid' : 'Unpaid';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _NoBillsView extends StatelessWidget {
  const _NoBillsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 38, 20, 38),
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: 42,
            ),
            SizedBox(height: 16),
            Text(
              'No bill or Koko records yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Use the Home page quick actions to add WiFi bill, GPT bill, electricity bill, or Koko 3/6 month payments.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}