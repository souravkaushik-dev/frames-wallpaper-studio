import 'dart:io';

import 'package:flutter/services.dart';

enum WallpaperTarget {
  home,
  lock,
  both,
}

abstract final class FleckWallpaperService {
  static const MethodChannel _channel =
  MethodChannel('fleck/wallpaper');

  static Future<void> setWallpaper({
    required File file,
    required WallpaperTarget target,
  }) async {
    if (!await file.exists()) {
      throw Exception(
        'Wallpaper file does not exist.',
      );
    }

    final size = await file.length();

    if (size <= 0) {
      throw Exception(
        'Wallpaper file is empty.',
      );
    }

    await _channel.invokeMethod<void>(
      'setWallpaper',
      <String, dynamic>{
        'path': file.path,
        'target': target.name,
      },
    );
  }
}