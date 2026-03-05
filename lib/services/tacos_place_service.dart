import 'dart:convert';
import '../models/tacos_place.dart';
import '../services/api_client.dart';

class TacosPlaceService {
  final ApiClient apiClient;

  TacosPlaceService(this.apiClient);

  Future<TacosPlacePage> getTacosPlaces({required int page, required int limit}) async {
    final res = await apiClient.get('/api/tacos-places', query: {
      'page': page.toString(),
      'limit': limit.toString(),
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((e) => TacosPlace.fromJson(e as Map<String, dynamic>))
          .toList();

      return TacosPlacePage(
        items: list,
        page: (data['page'] ?? page) as int,
        limit: (data['limit'] ?? limit) as int,
        hasMore: (data['hasMore'] ?? false) as bool,
        total: (data['total'] ?? 0) as int,
      );
    }

    throw ApiException('Failed to load tacos places (${res.statusCode}).', statusCode: res.statusCode);
  }

  Future<TacosPlace> getTacosPlace(int id) async {
    final res = await apiClient.get('/api/tacos-places/$id');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return TacosPlace.fromJson(data);
    }

    throw ApiException('Tacos place not found (${res.statusCode}).', statusCode: res.statusCode);
  }

  Future<TacosPlace> createTacosPlace({
    required String name,
    required String description,
    required String date,
    required int price,
    required double latitude,
    required double longitude,
    required String contactName,
    required String contactEmail,
    required String photoPath,
  }) async {
    final fields = <String, String>{
      'name': name,
      'description': description,
      'date': date,
      'price': price.toString(),
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'contact_name': contactName,
      'contact_email': contactEmail,
    };

    final res = await apiClient.multipart(
      '/api/tacos-places',
      fields: fields,
      fileField: 'photo',
      filePath: photoPath,
    );

    final body = await res.stream.bytesToString();
    if (res.statusCode == 201) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return TacosPlace.fromJson(data);
    }

    throw ApiException('Create failed (${res.statusCode}).', statusCode: res.statusCode);
  }
}
