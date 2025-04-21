import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:relate/features/relationship/bloc/relationship_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../../common/widgets/flutter_toast.dart';
import '../models/relationship_model.dart';

class RelationshipController {
  final BuildContext context;

  const RelationshipController(this.context);


  void submitRelationship() async {
    final state = context.read<RelationShipFormBlocs>().state;
    final relationship = Relationship(
      firstName: state.firstName,
      lastName: state.lastName,
      frequency: state.frequency,
      phoneNumber: state.phoneNumber,
      rating: state.rating,
      relationshipType: state.relationshipType
    );
    await saveRelationshipToFirestore(relationship);

  }
  Future<void> saveRelationshipToFirestore(Relationship relationship) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User is not signed in");
      final state = context.read<RelationShipFormBlocs>().state;
      var profilePath = "";
      if(state.profilePicture != null){
       profilePath = await uploadImage(user.uid, state.profilePicture!);
      }
      final payload = {...relationship.toMap(),"profileImageUrl":profilePath};
      await FirebaseFirestore.instance
          .collection('relationships')
          .doc(user.uid)
          .collection('my_relationships')
          .add(payload);
       toastInfo(msg: "Submitted the relationship successfully");
    } on Exception catch(e){
      toastInfo(msg: "Failed to create the user ${e.toString()}",backgroundColor: Colors.red,textColor: Colors.white);
    }
  }

  Future<String> uploadImage(String userId,XFile profileImage) async {
        try{
        firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final file = File(profileImage.path);
        await storageRef.putFile(file);
        String downloadURL = await storageRef.getDownloadURL();
        return downloadURL;
        } on Exception catch(e){
           toastInfo(msg: "Failed to submit profile picture.$e");
          return '';
        }
  }

}