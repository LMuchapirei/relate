import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:relate/common/widgets/flutter_toast.dart';
import 'package:relate/features/interactions/bloc/interaction_events.dart';
import 'package:relate/features/interactions/bloc/interaction_states.dart';
import 'package:relate/features/interactions/models/interaction_model.dart';

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
      try{
        final user = FirebaseAuth.instance.currentUser;
        if(user == null){
          emit(InteractionListError(error: "User not signed in."));
          return;
        } 

        final interactionsSnapshot = await  FirebaseFirestore.instance
                .collection('interactions')
                .doc(user.uid)
                .collection('my_interactions')
                .get();
        final List<Interaction> interactions = interactionsSnapshot.docs
              .map((doc)=>Interaction.fromFirestore(doc))
              .toList();
        emit(InteractionListLoaded(scheduledInteractions: interactions));
      } catch(e){
        toastInfo(msg: "Failed to load relationships",backgroundColor: Colors.red,textColor: Colors.white);
      }
  }
}