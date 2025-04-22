

import 'package:flutter/material.dart';

class DatePill extends StatelessWidget {
  final String date;
  final String month;
  const DatePill({super.key,required this.date, required this.month});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(date),
        Text(month)
      ],
    );
  }
}