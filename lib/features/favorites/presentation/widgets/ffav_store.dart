import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/models/wallpaper.dart';

class FleckFavoritesStore {
  FleckFavoritesStore._();

  static const String _key = 'fleck_favorite_wallpaper_urls';

  static final ValueNotifier<Set<String>> urls =
  ValueNotifier<Set<String>>(<String>{});

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    urls.value = {
      ...?prefs.getStringList(_key),
    };
  }

  static bool contains(Wallpaper wallpaper) {
    return urls.value.contains(wallpaper.url);
  }

  static Future<void> toggle(Wallpaper wallpaper) async {
    final next = <String>{...urls.value};

    if (next.contains(wallpaper.url)) {
      next.remove(wallpaper.url);
    } else {
      next.add(wallpaper.url);
    }

    // Update UI immediately.
    urls.value = next;

    // Persist it.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      next.toList(),
    );
  }

  static Future<void> clear() async {
    urls.value = <String>{};

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}