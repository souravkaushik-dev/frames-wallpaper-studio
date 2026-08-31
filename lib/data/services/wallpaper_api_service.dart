import 'dart:convert';

import 'package:http/http.dart' as http;

class WallpaperApiService {
  static const String apiUrl =
      'https://api.npoint.io/7e89575ce8a8ac3c27fe';

  final http.Client _client;

  WallpaperApiService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> fetchWallpapers() async {
    final response = await _client.get(
      Uri.parse(apiUrl),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load wallpapers: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid wallpaper API response.');
    }

    return decoded;
  }

  void dispose() {
    _client.close();
  }
}
