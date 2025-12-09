import 'package:intl/intl.dart';

class Formatters {
  // Format currency to Indonesian Rupiah
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Format date to readable format (e.g., "9 Des 2025")
  static String formatDate(DateTime date) {
    final formatter = DateFormat('d MMM yyyy');
    return formatter.format(date);
  }

  // Format date with time (e.g., "9 Des 2025, 10:30")
  static String formatDateTime(DateTime date) {
    final formatter = DateFormat('d MMM yyyy, HH:mm');
    return formatter.format(date);
  }

  // Format time only (e.g., "10:30")
  static String formatTime(DateTime date) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(date);
  }

  // Format compact number (e.g., 1000 -> 1K, 1000000 -> 1M)
  static String formatCompactNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // Parse date string safely
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
