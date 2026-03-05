import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/tacos_places_provider.dart';
import '../state/auth_provider.dart';
import '../widgets/tacos_place_card.dart';
import '../widgets/app_loader.dart';
import '../widgets/app_error.dart';
import '../theme/app_theme.dart';
import 'tacos_place_detail_screen.dart';
import 'tacos_place_create_screen.dart';
import 'login_screen.dart';

class TacosPlacesListScreen extends StatefulWidget {
  final bool isAdmin;

  const TacosPlacesListScreen({super.key, this.isAdmin = false});

  @override
  State<TacosPlacesListScreen> createState() => _TacosPlacesListScreenState();
}

class _TacosPlacesListScreenState extends State<TacosPlacesListScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<TacosPlacesProvider>();
    if (provider.items.isEmpty) {
      provider.refresh();
    }
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    final current = _controller.position.pixels;
    if (max <= 0) return;
    if (current / max >= 0.8) {
      context.read<TacosPlacesProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openCreate() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (!mounted || !auth.isAuthenticated) return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TacosPlaceCreateScreen()),
    );
    if (mounted) {
      context.read<TacosPlacesProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(widget.isAdmin ? 'Admin - Tacos Places' : 'Tacos Places'),
        actions: [
          if (widget.isAdmin)
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return TextButton.icon(
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout, size: 18, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: _openCreate,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add TacosPlace',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : null,
      body: Consumer<TacosPlacesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.items.isEmpty) {
            return const AppLoader(message: 'Loading tacos places...');
          }

          if (provider.error != null && provider.items.isEmpty) {
            return AppError(
              message: provider.error!,
              onRetry: provider.refresh,
            );
          }

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: provider.refresh,
            child: ListView.builder(
              controller: _controller,
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: provider.items.length + 1,
              itemBuilder: (context, index) {
                if (index < provider.items.length) {
                  final item = provider.items[index];
                  return TacosPlaceCard(
                    item: item,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TacosPlaceDetailScreen(tacosPlaceId: item.id),
                      ),
                    ),
                  );
                }

                if (provider.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  );
                }

                if (!provider.hasMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No more results.',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}
