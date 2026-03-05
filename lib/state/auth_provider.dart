import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final TokenStorage tokenStorage;
  final AuthService authService;
  final ApiClient apiClient;
  final VoidCallback? onLogout;

  bool _initialized = false;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  AuthProvider({
    required this.tokenStorage,
    required this.authService,
    required this.apiClient,
    this.onLogout,
  }) {
    apiClient.onUnauthorized = handleUnauthorized;
  }

  bool get isInitialized => _initialized;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init() async {
    final token = await tokenStorage.getToken();
    _isAuthenticated = token != null && token.isNotEmpty;
    _initialized = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await authService.login(email, password);
      await tokenStorage.saveToken(token);
      _isAuthenticated = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await tokenStorage.clearToken();
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
    onLogout?.call();
  }

  void handleUnauthorized() {
    if (_isAuthenticated) {
      logout();
    }
  }
}
