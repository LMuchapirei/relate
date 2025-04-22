import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:relate/common/service/storage_service.dart';

import 'features/interactions/bloc/media_hive_item.dart';
import 'package:appwrite/appwrite.dart';

// Client client = Client();

class Global {
  static late StorageService storageService;
  static late Client client;
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    storageService = await StorageService().init();
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path); 
    Hive.registerAdapter(MediaHiveItemAdapter());
    Hive.registerAdapter(MediaHiveTypeAdapter());
    Hive.registerAdapter(LocationHiveTypeAdapter());
    }
    
}