import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/currency_helper.dart';
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

    if (widget.initialType != null && widget.initialType!.isNotEmpty) {
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
      case MoneyRecordModel.typeIncome:
        return 'Income';
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
      case MoneyRecordModel.typeIncome:
        return 'Add Income';
      case MoneyRecordModel.typeBill:
        return 'Add Bill';
      case MoneyRecordModel.typeExpense:
        return 'Add Expense';
      case MoneyRecordModel.typeSaving:
        return 'Add Saving';
      case MoneyRecordModel.typeInstallment:
        return 'Add Koko Payment';
      default:
        return 'Add Record';
    }
  }

  String _screenSubtitle() {
    switch (_type) {
      case MoneyRecordModel.typeSalary:
        return 'Add your monthly salary or main income.';
      case MoneyRecordModel.typeIncome:
        return 'Add extra income or one-time money received.';
      case MoneyRecordModel.typeBill:
        return 'Add WiFi, GPT, electricity, phone, or other bills.';
      case MoneyRecordModel.typeExpense:
        return 'Add food, transport, shopping, or daily expenses.';
      case MoneyRecordModel.typeSaving:
        return 'Add money you want to save.';
      case MoneyRecordModel.typeInstallment:
        return 'Add Koko-style 3 month or 6 month payment plans.';
      default:
        return 'Add your money record details.';
    }
  }

  IconData _screenIcon() {
    switch (_type) {
      case MoneyRecordModel.typeSalary:
        return Icons.payments_rounded;
      case MoneyRecordModel.typeIncome:
        return Icons.trending_up_rounded;
      case MoneyRecordModel.typeBill:
        return Icons.receipt_long_rounded;
      case MoneyRecordModel.typeExpense:
        return Icons.shopping_bag_rounded;
      case MoneyRecordModel.typeSaving:
        return Icons.savings_rounded;
      case MoneyRecordModel.typeInstallment:
        return Icons.calendar_month_rounded;
      default:
        return Icons.add_card_rounded;
    }
  }

  Color _screenColor() {
    switch (_type) {
      case MoneyRecordModel.typeSalary:
      case MoneyRecordModel.typeIncome:
        return AppColors.success;
      case MoneyRecordModel.typeBill:
        return AppColors.warning;
      case MoneyRecordModel.typeExpense:
        return AppColors.danger;
      case MoneyRecordModel.typeSaving:
        return AppColors.savings;
      case MoneyRecordModel.typeInstallment:
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  String _amountLabel() {
    if (_type == MoneyRecordModel.typeInstallment) {
      return 'Total amount';
    }

    return 'Amount';
  }

  String _dateLabel() {
    if (_type == MoneyRecordModel.typeSalary ||
        _type == MoneyRecordModel.typeIncome) {
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

  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  double get _amountPreview {
    return _parseAmount(_amountController.text);
  }

  double get _monthlyInstallmentPreview {
    if (_installmentMonths <= 0) return 0;
    return _amountPreview / _installmentMonths;
  }

  TextStyle get _fieldTextStyle {
    return const TextStyle(
      color: AppColors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w800,
    );
  }

  InputDecoration _fieldDecoration({
    required String labelText,
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: labelText,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
      hintStyle: const TextStyle(
        color: AppColors.textLight,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(
        icon,
        color: AppColors.primary,
        size: 22,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: AppColors.border,
          width: 1.4,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: AppColors.danger,
          width: 1.4,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: AppColors.danger,
          width: 1.8,
        ),
      ),
    );
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

  void _changeType(String type) {
    setState(() {
      _type = type;
      _categoryController.text = _defaultCategory(type);
    });
  }

  void _goHomeAfterSave() {
    if (!mounted) return;

    FocusScope.of(context).unfocus();

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<MoneyRecordProvider>();

    final title = _titleController.text.trim();
    final amount = _parseAmount(_amountController.text);
    final category = _categoryController.text.trim().isEmpty
        ? _defaultCategory(_type)
        : _categoryController.text.trim();
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
        isPaid: _type == MoneyRecordModel.typeSalary ||
            _type == MoneyRecordModel.typeIncome,
      );
    }

    if (!mounted) return;

    if (success) {
      _goHomeAfterSave();
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.softGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 150),
              children: [
                _PageHeader(
                  title: _screenTitle(),
                  subtitle: _screenSubtitle(),
                  icon: _screenIcon(),
                  color: _screenColor(),
                  showBack: Navigator.of(context).canPop(),
                ),
                const SizedBox(height: 22),
                _HeroRecordCard(
                  title: _screenTitle(),
                  subtitle: _screenSubtitle(),
                  icon: _screenIcon(),
                ),
                const SizedBox(height: 22),
                const _SectionTitle(
                  title: 'Record Type',
                  subtitle: 'Choose what kind of money record this is.',
                ),
                const SizedBox(height: 12),
                _TypeGrid(
                  selectedType: _type,
                  onChanged: _changeType,
                ),
                const SizedBox(height: 22),
                const _SectionTitle(
                  title: 'Details',
                  subtitle: 'Add amount, reason, category, and date.',
                ),
                const SizedBox(height: 12),
                _CardBox(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        style: _fieldTextStyle,
                        cursorColor: AppColors.primary,
                        decoration: _fieldDecoration(
                          labelText:
                              isInstallment ? 'Purchase name' : 'Reason / name',
                          hintText: isInstallment
                              ? 'Phone / Laptop / Shoes'
                              : 'Salary / WiFi bill / GPT bill',
                          icon: Icons.edit_note_rounded,
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
                        style: _fieldTextStyle,
                        cursorColor: AppColors.primary,
                        keyboardType: TextInputType.number,
                        decoration: _fieldDecoration(
                          labelText: _amountLabel(),
                          hintText: '5000',
                          icon: Icons.payments_rounded,
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
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
                        style: _fieldTextStyle,
                        cursorColor: AppColors.primary,
                        decoration: _fieldDecoration(
                          labelText: 'Category',
                          hintText: 'WiFi / GPT / Food / Salary',
                          icon: Icons.label_rounded,
                        ),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: _fieldDecoration(
                            labelText: _dateLabel(),
                            hintText: 'Select date',
                            icon: Icons.calendar_month_rounded,
                          ),
                          child: Text(
                            _formatDate(_selectedDate),
                            style: _fieldTextStyle,
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
                              fontSize: 14,
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
                        const SizedBox(height: 14),
                        _InstallmentPreview(
                          months: _installmentMonths,
                          totalAmount: _amountPreview,
                          monthlyAmount: _monthlyInstallmentPreview,
                        ),
                      ],
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _noteController,
                        style: _fieldTextStyle,
                        cursorColor: AppColors.primary,
                        maxLines: 3,
                        decoration: _fieldDecoration(
                          labelText: 'Note',
                          hintText: 'Optional note',
                          icon: Icons.notes_rounded,
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

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool showBack;

  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.showBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack) ...[
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PaySave',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.20)),
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _HeroRecordCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HeroRecordCard({
    required this.title,
    required this.subtitle,
    required this.icon,
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
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
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

class _TypeGrid extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const _TypeGrid({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _TypeItem(
        type: MoneyRecordModel.typeSalary,
        title: 'Salary',
        icon: Icons.payments_rounded,
        color: AppColors.success,
      ),
      _TypeItem(
        type: MoneyRecordModel.typeBill,
        title: 'Bill',
        icon: Icons.receipt_long_rounded,
        color: AppColors.warning,
      ),
      _TypeItem(
        type: MoneyRecordModel.typeExpense,
        title: 'Expense',
        icon: Icons.shopping_bag_rounded,
        color: AppColors.danger,
      ),
      _TypeItem(
        type: MoneyRecordModel.typeInstallment,
        title: 'Koko',
        icon: Icons.calendar_month_rounded,
        color: AppColors.primary,
      ),
      _TypeItem(
        type: MoneyRecordModel.typeSaving,
        title: 'Saving',
        icon: Icons.savings_rounded,
        color: AppColors.savings,
      ),
      _TypeItem(
        type: MoneyRecordModel.typeIncome,
        title: 'Income',
        icon: Icons.trending_up_rounded,
        color: AppColors.info,
      ),
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = selectedType == item.type;

        return _TypeButton(
          item: item,
          selected: selected,
          onTap: () => onChanged(item.type),
        );
      },
    );
  }
}

class _TypeItem {
  final String type;
  final String title;
  final IconData icon;
  final Color color;

  const _TypeItem({
    required this.type,
    required this.title,
    required this.icon,
    required this.color,
  });
}

class _TypeButton extends StatelessWidget {
  final _TypeItem item;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? item.color : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? item.color : AppColors.border,
              width: 1.2,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: item.color.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                color: selected ? Colors.white : item.color,
                size: 25,
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontSize: 11,
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

class _InstallmentPreview extends StatelessWidget {
  final int months;
  final double totalAmount;
  final double monthlyAmount;

  const _InstallmentPreview({
    required this.months,
    required this.totalAmount,
    required this.monthlyAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softLavender.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.calculate_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              totalAmount <= 0
                  ? 'PaySave will create $months monthly payments.'
                  : '${CurrencyHelper.format(totalAmount)} ÷ $months months = ${CurrencyHelper.format(monthlyAmount)} per month',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 14),
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
        backgroundColor: selected ? AppColors.primary : Colors.white,
        foregroundColor: selected ? Colors.white : AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.3),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}