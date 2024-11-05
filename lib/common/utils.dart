import 'package:intl/intl.dart';

List<Map<String, dynamic>> generateMonthDates(DateTime dateTime) {
  final List<Map<String, dynamic>> dates = [];
  final DateFormat formatter = DateFormat('dd');

  final int daysInMonth = DateTime(dateTime.year, dateTime.month + 1, 0).day;

  for (int day = 1; day <= daysInMonth; day++) {
    final DateTime date = DateTime(dateTime.year, dateTime.month, day);
    final String formattedDate = formatter.format(date);
    final String month = DateFormat('MMM').format(date);
    final bool isToday = date.isToday();

    dates.add({
      'Date': formattedDate,
      'Month': month,
      'IsToday':isToday,
    });
  }

  return dates;
}


extension DateTimeExtensions on DateTime {
  bool isToday() {
    final DateTime now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}


bool isMonthGreaterThanCurrent(int month) {
  final DateTime now = DateTime.now();
  return month >= now.month;
}

