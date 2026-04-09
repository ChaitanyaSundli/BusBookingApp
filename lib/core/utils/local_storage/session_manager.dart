// lib/core/utils/local_storage/session_manager.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../auth/data/models/response/login_response.dart';
import 'storage_stub.dart' if (dart.library.js_interop) 'storage_web.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final _mobileStorage = const FlutterSecureStorage();
  final _webStorage = getWebStorage();

  String? _token;
  UserResponse? _currentUser;
  String? _pendingRedirect;
  bool _isGuest = false;

  static const _guestKey = 'is_guest';

  String? get token => _token;
  UserResponse? get currentUser => _currentUser;
  String? get pendingRedirect => _pendingRedirect;
  bool get isGuest => _isGuest;

  // ------------------------------------------------------------
  // Guest Mode
  // ------------------------------------------------------------
  void setGuestMode(bool value) {
    _isGuest = value;
    if (kIsWeb) {
      value ? _webStorage.save(_guestKey, 'true') : _webStorage.delete(_guestKey);
    } else {
      value
          ? _mobileStorage.write(key: _guestKey, value: 'true')
          : _mobileStorage.delete(key: _guestKey);
    }
  }

  // ------------------------------------------------------------
  // Pending Redirect
  // ------------------------------------------------------------
  void setPendingRedirect(String? path) {
    _pendingRedirect = path;
  }

  String? consumePendingRedirect() {
    final path = _pendingRedirect;
    _pendingRedirect = null;
    return path;
  }

  // ------------------------------------------------------------
  // Save Session
  // ------------------------------------------------------------
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

  // ------------------------------------------------------------
  // Load Session
  // ------------------------------------------------------------
  Future<void> loadSession() async {
    debugPrint('SessionManager: loadSession started');
    try {
      if (kIsWeb) {
        _token = _webStorage.read('auth_token');
        final userJson = _webStorage.read('user_data');
        if (userJson != null) {
          _currentUser = UserResponse.fromJson(jsonDecode(userJson));
        }
        _isGuest = _webStorage.read(_guestKey) == 'true';
      } else {
        _token = await _mobileStorage.read(key: 'auth_token');
        final userJson = await _mobileStorage.read(key: 'user_data');
        if (userJson != null) {
          _currentUser = UserResponse.fromJson(jsonDecode(userJson));
        }
        final guestValue = await _mobileStorage.read(key: _guestKey);
        _isGuest = guestValue == 'true';
      }
      debugPrint('SessionManager: token=${_token != null}, guest=$_isGuest');
    } catch (e) {
      debugPrint('SessionManager: loadSession error: $e');
      rethrow;
    }
  }
  // ------------------------------------------------------------
  // Clear Session
  // ------------------------------------------------------------
  Future<void> clearSession() async {
    _token = null;
    _currentUser = null;
    _pendingRedirect = null;
    setGuestMode(false);

    if (kIsWeb) {
      _webStorage.delete('auth_token');
      _webStorage.delete('user_data');
    } else {
      await _mobileStorage.delete(key: 'auth_token');
      await _mobileStorage.delete(key: 'user_data');
    }
  }
}