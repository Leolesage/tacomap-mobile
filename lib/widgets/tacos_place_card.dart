import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/tacos_place.dart';
import '../theme/app_theme.dart';

class TacosPlaceCard extends StatelessWidget {
  final TacosPlace item;
  final VoidCallback onTap;

  const TacosPlaceCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: item.photoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.photoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Center(
                            child: Icon(Icons.image_not_supported, color: AppTheme.textMuted, size: 32),
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFE2E8F0),
                        child: const Center(
                          child: Icon(Icons.photo, color: AppTheme.textMuted, size: 32),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.navy,
                      letterSpacing: 0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.date,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.euro_outlined, size: 13, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${item.price} EUR',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'DETAILS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.navy,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.navy,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward, size: 13, color: AppTheme.navy),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
