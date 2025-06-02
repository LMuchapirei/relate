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
  final String relationshipId;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String? createdAt;

  const Interaction({
    this.id,
    this.title = "",
    this.notes = "",
    this.frequency = "",
    this.priority = "",
    this.relationshipId = "",
    this.selectedDate,
    this.selectedTime,
    this.selectedRedirectApp = "",
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final selectedDateString = selectedDate?.toIso8601String();
    final selectedTimeString = selectedTime != null ? serializeTimeOfDay(selectedTime!) : "";
    return {
      'title': title,
      'notes': notes,
      'relationshipId': relationshipId,
      'priority': priority,
      'frequency': frequency,
      'selectedRedirectApp': selectedRedirectApp,
      'selectedDate': selectedDateString,
      'selectedTime': selectedTimeString,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Factory for Appwrite document
  factory Interaction.fromMap(Map<String, dynamic> map) {
    // Appwrite stores dates as ISO8601 strings
    DateTime? selectedDate;
    if (map['selectedDate'] != null && map['selectedDate'] is String) {
      selectedDate = DateTime.tryParse(map['selectedDate']);
    }
    
    TimeOfDay? selectedTime;
    if (map['selectedTime'] != null && map['selectedTime'] is String) {
      final DateTime? timeDate = DateTime.tryParse(map['selectedTime']);
      if (timeDate != null) {
        selectedTime = TimeOfDay(hour: timeDate.hour, minute: timeDate.minute);
      }
    }

    String? createdAtFormatted;
    if (map['\$createdAt'] != null && map['\$createdAt'] is String) {
      final dt = DateTime.tryParse(map['\$createdAt']);
      if (dt != null) {
        createdAtFormatted = DateFormat('d MMMM yy').format(dt);
      }
    } else if (map['createdAt'] != null && map['createdAt'] is String) {
      final dt = DateTime.tryParse(map['createdAt']);
      if (dt != null) {
        createdAtFormatted = DateFormat('d MMMM yy').format(dt);
      }
    }

    return Interaction(
      id: map['\$id'] ?? map['id'],
      title: map['title'] ?? '',
      notes: map['notes'] ?? '',
      frequency: map['frequency'] ?? '',
      priority: map['priority'] ?? '',
      selectedRedirectApp: map['selectedRedirectApp'] ?? '',
      relationshipId: map['relationshipId'] ?? '',
      selectedDate: selectedDate,
      selectedTime: selectedTime,
      createdAt: createdAtFormatted ?? '',
    );
  }
}