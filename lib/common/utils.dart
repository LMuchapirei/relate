import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// List<Map<String, dynamic>> generateMonthDates(DateTime dateTime) {
//   final List<Map<String, dynamic>> dates = [];
//   final DateFormat formatter = DateFormat('dd');
//   final DateTime today = DateTime.now();
//   final int daysInMonth = DateTime(dateTime.year, dateTime.month + 1, 0).day;

//   for (int day = 1; day <= daysInMonth; day++) {
//      DateTime date = DateTime(dateTime.year, dateTime.month, day);
//      String formattedDate = formatter.format(date);
//      String month = DateFormat('MMM').format(date);
//      bool isToday = date.year == today.year &&
//                          date.month == today.month &&
//                          date.day == today.day;
//     dates.add({
//       'Date': formattedDate,
//       'Month': month,
//       'IsToday':isToday,
//     });
//   }
//   print(dates);
//   return dates;
// }


// extension DateTimeExtensions on DateTime {
//   bool isToday() {
//     final DateTime now = DateTime.now();
//     return year == now.year && month == now.month && day == now.day;
//   }

//   String dMMYYY(){
//     final format = DateFormat('d MMMM yyyy');
//     return format.format(this);
//   }
// }

extension DateTimeExtensions on DateTime {
  bool isToday() {
    final DateTime now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

    String dMMYYY(){
    final format = DateFormat('d MMMM yyyy');
    return format.format(this);
  }
}

List<Map<String, dynamic>> getDatesOfMonth(DateTime dateTime) {
  final List<Map<String, dynamic>> dates = [];
  final DateFormat dayFormatter = DateFormat('dd');
  final DateFormat monthFormatter = DateFormat('MMM');

  final int daysInMonth = DateTime(dateTime.year, dateTime.month + 1, 0).day;

  for (int day = 1; day <= daysInMonth; day++) {
    final DateTime current = DateTime(dateTime.year, dateTime.month, day);
    
    dates.add({
      'date': dayFormatter.format(current),     
      'isToday': current.isToday(),            
      'month': monthFormatter.format(current),  
    });
  }

  return dates;
}


bool isMonthGreaterThanCurrent(int month) {
  final DateTime now = DateTime.now();
  return month >= now.month;
}



TimeOfDay deserializeTimeOfDay(String timeString) {
  final parts = timeString.split(':');
  if (parts.length != 2) {
    throw const  FormatException('Invalid time format, expected HH:mm');
  }

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);

  if (hour == null || minute == null) {
    throw  const FormatException('Invalid hour or minute in time string');
  }

  return TimeOfDay(hour: hour, minute: minute);
}

String serializeTimeOfDay(TimeOfDay? time) {
  if(time == null) {
    return "";
  }
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}


Map<String, dynamic> getLast90DaysData(DateTime endDate ) {
  final DateTime startDate = endDate.subtract(const Duration(days: 89));
  final DateFormat formatter = DateFormat('dd MMM yyyy');

  String label = 'Last 90 Days (${formatter.format(startDate)} - ${formatter.format(endDate)})';

  return {
    'label': label,
    'startDate': startDate,
    'endDate': endDate,
  };
}
