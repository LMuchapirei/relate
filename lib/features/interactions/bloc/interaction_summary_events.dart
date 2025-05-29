import 'package:equatable/equatable.dart';

abstract class InteractionSummaryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateNotesEvent extends InteractionSummaryEvent {
  final List<String> notes;
  UpdateNotesEvent(this.notes);
  @override
  List<Object?> get props => [notes];
}

class UpdateSummaryEvent extends InteractionSummaryEvent {
  final String summary;
  UpdateSummaryEvent(this.summary);
  @override
  List<Object?> get props => [summary];
}

class UpdateFeelingEvent extends InteractionSummaryEvent {
  final String feeling;
  UpdateFeelingEvent(this.feeling);
  @override
  List<Object?> get props => [feeling];
}

class UpdateMoodEvent extends InteractionSummaryEvent {
  final double mood;
  UpdateMoodEvent(this.mood);
  @override
  List<Object?> get props => [mood];
}

class SaveSummaryEvent extends InteractionSummaryEvent {
  final String userId;
  final String relationshipId;
  final List<String> attachments;
  final List<String> notes;
  final String summary;
  final String feeling;
  final double mood;

  SaveSummaryEvent({
    required this.userId,
    required this.relationshipId,
    required this.attachments,
    required this.notes,
    required this.summary,
    required this.feeling,
    required this.mood,
  });

  @override
  List<Object?> get props => [userId, relationshipId, attachments, notes, summary, feeling, mood];
}