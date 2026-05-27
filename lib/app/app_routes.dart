import 'package:flutter/material.dart';

import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/bills/add_bill_screen.dart';
import '../features/bills/bills_screen.dart';
import '../features/bills/edit_bill_screen.dart';
import '../features/expenses/add_expense_screen.dart';
import '../features/expenses/expenses_screen.dart';
import '../features/home/home_screen.dart';
import '../features/installments/add_installment_screen.dart';
import '../features/installments/installment_details_screen.dart';
import '../features/installments/installments_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/planner/monthly_plan_screen.dart';
import '../features/planner/monthly_plan_setup_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/savings/add_saving_goal_screen.dart';
import '../features/savings/savings_screen.dart';
import '../features/settings/profile_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String home = '/home';

  static const String monthlyPlanSetup = '/monthly-plan-setup';
  static const String monthlyPlan = '/monthly-plan';

  static const String bills = '/bills';
  static const String addBill = '/add-bill';
  static const String editBill = '/edit-bill';

  static const String installments = '/installments';
  static const String addInstallment = '/add-installment';
  static const String installmentDetails = '/installment-details';

  static const String savings = '/savings';
  static const String addSavingGoal = '/add-saving-goal';

  static const String expenses = '/expenses';
  static const String addExpense = '/add-expense';

  static const String reports = '/reports';

  static const String settings = '/settings';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _page(const SplashScreen());

      case onboarding:
        return _page(const OnboardingScreen());

      case login:
        return _page(const LoginScreen());

      case register:
        return _page(const RegisterScreen());

      case forgotPassword:
        return _page(const ForgotPasswordScreen());

      case home:
        return _page(const HomeScreen());

      case monthlyPlanSetup:
        return _page(const MonthlyPlanSetupScreen());

      case monthlyPlan:
        return _page(const MonthlyPlanScreen());

      case bills:
        return _page(const BillsScreen());

      case addBill:
        return _page(const AddBillScreen());

      case editBill:
        final billId = settings.arguments as String?;
        return _page(EditBillScreen(billId: billId));

      case installments:
        return _page(const InstallmentsScreen());

      case addInstallment:
        return _page(const AddInstallmentScreen());

      case installmentDetails:
        final installmentId = settings.arguments as String?;
        return _page(InstallmentDetailsScreen(installmentId: installmentId));

      case savings:
        return _page(const SavingsScreen());

      case addSavingGoal:
        return _page(const AddSavingGoalScreen());

      case expenses:
        return _page(const ExpensesScreen());

      case addExpense:
        return _page(const AddExpenseScreen());

      case reports:
        return _page(const ReportsScreen());

      case settings:
        return _page(const SettingsScreen());

      case profile:
        return _page(const ProfileScreen());

      default:
        return _page(
          const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }

  static PageRouteBuilder _page(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }
}
