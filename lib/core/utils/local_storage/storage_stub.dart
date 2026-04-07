import 'storage_interface.dart';
class WebStorageImpl implements WebStorage {
  @override
  void save(String key, String value) {}
  @override
  String? read(String key) => null;
  @override
  void delete(String key) {}
}

WebStorage getWebStorage() => WebStorageImpl();
