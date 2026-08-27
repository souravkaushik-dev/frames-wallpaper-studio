import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

import 'package:fleck/features/favorites/presentation/widgets/ffav_store.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/wallpaper.dart';

class WallpaperPreviewScreen extends StatefulWidget {
  const WallpaperPreviewScreen({
    super.key,
    required this.wallpaper,
  });

  final Wallpaper wallpaper;

  @override
  State<WallpaperPreviewScreen> createState() =>
      _WallpaperPreviewScreenState();
}

class _WallpaperPreviewScreenState
    extends State<WallpaperPreviewScreen> {
  bool _liked = false;
  bool _downloading = false;
  bool _applying = false;

  @override
  void initState() {
    super.initState();

    _liked = FleckFavoritesStore.urls.value.contains(
      widget.wallpaper.url,
    );
  }

  // ===========================================================================
  // FAVORITE
  // ===========================================================================

  void _toggleFavorite() {
    HapticFeedback.mediumImpact();

    FleckFavoritesStore.toggle(
      widget.wallpaper,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _liked = FleckFavoritesStore.urls.value.contains(
        widget.wallpaper.url,
      );
    });
  }


  // ===========================================================================
  // DOWNLOAD TO GALLERY
  // ===========================================================================

  Future<void> _download() async {
    if (_downloading) {
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() {
      _downloading = true;
    });

    _showMessage(
      'Preparing wallpaper…',
    );

    try {
      final file =
      await _getWallpaperFile();

      if (!await file.exists()) {
        throw Exception(
          'Downloaded file does not exist.',
        );
      }

      final bytes =
      await file.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception(
          'Downloaded file is empty.',
        );
      }

      _showMessage(
        'Saving wallpaper…',
      );

      final result =
      await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(bytes),
        quality: 100,
        name: _downloadFileName(),
      );

      debugPrint(
        'Fleck gallery result: $result',
      );

      if (!mounted) {
        return;
      }

      if (_gallerySaveSucceeded(result)) {
        _showMessage(
          'Wallpaper saved to your gallery.',
        );
      } else {
        _showMessage(
          'Could not save wallpaper.',
        );
      }
    } catch (error, stackTrace) {
      debugPrint(
        'Fleck download error: $error',
      );

      debugPrint(
        stackTrace.toString(),
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not download wallpaper.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _downloading = false;
        });
      }
    }
  }

  bool _gallerySaveSucceeded(
      dynamic result,
      ) {
    if (result is Map) {
      final value =
      result['isSuccess'];

      if (value is bool) {
        return value;
      }

      if (value is String) {
        return value.toLowerCase() ==
            'true';
      }
    }

    return false;
  }

  String _downloadFileName() {
    final name =
    _wallpaperName();

    if (name.isEmpty) {
      return 'fleck_wallpaper_'
          '${DateTime.now().millisecondsSinceEpoch}';
    }

    final safeName = name
        .replaceAll(
      RegExp(
        r'[^a-zA-Z0-9_\- ]',
      ),
      '',
    )
        .replaceAll(
      RegExp(r'\s+'),
      '_',
    )
        .trim();

    if (safeName.isEmpty) {
      return 'fleck_wallpaper_'
          '${DateTime.now().millisecondsSinceEpoch}';
    }

    return 'fleck_$safeName';
  }

  // ===========================================================================
  // APPLY WALLPAPER
  // ===========================================================================

  Future<void> _apply() async {
    if (_applying) {
      return;
    }

    HapticFeedback.mediumImpact();

    // ------------------------------------------------------------
    // 1. Choose destination FIRST.
    // ------------------------------------------------------------

    final target =
    await showGeneralDialog<_WallpaperApplyTarget>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Apply wallpaper',
      barrierColor: Colors.black.withValues(
        alpha: .50,
      ),
      transitionDuration:
      const Duration(milliseconds: 300),
      pageBuilder: (
          context,
          animation,
          secondaryAnimation,
          ) {
        return const _WallpaperApplyPopup();
      },
      transitionBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
          ) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: .94,
              end: 1,
            ).animate(curve),
            child: child,
          ),
        );
      },
    );

    if (!mounted || target == null) {
      return;
    }

    // ------------------------------------------------------------
    // 2. Lock UI AFTER destination is selected.
    // ------------------------------------------------------------

    setState(() {
      _applying = true;
    });

    try {
      _showMessage(
        'Downloading wallpaper…',
      );

      // ----------------------------------------------------------
      // 3. Download exactly like package documentation.
      // ----------------------------------------------------------

      final file =
      await _getWallpaperFile();

      if (!await file.exists()) {
        throw Exception(
          'Wallpaper file does not exist.',
        );
      }

      final bytes =
      await file.length();

      if (bytes <= 0) {
        throw Exception(
          'Wallpaper file is empty.',
        );
      }

      debugPrint(
        'Fleck: wallpaper file = ${file.path}',
      );

      debugPrint(
        'Fleck: wallpaper size = $bytes',
      );

      // ----------------------------------------------------------
      // 4. Resolve destination.
      // ----------------------------------------------------------

      final location = switch (target) {
        _WallpaperApplyTarget.home =>
        WallpaperManagerPlus.homeScreen,

        _WallpaperApplyTarget.lock =>
        WallpaperManagerPlus.lockScreen,

        _WallpaperApplyTarget.both =>
        WallpaperManagerPlus.bothScreens,
      };

      debugPrint(
        'Fleck: wallpaper location = $location',
      );

      _showMessage(
        'Applying wallpaper…',
      );

      // ----------------------------------------------------------
      // 5. Call plugin ONCE.
      // ----------------------------------------------------------

      final manager =
      WallpaperManagerPlus();

      debugPrint(
        'Fleck: BEFORE setWallpaper',
      );

      final result = await manager
          .setWallpaper(
        file,
        location,
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException(
            'setWallpaper did not return within 15 seconds.',
          );
        },
      );

      debugPrint(
        'Fleck: AFTER setWallpaper: $result',
      );

      debugPrint(
        'Fleck: wallpaper result = $result',
      );

      if (!mounted) {
        return;
      }

      HapticFeedback.mediumImpact();

      _showMessage(
        result?.isNotEmpty == true
            ? result!
            : '${target.label} applied',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Fleck wallpaper ERROR: $error',
      );

      debugPrint(
        stackTrace.toString(),
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not set wallpaper.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _applying = false;
        });
      }
    }
  }

  Future<File> _getWallpaperFile() async {
    final url = widget.wallpaper.url.trim();

    if (url.isEmpty) {
      throw Exception('Wallpaper URL is empty.');
    }

    final uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' &&
            uri.scheme != 'https')) {
      throw Exception('Invalid wallpaper URL.');
    }

    return DefaultCacheManager().getSingleFile(url);
  }
  // ===========================================================================
  // MESSAGE
  // ===========================================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    final colors =
        Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior:
          SnackBarBehavior.floating,
          backgroundColor:
          colors.inverseSurface,
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              22.r,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color:
              colors.onInverseSurface,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),
      );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ================================================================
          // WALLPAPER
          // ================================================================

          Hero(
            tag:
            'wallpaper-${widget.wallpaper.url}',
            child: _WallpaperImage(
              url:
              widget.wallpaper.url,
            ),
          ),

          // ================================================================
          // TOP GRADIENT
          // ================================================================

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 230.h,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration:
                BoxDecoration(
                  gradient:
                  LinearGradient(
                    begin:
                    Alignment.topCenter,
                    end:
                    Alignment.bottomCenter,
                    colors: [
                      Colors.black
                          .withValues(
                        alpha: .55,
                      ),
                      Colors.black
                          .withValues(
                        alpha: .12,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ================================================================
          // BACK
          // ================================================================

          Positioned(
            top:
            MediaQuery.of(context)
                .padding
                .top +
                10.h,
            left: 16.w,
            child:
            _TopButton(
              icon:
              Hicons.left2LightOutline,
              onPressed: () {
                HapticFeedback
                    .selectionClick();

                Navigator.of(context)
                    .maybePop();
              },
            ),
          ),

          // ================================================================
          // CONTENT
          // ================================================================

          DraggableScrollableSheet(
            initialChildSize: .25,
            minChildSize: .25,
            maxChildSize: .90,
            snap: true,
            snapSizes: const [
              .25,
              .52,
              .90,
            ],
            builder: (
                context,
                controller,
                ) {
              return _PreviewSheet(
                wallpaper:
                widget.wallpaper,
                controller:
                controller,
                liked: _liked,
                downloading:
                _downloading,
                applying:
                _applying,
                onFavorite:
                _toggleFavorite,
                onDownload:
                _download,
                onApply:
                _apply,
              );
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // NAME
  // ===========================================================================

  String _wallpaperName() {
    try {
      final uri =
      Uri.tryParse(
        widget.wallpaper.url,
      );

      if (uri == null ||
          uri.pathSegments.isEmpty) {
        return '';
      }

      var value =
          uri.pathSegments.last;

      value =
          value.split('?').first;

      value =
          value.split('#').first;

      value =
          value.replaceFirst(
            RegExp(
              r'\.(jpg|jpeg|png|webp|avif|gif)$',
              caseSensitive: false,
            ),
            '',
          );

      value =
          value.replaceAll(
            RegExp(r'[_\-]+'),
            ' ',
          );

      value =
          value.replaceAll(
            RegExp(r'\s+'),
            ' ',
          ).trim();

      return value
          .split(' ')
          .where(
            (word) =>
        word.isNotEmpty,
      )
          .map(
            (word) {
          if (word.length == 1) {
            return word.toUpperCase();
          }

          return word[0]
              .toUpperCase() +
              word.substring(1);
        },
      )
          .join(' ');
    } catch (_) {
      return '';
    }
  }
}

// =============================================================================
// WALLPAPER IMAGE
// =============================================================================

class _WallpaperImage
    extends StatelessWidget {
  const _WallpaperImage({
    required this.url,
  });

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.white,
            size: 34,
          ),
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      filterQuality:
      FilterQuality.high,
      loadingBuilder: (
          context,
          child,
          progress,
          ) {
        if (progress == null) {
          return child;
        }

        return const ColoredBox(
          color: Colors.black,
          child: Center(
            child:
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (
          context,
          error,
          stackTrace,
          ) {
        return const ColoredBox(
          color: Colors.black,
          child: Center(
            child: Icon(
              Icons
                  .image_not_supported_outlined,
              color: Colors.white,
              size: 34,
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// TOP BUTTON
// =============================================================================

class _TopButton
    extends StatelessWidget {
  const _TopButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
      Colors.black.withValues(
        alpha: .34,
      ),
      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(
          18.r,
        ),
        side: BorderSide(
          color:
          Colors.white.withValues(
            alpha: .28,
          ),
        ),
      ),
      clipBehavior:
      Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 50.w,
          height: 50.w,
          child: Icon(
            icon,
            color: Colors.white,
            size: 22.sp,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// PREVIEW SHEET
// =============================================================================

class _PreviewSheet
    extends StatelessWidget {
  const _PreviewSheet({
    required this.wallpaper,
    required this.controller,
    required this.liked,
    required this.downloading,
    required this.applying,
    required this.onFavorite,
    required this.onDownload,
    required this.onApply,
  });

  final Wallpaper wallpaper;
  final ScrollController controller;
  final bool liked;
  final bool downloading;
  final bool applying;

  final VoidCallback onFavorite;
  final VoidCallback onDownload;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme =
    Theme.of(context);

    final colors =
        theme.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius:
      BorderRadius.vertical(
        top: Radius.circular(
          38.r,
        ),
      ),
      clipBehavior:
      Clip.antiAlias,
      elevation: 12,
      child: CustomScrollView(
        controller:
        controller,
        physics:
        const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: _SheetHandle(),
          ),

          SliverPadding(
            padding:
            EdgeInsets.fromLTRB(
              20.w,
              8.h,
              20.w,
              100.h,
            ),
            sliver:
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  // =========================================================
                  // HEADER
                  // =========================================================

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _displayName(),
                          maxLines: 1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style: theme
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                            fontWeight:
                            FontWeight.w800,
                            letterSpacing:
                            -1,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 12.w,
                      ),

                      _FavoriteButton(
                        liked: liked,
                        onPressed:
                        onFavorite,
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 22.h,
                  ),

                  // =========================================================
                  // ACTIONS
                  // =========================================================

                  Row(
                    children: [
                      Expanded(
                        child:
                        _ActionButton(
                          label: downloading
                              ? 'Saving…'
                              : 'Download',
                          icon: Hicons
                              .downloadLightOutline,
                          background: colors
                              .surfaceContainerHighest,
                          foreground: colors
                              .onSurface,
                          loading:
                          downloading,
                          onPressed:
                          downloading
                              ? null
                              : onDownload,
                        ),
                      ),

                      SizedBox(
                        width: 10.w,
                      ),

                      Expanded(
                        child:
                        _ActionButton(
                          label: applying
                              ? 'Applying…'
                              : 'Apply',
                          icon: Hicons
                              .tickLightOutline,
                          background:
                          FleckTheme.seedColor,
                          foreground:
                          colors.onPrimary,
                          loading:
                          applying,
                          onPressed:
                          applying
                              ? null
                              : onApply,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 34.h,
                  ),

                  // =========================================================
                  // DETAILS
                  // =========================================================

                  _SectionTitle(
                    icon: Hicons
                        .informationSquareLightOutline,
                    title: 'Wallpaper',
                  ),

                  SizedBox(
                    height: 12.h,
                  ),

                  _DetailsCard(
                    wallpaper:
                    wallpaper,
                  ),

                  SizedBox(
                    height: 30.h,
                  ),

                  // =========================================================
                  // SOURCE
                  // =========================================================

                  _SectionTitle(
                    icon:
                    Hicons.linkLightOutline,
                    title: 'Source',
                  ),

                  SizedBox(
                    height: 12.h,
                  ),

                  _SourceCard(
                    url: wallpaper.url,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayName() {
    try {
      final uri =
      Uri.tryParse(
        wallpaper.url,
      );

      if (uri == null ||
          uri.pathSegments.isEmpty) {
        return 'Wallpaper';
      }

      var name =
          uri.pathSegments.last;

      name =
          name.split('?').first;

      name =
          name.replaceFirst(
            RegExp(
              r'\.(jpg|jpeg|png|webp|avif|gif)$',
              caseSensitive: false,
            ),
            '',
          );

      name =
          name.replaceAll(
            RegExp(r'[_\-]+'),
            ' ',
          );

      name =
          name.replaceAll(
            RegExp(r'\s+'),
            ' ',
          ).trim();

      if (name.isEmpty) {
        return 'Wallpaper';
      }

      final words =
      name.split(' ');

      if (words.length > 2) {
        name =
        '${words[0]} ${words[1]}';
      }

      return name
          .split(' ')
          .map(
            (word) =>
        word.isEmpty
            ? word
            : word[0]
            .toUpperCase() +
            word.substring(
              1,
            ),
      )
          .join(' ');
    } catch (_) {
      return 'Wallpaper';
    }
  }
}

// =============================================================================
// SHEET HANDLE
// =============================================================================

class _SheetHandle
    extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Padding(
      padding:
      EdgeInsets.only(
        top: 11.h,
        bottom: 10.h,
      ),
      child: Center(
        child: Container(
          width: 42.w,
          height: 5.h,
          decoration:
          BoxDecoration(
            color: colors
                .onSurfaceVariant
                .withValues(
              alpha: .28,
            ),
            borderRadius:
            BorderRadius.circular(
              99,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// FAVORITE
// =============================================================================

class _FavoriteButton
    extends StatelessWidget {
  const _FavoriteButton({
    required this.liked,
    required this.onPressed,
  });

  final bool liked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Material(
      color: liked
          ? FleckTheme.seedColor
          : colors
          .surfaceContainerHighest,
      shape:
      const CircleBorder(),
      clipBehavior:
      Clip.antiAlias,
      child: InkWell(
        customBorder:
        const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 54.w,
          height: 54.w,
          child: Icon(
            liked
                ? Hicons.heart2Bold
                : Hicons
                .heart2LightOutline,
            color: liked
                ? colors.onPrimary
                : colors
                .onSurfaceVariant,
            size: 26.sp,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// ACTION BUTTON
// =============================================================================

class _ActionButton
    extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onPressed,
    required this.loading,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius:
      BorderRadius.circular(
        23.r,
      ),
      clipBehavior:
      Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius:
        BorderRadius.circular(
          23.r,
        ),
        child: SizedBox(
          height: 58.h,
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(
                  width: 19.sp,
                  height: 19.sp,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color:
                    foreground,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 20.sp,
                  color:
                  foreground,
                ),
              SizedBox(
                width: 8.w,
              ),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  color:
                  foreground,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SECTION TITLE
// =============================================================================

class _SectionTitle
    extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme =
    Theme.of(context);

    return Row(
      children: [
        Container(
          width: 38.w,
          height: 38.w,
          decoration:
          BoxDecoration(
            color:
            FleckTheme.primarySoft,
            borderRadius:
            BorderRadius.circular(
              14.r,
            ),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color:
            FleckTheme.seedColor,
          ),
        ),
        SizedBox(
          width: 11.w,
        ),
        Text(
          title,
          style: theme
              .textTheme
              .titleLarge
              ?.copyWith(
            fontWeight:
            FontWeight.w800,
            letterSpacing: -.5,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// DETAILS CARD
// =============================================================================

class _DetailsCard
    extends StatelessWidget {
  const _DetailsCard({
    required this.wallpaper,
  });

  final Wallpaper wallpaper;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context)
            .colorScheme;

    final name =
    _name();

    final format =
    _format();

    return Material(
      color:
      colors.surfaceContainerLow,
      borderRadius:
      BorderRadius.circular(
        25.r,
      ),
      child: Padding(
        padding:
        EdgeInsets.all(15.w),
        child: Column(
          children: [
            _DetailRow(
              icon: Hicons
                  .informationSquareLightOutline,
              title: 'Title',
              value:
              name.isEmpty
                  ? 'Wallpaper'
                  : name,
            ),
            _Divider(),
            _DetailRow(
              icon: Hicons
                  .documentAlignCenter2LightOutline,
              title: 'Format',
              value: format,
            ),
          ],
        ),
      ),
    );
  }

  String _name() {
    try {
      final uri =
      Uri.tryParse(
        wallpaper.url,
      );

      if (uri == null ||
          uri.pathSegments.isEmpty) {
        return '';
      }

      var name =
          uri.pathSegments.last;

      name =
          name.split('?').first;

      name =
          name.replaceFirst(
            RegExp(
              r'\.(jpg|jpeg|png|webp|avif|gif)$',
              caseSensitive: false,
            ),
            '',
          );

      name =
          name.replaceAll(
            RegExp(r'[_\-]+'),
            ' ',
          );

      return name
          .replaceAll(
        RegExp(r'\s+'),
        ' ',
      )
          .trim();
    } catch (_) {
      return '';
    }
  }

  String _format() {
    try {
      final uri =
      Uri.tryParse(
        wallpaper.url,
      );

      if (uri == null ||
          uri.pathSegments.isEmpty) {
        return 'Image';
      }

      final filename =
          uri.pathSegments.last
              .split('?')
              .first;

      final match = RegExp(
        r'\.([a-zA-Z0-9]+)$',
      ).firstMatch(
        filename,
      );

      return match?.group(1)
          ?.toUpperCase() ??
          'IMAGE';
    } catch (_) {
      return 'IMAGE';
    }
  }
}

// =============================================================================
// DETAIL ROW
// =============================================================================

class _DetailRow
    extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme =
    Theme.of(context);
    final colors =
        theme.colorScheme;

    return Padding(
      padding:
      EdgeInsets.symmetric(
        vertical: 10.h,
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration:
            BoxDecoration(
              color:
              FleckTheme.primarySoft,
              borderRadius:
              BorderRadius.circular(
                14.r,
              ),
            ),
            child: Icon(
              icon,
              size: 19.sp,
              color:
              FleckTheme.seedColor,
            ),
          ),
          SizedBox(
            width: 12.w,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                    color: colors
                        .onSurfaceVariant,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: theme
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DIVIDER
// =============================================================================

class _Divider
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Divider(
      height: 1,
      indent: 54.w,
      color: colors
          .outlineVariant
          .withValues(
        alpha: .30,
      ),
    );
  }
}

// =============================================================================
// SOURCE
// =============================================================================

class _SourceCard
    extends StatelessWidget {
  const _SourceCard({
    required this.url,
  });

  final String url;

  @override
  Widget build(BuildContext context) {
    final theme =
    Theme.of(context);
    final colors =
        theme.colorScheme;

    return Material(
      color:
      colors.surfaceContainerLow,
      borderRadius:
      BorderRadius.circular(
        24.r,
      ),
      clipBehavior:
      Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Clipboard.setData(
            ClipboardData(
              text: url,
            ),
          );

          HapticFeedback
              .selectionClick();

          ScaffoldMessenger.of(
            context,
          )
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                behavior:
                SnackBarBehavior
                    .floating,
                content:
                Text(
                  'Image URL copied',
                ),
              ),
            );
        },
        child: Padding(
          padding:
          EdgeInsets.all(15.w),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration:
                BoxDecoration(
                  color:
                  FleckTheme.primarySoft,
                  borderRadius:
                  BorderRadius.circular(
                    15.r,
                  ),
                ),
                child: Icon(
                  Hicons
                      .linkLightOutline,
                  size: 21.sp,
                  color:
                  FleckTheme.seedColor,
                ),
              ),
              SizedBox(
                width: 12.w,
              ),
              Expanded(
                child: Text(
                  url,
                  maxLines: 3,
                  overflow:
                  TextOverflow.ellipsis,
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: colors
                        .onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// APPLY TARGET
// =============================================================================

enum _WallpaperApplyTarget {
  home,
  lock,
  both,
}

extension _WallpaperApplyTargetExtension
on _WallpaperApplyTarget {
  String get label {
    switch (this) {
      case _WallpaperApplyTarget.home:
        return 'Home screen';

      case _WallpaperApplyTarget.lock:
        return 'Lock screen';

      case _WallpaperApplyTarget.both:
        return 'Home & lock screen';
    }
  }

  String get description {
    switch (this) {
      case _WallpaperApplyTarget.home:
        return 'Use this wallpaper on your Home screen';

      case _WallpaperApplyTarget.lock:
        return 'Use this wallpaper on your Lock screen';

      case _WallpaperApplyTarget.both:
        return 'Use this wallpaper on both screens';
    }
  }

  IconData get icon {
    switch (this) {
      case _WallpaperApplyTarget.home:
        return Hicons.home1LightOutline;

      case _WallpaperApplyTarget.lock:
        return Hicons.lock2LightOutline;

      case _WallpaperApplyTarget.both:
        return Hicons.imageLightOutline;
    }
  }
}

// =============================================================================
// APPLY POPUP
// =============================================================================

class _WallpaperApplyPopup
    extends StatelessWidget {
  const _WallpaperApplyPopup();

  @override
  Widget build(BuildContext context) {
    final theme =
    Theme.of(context);
    final colors =
        theme.colorScheme;

    return Dialog(
      insetPadding:
      EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 28.h,
      ),
      backgroundColor:
      Colors.transparent,
      elevation: 0,
      child: Material(
        color:
        colors.surfaceContainerHigh,
        borderRadius:
        BorderRadius.circular(
          34.r,
        ),
        clipBehavior:
        Clip.antiAlias,
        child: Padding(
          padding:
          EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration:
                    BoxDecoration(
                      color: colors
                          .primaryContainer,
                      borderRadius:
                      BorderRadius.circular(
                        18.r,
                      ),
                    ),
                    child: Icon(
                      Hicons
                          .imageLightOutline,
                      size: 24.sp,
                      color: colors
                          .onPrimaryContainer,
                    ),
                  ),

                  SizedBox(
                    width: 13.w,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          'Apply wallpaper',
                          style: theme
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                            fontWeight:
                            FontWeight.w800,
                            letterSpacing:
                            -.4,
                          ),
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Text(
                          'Choose where to apply it.',
                          style: theme
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: colors
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Material(
                    color: colors
                        .surfaceContainerHighest,
                    shape:
                    const CircleBorder(),
                    clipBehavior:
                    Clip.antiAlias,
                    child: InkWell(
                      customBorder:
                      const CircleBorder(),
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pop();
                      },
                      child: SizedBox(
                        width: 42.w,
                        height: 42.w,
                        child: Icon(
                          Hicons
                              .closeLightOutline,
                          size: 18.sp,
                          color: colors
                              .onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 20.h,
              ),

              const _ApplyOption(
                target:
                _WallpaperApplyTarget
                    .home,
              ),

              SizedBox(
                height: 9.h,
              ),

              const _ApplyOption(
                target:
                _WallpaperApplyTarget
                    .lock,
              ),

              SizedBox(
                height: 9.h,
              ),

              const _ApplyOption(
                target:
                _WallpaperApplyTarget
                    .both,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// APPLY OPTION
// =============================================================================

class _ApplyOption
    extends StatefulWidget {
  const _ApplyOption({
    required this.target,
  });

  final _WallpaperApplyTarget target;

  @override
  State<_ApplyOption> createState() =>
      _ApplyOptionState();
}

class _ApplyOptionState
    extends State<_ApplyOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme =
    Theme.of(context);
    final colors =
        theme.colorScheme;

    return AnimatedScale(
      scale: _pressed
          ? .975
          : 1,
      duration:
      const Duration(
        milliseconds: 150,
      ),
      curve:
      Curves.easeOutCubic,
      child: Material(
        color:
        colors.surfaceContainer,
        borderRadius:
        BorderRadius.circular(
          24.r,
        ),
        clipBehavior:
        Clip.antiAlias,
        child: InkWell(
          borderRadius:
          BorderRadius.circular(
            24.r,
          ),
          onTap: () {
            HapticFeedback
                .selectionClick();

            Navigator.of(context).pop(
              widget.target,
            );
          },
          onTapDown: (_) {
            setState(() {
              _pressed = true;
            });
          },
          onTapCancel: () {
            setState(() {
              _pressed = false;
            });
          },
          onTapUp: (_) {
            setState(() {
              _pressed = false;
            });
          },
          child: Padding(
            padding:
            EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration:
                  BoxDecoration(
                    color: colors
                        .primaryContainer,
                    borderRadius:
                    BorderRadius.circular(
                      17.r,
                    ),
                  ),
                  child: Icon(
                    widget.target.icon,
                    size: 22.sp,
                    color: colors
                        .onPrimaryContainer,
                  ),
                ),

                SizedBox(
                  width: 14.w,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        widget.target.label,
                        style: theme
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      Text(
                        widget.target.description,
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: colors
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: 8.w,
                ),

                Icon(
                  Hicons
                      .right2LightOutline,
                  size: 20.sp,
                  color: colors
                      .onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}