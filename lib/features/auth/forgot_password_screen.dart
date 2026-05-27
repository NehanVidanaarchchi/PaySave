import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/validation_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import 'widgets/auth_header.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.sendPasswordResetEmail(
      email: _emailController.text,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _sent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to send email'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              children: [
                const AuthHeader(
                  title: 'Reset password',
                  subtitle:
                      'Enter your email and we will send a password reset link.',
                ),
                const SizedBox(height: 34),
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
                  child: _sent
                      ? Column(
                          children: [
                            Container(
                              height: 78,
                              width: 78,
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: const Icon(
                                Icons.mark_email_read_rounded,
                                color: AppColors.success,
                                size: 38,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Check your email',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'We sent a password reset link to your email address.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 22),
                            CustomButton(
                              text: 'Back to Login',
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        )
                      : Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: _emailController,
                                label: 'Email',
                                hint: 'example@email.com',
                                icon: Icons.email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: ValidationHelper.email,
                              ),
                              const SizedBox(height: 22),
                              CustomButton(
                                text: 'Send Reset Link',
                                isLoading: authProvider.isLoading,
                                onPressed: _sendResetEmail,
                              ),
                            ],
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
