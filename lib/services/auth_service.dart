import 'dart:convert';
import '../services/api_client.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

  Future<String> login(String email, String password) async {
    final res = await apiClient.post('/api/auth/login', {
      'email': email,
      'password': password,
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw ApiException('Invalid response from server.');
      }
      return token;
    }

    if (res.statusCode == 401) {
      throw ApiException('Invalid credentials.', statusCode: 401);
    }

    throw ApiException('Login failed (${res.statusCode}).', statusCode: res.statusCode);
  }
}
