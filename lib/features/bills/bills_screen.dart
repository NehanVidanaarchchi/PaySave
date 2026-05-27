import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/bill_model.dart';
import '../../providers/bill_provider.dart';
import 'widgets/bill_card.dart';
import 'widgets/bill_filter_chips.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  String _selectedFilter = 'All';

  List<BillModel> _filterBills(List<BillModel> bills) {
    final sortedBills = [...bills]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    switch (_selectedFilter) {
      case 'Upcoming':
        return sortedBills.where((bill) => !bill.isPaid).toList();
      case 'Paid':
        return sortedBills.where((bill) => bill.isPaid).toList();
      case 'Unpaid':
        return sortedBills.where((bill) => !bill.isPaid).toList();
      case 'All':
      default:
        return sortedBills;
    }
  }

  @override
  Widget build(BuildContext context) {
    final billProvider = context.read<BillProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addBill);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Bill',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bill Reminders',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Track due dates and remember payments on time.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                BillFilterChips(
                  selectedFilter: _selectedFilter,
                  onChanged: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: StreamBuilder<List<BillModel>>(
                    stream: billProvider.watchBills(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return ErrorView(message: snapshot.error.toString());
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingView(message: 'Loading bills...');
                      }

                      final bills = _filterBills(snapshot.data ?? []);

                      if (bills.isEmpty) {
                        return EmptyState(
                          icon: Icons.receipt_long_rounded,
                          title: 'No bills yet',
                          message:
                              'Add rent, electricity, internet, phone, or other bill reminders.',
                          buttonText: 'Add Bill',
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.addBill);
                          },
                        );
                      }

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 120),
                        itemCount: bills.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final bill = bills[index];

                          return BillCard(
                            bill: bill,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.editBill,
                                arguments: bill.id,
                              );
                            },
                            onPaidChanged: (value) async {
                              await context.read<BillProvider>().markBillPaid(
                                bill,
                                value,
                              );
                            },
                          );
                        },
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
