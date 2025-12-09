import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:relate/common/widgets/flutter_toast.dart';
import 'package:relate/features/relationship/bloc/relationship_event.dart';
import 'package:relate/features/relationship/bloc/relationship_state.dart';
import '../models/relationship_model.dart';
import 'package:relate/global.dart';

class RelationShipFormBlocs
    extends Bloc<RelationShipEvent, RelationshipFormStates> {
  RelationShipFormBlocs() : super(const RelationshipFormStates()) {
    on<FirstNameEvent>(_firstNameHandler);
    on<LastNameEvent>(_lastNameHandler);
    on<PhoneNumberEvent>(_phoneNumberHandler);
    on<RatingEvent>(_ratingHandler);
    on<FrequencyEvent>(_frequencyHandler);
    on<RelationshipTypeEvent>(_relationshipTypeHandler);
    on<NickNameEvent>(_nickNameHandler);
    on<ProfilePictureEvent>(_profilePictureHandler);
    on<AddTagEvent>(_addTagHandler);
    on<RemoveTagEvent>(_removeTagHandler);
  }

  void _firstNameHandler(
      FirstNameEvent event, Emitter<RelationshipFormStates> emit) {
    emit(state.copyWith(firstName: event.firstName));
  }

  void _lastNameHandler(
      LastNameEvent event, Emitter<RelationshipFormStates> emit) {
    emit(state.copyWith(lastName: event.lastName));
  }

  void _phoneNumberHandler(
      PhoneNumberEvent event, Emitter<RelationshipFormStates> emit) {
    emit(state.copyWith(phoneNumber: event.phoneNumber));
  }

  void _relationshipTypeHandler(
      RelationshipTypeEvent event, Emitter<RelationshipFormStates> emit) {
    emit(state.copyWith(relationshipType: event.relationShipType));
  }

  void _ratingHandler(RatingEvent event, Emitter<RelationshipFormStates> emit) {
    emit(state.copyWith(rating: event.rating));
  }

  void _frequencyHandler(
      FrequencyEvent event, Emitter<RelationshipFormStates> emit) {
    emit(state.copyWith(frequency: event.frequency));
  }

  void _nickNameHandler(
      NickNameEvent event, Emitter<RelationshipFormStates> emit) {
    emit(state.copyWith(nickName: event.nickName));
  }

  _profilePictureHandler(
      ProfilePictureEvent event, Emitter<RelationshipFormStates> emit) {
    emit(state.copyWith(profilePicture: event.file));
  }

  void _addTagHandler(AddTagEvent event, Emitter<RelationshipFormStates> emit) {
    final updatedTags = List<String>.from(state.tags);
    if (!updatedTags.contains(event.tag)) {
      updatedTags.add(event.tag);
      emit(state.copyWith(tags: updatedTags));
    }
  }

  void _removeTagHandler(
      RemoveTagEvent event, Emitter<RelationshipFormStates> emit) {
    final updatedTags = List<String>.from(state.tags);
    updatedTags.remove(event.tag);
    emit(state.copyWith(tags: updatedTags));
  }
}

class RelationshipListBloc
    extends Bloc<RelationShipEvent, RelationshipListState> {
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

      // --- Appwrite fetch logic ---
      final database = Databases(Global.client);
      // const databaseId = 'your_database_id'; // Replace with your Appwrite DB ID
      // const collectionId = 'your_collection_id'; // Replace with your Appwrite Collection ID
      const databaseId = '683d422f003d2714d076'; //db id
      const collectionId = '683d45f700104e5e6cd1'; // relationship id

      final appwrite_models.DocumentList docs = await database.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('userId', user.uid),
        ],
      );

      final List<Relationship> relationships =
          docs.documents.map((doc) => Relationship.fromMap(doc.data)).toList();

      emit(RelationshipListLoaded(relationships: relationships));
    } catch (e) {
      if (kDebugMode) {
        print("Error loading relationships: $e");
      }
      toastInfo(
          msg: "Failed to load relationships",
          backgroundColor: Colors.red,
          textColor: Colors.white);
      emit(RelationshipListError(error: "Failed to load relationships."));
    }
  }
}
