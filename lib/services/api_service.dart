import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiException implements Exception {
  ApiException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  String? get token => _token;

  Map<String, String> _headers({bool jsonBody = false}) {
    final h = <String, String>{};
    if (jsonBody) h['Content-Type'] = 'application/json';
    if (_token != null && _token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  Uri _u(String path) => Uri.parse('${AppConfig.apiBase}$path');

  dynamic _decodeRaw(http.Response r) {
    final body = r.body;
    if (body.isEmpty) return null;
    return jsonDecode(body);
  }

  Future<Map<String, dynamic>> _decodeMap(http.Response r) async {
    final decoded = _decodeRaw(r);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded == null) return {};
    return {'data': decoded};
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final res = await _client.post(
      _u(path),
      headers: _headers(jsonBody: true),
      body: jsonEncode(body),
    );
    final map = await _decodeMap(res);
    if (res.statusCode >= 400) {
      throw ApiException(map['message']?.toString() ?? 'Error', res.statusCode);
    }
    return map;
  }

  Future<Map<String, dynamic>> get(String path) async {
    final res = await _client.get(_u(path), headers: _headers());
    final map = await _decodeMap(res);
    if (res.statusCode >= 400) {
      throw ApiException(map['message']?.toString() ?? 'Error', res.statusCode);
    }
    return map;
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final res = await _client.put(
      _u(path),
      headers: _headers(jsonBody: true),
      body: jsonEncode(body),
    );
    final map = await _decodeMap(res);
    if (res.statusCode >= 400) {
      throw ApiException(map['message']?.toString() ?? 'Error', res.statusCode);
    }
    return map;
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final res = await _client.delete(_u(path), headers: _headers());
    final map = await _decodeMap(res);
    if (res.statusCode >= 400) {
      throw ApiException(map['message']?.toString() ?? 'Error', res.statusCode);
    }
    return map;
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return post('/api/auth/register', {
      'fullName': fullName,
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return post('/api/auth/login', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>> me() => get('/api/auth/me');

  Future<List<dynamic>> scenarios() async {
    final res = await _client.get(_u('/api/scenarios'), headers: _headers());
    final raw = _decodeRaw(res);
    if (res.statusCode >= 400) {
      final msg = raw is Map ? raw['message']?.toString() : 'Error';
      throw ApiException(msg ?? 'Error', res.statusCode);
    }
    if (raw is List<dynamic>) return raw;
    return [];
  }

  Future<Map<String, dynamic>> scenario(String id) => get('/api/scenarios/$id');

  Future<Map<String, dynamic>> startAttempt(String scenarioId) {
    return post('/api/attempts/start', {'scenarioId': scenarioId});
  }

  Future<Map<String, dynamic>> submitDecision(
    String attemptId,
    int stepNumber,
    int optionIndex,
  ) {
    return post('/api/attempts/$attemptId/decision', {
      'stepNumber': stepNumber,
      'optionIndex': optionIndex,
    });
  }

  Future<Map<String, dynamic>> completeAttempt(String attemptId, {bool force = false}) {
    return post('/api/attempts/$attemptId/complete', {'force': force});
  }

  Future<Map<String, dynamic>> analytics() => get('/api/analytics/me');

  Future<Map<String, dynamic>> adminOverview() => get('/api/admin/overview');

  Future<List<dynamic>> adminUsers() async {
    final res = await _client.get(_u('/api/admin/users'), headers: _headers());
    final raw = _decodeRaw(res);
    if (res.statusCode >= 400) {
      final msg = raw is Map ? raw['message']?.toString() : 'Error';
      throw ApiException(msg ?? 'Error', res.statusCode);
    }
    if (raw is List<dynamic>) return raw;
    return [];
  }

  Future<List<dynamic>> adminAttempts() async {
    final res =
        await _client.get(_u('/api/admin/attempts'), headers: _headers());
    final raw = _decodeRaw(res);
    if (res.statusCode >= 400) {
      final msg = raw is Map ? raw['message']?.toString() : 'Error';
      throw ApiException(msg ?? 'Error', res.statusCode);
    }
    if (raw is List<dynamic>) return raw;
    return [];
  }

  Future<Map<String, dynamic>> adminScenarioStats() =>
      get('/api/admin/scenario-stats');

  Future<Map<String, dynamic>> createScenario(Map<String, dynamic> body) {
    return post('/api/scenarios', body);
  }

  Future<Map<String, dynamic>> updateScenario(String id, Map<String, dynamic> body) {
    return put('/api/scenarios/$id', body);
  }

  Future<Map<String, dynamic>> deleteScenario(String id) {
    return delete('/api/scenarios/$id');
  }
}
