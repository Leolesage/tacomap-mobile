import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/token_storage.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/tacos_place_service.dart';
import 'services/location_service.dart';
import 'state/auth_provider.dart';
import 'state/tacos_places_provider.dart';
import 'screens/login_screen.dart';
import 'screens/tacos_places_list_screen.dart';
import 'widgets/app_loader.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage);
  final authService = AuthService(apiClient);
  final tacosPlaceService = TacosPlaceService(apiClient);
  final locationService = LocationService();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: tokenStorage),
        Provider.value(value: apiClient),
        Provider.value(value: authService),
        Provider.value(value: tacosPlaceService),
        Provider.value(value: locationService),
        ChangeNotifierProvider(
          create: (_) => TacosPlacesProvider(tacosPlaceService: tacosPlaceService),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            tokenStorage: tokenStorage,
            authService: authService,
            apiClient: apiClient,
            onLogout: () => context.read<TacosPlacesProvider>().reset(),
          ),
        ),
      ],
      child: const TacoMapApp(),
    ),
  );
}

class TacoMapApp extends StatelessWidget {
  const TacoMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TacoMap France',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().init();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isInitialized) {
          return const Scaffold(body: AppLoader(message: 'Starting...'));
        }
        return const HomeShell();
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const TacosPlacesListScreen(isAdmin: false),
      const AdminGateScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tacos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}

class AdminGateScreen extends StatelessWidget {
  const AdminGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isAuthenticated) {
          return const LoginScreen(popOnSuccess: false);
        }
        return const TacosPlacesListScreen(isAdmin: true);
      },
    );
  }
}
