import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactService {
  Future<bool> requestPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  Future<List<Contact>> getContacts() async {
    if (await FlutterContacts.requestPermission(readonly: true)) {
      return await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
    } else {
      return [];
    }
  }
}
