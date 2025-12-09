import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:relate/features/interactions/bloc/media_hive_item.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as Models;
import 'package:relate/common/values/constants.dart';
import 'package:relate/global.dart';

class InteractionFileController {
  Future<bool> saveMediaItem({
    required MediaHiveType type,
    required List<int> bytes, // media data
    required String extension, // e.g. '.jpg', '.m4a'
    required String interactionId,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final id = const Uuid().v4(); // unique file ID
      final filePath = '${dir.path}/$id$extension';
      final file = io.File(filePath);

      await file.writeAsBytes(bytes);

      final mediaItem = MediaHiveItem(
        type: type,
        content: filePath,
        interactionId: interactionId,
        locationType: LocationHiveType.local,
      );

      final box = await Hive.openBox<MediaHiveItem>('media_items');
      await box.add(mediaItem);

      // Attempt upload
      final uploadResult = await _uploadToAppwrite(file);
      if (uploadResult != null) {
        mediaItem.fileId = uploadResult.$id;
        mediaItem.bucketId = uploadResult.bucketId;
        mediaItem.syncStatus = 0; // Synced
        await mediaItem.save();
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<MediaHiveItem>> getMediaItemsForInteraction(
      String interactionId) async {
    print("Getting media for interactionId: $interactionId");
    final box = await Hive.openBox<MediaHiveItem>('media_items');
    final items = box.values
        .where((item) => item.interactionId == interactionId)
        .toList();
    print("Found ${items.length} items in Hive");

    // Check for missing local files and download if possible
    for (var item in items) {
      final file = io.File(item.content);
      if (!await file.exists() &&
          item.fileId != null &&
          item.bucketId != null) {
        await _downloadFromAppwrite(item);
      }
    }

    return items;
  }

  Future<Models.File?> _uploadToAppwrite(io.File file) async {
    try {
      final storage = Storage(Global.client);
      final result = await storage.createFile(
        bucketId: AppConstants.MEDIA_BUCKET_ID,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path),
      );
      return result;
    } catch (e) {
      print("Upload failed: $e");
      return null;
    }
  }

  Future<void> _downloadFromAppwrite(MediaHiveItem item) async {
    try {
      final storage = Storage(Global.client);
      final bytes = await storage.getFileDownload(
        bucketId: item.bucketId!,
        fileId: item.fileId!,
      );

      final file = io.File(item.content);
      await file.writeAsBytes(bytes);
    } catch (e) {
      print("Download failed: $e");
    }
  }

  Future<void> syncPendingItems() async {
    final box = await Hive.openBox<MediaHiveItem>('media_items');
    final pendingItems =
        box.values.where((item) => item.syncStatus == 1).toList();

    for (var item in pendingItems) {
      final file = io.File(item.content);
      if (await file.exists()) {
        final uploadResult = await _uploadToAppwrite(file);
        if (uploadResult != null) {
          item.fileId = uploadResult.$id;
          item.bucketId = uploadResult.bucketId;
          item.syncStatus = 0; // Synced
          await item.save();
        }
      }
    }
  }

  Future<bool> deleteMediaItem(MediaHiveItem item) async {
    try {
      final file = io.File(item.content);
      if (await file.exists()) {
        await file.delete();
      }
      await item.delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}
