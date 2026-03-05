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
        title: Text(widget.isAdmin ? 'Espace admin' : 'TacoMap France'),
        actions: [
          if (widget.isAdmin)
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return IconButton(
                  tooltip: 'Se deconnecter',
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout_rounded),
                );
              },
            ),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: _openCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ajouter un lieu'),
            )
          : null,
      body: Consumer<TacosPlacesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.items.isEmpty) {
            return const AppLoader(message: 'Chargement des adresses tacos');
          }

          if (provider.error != null && provider.items.isEmpty) {
            return AppError(
              message: provider.error!,
              onRetry: provider.refresh,
            );
          }

          final itemCount = provider.items.length + 2;

          return RefreshIndicator(
            color: AppTheme.primary,
            backgroundColor: Colors.white,
            onRefresh: provider.refresh,
            child: ListView.builder(
              controller: _controller,
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _HeroHeader(
                    isAdmin: widget.isAdmin,
                  );
                }

                if (index <= provider.items.length) {
                  final item = provider.items[index - 1];
                  return TacosPlaceCard(
                    item: item,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TacosPlaceDetailScreen(tacosPlaceId: item.id),
                      ),
                    ),
                  );
                }

                if (provider.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.6, color: AppTheme.primary),
                      ),
                    ),
                  );
                }

                if (!provider.hasMore) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        'Fin de la liste',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 12.5),
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

class _HeroHeader extends StatelessWidget {
  final bool isAdmin;

  const _HeroHeader({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppTheme.heroGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lunch_dining, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAdmin
                        ? 'Gestion des TacosPlace'
                        : 'Adresses tacos en France',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            if (isAdmin) ...[
              const SizedBox(height: 12),
              const Text(
                'Mode admin actif',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
