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
    // final collection = path.dirname(filename);
    // filename = path.basename(filename);
    // return _store.collection(collection).doc(filename).get();
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
    // final collection = path.dirname(filename);
    // filename = path.basename(filename);
    // await _store.collection(collection).doc(filename).set(data);
    final file = File(path.join(base, filename));
    await file.create(recursive: true);
    await file.writeAsString(data);
  }

  static Future<void> deleteFile(String filename) async {
    debugPrint('Deleting file: $filename');
    // final collection = path.dirname(filename);
    // filename = path.basename(filename);
    // await _store.collection(collection).doc(filename).delete();
    final file = File(path.join(base, filename));
    await file.delete();
  }

  static Future<List<String>> readDirectory(
    String collection,
  ) async {
    // final docs = await _store.collection(collection).get();
    // debugPrint('Listing collection: $collection, ${docs?.length} docs');
    // return (docs ?? {}).cast<String, String>();
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
    // await _store.collection(collection).delete();
    final dir = Directory(path.join(base, collection));
    await dir.delete(recursive: true);
  }
}

class ProfileStorage {
  static Future<String?> readProfileFile(
      String profile, String filename) async {
    return FileStorage.readFile('profiles/$profile/$filename');
  }

  static Future<void> writeProfileFile(
      String profile, String filename, String data) async {
    await FileStorage.writeFile('profiles/$profile/$filename', data);
  }

  static Future<void> deleteProfile(String profile) async {
    await FileStorage.deleteDirectory('profiles/$profile');
  }

  static Future<void> deleteProfileFile(String profile, String filename) async {
    await FileStorage.deleteFile('profiles/$profile/$filename');
  }

  static Future<List<String>> listAllProfiles() async {
    final list = await FileStorage.readDirectory('profiles');
    return list
        .where((f) =>
            Directory(path.join(FileStorage.base, 'profiles', f)).existsSync())
        .toList();
  }

  static Future<List<String>> listProfileFiles(
    String profile, [
    String? directory,
  ]) async {
    return FileStorage.readDirectory(
        'profiles/$profile${directory != null ? '/$directory' : ''}');
  }

  static Future<void> deleteAllProfiles() async {
    await FileStorage.deleteDirectory('profiles');
  }
}

