import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:relate/global.dart';
import '../models/interaction_summary_item.dart'; // Make sure this import path is correct
import 'package:mime/mime.dart';

class InteractionSummaryController {
  /// Uploads a file to Appwrite and returns a map with url, name, and mime type.
  Future<Map<String, String>> uploadFileToAppwrite(String filePath, String bucketId) async {
    final storage = Storage(Global.client);
    final file = InputFile.fromPath(path: filePath);
    final appwrite_models.File uploaded = await storage.createFile(
      bucketId: bucketId,
      fileId: ID.unique(),
      file: file,
    );
    final fileUrl =
        '${Global.client.endPoint}/storage/buckets/$bucketId/files/${uploaded.$id}/view?project=${Global.client.config['project']}';
    final fileName = filePath.split('/').last;
    final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
    return {
      'url': fileUrl,
      'name': fileName,
      'mime': mimeType,
    };
  }

  Future<void> saveSummary({
    required String userId,
    required String relationshipId,
    required List<String> notes,
    required String summary,
    required String feeling,
    required double mood,
    List<Map<String, String>>? attachments, // <-- Now expects list of maps
  }) async {
    final summaryData = {
      'relationship_id': relationshipId,
      'user_id': userId,
      'notes': notes,
      'summary': summary,
      'feeling': feeling,
      'mood': mood,
      'files': attachments ?? [],
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Generate a unique summary ID using timestamp and userId
    final summaryId = '${DateTime.now().millisecondsSinceEpoch}_$userId';

    await FirebaseFirestore.instance
        .collection('my_interaction_summary')
        .doc(userId)
        .collection(relationshipId)
        .doc(summaryId)
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
        .map((doc) => InteractionSummaryItem.fromDoc(doc))
        .toList();
  }

  /// Deletes a summary for a given userId, relationshipId, and summaryId.
  /// Returns true if successful, false if the document did not exist.
  Future<bool> deleteSummary({
    required String userId,
    required String relationshipId,
    required String summaryId,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('my_interaction_summary')
        .doc(userId)
        .collection(relationshipId)
        .doc(summaryId);

    final doc = await docRef.get();
    if (!doc.exists) {
      return false;
    }
    await docRef.delete();
    return true;
  }
}