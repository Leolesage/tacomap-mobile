import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  final TokenStorage tokenStorage;
  VoidCallback? onUnauthorized;

  ApiClient(this.tokenStorage);

  Uri _uri(String path, [Map<String, String>? query]) {
    const base = ApiConfig.baseUrl;
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  Future<Map<String, String>> _headers({bool json = false}) async {
    final token = await tokenStorage.getToken();
    final headers = <String, String>{};
    if (json) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String path, {Map<String, String>? query}) async {
    final res = await http.get(_uri(path, query), headers: await _headers());
    _handleUnauthorized(res);
    return res;
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      _uri(path),
      headers: await _headers(json: true),
      body: jsonEncode(body),
    );
    _handleUnauthorized(res);
    return res;
  }

  Future<http.StreamedResponse> multipart(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    required String filePath,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    request.fields.addAll(fields);
    final token = await tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    final res = await request.send();
    if (res.statusCode == 401) {
      onUnauthorized?.call();
    }
    return res;
  }

  void _handleUnauthorized(http.Response res) {
    if (res.statusCode == 401) {
      onUnauthorized?.call();
    }
  }
}
