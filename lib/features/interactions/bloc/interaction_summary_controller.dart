import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:relate/global.dart';
import '../models/interaction_summary_item.dart'; // Make sure this import path is correct

class InteractionSummaryController {
  /// Uploads a file to Appwrite and returns its public URL.
  Future<String> uploadFileToAppwrite(String filePath, String bucketId) async {
    final storage = Storage(Global.client);
    final file = InputFile.fromPath(path: filePath);
    final appwrite_models.File uploaded = await storage.createFile(
      bucketId: bucketId,
      fileId: ID.unique(),
      file: file,
    );
    // Construct the file URL (adjust as needed for your Appwrite setup)
    final fileUrl =
        '${Global.client.endPoint}/storage/buckets/$bucketId/files/${uploaded.$id}/view?project=${Global.client.config['project']}';
    return fileUrl;
  }

  Future<void> saveSummary({
    required String userId,
    required String relationshipId,
    required List<String> notes,
    required String summary,
    required String feeling,
    required double mood,
    List<String>? fileUrls,
  }) async {
    final summaryData = {
      'relationship_id': relationshipId,
      'user_id': userId,
      'notes': notes,
      'summary': summary,
      'feeling': feeling,
      'mood': mood,
      'files': fileUrls ?? [],
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Generate a unique summary ID using timestamp and userId
    final summaryId = '${DateTime.now().millisecondsSinceEpoch}_$userId';

    await FirebaseFirestore.instance
        .collection('my_interaction_summary')
        .doc(userId)
        .collection(relationshipId) // <-- Use relationshipId as collection name
        .doc(summaryId)             // <-- Unique summary doc ID
        .set(summaryData);
  }

  /// Fetches all summaries for a given userId and relationshipId and parses them to the model.
  Future<List<InteractionSummaryItem>> getSummaries({
    required String userId,
    required String relationshipId,
  }) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('my_interaction_summary')
        .doc(userId)
        .collection(relationshipId)
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => InteractionSummaryItem.fromMap(doc.data()))
        .toList();
  }
}