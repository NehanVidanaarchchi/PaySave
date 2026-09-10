import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/error/error_handler.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/widgets/error_state.dart';
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

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  List<MoneyRecordModel> _filterRecords(List<MoneyRecordModel> records) {
    final payments = records.where((record) {
      return record.isBill || record.isInstallment;
    }).toList();

    payments.sort((a, b) => a.date.compareTo(b.date));

    switch (_selectedFilter) {
      case 'Bills':
        return payments.where((record) => record.isBill).toList();

      case 'Instalment':
        return payments.where((record) => record.isInstallment).toList();

      case 'Upcoming':
        return payments
            .where((record) => !record.isPaid && !record.date.isBefore(_today()))
            .toList();

      case 'Unpaid':
        return payments.where((record) => !record.isPaid).toList();

      case 'Paid':
        return payments.where((record) => record.isPaid).toList();

      case 'All':
      default:
        return payments;
    }
  }

  double _totalAmount(List<MoneyRecordModel> records) {
    return records.fold<double>(0, (total, item) => total + item.amount);
  }

  int _unpaidCount(List<MoneyRecordModel> records) {
    return records.where((item) => !item.isPaid).length;
  }

  int _instalmentCount(List<MoneyRecordModel> records) {
    return records.where((item) => item.isInstallment).length;
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bills & Instalment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Track WiFi, GPT, electricity bills, and instalment payments.',
          style: TextStyle(
            color: Color(0xffA1A1A1),
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        _buildFilters(),
      ],
    );
  }

  Widget _buildFilters() {
    const filters = [
      'All',
      'Bills',
      'Instalment',
      'Upcoming',
      'Unpaid',
      'Paid',
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = _selectedFilter == filters[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filters[index];
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selected ? Colors.white : const Color(0xff151515),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? Colors.white : const Color(0xff303030),
                ),
              ),
              child: Center(
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: selected ? Colors.black : Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MoneyRecordProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<List<MoneyRecordModel>>(
                    stream: provider.watchRecords(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return ErrorState(
                          message: ErrorHandler.getMessage(snapshot.error),
                          onRetry: () {
                            setState(() {});
                          },
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingView(
                          message: 'Loading bills and instalment payments...',
                        );
                      }

                      final records = _filterRecords(snapshot.data ?? []);
                      final total = _totalAmount(records);
                      final unpaid = _unpaidCount(records);
                      final instalment = _instalmentCount(records);

                      if (records.isEmpty) {
                        return const _NoBillsView();
                      }

                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 145),
                        children: [
                          _BillsSummaryCard(
                            totalAmount: total,
                            unpaidCount: unpaid,
                            instalmentCount: instalment,
                            recordCount: records.length,
                          ),
                          const SizedBox(height: 18),
                          ...records.map((record) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _CleanPaymentCard(record: record),
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

class _BillsSummaryCard extends StatelessWidget {
  final double totalAmount;
  final int unpaidCount;
  final int instalmentCount;
  final int recordCount;

  const _BillsSummaryCard({
    required this.totalAmount,
    required this.unpaidCount,
    required this.instalmentCount,
    required this.recordCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: const Color(0xff111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xff292929)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      'Selected Payments',
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
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniSummaryPill(
                  title: 'Records',
                  value: '$recordCount',
                  icon: Icons.list_alt_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniSummaryPill(
                  title: 'Unpaid',
                  value: '$unpaidCount',
                  icon: Icons.warning_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniSummaryPill(
                  title: 'Instalment',
                  value: '$instalmentCount',
                  icon: Icons.calendar_month_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniSummaryPill extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MiniSummaryPill({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 17,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CleanPaymentCard extends StatelessWidget {
  final MoneyRecordModel record;

  const _CleanPaymentCard({
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

  String get _typeLabel {
    if (record.isInstallment) return 'Instalment Payment';
    return 'Bill';
  }

  String get _cleanTitle {
    if (!record.isInstallment) return record.title;

    final pattern = RegExp(r'\s*\(\d+\/\d+\)$');
    return record.title.replaceAll(pattern, '').trim();
  }

  String get _installmentText {
    if (!record.isInstallment) return record.category;

    final index = record.installmentIndex;
    final months = record.installmentMonths;

    if (index == null || months == null) {
      return 'Installment payment';
    }

    return 'Payment $index of $months';
  }

  double get _installmentProgress {
    if (!record.isInstallment) return 0;

    final index = record.installmentIndex;
    final months = record.installmentMonths;

    if (index == null || months == null || months == 0) return 0;

    return (index / months).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final dueText = DateHelper.dueText(record.date);
    final dateText = DateHelper.formatDate(record.date);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: const Color(0xff111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xff292929)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _typeIcon,
                  color: _typeColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cleanTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SmallChip(
                          text: _typeLabel,
                          color: _typeColor,
                        ),
                        _SmallChip(
                          text: record.isPaid ? 'Paid' : 'Unpaid',
                          color: record.isPaid
                              ? AppColors.success
                              : AppColors.warning,
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
                  const Text(
                    'Amount',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
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
            ],
          ),
          const SizedBox(height: 16),
          _DetailPanel(
            children: [
              _DetailRow(
                icon: Icons.event_rounded,
                title: dueText,
                value: dateText,
                color: _typeColor,
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: record.isInstallment
                    ? Icons.payments_rounded
                    : Icons.label_rounded,
                title: record.isInstallment ? 'Installment' : 'Category',
                value: _installmentText,
                color: _typeColor,
              ),
              if (record.isInstallment) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _installmentProgress,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    color: AppColors.primary,
                  ),
                ),
              ],
              if (record.note.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                _NoteBox(note: record.note.trim()),
              ],
            ],
          ),
          if (!record.isPaid) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
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

class _DetailPanel extends StatelessWidget {
  final List<Widget> children;

  const _DetailPanel({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff181818),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteBox extends StatelessWidget {
  final String note;

  const _NoteBox({
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        note,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String text;
  final Color color;

  const _SmallChip({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
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
              'No bill or instalment records yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Use the Home page quick actions to add WiFi bill, GPT bill, electricity bill, or 3/6 month instalment payments.',
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