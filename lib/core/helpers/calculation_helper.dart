class CalculationHelper {
  static double calculateRemainingBalance({
    required double income,
    required double rent,
    required double bills,
    required double savings,
    required double food,
    required double transport,
    required double other,
  }) {
    return income - rent - bills - savings - food - transport - other;
  }

  static double calculateDailySafeSpending({
    required double remainingBalance,
    DateTime? date,
  }) {
    final currentDate = date ?? DateTime.now();
    final lastDay = DateTime(currentDate.year, currentDate.month + 1, 0).day;
    final daysLeft = lastDay - currentDate.day + 1;

    if (daysLeft <= 0) return 0;
    return remainingBalance / daysLeft;
  }

  static double percentage(double value, double total) {
    if (total <= 0) return 0;
    return (value / total).clamp(0, 1);
  }

  static double installmentAmount({
    required double totalAmount,
    required int count,
  }) {
    if (count <= 0) return 0;
    return totalAmount / count;
  }
}
