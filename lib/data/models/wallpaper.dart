class Wallpaper {
  const Wallpaper({
    required this.url,
    this.category,
    this.id,
    this.title,
    this.author,
    this.collection,
    this.dimensions,
    this.license,
    this.isExclusive = false,
    this.colors = const [],
  });

  final String url;
  final String? category;

  // Optional metadata.
  final String? id;
  final String? title;
  final String? author;
  final String? collection;
  final String? dimensions;
  final String? license;
  final bool isExclusive;
  final List<String> colors;

  factory Wallpaper.fromJson(
      dynamic json, {
        String? category,
      }) {
    /*
     * Your CURRENT API:
     *
     * "wallpapers": [
     *   "https://..."
     * ]
     *
     * So strings are still supported.
     */
    if (json is String) {
      return Wallpaper(
        url: json,
        category: category,
      );
    }

    /*
     * Future / extended API:
     *
     * {
     *   "id": "...",
     *   "url": "...",
     *   "title": "...",
     *   ...
     * }
     */
    if (json is Map<String, dynamic>) {
      return Wallpaper(
        url: json['url']?.toString() ??
            json['imageUrl']?.toString() ??
            '',
        category: category,
        id: json['id']?.toString(),
        title: json['title']?.toString(),
        author: json['author']?.toString(),
        collection: json['collection']?.toString(),
        dimensions: json['dimensions']?.toString(),
        license: json['license']?.toString(),
        isExclusive: json['isExclusive'] == true,
        colors: (json['colors'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList() ??
            const [],
      );
    }

    return Wallpaper(
      url: '',
      category: category,
    );
  }
}