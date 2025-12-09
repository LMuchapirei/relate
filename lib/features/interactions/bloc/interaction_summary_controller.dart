import 'dart:convert';

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
    List<Map<String, String>>? attachments,
  }) async {
    try {
      final database = Databases(Global.client);
      const databaseId = '683d422f003d2714d076'; 
      const collectionId = '683ec7aa0031f9c9ceb7';

      final summaryData = {
        'relationshipId': relationshipId,
        'userId': userId,
        'notes': notes,
        'summary': summary,
        'feeling': feeling,
        'mood': mood,
        'files': (attachments ?? []).map((e)=>jsonEncode(e)).toList() ?? [],
        'createdAt': DateTime.now().toIso8601String(),
      };

      await database.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: summaryData,
      );
    } catch (e) {
      throw Exception('Failed to save summary: $e');
    }
  }

  /// Fetches all summaries for a given userId and relationshipId and parses them to the model.
  Future<List<InteractionSummaryItem>> getSummaries({
    required String userId,
    required String relationshipId,
  }) async {
    try {
      final database = Databases(Global.client);
      const databaseId = '683d422f003d2714d076'; 
      const collectionId = '683ec7aa0031f9c9ceb7';

      final docs = await database.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('userId', userId),
          Query.equal('relationshipId', relationshipId),
          Query.orderDesc('createdAt'),
        ],
      );

      return docs.documents
          .map((doc) => InteractionSummaryItem.fromMap(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch summaries: $e');
    }
  }

  /// Deletes a summary for a given userId, relationshipId, and summaryId.
  /// Returns true if successful, false if the document did not exist.
  Future<bool> deleteSummary({
    required String userId,
    required String relationshipId,
    required String summaryId,
  }) async {
    try {
      final database = Databases(Global.client);
      const databaseId = '683d422f003d2714d076'; 
      const collectionId = '683ec7aa0031f9c9ceb7';

      await database.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: summaryId,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}