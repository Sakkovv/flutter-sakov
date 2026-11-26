import 'dart:convert';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';

typedef UsersResult = ({List<User> items, bool fromCache});

class UserRepository {
  UserRepository(this._api, this._cache);

  final ApiClient _api;
  final UsersCache _cache;

  Future<List<User>> _fetch() async {
    final uri = Uri.https(_api.host, '/users');
    final response = await _api.get(uri);
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

  Future<UsersResult> getAll() async {
    try {
      final fresh = await _fetch();
      await _cache.save(fresh);
      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    }
  }

  Future<User> getById(int id) async {
    final uri = Uri.https(_api.host, '/users/$id');
    final response = await _api.get(uri);
    final decoded = _api.decode(response);
    try {
      return User.fromJson(decoded as Map<String, dynamic>);
    } catch (e) {
      throw BadResponseException('users/$id: $e');
    }
  }

  Future<User> create(User draft) async {
    final uri = Uri.https(_api.host, '/users');
    final response = await _api.post(uri, body: jsonEncode(draft.toJson()));
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
