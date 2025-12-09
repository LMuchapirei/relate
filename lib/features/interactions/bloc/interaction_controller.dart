import 'package:appwrite/appwrite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:relate/common/widgets/flutter_toast.dart';
import 'package:relate/features/interactions/bloc/interaction_blocs.dart';
import 'package:relate/features/interactions/bloc/interaction_events.dart';
import 'package:relate/features/interactions/models/interaction_model.dart';
import 'package:relate/global.dart';
import 'package:relate/services/notification_service.dart';

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

      // Schedule notification
      final notificationTime = DateTime(
        interaction.selectedDate!.year,
        interaction.selectedDate!.month,
        interaction.selectedDate!.day,
        interaction.selectedTime!.hour,
        interaction.selectedTime!.minute,
      );

      // Only schedule if in the future
      if (notificationTime.isAfter(DateTime.now())) {
        // Create a unique numeric ID for the notification
        final notificationId = notificationTime.millisecondsSinceEpoch ~/ 1000;

        final now = DateTime.now();
        final fifteenMinsBefore =
            notificationTime.subtract(const Duration(minutes: 15));

        DateTime scheduledTime;
        String body;

        // Logic:
        // 1. If we are more than 15 mins away, schedule for 15 mins before.
        // 2. If we are less than 15 mins away but not yet AT the event, schedule for the event time?
        //    Or maybe immediately?
        //    Let's go with: If 15 mins before is passed, schedule for the event time itself.
        //    If event time is also passed (checked by outer if), we can't do much (handled by outer if).

        if (fifteenMinsBefore.isAfter(now)) {
          scheduledTime = fifteenMinsBefore;
          body = "You have an interaction in 15 minutes.";
        } else {
          // We are within the 15 minute window. Schedule for the event time.
          // However, if the event time is extremely close (e.g. 1 min away), we still want to ensure it fires.
          scheduledTime = notificationTime;
          body = "It is time for your interaction.";

          // If the event time is literally NOW or passed by milliseconds between the check and execute
          // local_notifications usually handles 'now' or 'recent past' by firing immediately,
          // but to be safe, if we are extremely close (e.g. < 5 seconds?), we might want to add a small buffer?
          // The outer check `notificationTime.isAfter(DateTime.now())` ensures we are at least slightly in the future.
        }

        await NotificationService().scheduleNotification(
          notificationId,
          "Upcoming Interaction: ${interaction.title}",
          body,
          scheduledTime,
        );
      }

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
