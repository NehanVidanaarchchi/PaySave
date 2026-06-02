import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text('Are you sure you want to logout from PaySave?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Logout',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    // await context.read<AuthProvider>().logout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.softGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage your profile, reminders, theme, and app preferences.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              _ProfileCard(
                name: user?.displayName ?? 'PaySave User',
                email: user?.email ?? 'No email',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.profile);
                },
              ),
              const SizedBox(height: 22),
              const _SectionTitle(title: 'Preferences'),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.currency_exchange_rounded,
                title: 'Currency',
                subtitle: 'Sri Lankan Rupees - Rs.',
                color: AppColors.info,
                onTap: () {
                  _showInfo(
                    context,
                    'Currency',
                    'PaySave currently uses Sri Lankan Rupees. Multi-currency support can be added later.',
                  );
                },
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.notifications_active_rounded,
                title: 'Reminder Preferences',
                subtitle: 'Bill and installment reminders',
                color: AppColors.warning,
                onTap: () {
                  _showInfo(
                    context,
                    'Reminder Preferences',
                    'You can set reminder times when adding bills and installments.',
                  );
                },
              ),
              const SizedBox(height: 12),
              _SettingsSwitchTile(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                subtitle: 'Switch app theme',
                color: AppColors.primary,
                value: themeProvider.isDarkMode,
                onChanged: (_) {
                  themeProvider.toggleTheme();
                },
              ),
              const SizedBox(height: 22),
              const _SectionTitle(title: 'Data'),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.file_download_rounded,
                title: 'Export Data',
                subtitle: 'Coming soon',
                color: AppColors.success,
                onTap: () {
                  _showInfo(
                    context,
                    'Export Data',
                    'PDF or Excel export can be added in a later version.',
                  );
                },
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.cloud_done_rounded,
                title: 'Firebase Cloud Sync',
                subtitle: 'Your data is saved under your account',
                color: AppColors.primary,
                onTap: () {
                  _showInfo(
                    context,
                    'Firebase Cloud Sync',
                    'Your monthly plans, bills, installments, savings, and records are stored in Firebase Firestore.',
                  );
                },
              ),
              const SizedBox(height: 22),
              const _SectionTitle(title: 'About'),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
                subtitle: 'Planning app only',
                color: AppColors.info,
                onTap: () {
                  _showInfo(
                    context,
                    'Privacy Policy',
                    'PaySave is only a planning and reminder app. It does not transfer money, connect to banks, or process payments.',
                  );
                },
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.info_rounded,
                title: 'About PaySave',
                subtitle: 'Version 1.0.0',
                color: AppColors.primary,
                onTap: () {
                  _showInfo(
                    context,
                    'About PaySave',
                    'PaySave helps users plan monthly income, savings, bills, and installment reminders.',
                  );
                },
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _logout(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'PaySave does not transfer money, connect to banks, or process payments.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.name,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            gradient: AppColors.cardPurpleGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.22),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 34,
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
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
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
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textLight,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
