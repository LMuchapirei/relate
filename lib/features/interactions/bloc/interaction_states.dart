import 'package:flutter/material.dart';
import 'package:relate/features/interactions/models/interaction_model.dart';

class InteractionFormStates {
  final String title;
  final String notes;
  final String frequency;
  final String priority;
  final String selectedRedirectApp;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;

  const InteractionFormStates({
    this.title = "",
    this.notes = "",
    this.frequency = "",
    this.priority = "",
    this.selectedDate,
    this.selectedTime,
    this.selectedRedirectApp = ""
  });

  InteractionFormStates copyWith({
   String? title,
   String? notes,
   String? frequency,
   String? priority,
   String? selectedRedirectApp,
   DateTime? selectedDate,
   TimeOfDay? selectedTime,
  }) {
    return InteractionFormStates(
       title: title ?? this.title,
       notes: notes ?? this.notes,
       frequency: frequency ?? this.frequency,
       priority : priority ?? this.priority,
       selectedRedirectApp: selectedRedirectApp ?? this.selectedRedirectApp,
       selectedDate: selectedDate ?? this.selectedDate,
       selectedTime : selectedTime ?? this.selectedTime,
     );
  }

}

abstract class InteractionListState {
  final List<Interaction> scheduledInteractions;
  final bool isLoading;
  final String? error;
  InteractionListState({
    this.scheduledInteractions = const [],
    this.isLoading = false,
    this.error
  });
}


class InteractionListInitial extends InteractionListState {}

class InteractionListLoading extends InteractionListState {
  InteractionListLoading() : super(isLoading: true);
}

class InteractionListLoaded extends InteractionListState {
  InteractionListLoaded({required super.scheduledInteractions})
      : super(isLoading: false);
}

class InteractionListError extends InteractionListState {
        InteractionListError({required String error})
      : super(isLoading: false, error: error);
}
