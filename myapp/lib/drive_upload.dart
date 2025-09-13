import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis_auth/auth_io.dart';

Future<void> uploadToDrive(
  String content, {
  required String folderId,
  required String filename,
}) async {
  // Load the service account JSON from assets
  final jsonString = await rootBundle.loadString(
    'assets/flutter-practice-471914-504ada6d4766.json',
  );
  final serviceAccount = ServiceAccountCredentials.fromJson(jsonString);

  final scopes = [drive.DriveApi.driveFileScope];
  final authClient = await clientViaServiceAccount(serviceAccount, scopes);

  final driveApi = drive.DriveApi(authClient);

  // Convert content to bytes
  final mediaStream = Stream.value(Uint8List.fromList(utf8.encode(content)));
  final media = drive.Media(mediaStream, content.length);

  final file = drive.File()
    ..name = 'attendance.txt'
    ..parents = ['1EffJmsh_3PBrx-fDZthA1mIKgJrSTNY8'];

  await driveApi.files.create(file, uploadMedia: media);
  authClient.close();
}
