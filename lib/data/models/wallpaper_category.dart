import 'wallpaper.dart';

class WallpaperCategory {
  const WallpaperCategory({
    required this.name,
    required this.thumbnail,
    required this.wallpapers,
  });

  final String name;
  final String thumbnail;
  final List<Wallpaper> wallpapers;

  factory WallpaperCategory.fromJson(
      String name,
      Map<String, dynamic> json,
      ) {
    final wallpapers =
    (json['wallpapers'] as List<dynamic>? ?? [])
        .map(
          (item) => Wallpaper.fromJson(
        item,
        category: name,
      ),
    )
        .where(
          (wallpaper) => wallpaper.url.isNotEmpty,
    )
        .toList();

    return WallpaperCategory(
      name: name,
      thumbnail: json['thumbnail']?.toString() ?? '',
      wallpapers: wallpapers,
    );
  }
}