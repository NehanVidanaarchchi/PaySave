import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/validation_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/saving_provider.dart';

class AddSavingGoalScreen extends StatefulWidget {
  const AddSavingGoalScreen({super.key});

  @override
  State<AddSavingGoalScreen> createState() => _AddSavingGoalScreenState();
}

class _AddSavingGoalScreenState extends State<AddSavingGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  final _goalNameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _savedAmountController = TextEditingController(text: '0');
  final _monthlyTargetController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _targetDate = DateTime.now().add(const Duration(days: 180));

  @override
  void initState() {
    super.initState();

    _targetAmountController.addListener(() => setState(() {}));
    _savedAmountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    _targetAmountController.dispose();
    _savedAmountController.dispose();
    _monthlyTargetController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _targetAmount {
    return double.tryParse(_targetAmountController.text.trim()) ?? 0;
  }

  double get _savedAmount {
    return double.tryParse(_savedAmountController.text.trim()) ?? 0;
  }

  double get _monthlyTarget {
    return double.tryParse(_monthlyTargetController.text.trim()) ?? 0;
  }

  double get _progress {
    if (_targetAmount <= 0) return 0;
    return (_savedAmount / _targetAmount).clamp(0, 1);
  }

  Future<void> _pickTargetDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );

    if (pickedDate == null) return;

    setState(() {
      _targetDate = pickedDate;
    });
  }

  Future<void> _saveGoal() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SavingProvider>();

    final success = await provider.addSavingGoal(
      goalName: _goalNameController.text,
      targetAmount: _targetAmount,
      savedAmount: _savedAmount,
      monthlyTarget: _monthlyTarget,
      targetDate: _targetDate,
      note: _noteController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      _showMessage(provider.errorMessage ?? 'Failed to save goal');
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
    final provider = context.watch<SavingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Saving Goal')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          top: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            children: [
              const Text(
                'Create saving goal',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set a target amount and track your progress every month.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              _GoalPreviewCard(
                targetAmount: _targetAmount,
                savedAmount: _savedAmount,
                progress: _progress,
              ),
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
                      CustomTextField(
                        controller: _goalNameController,
                        label: 'Goal Name',
                        hint: 'New Laptop',
                        icon: Icons.flag_rounded,
                        validator: (value) {
                          return ValidationHelper.requiredField(
                            value,
                            fieldName: 'Goal name',
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _targetAmountController,
                        label: 'Target Amount',
                        hint: '250000',
                        icon: Icons.track_changes_rounded,
                        keyboardType: TextInputType.number,
                        validator: ValidationHelper.amount,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _savedAmountController,
                        label: 'Already Saved',
                        hint: '45000',
                        icon: Icons.savings_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _monthlyTargetController,
                        label: 'Monthly Saving Target',
                        hint: '22000',
                        icon: Icons.calendar_month_rounded,
                        keyboardType: TextInputType.number,
                        validator: ValidationHelper.amount,
                      ),
                      const SizedBox(height: 16),
                      _DateBox(
                        title: 'Target Date',
                        value:
                            '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                        onTap: _pickTargetDate,
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
                        text: 'Save Goal',
                        icon: Icons.check_rounded,
                        isLoading: provider.isLoading,
                        onPressed: _saveGoal,
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

class _GoalPreviewCard extends StatelessWidget {
  final double targetAmount;
  final double savedAmount;
  final double progress;

  const _GoalPreviewCard({
    required this.targetAmount,
    required this.savedAmount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toStringAsFixed(0);
    final remaining = (targetAmount - savedAmount).clamp(0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: AppColors.cardPurpleGradient,
        borderRadius: BorderRadius.circular(30),
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
          const Text(
            'Goal Preview',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percent%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${CurrencyHelper.format(savedAmount)} saved • ${CurrencyHelper.format(remaining.toDouble())} remaining',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.2),
              color: Colors.white,
            ),
          ),
        ],
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
