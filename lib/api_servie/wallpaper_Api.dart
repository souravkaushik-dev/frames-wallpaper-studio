import 'dart:convert';

class Wallpaper {
  final String id;
  final String image;
  final String title;
  final String subtitle;
  final String category;
  final bool isViewed;
  final DateTime addedAt;

  const Wallpaper({
    required this.id,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.isViewed,
    required this.addedAt,
  });

  factory Wallpaper.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawAddedAt =
    json['addedAt']?.toString();

    DateTime parsedAddedAt;

    if (rawAddedAt != null &&
        rawAddedAt.isNotEmpty) {
      parsedAddedAt =
          DateTime.tryParse(
            rawAddedAt,
          ) ??
              DateTime.now();
    } else {
      parsedAddedAt =
          DateTime.now();
    }

    return Wallpaper(
      id:
      json['id']?.toString() ??
          DateTime.now()
              .millisecondsSinceEpoch
              .toString(),

      image:
      json['image']?.toString() ??
          '',

      title:
      json['title']?.toString() ??
          'Wallpaper',

      subtitle:
      json['subtitle']?.toString() ??
          'Awesome wallpaper',

      category:
      json['category']?.toString() ??
          'Unknown',

      isViewed:
      json['isViewed'] == true,

      addedAt:
      parsedAddedAt,
    );
  }
}