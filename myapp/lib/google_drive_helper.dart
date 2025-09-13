import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class GoogleDriveHelper {
  static const _scopes = [drive.DriveApi.driveFileScope];

  Future<drive.DriveApi> getDriveApi() async {
    // Load service account JSON
    final data = await rootBundle.loadString('assets/service_account.json');
    final accountCredentials = ServiceAccountCredentials.fromJson(data);

    // Authenticate and get client
    final client = await clientViaServiceAccount(accountCredentials, _scopes);
    return drive.DriveApi(client);
  }

  Future<void> uploadFile(String filePath) async {
    try {
      final driveApi = await getDriveApi();

      final file = drive.File()
        ..name = "attendance_${DateTime.now().millisecondsSinceEpoch}.txt";

      final media = drive.Media(
        http.ByteStream(File(filePath).openRead()),
        await File(filePath).length(),
      );

      final uploadedFile =
          await driveApi.files.create(file, uploadMedia: media);

      print("Uploaded file ID: ${uploadedFile.id}");
    } catch (e) {
      print("Upload failed: $e");
    }
  }
}
