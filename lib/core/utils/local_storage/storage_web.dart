import 'package:web/web.dart' as web;
import 'storage_interface.dart';

class WebStorageImpl implements WebStorage {
  @override
  void save(String key, String value) => web.window.sessionStorage.setItem(key, value);
  @override
  String? read(String key) => web.window.sessionStorage.getItem(key);
  @override
  void delete(String key) => web.window.sessionStorage.removeItem(key);
}

WebStorage getWebStorage() => WebStorageImpl();
