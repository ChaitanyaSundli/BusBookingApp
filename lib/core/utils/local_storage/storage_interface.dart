abstract class WebStorage {
  void save(String key, String value);
  String? read(String key);
  void delete(String key);
}
WebStorage getWebStorage() => throw UnsupportedError('Cannot create storage');
