import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/money_record_model.dart';
import '../../providers/money_record_provider.dart';

class AddMoneyRecordScreen extends StatefulWidget {
  final String? initialType;

  const AddMoneyRecordScreen({
    super.key,
    this.initialType,
  });

  @override
  State<AddMoneyRecordScreen> createState() => _AddMoneyRecordScreenState();
}

class _AddMoneyRecordScreenState extends State<AddMoneyRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = MoneyRecordModel.typeSalary;
  DateTime _selectedDate = DateTime.now();
  int _installmentMonths = 3;
  bool _didLoadArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didLoadArgs) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (widget.initialType != null) {
      _type = widget.initialType!;
    } else if (args is String && args.isNotEmpty) {
      _type = args;
    }

    _categoryController.text = _defaultCategory(_type);
    _didLoadArgs = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _defaultCategory(String type) {
    switch (type) {
      case MoneyRecordModel.typeSalary:
        return 'Salary';
      case MoneyRecordModel.typeBill:
        return 'Bill';
      case MoneyRecordModel.typeExpense:
        return 'General';
      case MoneyRecordModel.typeSaving:
        return 'Saving';
      case MoneyRecordModel.typeInstallment:
        return 'Installment';
      default:
        return 'Other';
    }
  }

  String _screenTitle() {
    switch (_type) {
      case MoneyRecordModel.typeSalary:
        return 'Add Salary';
      case MoneyRecordModel.typeBill:
        return 'Add Bill';
      case MoneyRecordModel.typeExpense:
        return 'Add Expense';
      case MoneyRecordModel.typeSaving:
        return 'Add Saving';
      case MoneyRecordModel.typeInstallment:
        return 'Add Koko / Installment';
      default:
        return 'Add Record';
    }
  }

  String _amountLabel() {
    if (_type == MoneyRecordModel.typeInstallment) {
      return 'Total amount';
    }

    return 'Amount';
  }

  String _dateLabel() {
    if (_type == MoneyRecordModel.typeSalary) {
      return 'Received date';
    }

    if (_type == MoneyRecordModel.typeBill) {
      return 'Bill due date';
    }

    if (_type == MoneyRecordModel.typeInstallment) {
      return 'First payment date';
    }

    return 'Date';
  }

  double _parseAmount(String value) {
    final clean = value.replaceAll(',', '').trim();
    return double.tryParse(clean) ?? 0;
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (result == null) return;

    setState(() {
      _selectedDate = result;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<MoneyRecordProvider>();

    final title = _titleController.text.trim();
    final amount = _parseAmount(_amountController.text);
    final category = _categoryController.text.trim();
    final note = _noteController.text.trim();

    bool success;

    if (_type == MoneyRecordModel.typeInstallment) {
      success = await provider.addInstallmentPlan(
        title: title,
        totalAmount: amount,
        months: _installmentMonths,
        firstDueDate: _selectedDate,
        note: note,
      );
    } else {
      success = await provider.addMoneyRecord(
        title: title,
        amount: amount,
        type: _type,
        category: category,
        date: _selectedDate,
        note: note,
        isPaid: _type == MoneyRecordModel.typeSalary,
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.errorMessage ?? 'Failed to save record'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInstallment = _type == MoneyRecordModel.typeInstallment;
    final provider = context.watch<MoneyRecordProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_screenTitle()),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.softGradient,
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 140),
              children: [
                const Text(
                  'Record Details',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Add salary, bills, expenses, savings, or Koko-style installment payments.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),

                _CardBox(
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: const InputDecoration(
                          labelText: 'Record type',
                          prefixIcon: Icon(Icons.category_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: MoneyRecordModel.typeSalary,
                            child: Text('Salary / Income'),
                          ),
                          DropdownMenuItem(
                            value: MoneyRecordModel.typeBill,
                            child: Text('Bill - WiFi / GPT / Electricity'),
                          ),
                          DropdownMenuItem(
                            value: MoneyRecordModel.typeExpense,
                            child: Text('Expense'),
                          ),
                          DropdownMenuItem(
                            value: MoneyRecordModel.typeSaving,
                            child: Text('Saving'),
                          ),
                          DropdownMenuItem(
                            value: MoneyRecordModel.typeInstallment,
                            child: Text('Koko / Installment'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _type = value;
                            _categoryController.text =
                                _defaultCategory(value);
                          });
                        },
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: isInstallment
                              ? 'Purchase name'
                              : 'Reason / name',
                          hintText: isInstallment
                              ? 'Phone / Laptop / Shoes'
                              : 'Salary / WiFi bill / GPT bill',
                          prefixIcon: const Icon(Icons.edit_note_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a reason';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: _amountLabel(),
                          hintText: '5000',
                          prefixIcon:
                              const Icon(Icons.payments_rounded),
                        ),
                        validator: (value) {
                          final amount = _parseAmount(value ?? '');

                          if (amount <= 0) {
                            return 'Please enter a valid amount';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          hintText: 'WiFi / GPT / Food / Salary',
                          prefixIcon: Icon(Icons.label_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),

                      InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: _dateLabel(),
                            prefixIcon:
                                const Icon(Icons.calendar_month_rounded),
                          ),
                          child: Text(
                            '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      if (isInstallment) ...[
                        const SizedBox(height: 18),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Installment months',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _MonthButton(
                                label: '3 Months',
                                selected: _installmentMonths == 3,
                                onTap: () {
                                  setState(() {
                                    _installmentMonths = 3;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MonthButton(
                                label: '6 Months',
                                selected: _installmentMonths == 6,
                                onTap: () {
                                  setState(() {
                                    _installmentMonths = 6;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'PaySave will automatically create $_installmentMonths monthly payments.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Note',
                          hintText: 'Optional note',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: provider.isLoading ? null : _save,
                    icon: provider.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(
                      provider.isLoading ? 'Saving...' : 'Save Record',
                    ),
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

class _CardBox extends StatelessWidget {
  final Widget child;

  const _CardBox({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MonthButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MonthButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor:
            selected ? AppColors.primary : Colors.transparent,
        foregroundColor:
            selected ? Colors.white : AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}