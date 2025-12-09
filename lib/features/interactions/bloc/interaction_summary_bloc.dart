import 'package:flutter_bloc/flutter_bloc.dart';
import 'interaction_summary_events.dart';
import 'interaction_summary_state.dart';
import 'interaction_summary_controller.dart';

class InteractionSummaryBloc
    extends Bloc<InteractionSummaryEvent, InteractionSummaryState> {
  final InteractionSummaryController controller;

  InteractionSummaryBloc(this.controller)
      : super(const InteractionSummaryState()) {
    on<UpdateNotesEvent>((event, emit) {
      emit(state.copyWith(notes: event.notes));
    });
    on<UpdateSummaryEvent>((event, emit) {
      emit(state.copyWith(summary: event.summary));
    });
    on<UpdateFeelingEvent>((event, emit) {
      emit(state.copyWith(feeling: event.feeling));
    });
    on<UpdateMoodEvent>((event, emit) {
      emit(state.copyWith(mood: event.mood));
    });
    on<SaveSummaryEvent>((event, emit) async {
      emit(state.copyWith(isSaving: true, saveSuccess: false, error: null));
      try {
        await controller.saveSummary(
            userId: event.userId,
            relationshipId: event.relationshipId,
            notes: event.notes,
            summary: event.summary,
            feeling: event.feeling,
            mood: event.mood,
            attachments: event.attachments);
        emit(state.copyWith(isSaving: false, saveSuccess: true));
      } catch (e) {
        emit(state.copyWith(
            isSaving: false, saveSuccess: false, error: e.toString()));
      }
    });
  }
}
