import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _key = 'tacomap_admin_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _key, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _key);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _key);
  }
}
