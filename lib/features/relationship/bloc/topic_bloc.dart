import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:relate/features/relationship/bloc/topic_model.dart';
import 'topic_events.dart';
import 'topic_states.dart';
import 'package:relate/global.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TopicsBloc extends Bloc<TopicEvent, TopicState> {
  TopicsBloc() : super(TopicsInitial()) {
    on<LoadTopics>(_onLoadTopics);
    on<CreateTopic>(_onCreateTopic);
    on<DeleteTopic>(_onDeleteTopic);
  }

  Future<void> _onLoadTopics(LoadTopics event, Emitter<TopicState> emit) async {
    emit(TopicsLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(TopicsError('User not signed in.'));
        return;
      }
      final database = Databases(Global.client);
      const databaseId = '683d422f003d2714d076';
      const collectionId = '683f0b77003cc55fafb7';

      final appwrite_models.DocumentList docs = await database.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('relationshipId', event.relationshipId),
          Query.equal('userId', user.uid), // Filter by userId
          Query.orderDesc('createdAt'),
        ],
      );

      final topics = docs.documents.map((doc) => Topic.fromMap(doc.data)).toList();
      emit(TopicsLoaded(topics));
    } catch (e) {
      emit(TopicsError('Failed to load topics: $e'));
    }
  }

  Future<void> _onCreateTopic(CreateTopic event, Emitter<TopicState> emit) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(TopicsError('User not signed in.'));
        return;
      }
      final database = Databases(Global.client);
      const databaseId = '683d422f003d2714d076';
      const collectionId = '683f0b77003cc55fafb7';

      final topic = Topic(
        id: '',
        relationshipId: event.relationshipId,
        userId: user.uid, // Add userId from Firebase
        title: event.title,
        description: event.description,
        createdAt: DateTime.now(),
      );

      await database.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: topic.toMap(),
      );

      add(LoadTopics(event.relationshipId));
    } catch (e) {
      emit(TopicsError('Failed to create topic: $e'));
    }
  }

  Future<void> _onDeleteTopic(DeleteTopic event, Emitter<TopicState> emit) async {
    try {
      final database = Databases(Global.client);
      const databaseId = '683d422f003d2714d076';
      const collectionId = '683f0b77003cc55fafb7';

      await database.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: event.topicId,
      );

      // Optionally reload topics after deletion
      // You may want to keep track of the current relationshipId in the Bloc
    } catch (e) {
      emit(TopicsError('Failed to delete topic: $e'));
    }
  }
}