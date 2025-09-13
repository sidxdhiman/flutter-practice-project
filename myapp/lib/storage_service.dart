import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  Future<String> uploadAttendanceFile(File file, String userId) async {
    final timestamp = DateTime.now().toIso8601String();
    final filename = '${timestamp}_${userId}.txt';
    final remotePath = 'attendance/$filename';

    final ref = FirebaseStorage.instance.ref().child(remotePath);
    final uploadTask = ref.putFile(file);

    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl; // return shareable URL
  }
}
