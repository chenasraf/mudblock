import 'dart:io';

import 'package:mudblock/core/storage/storage_base.dart';

class FileStorage implements IFileStorage {
  @override
  Future<void> createDirectory(String path) => Directory(path).create(recursive: true);

  @override
  Future<void> delete(String path) => File(path).delete();

  @override
  Future<void> deleteDirectory(String path) => Directory(path).delete(recursive: true);

  @override
  Future<bool> exists(String path) async {
    final type = await FileSystemEntity.type(path);
    return type != FileSystemEntityType.notFound;
  }

  @override
  Future<List<String>> list(String path) {
    return Directory(path)
        .list()
        .map((e) => e.path.substring(
              e.path.lastIndexOf(Platform.pathSeparator) + 1,
            ))
        .toList();
  }

  @override
  Future<String> read(String path) => File(path).readAsString();

  @override
  Future<void> write(String path, String value) => File(path).writeAsString(value);
}

