import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'platform_utils.dart';

abstract class IStorage<T> {
  bool get initialized;
  Future<void> init();
  Future<T?> readFile(String filename);
  Future<void> writeFile(String filename, T data);
  Future<void> deleteFile(String filename);
  Future<List<String>> readDirectory(String directory);
  Future<void> deleteDirectory(String directory);
}

class FileStorage<T> implements IStorage<T> {
  late String base;

  final String _base;

  @override
  bool initialized = false;

  FileStorage({String? base}) : _base = base ?? '';

  @override
  Future<void> init() async {
    base = path.join(await PlatformUtils.getStorageBasePath(), _base);
    initialized = true;
    debugPrint('init: $this');
  }

  @override
  Future<T?> readFile(String filename) async {
    debugPrint('Getting file: $filename');
    final file = File(path.join(base, filename));
    var exists = await file.exists();
    if (!exists) {
      debugPrint('File does not exist: $filename');
      return null;
    }
    return file.readAsString() as Future<T>;
  }

  @override
  Future<void> writeFile(String filename, T data) async {
    debugPrint(
        'Setting file: $filename, data: ${data.toString().length} bytes');
    final file = File(path.join(base, filename));
    await file.create(recursive: true);
    if (T == String) {
      await file.writeAsString(data as String);
      return;
    } else if (T == List<int>) {
      await file.writeAsBytes(data as List<int>);
      return;
    }
    throw Exception('Unsupported type: $T');
  }

  @override
  Future<void> deleteFile(String filename) async {
    debugPrint('Deleting file: $filename');
    final file = File(path.join(base, filename));
    await file.delete();
  }

  @override
  Future<List<String>> readDirectory(
    String directory,
  ) async {
    final dir = Directory(path.join(base, directory));
    var exists = await dir.exists();
    if (!exists) {
      debugPrint('Directory does not exist: $dir');
      return [];
    }
    final list = await dir.list().map((e) => path.basename(e.path)).toList();
    debugPrint('Base: $base');
    debugPrint('Listing directory: $dir, $list');
    return list;
  }

  @override
  Future<void> deleteDirectory(String directory) async {
    debugPrint('Clearing directory: $directory');
    final dir = Directory(directory == '.' ? base : path.join(base, directory));
    await dir.delete(recursive: true);
  }

  @override
  String toString() => 'FileStorage(base: $base)';
}

class JsonStorage implements IStorage<Map<String, dynamic>> {
  JsonStorage({String? base}) : _storage = FileStorage(base: base);

  final FileStorage<String> _storage;

  @override
  bool get initialized => _storage.initialized;

  final encoder = const JsonEncoder.withIndent('  ');
  final decoder = const JsonDecoder();

  @override
  Future<void> init() {
    return _storage.init();
  }

  String get base => _storage.base;

  @override
  Future<Map<String, dynamic>?> readFile(String filename) async {
    final data = await _storage.readFile('$filename.json');
    return data != null ? decoder.convert(data) : null;
  }

  @override
  Future<void> writeFile(String filename, Map<String, dynamic> data) async {
    final output = encoder.convert(data);
    await _storage.writeFile('$filename.json', output);
  }

  @override
  Future<void> deleteFile(String filename) async {
    await _storage.deleteFile('$filename.json');
  }

  @override
  Future<List<String>> readDirectory(
    String directory,
  ) async {
    final list = await _storage.readDirectory(directory);
    return list.map((f) => path.withoutExtension(f)).toList();
  }

  @override
  Future<void> deleteDirectory(String directory) async {
    await _storage.deleteDirectory(directory);
  }

  @override
  String toString() {
    return 'JsonStorage(base: $base)';
  }
}

class ProfileStorage extends JsonStorage {
  final String profileId;

  ProfileStorage(this.profileId) : super(base: 'profiles/$profileId');
  ProfileStorage._(this.profileId, String base)
      : super(base: 'profiles/$profileId/$base');

  @override
  Future<void> init() async {
    await super.init();
  }

  @override
  String toString() => 'ProfileStorage(profileId: $profileId, base: $base)';
}

class PluginStorage extends ProfileStorage {
  final String pluginId;

  PluginStorage(String profileId, this.pluginId)
      : super._(profileId, 'plugins/$pluginId');

  @override
  String toString() =>
      'PluginStorage(profileId: $profileId, pluginId: $pluginId, base: $base)';
}

