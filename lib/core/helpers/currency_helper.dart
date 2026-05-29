import 'package:intl/intl.dart';

class CurrencyHelper {
  static final NumberFormat _formatter = NumberFormat('#,##0.##');

  static String format(double amount, {String symbol = 'Rs.'}) {
    return '$symbol ${_formatter.format(amount)}';
  }

  static double parse(String value) {
    final cleaned = value.replaceAll(',', '').replaceAll('Rs.', '').trim();
    return double.tryParse(cleaned) ?? 0;
  }
}