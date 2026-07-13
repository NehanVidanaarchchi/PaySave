import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/bill_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/installment_provider.dart';
import 'providers/money_record_provider.dart';
import 'providers/monthly_plan_provider.dart';
import 'providers/saving_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await NotificationService.instance.init();
  } catch (e) {
    debugPrint('Notification init error: $e');
  }

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider<MonthlyPlanProvider>(
          create: (_) => MonthlyPlanProvider(),
        ),
        ChangeNotifierProvider<BillProvider>(
          create: (_) => BillProvider(),
        ),
        ChangeNotifierProvider<InstallmentProvider>(
          create: (_) => InstallmentProvider(),
        ),
        ChangeNotifierProvider<SavingProvider>(
          create: (_) => SavingProvider(),
        ),
        ChangeNotifierProvider<ExpenseProvider>(
          create: (_) => ExpenseProvider(),
        ),
        ChangeNotifierProvider<MoneyRecordProvider>(
          create: (_) => MoneyRecordProvider(),
        ),
      ],
      child: const PaySaveApp(),
    ),
  );
}