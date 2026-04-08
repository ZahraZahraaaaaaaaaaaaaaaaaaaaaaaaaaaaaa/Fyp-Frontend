import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api);

  final ApiService _api;
  static const _kToken = 'jwt_token';

  String? _token;
  UserModel? _user;

  String? get token => _token;
  UserModel? get user => _user;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isAdmin => _user?.role == 'admin';

  Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_kToken);
    if (t == null || t.isEmpty) return;
    _api.setToken(t);
    _token = t;
    try {
      final m = await _api.me();
      _user = UserModel.fromJson(m);
    } catch (_) {
      _token = null;
      _user = null;
      _api.setToken(null);
      await prefs.remove(_kToken);
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final res = await _api.login(email: email, password: password);
    final t = res['token'] as String?;
    if (t == null) throw Exception('No token');
    await _persistToken(t);
    _user = UserModel.fromJson(res['user'] as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final res = await _api.register(
      fullName: fullName,
      email: email,
      password: password,
    );
    final t = res['token'] as String?;
    if (t == null) throw Exception('No token');
    await _persistToken(t);
    _user = UserModel.fromJson(res['user'] as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    final m = await _api.me();
    _user = UserModel.fromJson(m);
    notifyListeners();
  }

  Future<void> _persistToken(String t) async {
    _token = t;
    _api.setToken(t);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, t);
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _api.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    notifyListeners();
  }
}
