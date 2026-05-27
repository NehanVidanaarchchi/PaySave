import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/helpers/validation_helper.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/firebase/firebase_user_service.dart';
import '../../data/models/user_model.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _loaded = false;
  String _currency = 'LKR';
  String _themeMode = 'light';
  int _reminderMinutesBefore = 1440;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadUser(UserModel? user) {
    if (_loaded) return;

    final firebaseUser = FirebaseAuth.instance.currentUser;

    _nameController.text =
        user?.name ?? firebaseUser?.displayName ?? 'PaySave User';
    _emailController.text = user?.email ?? firebaseUser?.email ?? '';

    _currency = user?.currency ?? 'LKR';
    _themeMode = user?.themeMode ?? 'light';
    _reminderMinutesBefore = user?.reminderMinutesBefore ?? 1440;

    _loaded = true;
  }

  Future<void> _saveProfile(UserModel? currentUserModel) async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      _showMessage('User not logged in');
      return;
    }

    final now = DateTime.now();

    final updatedUser = UserModel(
      uid: firebaseUser.uid,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      photoUrl: firebaseUser.photoURL,
      currency: _currency,
      themeMode: _themeMode,
      reminderMinutesBefore: _reminderMinutesBefore,
      createdAt: currentUserModel?.createdAt ?? now,
      updatedAt: now,
    );

    await firebaseUser.updateDisplayName(updatedUser.name);

    if (!mounted) return;

    final success = await context.read<UserProvider>().updateUserProfile(
      updatedUser,
    );

    if (!mounted) return;

    if (success) {
      _showSuccess('Profile updated');
    } else {
      _showMessage(
        context.read<UserProvider>().errorMessage ?? 'Failed to update profile',
      );
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = FirebaseUserService();
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          top: false,
          child: StreamBuilder<UserModel?>(
            stream: userService.watchCurrentUserProfile(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              _loadUser(user);

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                children: [
                  _ProfileHero(
                    name: _nameController.text.isEmpty
                        ? 'PaySave User'
                        : _nameController.text,
                    email: _emailController.text,
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
                            controller: _nameController,
                            label: 'Name',
                            icon: Icons.person_rounded,
                            validator: (value) {
                              return ValidationHelper.requiredField(
                                value,
                                fieldName: 'Name',
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: ValidationHelper.email,
                          ),
                          const SizedBox(height: 16),
                          _DropdownBox(
                            label: 'Currency',
                            value: _currency,
                            items: const ['LKR', 'USD', 'EUR', 'INR'],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _currency = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          _DropdownBox(
                            label: 'Theme Mode',
                            value: _themeMode,
                            items: const ['light', 'dark', 'system'],
                            labelBuilder: (value) {
                              if (value == 'light') return 'Light';
                              if (value == 'dark') return 'Dark';
                              return 'System';
                            },
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _themeMode = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          _DropdownBox<int>(
                            label: 'Default Reminder',
                            value: _reminderMinutesBefore,
                            items: const [0, 60, 1440, 4320, 10080],
                            labelBuilder: (value) {
                              switch (value) {
                                case 0:
                                  return 'On due time';
                                case 60:
                                  return '1 hour before';
                                case 1440:
                                  return '1 day before';
                                case 4320:
                                  return '3 days before';
                                case 10080:
                                  return '1 week before';
                                default:
                                  return '$value minutes before';
                              }
                            },
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _reminderMinutesBefore = value);
                            },
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Save Profile',
                            icon: Icons.check_rounded,
                            isLoading: userProvider.isLoading,
                            onPressed: () => _saveProfile(user),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Your profile is used only for your PaySave account and app preferences.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileHero({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.17),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
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

class _DropdownBox<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T value)? labelBuilder;

  const _DropdownBox({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(labelBuilder?.call(item) ?? item.toString()),
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
