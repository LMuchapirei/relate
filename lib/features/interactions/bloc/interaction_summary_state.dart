import 'package:equatable/equatable.dart';

class InteractionSummaryState extends Equatable {
  final List<String> notes;
  final String summary;
  final String feeling;
  final double mood;
  final bool isSaving;
  final bool saveSuccess;
  final String? error;

  const InteractionSummaryState({
    this.notes = const [],
    this.summary = '',
    this.feeling = '',
    this.mood = 0.0,
    this.isSaving = false,
    this.saveSuccess = false,
    this.error,
  });

  InteractionSummaryState copyWith({
    List<String>? notes,
    String? summary,
    String? feeling,
    double? mood,
    bool? isSaving,
    bool? saveSuccess,
    String? error,
  }) {
    return InteractionSummaryState(
      notes: notes ?? this.notes,
      summary: summary ?? this.summary,
      feeling: feeling ?? this.feeling,
      mood: mood ?? this.mood,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      error: error,
    );
  }

  @override
  List<Object?> get props => [notes, summary, feeling, mood, isSaving, saveSuccess, error];
}