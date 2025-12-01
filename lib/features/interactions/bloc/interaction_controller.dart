import 'package:appwrite/appwrite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:relate/common/widgets/flutter_toast.dart';
import 'package:relate/features/interactions/bloc/interaction_blocs.dart';
import 'package:relate/features/interactions/bloc/interaction_events.dart';
import 'package:relate/features/interactions/models/interaction_model.dart';
import 'package:relate/global.dart';

class InteractionController {
  final BuildContext context;
  const InteractionController(this.context);

  Future<bool> scheduleInteraction(String relationshipId) async {
    final state = context.read<InteractionBloc>().state;

    if (state.title.isEmpty) {
      toastInfo(msg: "Please enter a title");
      return false;
    }
    if (state.selectedDate == null) {
      toastInfo(msg: "Please select a date");
      return false;
    }
    if (state.selectedTime == null) {
      toastInfo(msg: "Please select a time");
      return false;
    }

    final interaction = Interaction(
        notes: state.notes,
        frequency: state.frequency,
        priority: state.priority,
        selectedDate: state.selectedDate,
        selectedTime: state.selectedTime,
        selectedRedirectApp: state.selectedRedirectApp,
        title: state.title);
    await saveInteractionToAppwrite(interaction, relationshipId);
    return true;
  }

  Future<void> saveInteractionToAppwrite(
      Interaction interaction, String relationshipId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User is not signed in");
      final payload = interaction.toMap();
      payload["type"] = "Outgoing";
      payload["completed"] = false;
      payload["relationshipId"] = relationshipId;
      payload["userId"] = user.uid;

      final database = Databases(Global.client);
      const databaseId = '683d422f003d2714d076'; // Appwrite DB ID
      const collectionId = '683d579b0012fd673698'; // Appwrite Collection ID

      await database.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: payload,
      );
      toastInfo(msg: "Submitted the interaction successfully");
      context.read<InteractionListBloc>().add(LoadScheduledInteractions());
    } on Exception catch (e) {
      toastInfo(msg: "Failed to create the interaction ${e.toString()}");
    }
  }

  Future<void> markAsDone(String interactionId, bool isCompleted) async {
    try {
      final database = Databases(Global.client);
      const databaseId = '683d422f003d2714d076'; // Appwrite DB ID
      const collectionId = '683d579b0012fd673698'; // Appwrite Collection ID

      await database.updateDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: interactionId,
        data: {'completed': isCompleted},
      );
      toastInfo(
          msg: "Interaction marked as ${isCompleted ? 'done' : 'incomplete'}");
      context.read<InteractionListBloc>().add(LoadScheduledInteractions());
    } catch (e) {
      toastInfo(msg: "Failed to update interaction: ${e.toString()}");
    }
  }

  Future<List<Interaction>> getInteractions(String relationshipId) async {
    try {
      final database = Databases(Global.client);
      const databaseId = '683d422f003d2714d076'; // Appwrite DB ID
      const collectionId = '683d579b0012fd673698'; // Appwrite Collection ID

      final response = await database.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('relationshipId', relationshipId),
          Query.orderDesc('selectedDate'),
        ],
      );

      return response.documents
          .map((e) => Interaction.fromMap(e.data))
          .toList();
    } catch (e) {
      print('Error fetching interactions: $e');
      return [];
    }
  }
}
