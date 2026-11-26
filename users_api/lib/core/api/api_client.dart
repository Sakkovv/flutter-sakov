import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(
    this._client,
    this._store, {
    this.host = 'jsonplaceholder.typicode.com',
  });

  final http.Client _client;
  final SecureStore _store;
  final String host;

  Future<Map<String, String>> _headers() async {
    return {
      'Accept': 'application/json',
      if (await _store.readToken() case final t?) 'Authorization': 'Bearer $t',
    };
  }

  Future<http.Response> get(Uri uri) async {
    final headers = await _headers();
    final response = await _send(() => _client.get(uri, headers: headers));
    _logResponse(response);
    _check(response);
    return response;
  }

  Future<http.Response> post(Uri uri, {required String body}) async {
    final headers = await _headers();
    final response = await _send(
      () => _client.post(
        uri,
        headers: {...headers, 'Content-Type': 'application/json'},
        body: body,
      ),
    );
    _logResponse(response);
    _check(response);
    return response;
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(const Duration(seconds: 10));
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response r) {
    if (r.statusCode == 401) {
      throw const UnauthorizedException();
    }
    if (r.statusCode == 404) {
      throw const NotFoundException();
    }
    if (r.statusCode >= 500) {
      throw ServerException(r.statusCode);
    }
  }

  dynamic decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException(e.message);
    }
  }

  void _logResponse(http.Response r) {
    if (kDebugMode) {
      log(
        '${r.request?.method} ${r.request?.url} -> ${r.statusCode}',
        name: 'api',
      );
    }
  }
}
