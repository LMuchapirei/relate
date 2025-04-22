import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:relate/common/widgets/flutter_toast.dart';
import 'package:relate/features/relationship/bloc/relationship_event.dart';
import 'package:relate/features/relationship/bloc/relationship_state.dart';

import '../models/relationship_model.dart';

class RelationShipFormBlocs extends Bloc<RelationShipEvent,RelationshipFormStates>{
  RelationShipFormBlocs(): super(const RelationshipFormStates()){
    on<FirstNameEvent>(_firstNameHandler);
    on<LastNameEvent>(_lastNameHandler);
    on<PhoneNumberEvent>(_phoneNumberHandler);
    on<RatingEvent>(_ratingHandler);
    on<FrequencyEvent>(_frequencyHandler);
    on<RelationshipTypeEvent>(_relationshipTypeHandler);
    on<NickNameEvent>(_nickNameHandler);
    on<ProfilePictureEvent>(_profilePictureHandler);
  }

  void _firstNameHandler(FirstNameEvent event,Emitter<RelationshipFormStates> emit){
    emit(state.copyWith(
      firstName: event.firstName
    ));
  }

  void _lastNameHandler(LastNameEvent event,Emitter<RelationshipFormStates> emit){
    emit(state.copyWith(
      lastName: event.lastName
    ));
  }

  void _phoneNumberHandler(PhoneNumberEvent event,Emitter<RelationshipFormStates> emit){
    emit(state.copyWith(
      phoneNumber: event.phoneNumber
    ));
  }

  void _relationshipTypeHandler(RelationshipTypeEvent event,Emitter<RelationshipFormStates> emit){
    emit(state.copyWith(
      relationshipType: event.relationShipType
    ));
  }

  void _ratingHandler(RatingEvent event,Emitter<RelationshipFormStates> emit){
    emit(state.copyWith(
      rating: event.rating
    ));
  }

  void _frequencyHandler(FrequencyEvent event,Emitter<RelationshipFormStates> emit){
    emit(state.copyWith(
      frequency: event.frequency
    ));
  }

    void _nickNameHandler(NickNameEvent event,Emitter<RelationshipFormStates> emit){
    emit(state.copyWith(
      nickName: event.nickName
    ));
  }

  _profilePictureHandler(ProfilePictureEvent event,Emitter<RelationshipFormStates> emit){
    emit(state.copyWith(
      profilePicture: event.file
    ));
  }
}


class RelationshipListBloc extends Bloc<RelationShipEvent,RelationshipListState> {
  RelationshipListBloc() : super(RelationshipListInitial()) {
    on<LoadRelationships>(_onLoadRelationships);
  }

  Future<void> _onLoadRelationships(
    LoadRelationships event,
    Emitter<RelationshipListState> emit,
  ) async {
    emit(RelationshipListLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(RelationshipListError(error: "User is not signed in."));
        return;
      }

      final relationshipsSnapshot = await FirebaseFirestore.instance
          .collection('relationships')
          .doc(user.uid)
          .collection('my_relationships')
          .get();

      final List<Relationship> relationships = relationshipsSnapshot.docs
          .map((doc) => Relationship.fromFirestore(doc))
          .toList();
      emit(RelationshipListLoaded(relationships: relationships));
    } catch (e) {
      if (kDebugMode) {
        print("Error loading relationships: $e");
      }
      toastInfo(msg: "Failed to load relationships",backgroundColor: Colors.red,textColor: Colors.white);
      emit(RelationshipListError(error: "Failed to load relationships."));
    }
  }
}


