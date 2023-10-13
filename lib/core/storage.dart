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

  static Future<List<String>> listDirectoryFiles(
    String collection,
  ) async {
    final dir = Directory(path.join(base, collection));
    var exists = await dir.exists();
    if (!exists) {
      debugPrint('Directory does not exist: $collection');
      return [];
    }
    // TODO use absolute paths?
    final list = await dir.list().map((e) => path.basename(e.path)).toList();
    debugPrint('Listing directory: $collection, $list');
    return list;
  }

  static Future<void> deleteDirectory(String collection) async {
    debugPrint('Clearing collection: $collection');
    final dir = Directory(path.join(base, collection));
    await dir.delete(recursive: true);
  }
}

class JsonStorage {
  static const encoder = JsonEncoder.withIndent('  ');
  static const decoder = JsonDecoder();

  static Future<Map<String, dynamic>?> readFile(String filename) async {
    final data = await FileStorage.readFile('$filename.json');
    return data != null ? decoder.convert(data) : null;
  }

  static Future<void> writeFile(
      String filename, Map<String, dynamic> data) async {
    final output = encoder.convert(data);
    await FileStorage.writeFile('$filename.json', output);
  }

  static Future<void> deleteFile(String filename) async {
    await FileStorage.deleteFile('$filename.json');
  }

  static Future<List<Map<String, dynamic>?>> readDirectory(
    String collection,
  ) async {
    final list = await FileStorage.listDirectoryFiles(collection);
    return Future.wait(
      list.map((f) => readFile('$collection/${path.withoutExtension(f)}')),
    );
  }

  static Future<void> deleteDirectory(String collection) async {
    await FileStorage.deleteDirectory(collection);
  }
}

class ProfileStorage {
  static const encoder = JsonEncoder.withIndent('  ');
  static const decoder = JsonDecoder();

  static Future<Map<String, dynamic>?> readProfileFile(
      String profile, String filename) async {
    return JsonStorage.readFile('profiles/$profile/$filename');
  }

  static Future<void> writeProfileFile(
      String profile, String filename, dynamic data) async {
    await JsonStorage.writeFile('profiles/$profile/$filename', data);
  }

  static Future<void> deleteProfile(String profile) async {
    await JsonStorage.deleteDirectory('profiles/$profile');
  }

  static Future<void> deleteProfileFile(String profile, String filename) async {
    await JsonStorage.deleteFile('profiles/$profile/$filename');
  }

  static Future<List<String>> listAllProfiles() async {
    final list = await FileStorage.listDirectoryFiles('profiles');
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
    final dir = directory != null ? '$profile/$directory' : profile;
    final list = await FileStorage.listDirectoryFiles('profiles/$dir');
    return list.map((f) => path.withoutExtension(f)).toList();
  }

  static Future<void> deleteAllProfiles() async {
    await JsonStorage.deleteDirectory('profiles');
  }
}

