import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quick_bus/core/features/auth/data/models/response/login_response.dart';
import 'storage_stub.dart' if (dart.library.js_interop) 'storage_web.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final _mobileStorage = const FlutterSecureStorage();
  final _webStorage = getWebStorage();

  String? _token;
  UserResponse? _currentUser;

  String? get token => _token;
  UserResponse? get currentUser => _currentUser;

  String? _pendingRedirect;

  String? get pendingRedirect => _pendingRedirect;

  void setPendingRedirect(String? path) {
    _pendingRedirect = path;
  }

  String? consumePendingRedirect() {
    final path = _pendingRedirect;
    _pendingRedirect = null;
    return path;
  }

  Future<void> saveSession(String token, UserResponse user, {bool persist = true}) async {
    _token = token;
    _currentUser = user;
    final userJson = jsonEncode(user.toJson());

    if (!persist) {
      if (kIsWeb) {
        _webStorage.delete('auth_token');
        _webStorage.delete('user_data');
      } else {
        await _mobileStorage.delete(key: 'auth_token');
        await _mobileStorage.delete(key: 'user_data');
      }
      return;
    }

    if (kIsWeb) {
      _webStorage.save('auth_token', token);
      _webStorage.save('user_data', userJson);
    } else {
      await _mobileStorage.write(key: 'auth_token', value: token);
      await _mobileStorage.write(key: 'user_data', value: userJson);
    }
  }

  Future<void> loadSession() async {
    if (kIsWeb) {
      _token = _webStorage.read('auth_token');
      final userJson = _webStorage.read('user_data');
      if (userJson != null) _currentUser = UserResponse.fromJson(jsonDecode(userJson));
    } else {
      _token = await _mobileStorage.read(key: 'auth_token');
      final userJson = await _mobileStorage.read(key: 'user_data');
      if (userJson != null) _currentUser = UserResponse.fromJson(jsonDecode(userJson));
    }
  }

  Future<void> clearSession() async {
    _token = null;
    _currentUser = null;
    _pendingRedirect = null;

    if (kIsWeb) {
      _webStorage.delete('auth_token');
      _webStorage.delete('user_data');
    } else {
      await _mobileStorage.delete(key: 'auth_token');
      await _mobileStorage.delete(key: 'user_data');
    }
  }

}
