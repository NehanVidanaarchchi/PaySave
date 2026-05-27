import '../firebase/firebase_expense_service.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final FirebaseExpenseService _expenseService = FirebaseExpenseService();

  Future<void> addExpense(ExpenseModel expense) async {
    await _expenseService.addExpense(expense);
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _expenseService.updateExpense(expense);
  }

  Future<ExpenseModel?> getExpenseById(String expenseId) async {
    return _expenseService.getExpenseById(expenseId);
  }

  Stream<List<ExpenseModel>> watchExpenses() {
    return _expenseService.watchExpenses();
  }

  Stream<List<ExpenseModel>> watchExpensesByMonth({required DateTime month}) {
    return _expenseService.watchExpensesByMonth(month: month);
  }

  Future<void> deleteExpense(String expenseId) async {
    await _expenseService.deleteExpense(expenseId);
  }
}
