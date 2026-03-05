import '../config/api_config.dart';

class TacosPlace {
  final int id;
  final String name;
  final String description;
  final String date;
  final int price;
  final double latitude;
  final double longitude;
  final String contactName;
  final String contactEmail;
  final String photo;
  final String photoUrl;
  final String createdAt;
  final String updatedAt;

  TacosPlace({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.price,
    required this.latitude,
    required this.longitude,
    required this.contactName,
    required this.contactEmail,
    required this.photo,
    required this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TacosPlace.fromJson(Map<String, dynamic> json) {
    final rawPhoto = (json['photo_url'] ?? '').toString();
    return TacosPlace(
      id: (json['id'] as num? ?? 0).toInt(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      price: (json['price'] as num? ?? 0).toInt(),
      latitude: (json['latitude'] as num? ?? 0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0).toDouble(),
      contactName: (json['contact_name'] ?? '').toString(),
      contactEmail: (json['contact_email'] ?? '').toString(),
      photo: (json['photo'] ?? '').toString(),
      photoUrl: _normalizePhotoUrl(rawPhoto),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
    );
  }

  static String _normalizePhotoUrl(String raw) {
    if (raw.isEmpty) return '';

    // If API returned a relative path, prefix with baseUrl.
    if (raw.startsWith('/')) {
      return '${ApiConfig.baseUrl}$raw';
    }
    if (raw.startsWith('uploads/')) {
      return '${ApiConfig.baseUrl}/$raw';
    }

    // If API returned localhost in container, rewrite to mobile baseUrl.
    try {
      final uri = Uri.parse(raw);
      if (uri.host == 'localhost' ||
          uri.host == '127.0.0.1' ||
          uri.host == '0.0.0.0') {
        final path = uri.path;
        return '${ApiConfig.baseUrl}$path';
      }
    } catch (_) {}

    return raw;
  }
}

class TacosPlacePage {
  final List<TacosPlace> items;
  final int page;
  final int limit;
  final bool hasMore;
  final int total;

  TacosPlacePage({
    required this.items,
    required this.page,
    required this.limit,
    required this.hasMore,
    required this.total,
  });
}
