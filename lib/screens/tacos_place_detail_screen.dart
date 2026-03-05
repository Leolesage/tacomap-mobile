import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tacos_place_service.dart';
import '../models/tacos_place.dart';
import '../widgets/app_loader.dart';
import '../widgets/app_error.dart';
import '../widgets/resilient_network_image.dart';
import '../theme/app_theme.dart';

class TacosPlaceDetailScreen extends StatelessWidget {
  final int tacosPlaceId;

  const TacosPlaceDetailScreen({super.key, required this.tacosPlaceId});

  @override
  Widget build(BuildContext context) {
    final service = context.read<TacosPlaceService>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Detail du lieu')),
      body: FutureBuilder<TacosPlace>(
        future: service.getTacosPlace(tacosPlaceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader(message: 'Chargement du detail');
          }
          if (snapshot.hasError) {
            return AppError(message: snapshot.error.toString());
          }

          final item = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroPhoto(item: item),
                const SizedBox(height: 16),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                _groupTitle('Informations principales'),
                const SizedBox(height: 10),
                _infoTile(Icons.schedule_rounded, 'Date', item.date),
                _infoTile(
                    Icons.euro_rounded, 'Prix moyen', '${item.price} EUR'),
                _infoTile(Icons.pin_drop_rounded, 'Latitude',
                    item.latitude.toString()),
                _infoTile(Icons.pin_drop_rounded, 'Longitude',
                    item.longitude.toString()),
                const SizedBox(height: 16),
                _groupTitle('Contact'),
                const SizedBox(height: 10),
                _infoTile(Icons.person_outline_rounded, 'Nom contact',
                    item.contactName),
                _infoTile(Icons.mail_outline_rounded, 'Email contact',
                    item.contactEmail),
                const SizedBox(height: 16),
                _groupTitle('Technique'),
                const SizedBox(height: 10),
                _infoTile(Icons.photo_outlined, 'Chemin photo', item.photo),
                _infoTile(Icons.history_toggle_off_rounded, 'Creation',
                    item.createdAt),
                _infoTile(Icons.update_rounded, 'Mise a jour', item.updatedAt),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _groupTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.textMuted,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 1),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: AppTheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPhoto extends StatelessWidget {
  final TacosPlace item;

  const _HeroPhoto({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 260,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ResilientNetworkImage(
              photoUrl: item.photoUrl,
              photoPath: item.photo,
              fit: BoxFit.cover,
              fallback: _fallback(showLoader: false),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x30000000), Color(0xB3000000)],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${item.price} EUR',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback({required bool showLoader}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3EEF5), Color(0xFFD6E4EE)],
        ),
      ),
      alignment: Alignment.center,
      child: showLoader
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2.8, color: AppTheme.primary),
            )
          : const Icon(Icons.image_not_supported_outlined,
              size: 38, color: AppTheme.textMuted),
    );
  }
}
