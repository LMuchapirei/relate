import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:relate/common/widgets/flutter_toast.dart';
import 'package:relate/features/interactions/bloc/interaction_events.dart';
import 'package:relate/features/interactions/bloc/interaction_states.dart';
import 'package:relate/features/interactions/models/interaction_model.dart';
import 'package:relate/global.dart';

class InteractionBloc extends Bloc<InteractionEvent,InteractionFormStates>{
    InteractionBloc(): super(const InteractionFormStates()) {
      on<TitleEvent>(_titleEventHandler);
      on<NotesEvent>(_notesEventHandler);
      on<FrequencyEvent>(_frequencyEventHandler);
      on<PriorityEvent>(_priorityEventHandler);
      on<SelectedDateEvent>(_selectedDateEventHandler);
      on<SelectedTimeEvent>(_selectedTimeEventHandler);
      on<SelectedRedirectAppEvent>(_selectedRedirectAppEvent);
    }

    void _titleEventHandler(TitleEvent event,Emitter<InteractionFormStates> emit) {
      emit(state.copyWith(
        title: event.title
      ));
    }

    void _notesEventHandler(NotesEvent event,Emitter<InteractionFormStates> emit) {
      emit(state.copyWith(
        notes: event.note
      ));
    }

    void _frequencyEventHandler(FrequencyEvent event,Emitter<InteractionFormStates> emit) {
      emit(state.copyWith(
        frequency: event.frequency
      ));
    }

   void _priorityEventHandler(PriorityEvent event,Emitter<InteractionFormStates> emit) {
      emit(state.copyWith(
        priority: event.priority
      ));
    }

  void _selectedDateEventHandler(SelectedDateEvent event,Emitter<InteractionFormStates> emit) {
      emit(state.copyWith(
        selectedDate: event.date
      ));
    }

  void _selectedTimeEventHandler(SelectedTimeEvent event,Emitter<InteractionFormStates> emit) {
      emit(state.copyWith(
        selectedTime: event.time
      ));
    }

    void _selectedRedirectAppEvent(SelectedRedirectAppEvent event,Emitter<InteractionFormStates> emit) {
      emit(state.copyWith(
        selectedRedirectApp: event.appSelected
      ));
    }
}

class InteractionListBloc extends Bloc<InteractionEvent,InteractionListState> {
  InteractionListBloc(): super(InteractionListInitial()) {
    on<LoadScheduledInteractions>(_onLoadInteractions);
  }

  void _onLoadInteractions(LoadScheduledInteractions event,Emitter<InteractionListState> emit) async {
    emit(InteractionListInitial());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(InteractionListError(error: "User not signed in."));
        return;
      }
      final database = Databases(Global.client);
      const databaseId = '683d422f003d2714d076'; // Appwrite DB ID
      const collectionId = '683d579b0012fd673698'; // Appwrite Collection ID

      final appwrite_models.DocumentList docs = await database.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('userId', user.uid),
        ],
      );

      final List<Interaction> interactions = docs.documents
          .map((doc) => Interaction.fromMap(doc.data))
          .toList();

      emit(InteractionListLoaded(scheduledInteractions: interactions));
    } catch (e) {
      toastInfo(msg: "Failed to load interactions", backgroundColor: Colors.red, textColor: Colors.white);
      emit(InteractionListError(error: "Failed to load interactions."));
    }
  }
}