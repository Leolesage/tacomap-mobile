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
    final rawPhotoUrl = (json['photo_url'] ?? '').toString();
    final rawPhotoPath = (json['photo'] ?? '').toString();

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
      photo: rawPhotoPath,
      photoUrl: _resolvePhotoUrl(rawPhotoUrl, rawPhotoPath),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
    );
  }

  static String _resolvePhotoUrl(String photoUrl, String photoPath) {
    final byPhotoUrl = _normalizeToApiBase(photoUrl);
    if (byPhotoUrl.isNotEmpty) {
      return byPhotoUrl;
    }

    final byPhotoPath = _normalizeToApiBase(photoPath);
    if (byPhotoPath.isNotEmpty) {
      return byPhotoPath;
    }

    return '';
  }

  static String _normalizeToApiBase(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';

    if (value.startsWith('uploads/')) {
      return '${ApiConfig.baseUrl}/$value';
    }

    if (value.startsWith('/uploads/')) {
      return '${ApiConfig.baseUrl}$value';
    }

    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      final normalizedPath =
          uri.path.startsWith('/') ? uri.path : '/${uri.path}';
      final query = uri.hasQuery ? '?${uri.query}' : '';

      if (normalizedPath.startsWith('/uploads/')) {
        return '${ApiConfig.baseUrl}$normalizedPath$query';
      }

      final localHost = uri.host == 'localhost' ||
          uri.host == '127.0.0.1' ||
          uri.host == '0.0.0.0';
      final dockerHost = !uri.host.contains('.') || uri.host.endsWith('.local');
      if (localHost || dockerHost) {
        return '${ApiConfig.baseUrl}$normalizedPath$query';
      }

      return value;
    }

    if (value.startsWith('/')) {
      return '${ApiConfig.baseUrl}$value';
    }

    return '${ApiConfig.baseUrl}/$value';
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
