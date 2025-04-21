import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:relate/common/widgets/flutter_toast.dart';
import 'package:relate/features/interactions/bloc/interaction_blocs.dart';
import 'package:relate/features/interactions/models/interaction_model.dart';

class InteractionController {
  final BuildContext context;
  const InteractionController(this.context);


  Future<void> scheduleInteraction() async {
    final state = context.read<InteractionBloc>().state;
    final interaction = Interaction(
      notes: state.notes,
      frequency: state.frequency,
      priority: state.priority,
      selectedDate: state.selectedDate,
      selectedTime: state.selectedTime,
      selectedRedirectApp: state.selectedRedirectApp,
      title: state.title
    );
    await saveInteractionToFirestore(interaction);
  }

  Future<void> saveInteractionToFirestore(Interaction interaction) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if(user == null) throw Exception("User in not signed in");
      final payload = interaction.toMap();
      payload["type"] = "Outgoing";
      payload["completed"] = false;
      await FirebaseFirestore.instance
            .collection("interactions")
            .doc(user.uid)
            .collection("my_interactions")
            .add(payload);
      toastInfo(msg: "Submitted the interaction successfully");
    } on Exception catch(e){
      toastInfo(msg: "Failed to create the interaction ${e.toString()}");
    }
  }
}