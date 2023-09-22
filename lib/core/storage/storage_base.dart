abstract class IFileStorage {
  Future<String> read(String path);
  Future<void> write(String path, String value);
  Future<void> delete(String path);
  Future<bool> exists(String path);
  Future<List<String>> list(String path);
  Future<void> createDirectory(String path);
  Future<void> deleteDirectory(String path);
}
