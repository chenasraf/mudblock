import 'package:flutter/foundation.dart';
import 'package:localstore/localstore.dart';
import 'package:path/path.dart' as path;

class FileStorage {
  static final Localstore _store = Localstore.instance;

  static Future<Map<String, dynamic>?> readFile(String filename) async {
    debugPrint('Getting file: $filename');
    final collection = path.dirname(filename);
    filename = path.basename(filename);
    return _store.collection(collection).doc(filename).get();
  }

  static Future<void> writeFile(
      String filename, Map<String, dynamic> data) async {
    debugPrint(
        'Setting file: $filename, data: ${data.toString().length} bytes');
    final collection = path.dirname(filename);
    filename = path.basename(filename);
    await _store.collection(collection).doc(filename).set(data);
  }

  static Future<void> deleteFile(String filename) async {
    debugPrint('Deleting file: $filename');
    final collection = path.dirname(filename);
    filename = path.basename(filename);
    await _store.collection(collection).doc(filename).delete();
  }

  static Future<Map<String, Map<String, dynamic>>> readDirectory(
    String collection,
  ) async {
    final docs = await _store.collection(collection).get();
    debugPrint('Listing collection: $collection, ${docs?.length} docs');
    return (docs ?? {}).cast<String, Map<String, dynamic>>();
  }

  static Future<void> deleteDirectory(String collection) async {
    debugPrint('Clearing collection: $collection');
    await _store.collection(collection).delete();
  }
}

class ProfileStorage {
  static Future<Map<String, dynamic>?> readProfileFile(
      String profile, String filename) async {
    return FileStorage.readFile('profiles/$profile/$filename');
  }

  static Future<void> writeProfileFile(
      String profile, String filename, Map<String, dynamic> data) async {
    await FileStorage.writeFile('profiles/$profile/$filename', data);
  }

  static Future<void> deleteProfile(String profile) async {
    await FileStorage.deleteDirectory('profiles/$profile');
  }

  static Future<void> deleteProfileFile(String profile, String filename) async {
    await FileStorage.deleteFile('profiles/$profile/$filename');
  }

  static Future<List<Map<String, dynamic>>> listAllProfiles() async {
    final list = await FileStorage.readDirectory('profiles');
    return list.values.toList();
  }

  static Future<Map<String, Map<String, dynamic>>> listProfileFiles(
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

