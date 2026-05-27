import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/validation_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models/bill_model.dart';
import '../../providers/bill_provider.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();

  final _billNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _category = 'Electricity';
  String _repeatType = BillModel.repeatMonthly;
  bool _isPaid = false;

  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  final List<String> _categories = [
    'Rent',
    'Electricity',
    'Water',
    'Internet',
    'Phone',
    'Subscription',
    'Installment',
    'Other',
  ];

  final Map<String, String> _repeatTypes = {
    BillModel.repeatOneTime: 'One Time',
    BillModel.repeatWeekly: 'Weekly',
    BillModel.repeatMonthly: 'Monthly',
    BillModel.repeatYearly: 'Yearly',
  };

  @override
  void dispose() {
    _billNameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  DateTime get _reminderDateTime {
    return DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _reminderTime.hour,
      _reminderTime.minute,
    );
  }

  Future<void> _pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (pickedDate == null) return;

    setState(() {
      _dueDate = pickedDate;
    });
  }

  Future<void> _pickReminderTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (pickedTime == null) return;

    setState(() {
      _reminderTime = pickedTime;
    });
  }

  Future<void> _saveBill() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<BillProvider>();

    final success = await provider.addBill(
      billName: _billNameController.text,
      category: _category,
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
      dueDate: _dueDate,
      reminderDateTime: _reminderDateTime,
      repeatType: _repeatType,
      isPaid: _isPaid,
      note: _noteController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      _showMessage(provider.errorMessage ?? 'Failed to save bill');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Bill')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          top: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            children: [
              const Text(
                'Create bill reminder',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add due date and reminder time. This is not a payment feature.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _billNameController,
                        label: 'Bill Name',
                        hint: 'Electricity Bill',
                        icon: Icons.receipt_long_rounded,
                        validator: (value) {
                          return ValidationHelper.requiredField(
                            value,
                            fieldName: 'Bill name',
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _amountController,
                        label: 'Amount',
                        hint: '4000',
                        icon: Icons.payments_rounded,
                        keyboardType: TextInputType.number,
                        validator: ValidationHelper.amount,
                      ),
                      const SizedBox(height: 16),
                      _DropdownBox(
                        label: 'Category',
                        value: _category,
                        items: _categories,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _category = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      _DateTimeBox(
                        icon: Icons.calendar_today_rounded,
                        title: 'Due Date',
                        value:
                            '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                        onTap: _pickDueDate,
                      ),
                      const SizedBox(height: 16),
                      _DateTimeBox(
                        icon: Icons.notifications_rounded,
                        title: 'Reminder Time',
                        value: _reminderTime.format(context),
                        onTap: _pickReminderTime,
                      ),
                      const SizedBox(height: 16),
                      _DropdownBox(
                        label: 'Repeat Type',
                        value: _repeatType,
                        items: _repeatTypes.keys.toList(),
                        labelBuilder: (value) => _repeatTypes[value] ?? value,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _repeatType = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        value: _isPaid,
                        activeColor: AppColors.success,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Already Paid',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        subtitle: const Text(
                          'Turn on if this bill is already paid',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _isPaid = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _noteController,
                        label: 'Note',
                        hint: 'Optional note',
                        icon: Icons.notes_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Save Bill',
                        icon: Icons.check_rounded,
                        isLoading: provider.isLoading,
                        onPressed: _saveBill,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownBox extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String Function(String value)? labelBuilder;

  const _DropdownBox({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(labelBuilder?.call(item) ?? item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.tune_rounded, color: AppColors.primary),
      ),
    );
  }
}

class _DateTimeBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _DateTimeBox({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
