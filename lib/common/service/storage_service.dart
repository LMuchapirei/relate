import 'package:shared_preferences/shared_preferences.dart';

import '../values/constants.dart';


class StorageService {
  late final SharedPreferences _prefs;

   Future<StorageService> init() async{
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

 Future<bool> setBool(String key,bool value) async{
    return await _prefs.setBool(key, value);
  }

 bool getBool(String key) {
    return  _prefs.getBool(key) ?? false;
  }

 Future<bool> setString(String key,String value) async{
    return await _prefs.setString(key, value);
  }
  
 bool getIsLoggedIn(){
    return _prefs.getString(AppConstants.STORAGE_USER_TOKEN_KEY) == null ? false : true;
 }
}