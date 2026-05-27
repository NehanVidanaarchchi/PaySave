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
import 'providers/monthly_plan_provider.dart';
import 'providers/saving_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MonthlyPlanProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
        ChangeNotifierProvider(create: (_) => InstallmentProvider()),
        ChangeNotifierProvider(create: (_) => SavingProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: const PaySaveApp(),
    ),
  );
}