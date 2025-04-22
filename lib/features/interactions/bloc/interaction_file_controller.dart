import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:relate/features/interactions/bloc/media_hive_item.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';


class InteractionFileController {


Future<bool> saveMediaItem({
  required MediaHiveType type,
  required List<int> bytes, // media data
  required String extension, // e.g. '.jpg', '.m4a'
  required String interactionId,
}) async {
  try{
  final dir = await getApplicationDocumentsDirectory();
  final id = const Uuid().v4(); // unique file ID
  final filePath = '${dir.path}/$id$extension';
  final file = File(filePath);

  await file.writeAsBytes(bytes);

  final mediaItem = MediaHiveItem(
    type: type,
    content: filePath,
    interactionId: interactionId,
    locationType: LocationHiveType.local,
  );

  final box = await Hive.openBox<MediaHiveItem>('media_items');
  await box.add(mediaItem);
  return true;
  } catch(e){
    print(e);
    return false;
  }
}

Future<List<MediaHiveItem>> getMediaItemsForInteraction(String interactionId) async {
  final box = await Hive.openBox<MediaHiveItem>('media_items');
  return box.values
      .where((item) => item.interactionId == interactionId)
      .toList();
}


Future<bool> deleteMediaItem(MediaHiveItem item) async {
  try{
  final file = File(item.content);
  if (await file.exists()) {
    await file.delete();
  }
    await item.delete();
    return true;
  } catch(_){
     return false;
  }
}
}
