import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/validation_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models/expense_model.dart';
import '../../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = ExpenseModel.typeExpense;
  String _category = 'Food';
  DateTime _date = DateTime.now();

  final List<String> _expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Education',
    'Health',
    'Internet',
    'Rent',
    'Bills',
    'Other',
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Gift',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    _amountController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _amount {
    return double.tryParse(_amountController.text.trim()) ?? 0;
  }

  List<String> get _categories {
    return _type == ExpenseModel.typeIncome
        ? _incomeCategories
        : _expenseCategories;
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (pickedDate == null) return;

    setState(() {
      _date = pickedDate;
    });
  }

  void _changeType(String type) {
    setState(() {
      _type = type;
      _category = type == ExpenseModel.typeIncome ? 'Salary' : 'Food';
    });
  }

  Future<void> _saveRecord() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ExpenseProvider>();

    final success = await provider.addExpense(
      title: _titleController.text,
      amount: _amount,
      type: _type,
      category: _category,
      date: _date,
      note: _noteController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      _showMessage(provider.errorMessage ?? 'Failed to save record');
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
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Record')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          top: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            children: [
              const Text(
                'Add money record',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Record income or expense manually. This is not a money transfer.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              _RecordPreviewCard(type: _type, amount: _amount),
              const SizedBox(height: 18),
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
                      _TypeSelector(
                        selectedType: _type,
                        onChanged: _changeType,
                      ),
                      const SizedBox(height: 18),
                      CustomTextField(
                        controller: _titleController,
                        label: 'Title',
                        hint: _type == ExpenseModel.typeIncome
                            ? 'Salary'
                            : 'Lunch',
                        icon: Icons.edit_note_rounded,
                        validator: (value) {
                          return ValidationHelper.requiredField(
                            value,
                            fieldName: 'Title',
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _amountController,
                        label: 'Amount',
                        hint: _type == ExpenseModel.typeIncome
                            ? '55000'
                            : '1200',
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
                      _DateBox(
                        title: 'Date',
                        value: '${_date.day}/${_date.month}/${_date.year}',
                        onTap: _pickDate,
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
                        text: 'Save Record',
                        icon: Icons.check_rounded,
                        isLoading: provider.isLoading,
                        onPressed: _saveRecord,
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

class _RecordPreviewCard extends StatelessWidget {
  final String type;
  final double amount;

  const _RecordPreviewCard({required this.type, required this.amount});

  @override
  Widget build(BuildContext context) {
    final isIncome = type == ExpenseModel.typeIncome;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: isIncome
            ? const LinearGradient(
                colors: [Color(0xFF26B56E), Color(0xFF12A56C)],
              )
            : const LinearGradient(
                colors: [Color(0xFFFF7676), Color(0xFFFF4F68)],
              ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: (isIncome ? AppColors.success : AppColors.danger)
                .withOpacity(0.23),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              isIncome
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIncome ? 'Income Record' : 'Expense Record',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyHelper.format(amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
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

class _TypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const _TypeSelector({required this.selectedType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isIncome = selectedType == ExpenseModel.typeIncome;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              title: 'Expense',
              icon: Icons.trending_down_rounded,
              isSelected: !isIncome,
              color: AppColors.danger,
              onTap: () => onChanged(ExpenseModel.typeExpense),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TypeButton(
              title: 'Income',
              icon: Icons.trending_up_rounded,
              isSelected: isIncome,
              color: AppColors.success,
              onTap: () => onChanged(ExpenseModel.typeIncome),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: isSelected ? Colors.white : color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontSize: 13,
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

class _DropdownBox extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownBox({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(
          Icons.category_rounded,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _DateBox({
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
              const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primary,
              ),
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
