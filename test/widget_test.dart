import 'package:flutter_test/flutter_test.dart';
import 'package:tacomap_mobile/config/api_config.dart';

void main() {
  test('API base URL is configured', () {
    expect(ApiConfig.baseUrl.isNotEmpty, isTrue);
  });
}

