import '../models/wallpaper.dart';
import '../models/wallpaper_category.dart';
import '../services/wallpaper_api_service.dart';

class WallpaperRepository {
  WallpaperRepository({
    WallpaperApiService? apiService,
  }) : _apiService = apiService ?? WallpaperApiService();

  final WallpaperApiService _apiService;

  Future<List<Wallpaper>> getTrending() async {
    final data = await _apiService.fetchWallpapers();

    final trending = data['trending'] as List<dynamic>? ?? [];

    return trending
        .map(
          (url) => Wallpaper(
        url: url.toString(),
      ),
    )
        .toList();
  }

  Future<List<WallpaperCategory>> getCategories() async {
    final data = await _apiService.fetchWallpapers();

    final categories =
        data['categories'] as Map<String, dynamic>? ?? {};

    return categories.entries
        .map(
          (entry) => WallpaperCategory.fromJson(
        entry.key,
        Map<String, dynamic>.from(entry.value as Map),
      ),
    )
        .toList();
  }

  Future<WallpaperData> getAll() async {
    final data = await _apiService.fetchWallpapers();

    final trending = (data['trending'] as List<dynamic>? ?? [])
        .map(
          (url) => Wallpaper(
        url: url.toString(),
      ),
    )
        .toList();

    final rawCategories =
        data['categories'] as Map<String, dynamic>? ?? {};

    final categories = rawCategories.entries
        .map(
          (entry) => WallpaperCategory.fromJson(
        entry.key,
        Map<String, dynamic>.from(entry.value as Map),
      ),
    )
        .toList();

    return WallpaperData(
      trending: trending,
      categories: categories,
    );
  }

  void dispose() {
    _apiService.dispose();
  }
}

class WallpaperData {
  const WallpaperData({
    required this.trending,
    required this.categories,
  });

  final List<Wallpaper> trending;
  final List<WallpaperCategory> categories;
}
