import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'platform_utils.dart';

class FileStorage {
  static late final String base;

  static Future<void> init() async {
    base = await PlatformUtils.getStorageBasePath();
    debugPrint('Storage base: $base');
  }

  static Future<String?> readFile(String filename) async {
    debugPrint('Getting file: $filename');
    final file = File(path.join(base, filename));
    var exists = await file.exists();
    if (!exists) {
      debugPrint('File does not exist: $filename');
      return null;
    }
    return file.readAsString();
  }

  static Future<void> writeFile(String filename, String data) async {
    debugPrint(
        'Setting file: $filename, data: ${data.toString().length} bytes');
    final file = File(path.join(base, filename));
    await file.create(recursive: true);
    await file.writeAsString(data);
  }

  static Future<void> deleteFile(String filename) async {
    debugPrint('Deleting file: $filename');
    final file = File(path.join(base, filename));
    await file.delete();
  }

  static Future<List<String>> readDirectory(
    String collection,
  ) async {
    final dir = Directory(path.join(base, collection));
    var exists = await dir.exists();
    if (!exists) {
      debugPrint('Directory does not exist: $collection');
      return [];
    }
    // TODO use absolute paths?
    return dir.list().map((e) => path.basename(e.path)).toList();
  }

  static Future<void> deleteDirectory(String collection) async {
    debugPrint('Clearing collection: $collection');
    final dir = Directory(path.join(base, collection));
    await dir.delete(recursive: true);
  }
}

class ProfileStorage {
  static Future<Map<String, dynamic>?> readProfileFile(
      String profile, String filename) async {
    final data = await FileStorage.readFile('profiles/$profile/$filename.json');
    return data != null ? jsonDecode(data) : null;
  }

  static Future<void> writeProfileFile(
      String profile, String filename, dynamic data) async {
    data = jsonEncode(data);
    await FileStorage.writeFile('profiles/$profile/$filename.json', data);
  }

  static Future<void> deleteProfile(String profile) async {
    await FileStorage.deleteDirectory('profiles/$profile.json');
  }

  static Future<void> deleteProfileFile(String profile, String filename) async {
    await FileStorage.deleteFile('profiles/$profile/$filename.json');
  }

  static Future<List<String>> listAllProfiles() async {
    final list = await FileStorage.readDirectory('profiles');
    return list
        .where((f) =>
            Directory(path.join(FileStorage.base, 'profiles', f)).existsSync())
        .map((f) => path.withoutExtension(f))
        .toList();
  }

  static Future<List<String>> listProfileFiles(
    String profile, [
    String? directory,
  ]) async {
    final list = await FileStorage.readDirectory(
        'profiles/$profile${directory != null ? '/$directory' : ''}');
    return list.map((f) => path.withoutExtension(f)).toList();
  }

  static Future<void> deleteAllProfiles() async {
    await FileStorage.deleteDirectory('profiles');
  }
}
