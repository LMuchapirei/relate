

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:relate/common/utils.dart';

class Interaction {
    final String? id;
    final String title;
    final String notes;
    final String frequency;
    final String priority;
    final String selectedRedirectApp;
    final DateTime? selectedDate;
    final TimeOfDay? selectedTime;
    final String? createdAt;

    const Interaction({
      this.id,
      this.title = "",
      this.notes = "",
      this.frequency = "",
      this.priority = "",
      this.selectedDate,
      this.selectedTime,
      this.selectedRedirectApp = "",
      this.createdAt
    });

    Map<String, dynamic> toMap() {
      final selectedDateObject = selectedDate != null ? Timestamp.fromDate(selectedDate!) :  null ;
      final selectedTimeString = selectedTime != null ? serializeTimeOfDay(selectedTime!) :  "" ;
      return {
        'title': title,
        'notes': notes,
        'priority': priority,
        'frequency': frequency,
        'selectedRedirectApp': selectedRedirectApp,
        'selectedDate': selectedDateObject,
        'selectedTime': selectedTimeString,
        'createdAt':FieldValue.serverTimestamp(),
      };
  }

    factory Interaction.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final timestamp = data['selectedDate'] as Timestamp?;
    final timeString = data['selectedTime'] as String?;
    final createdAtTimestamp = data['createdAt'] as Timestamp?;

    String? createdAtFormatted;
    if (createdAtTimestamp != null) {
      createdAtFormatted = DateFormat('d MMMM yy').format(createdAtTimestamp.toDate());
    }

    return Interaction(
      id: doc.id,
      title: data['title'] ?? '',
      notes: data['notes'] ?? '',
      frequency: data['frequency'] ?? '',
      priority: data['priority'] ?? '',
      selectedRedirectApp: data['selectedRedirectApp'] ?? '',
      selectedDate: timestamp?.toDate(),
      selectedTime: (timeString != null && timeString.isNotEmpty)
          ? deserializeTimeOfDay(timeString)
          : null,
      createdAt: createdAtFormatted ?? '',
    );
  }
}