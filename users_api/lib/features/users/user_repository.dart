import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final uri = Uri.https(_api.host, '/users');
    final http.Response response = await _api.get(uri);
    final decoded = _api.decode(response);
    try {
      final list = decoded as List<dynamic>;
      return list
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw BadResponseException('users: $e');
    }
  }

  Future<User> getById(int id) async {
    final uri = Uri.https(_api.host, '/users/$id');
    final http.Response response = await _api.get(uri);
    final decoded = _api.decode(response);
    try {
      return User.fromJson(decoded as Map<String, dynamic>);
    } catch (e) {
      throw BadResponseException('users/$id: $e');
    }
  }

  Future<User> create(User draft) async {
    final uri = Uri.https(_api.host, '/users');
    final http.Response response = await _api.post(
      uri,
      body: jsonEncode(draft.toJson()),
    );
    if (response.statusCode != 201) {
      throw BadResponseException(
        'users/create: expected 201, got ${response.statusCode}',
      );
    }
    final decoded = _api.decode(response);
    try {
      return User.fromJson(decoded as Map<String, dynamic>);
    } catch (e) {
      throw BadResponseException('users/create: $e');
    }
  }
}
