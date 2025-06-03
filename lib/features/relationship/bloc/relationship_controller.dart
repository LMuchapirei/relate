import 'package:appwrite/appwrite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:relate/features/relationship/bloc/relationship_bloc.dart';
import 'package:relate/global.dart';
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
      frequency: state.frequency.toStringAsPrecision(2),
      phoneNumber: state.phoneNumber,
      rating: state.rating.toInt(),
      relationshipType: state.relationshipType,
    );
    await saveRelationshipToAppwrite(relationship);
  }

  Future<void> saveRelationshipToAppwrite(Relationship relationship) async {
    try {
      // Use FirebaseAuth for user ID
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User is not signed in");
      final state = context.read<RelationShipFormBlocs>().state;
      var profilePath = "";
      if (state.profilePicture != null) {
        profilePath = await uploadImageToAppwrite(userId, state.profilePicture!);
      }
      final payload = {...relationship.toMap(), "profileImageUrl": profilePath};
      final database = Databases(Global.client);
      const databaseId = '683d422f003d2714d076'; //db id
      const collectionId = '683d45f700104e5e6cd1'; // relationship id

      await database.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: {
          ...payload,
          'userId': userId,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      toastInfo(msg: "Submitted the relationship successfully");
    } on Exception catch (e) {
      toastInfo(
        /// optional check if the profile image path is not empty and delete it given the relationship creation fails
        /// 
        msg: "Failed to create the user ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<String> uploadImageToAppwrite(String userId, XFile profileImage) async {
    try {
      final storage = Storage(Global.client);
      final file = InputFile.fromPath(path: profileImage.path);
      // Replace with your Appwrite bucket ID
      const bucketId = '683d463300303a71871b'; //bucket for profile images
      final uploaded = await storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: file,
      );
      // Construct the file URL
      final fileUrl =
          '${Global.client.endPoint}/storage/buckets/$bucketId/files/${uploaded.$id}/view?project=${Global.client.config['project']}';
      return fileUrl;
    } on Exception catch (e) {
      toastInfo(msg: "Failed to submit profile picture.$e");
      return '';
    }
  }
}