import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/tacos_place_service.dart';
import '../models/tacos_place.dart';
import '../widgets/app_loader.dart';
import '../widgets/app_error.dart';
import '../theme/app_theme.dart';

class TacosPlaceDetailScreen extends StatelessWidget {
  final int tacosPlaceId;

  const TacosPlaceDetailScreen({super.key, required this.tacosPlaceId});

  @override
  Widget build(BuildContext context) {
    final service = context.read<TacosPlaceService>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('TacosPlace details')),
      body: FutureBuilder<TacosPlace>(
        future: service.getTacosPlace(tacosPlaceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader(message: 'Loading...');
          }
          if (snapshot.hasError) {
            return AppError(message: snapshot.error.toString());
          }

          final item = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: item.photoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.photoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.border,
                            child: const Center(
                              child: CircularProgressIndicator(color: AppTheme.primary),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.border,
                            child: const Center(
                              child: Icon(Icons.image_not_supported, color: AppTheme.textMuted, size: 40),
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.border,
                          child: const Center(
                            child: Icon(Icons.photo, color: AppTheme.textMuted, size: 40),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.navy,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _section('Description', item.description),
                      _section('Date', item.date),
                      _section('Price', '${item.price} EUR'),
                      _section('Latitude', item.latitude.toString()),
                      _section('Longitude', item.longitude.toString()),
                      _section('Contact name', item.contactName),
                      _section('Contact email', item.contactEmail),
                      _section('Photo path', item.photo),
                      _section('Created at', item.createdAt),
                      _section('Updated at', item.updatedAt),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _section(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
