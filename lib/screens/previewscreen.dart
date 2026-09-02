import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/models/fav_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

class PreviewScreen extends StatefulWidget {
  final String imageUrl;
  final String category;

  const PreviewScreen({
    super.key,
    required this.imageUrl,
    required this.category,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  bool _favoriteLoading = false;
  bool _isDownloading = false;
  bool _isSettingWallpaper = false;

  bool _showSetPanel = false;

  late final AnimationController _introController;
  late final Animation<double> _imageScale;
  late final Animation<double> _uiOpacity;
  late final Animation<Offset> _uiSlide;

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _background => _isDark
      ? AppColors.darkBackground
      : AppColors.lightBackground;

  Color get _primary => _isDark
      ? AppColors.darkPrimary
      : AppColors.lightPrimary;

  Color get _secondary => _isDark
      ? AppColors.darkSecondary
      : AppColors.lightSecondary;

  Color get _muted => _isDark
      ? AppColors.darkMuted
      : AppColors.lightMuted;

  Color get _divider => _isDark
      ? AppColors.darkDivider
      : AppColors.lightDivider;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _imageScale = Tween<double>(
      begin: 1.035,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Curves.easeOutCubic,
      ),
    );

    _uiOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(
        .08,
        1,
        curve: Curves.easeOutCubic,
      ),
    );

    _uiSlide = Tween<Offset>(
      begin: const Offset(0, .035),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(
          .08,
          1,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _loadFavorite();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarIconBrightness:
          Brightness.light,
          systemNavigationBarDividerColor:
          Colors.transparent,
        ),
      );

      _introController.forward();
    });
  }

  @override
  void dispose() {
    _introController.dispose();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    super.dispose();
  }

  // ===========================================================================
  // FAVORITE
  // ===========================================================================

  Future<void> _loadFavorite() async {
    try {
      final result =
      await FavoritesService.isFavorite(
        widget.imageUrl,
      );

      if (!mounted) return;

      setState(() {
        _isFavorite = result;
      });
    } catch (e) {
      debugPrint(
        'Favorite load error: $e',
      );
    }
  }

  Future<void> _toggleFavorite() async {
    if (_favoriteLoading) return;

    setState(() {
      _favoriteLoading = true;
    });

    HapticFeedback.selectionClick();

    try {
      await FavoritesService.toggleFavorite(
        imageUrl: widget.imageUrl,
        category: widget.category,
      );

      if (!mounted) return;

      setState(() {
        _isFavorite = !_isFavorite;
      });

      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint(
        'Favorite error: $e',
      );

      if (mounted) {
        _showMessage(
          'Could not update favorite',
          error: true,
        );
      }
    } finally {
      if (!mounted) return;

      setState(() {
        _favoriteLoading = false;
      });
    }
  }

  // ===========================================================================
  // SET PANEL
  // ===========================================================================

  void _openSetPanel() {
    if (_isSettingWallpaper) return;

    HapticFeedback.selectionClick();

    setState(() {
      _showSetPanel = true;
    });
  }

  void _closeSetPanel() {
    if (!mounted) return;

    HapticFeedback.selectionClick();

    setState(() {
      _showSetPanel = false;
    });
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: _background,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildWallpaper(),
          _buildWallpaperOverlay(),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                12.w,
                11.h,
                12.w,
                0,
              ),
              child: IgnorePointer(
                ignoring: _isSettingWallpaper,
                child: FadeTransition(
                  opacity: _uiOpacity,
                  child: Column(
                    children: [
                      _buildTopBar(),

                      const Spacer(),

                      Padding(
                        padding: EdgeInsets.only(
                          bottom:
                          10.h + bottomInset,
                        ),
                        child:
                        _buildBottomControls(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_isSettingWallpaper)
            const _SettingOverlay(),
        ],
      ),
    );
  }

  // ===========================================================================
  // WALLPAPER
  // ===========================================================================

  Widget _buildWallpaper() {
    return Positioned.fill(
      child: Hero(
        tag: widget.imageUrl,
        child: AnimatedBuilder(
          animation: _imageScale,
          builder: (
              context,
              child,
              ) {
            return Transform.scale(
              scale: _imageScale.value,
              child: child,
            );
          },
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            cacheWidth: 1440,
            gaplessPlayback: true,
            errorBuilder: (
                context,
                error,
                stackTrace,
                ) {
              return ColoredBox(
                color: _background,
                child: Center(
                  child: Icon(
                    Icons
                        .image_not_supported_outlined,
                    color: _muted,
                    size: 44.sp,
                  ),
                ),
              );
            },
            loadingBuilder: (
                context,
                child,
                progress,
                ) {
              if (progress == null) {
                return child;
              }

              return ColoredBox(
                color: _background,
                child: Center(
                  child: SizedBox(
                    width: 25.w,
                    height: 25.w,
                    child:
                    const CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWallpaperOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [
                0,
                .16,
                .60,
                .82,
                1,
              ],
              colors: [
                AppColors.darkBackground
                    .withOpacity(.34),
                AppColors.darkBackground
                    .withOpacity(.02),
                Colors.transparent,
                AppColors.darkBackground
                    .withOpacity(.10),
                AppColors.darkBackground
                    .withOpacity(.55),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TOP BAR
  // ===========================================================================

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        _GlassIconButton(
          icon: Hicons.left2LightOutline,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.pop(context);
          },
        ),

        Row(
          children: [
            _GlassIconButton(
              icon: _isFavorite
                  ? Hicons.heart3Bold
                  : Hicons.heart3LightOutline,
              iconColor: _isFavorite
                  ? AppColors.accent
                  : null,
              loading: _favoriteLoading,
              onTap: _toggleFavorite,
            ),

            SizedBox(width: 7.w),

            _GlassIconButton(
              icon:
              Hicons.downloadLightOutline,
              loading: _isDownloading,
              onTap: _isDownloading
                  ? null
                  : _downloadWallpaper,
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // BOTTOM AREA
  // ===========================================================================
  //
  // IMPORTANT:
  // The SET panel lives INSIDE this row.
  //
  // Therefore when it expands:
  //
  //     [ NAME ] [ SET ]
  //
  // becomes
  //
  //     [ NAME ] [ SET WALLPAPER ]
  //             [ HOME ]
  //             [ LOCK ]
  //             [ BOTH ]
  //
  // It expands upward from exactly the same position.
  //

  Widget _buildBottomControls() {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 126.w,
          height: 112.w,
          child: _WallpaperNameBox(
            name:
            getWallpaperName(
              widget.imageUrl,
            ),
            category:
            widget.category,
          ),
        ),

        SizedBox(width: 9.w),

        Expanded(
          child: Align(
            alignment:
            Alignment.bottomCenter,
            child: AnimatedSize(
              duration:
              const Duration(
                milliseconds: 360,
              ),
              reverseDuration:
              const Duration(
                milliseconds: 300,
              ),
              curve:
              Curves.easeOutCubic,
              alignment:
              Alignment.bottomCenter,
              child: _showSetPanel
                  ? _SetPanel(
                onClose:
                _closeSetPanel,
                onHome: () {
                  _applyWallpaper(
                    WallpaperManagerPlus
                        .homeScreen,
                    'Home Screen',
                  );
                },
                onLock: () {
                  _applyWallpaper(
                    WallpaperManagerPlus
                        .lockScreen,
                    'Lock Screen',
                  );
                },
                onBoth: () {
                  _applyWallpaper(
                    WallpaperManagerPlus
                        .bothScreens,
                    'Both Screens',
                  );
                },
              )
                  : SizedBox(
                width: double.infinity,
                height: 112.w,
                child:
                _SetActionCard(
                  onTap:
                  _openSetPanel,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // APPLY WALLPAPER
  // ===========================================================================

  Future<void> _applyWallpaper(
      int location,
      String locationName,
      ) async {
    if (_isSettingWallpaper) return;

    final uri =
    Uri.tryParse(widget.imageUrl);

    if (uri == null || !uri.hasScheme) {
      _showMessage(
        'Invalid wallpaper URL',
        error: true,
      );
      return;
    }

    setState(() {
      _isSettingWallpaper = true;
      _showSetPanel = false;
    });

    HapticFeedback.mediumImpact();

    File? wallpaperFile;

    try {
      final response = await http.get(
        uri,
        headers: const {
          'Accept': 'image/*',
        },
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw HttpException(
          'Server returned ${response.statusCode}',
        );
      }

      final bytes =
          response.bodyBytes;

      if (bytes.isEmpty) {
        throw Exception(
          'Downloaded image is empty',
        );
      }

      if (bytes.length < 10 * 1024) {
        throw Exception(
          'Downloaded image is invalid',
        );
      }

      final directory =
      await getTemporaryDirectory();

      final timestamp =
          DateTime.now()
              .microsecondsSinceEpoch;

      wallpaperFile = File(
        '${directory.path}/dotty_wallpaper_$timestamp.jpg',
      );

      await wallpaperFile.writeAsBytes(
        bytes,
        flush: true,
      );

      if (!await wallpaperFile.exists()) {
        throw Exception(
          'Temporary wallpaper file was not created',
        );
      }

      if (await wallpaperFile.length() <= 0) {
        throw Exception(
          'Temporary wallpaper file is empty',
        );
      }

      await WallpaperManagerPlus()
          .setWallpaper(
        wallpaperFile,
        location,
      )
          .timeout(
        const Duration(seconds: 30),
      );

      if (!mounted) return;

      HapticFeedback.heavyImpact();

      _showMessage(
        '$locationName wallpaper applied',
      );
    } on TimeoutException {
      if (mounted) {
        _showMessage(
          'Wallpaper operation timed out',
          error: true,
        );
      }
    } on SocketException {
      if (mounted) {
        _showMessage(
          'Could not download wallpaper',
          error: true,
        );
      }
    } on HttpException catch (e) {
      debugPrint(
        'Wallpaper HTTP error: $e',
      );

      if (mounted) {
        _showMessage(
          'Wallpaper download failed',
          error: true,
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Wallpaper error: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );

      if (mounted) {
        _showMessage(
          'Could not set wallpaper',
          error: true,
        );
      }
    } finally {
      try {
        if (wallpaperFile != null &&
            await wallpaperFile.exists()) {
          await wallpaperFile.delete();
        }
      } catch (e) {
        debugPrint(
          'Wallpaper cleanup error: $e',
        );
      }

      if (mounted) {
        setState(() {
          _isSettingWallpaper = false;
        });
      }
    }
  }

  // ===========================================================================
  // DOWNLOAD
  // ===========================================================================

  Future<void> _downloadWallpaper() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    HapticFeedback.mediumImpact();

    File? file;

    try {
      final permission =
      await Permission.photos.request();

      if (!permission.isGranted &&
          !permission.isLimited) {
        throw Exception(
          'Photos permission denied',
        );
      }

      final uri =
      Uri.tryParse(widget.imageUrl);

      if (uri == null || !uri.hasScheme) {
        throw Exception(
          'Invalid wallpaper URL',
        );
      }

      final response = await http.get(
        uri,
        headers: const {
          'Accept': 'image/*',
        },
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw HttpException(
          'Download failed: ${response.statusCode}',
        );
      }

      final bytes =
          response.bodyBytes;

      if (bytes.isEmpty) {
        throw Exception(
          'Downloaded image is empty',
        );
      }

      final directory =
      await getTemporaryDirectory();

      final timestamp =
          DateTime.now()
              .microsecondsSinceEpoch;

      file = File(
        '${directory.path}/dotty_download_$timestamp.jpg',
      );

      await file.writeAsBytes(
        bytes,
        flush: true,
      );

      await Gal.putImage(
        file.path,
      );

      if (!mounted) return;

      HapticFeedback.heavyImpact();

      _showMessage(
        'Wallpaper saved to gallery',
      );
    } on TimeoutException {
      if (mounted) {
        _showMessage(
          'Download timed out',
          error: true,
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Download error: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );

      if (mounted) {
        _showMessage(
          'Could not save wallpaper',
          error: true,
        );
      }
    } finally {
      try {
        if (file != null &&
            await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint(
          'Download cleanup error: $e',
        );
      }

      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  // ===========================================================================
  // MESSAGE
  // ===========================================================================

  void _showMessage(
      String message, {
        bool error = false,
      }) {
    if (!mounted) return;

    final messenger =
    ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior:
        SnackBarBehavior.floating,
        backgroundColor: _isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        margin: EdgeInsets.fromLTRB(
          14.w,
          0,
          14.w,
          15.h,
        ),
        elevation: 0,
        duration:
        const Duration(
          milliseconds: 2200,
        ),
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            18.r,
          ),
          side: BorderSide(
            color: error
                ? AppColors.accent
                .withOpacity(.28)
                : _divider,
          ),
        ),
        content: Row(
          children: [
            Icon(
              error
                  ? Icons.error_outline_rounded
                  : Icons
                  .check_circle_outline_rounded,
              color:
              AppColors.accent,
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style:
                GoogleFonts.manrope(
                  color: _primary,
                  fontSize: 10.sp,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // WALLPAPER NAME
  // ===========================================================================

  String getWallpaperName(
      String url,
      ) {
    String fileName =
        url.split('/').last;

    fileName =
        fileName.replaceAll(
          RegExp(
            r'\.(jpg|jpeg|png|webp)$',
            caseSensitive: false,
          ),
          '',
        );

    fileName =
        fileName.replaceAll(
          RegExp(
            r'-\d+x\d+-\d+$',
          ),
          '',
        );

    fileName =
        fileName.replaceAll(
          RegExp(r'[_-]+'),
          ' ',
        );

    final result = fileName
        .split(' ')
        .where(
          (word) =>
      word.isNotEmpty,
    )
        .map(
          (word) {
        return word[0]
            .toUpperCase() +
            word.substring(1);
      },
    )
        .join(' ');

    return result.isEmpty
        ? 'UNTITLED'
        : result;
  }
}

// ==============================================================================
// GLASS BUTTON
// ==============================================================================
//
// ONLY:
// - BACK
// - FAVORITE
// - DOWNLOAD
//
// use this.
//
// No shadow.
// No glow.
// No gradient.
//
// The glass follows the current Home/Categories theme.
//

class _GlassIconButton
    extends StatefulWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool loading;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.loading = false,
  });

  @override
  State<_GlassIconButton> createState() =>
      _GlassIconButtonState();
}

class _GlassIconButtonState
    extends State<_GlassIconButton> {
  bool _pressed = false;

  bool get _isDark =>
      Theme.of(context).brightness ==
          Brightness.dark;

  Color get _glassColor => _isDark
      ? AppColors.darkSurface
      .withOpacity(.34)
      : AppColors.lightSurface
      .withOpacity(.42);

  Color get _glassBorder => _isDark
      ? AppColors.darkPrimary
      .withOpacity(.12)
      : AppColors.lightPrimary
      .withOpacity(.14);

  Color get _iconColor => _isDark
      ? AppColors.darkPrimary
      : AppColors.lightPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior:
      HitTestBehavior.opaque,

      onTapDown: widget.onTap == null
          ? null
          : (_) {
        setState(() {
          _pressed = true;
        });
      },

      onTapCancel: widget.onTap == null
          ? null
          : () {
        setState(() {
          _pressed = false;
        });
      },

      onTapUp: widget.onTap == null
          ? null
          : (_) {
        setState(() {
          _pressed = false;
        });

        widget.onTap!();
      },

      child: AnimatedScale(
        scale: _pressed ? .90 : 1,
        duration:
        const Duration(
          milliseconds: 120,
        ),
        curve:
        Curves.easeOutCubic,
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(
            18.r,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ),
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration:
              BoxDecoration(
                color: _glassColor,
                borderRadius:
                BorderRadius.circular(
                  18.r,
                ),
                border: Border.all(
                  color: _glassBorder,
                  width: 1,
                ),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration:
                  const Duration(
                    milliseconds: 150,
                  ),
                  child: widget.loading
                      ? SizedBox(
                    key:
                    const ValueKey(
                      'loading',
                    ),
                    width: 17.w,
                    height: 17.w,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      1.7,
                      color:
                      _iconColor,
                    ),
                  )
                      : Icon(
                    widget.icon,
                    key: ValueKey(
                      widget.icon,
                    ),
                    color:
                    widget.iconColor ??
                        _iconColor,
                    size: 19.sp,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// CUSTOM SQUARE
// ==============================================================================
//
// Everything except the top three buttons uses this.
//
// No glass.
// No blur.
// No shadow.
// No glow.
//

class _CustomSquare
    extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color color;
  final double radius;

  const _CustomSquare({
    required this.child,
    required this.color,
    this.padding,
    this.radius = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      shadowColor:
      Colors.transparent,
      surfaceTintColor:
      Colors.transparent,
      clipBehavior:
      Clip.antiAlias,
      shape:
      ContinuousRectangleBorder(
        borderRadius:
        BorderRadius.circular(
          radius.r,
        ),
        side: BorderSide(
          color:
          Colors.black.withOpacity(.045),
          width: 1,
        ),
      ),
      child: Container(
        padding: padding,
        decoration:
        BoxDecoration(
          color: color,
          borderRadius:
          BorderRadius.circular(
            radius.r,
          ),
        ),
        child: child,
      ),
    );
  }
}

// ==============================================================================
// WALLPAPER NAME BOX
// ==============================================================================

class _WallpaperNameBox
    extends StatelessWidget {
  final String name;
  final String category;

  const _WallpaperNameBox({
    required this.name,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return _CustomSquare(
      color:
      const Color(0xFFF7F7F4),
      radius: 32,
      padding:
      EdgeInsets.fromLTRB(
        15.w,
        14.w,
        13.w,
        14.w,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration:
            const BoxDecoration(
              color:
              Color(0xFFFFFFFF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons
                  .auto_awesome_rounded,
              color:
              Colors.black
                  .withOpacity(.60),
              size: 18.sp,
            ),
          ),

          const Spacer(),

          Text(
            name,
            maxLines: 3,
            overflow:
            TextOverflow.ellipsis,
            style:
            GoogleFonts.manrope(
              color:
              Colors.black
                  .withOpacity(.78),
              fontSize: 12.5.sp,
              fontWeight:
              FontWeight.w500,
              height: 1.16,
              letterSpacing: -.25,
            ),
          ),

          SizedBox(height: 7.h),

          Text(
            category.toUpperCase(),
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            GoogleFonts.manrope(
              color:
              Colors.black
                  .withOpacity(.34),
              fontSize: 6.sp,
              fontWeight:
              FontWeight.w800,
              letterSpacing: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// SET ACTION CARD
// ==============================================================================

class _SetActionCard
    extends StatefulWidget {
  final VoidCallback onTap;

  const _SetActionCard({
    required this.onTap,
  });

  @override
  State<_SetActionCard> createState() =>
      _SetActionCardState();
}

class _SetActionCardState
    extends State<_SetActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior:
      HitTestBehavior.opaque,

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

        HapticFeedback.selectionClick();

        widget.onTap();
      },

      child: AnimatedScale(
        scale: _pressed ? .965 : 1,
        duration:
        const Duration(
          milliseconds: 120,
        ),
        curve:
        Curves.easeOutCubic,
        child: _CustomSquare(
          color:
          const Color(0xFFF7F7F4),
          radius: 32,
          padding:
          EdgeInsets.all(15.w),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration:
                const BoxDecoration(
                  color:
                  Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wallpaper_rounded,
                  color:
                  Colors.black
                      .withOpacity(.60),
                  size: 18.sp,
                ),
              ),

              const Spacer(),

              Row(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'SET',
                      style:
                      GoogleFonts.bebasNeue(
                        color:
                        Colors.black
                            .withOpacity(.80),
                        fontSize: 27.sp,
                        height: .85,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),

                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration:
                    const BoxDecoration(
                      color:
                      Color(0xFFFFFFFF),
                      shape:
                      BoxShape.circle,
                    ),
                    child: Icon(
                      Icons
                          .arrow_outward_rounded,
                      color:
                      Colors.black
                          .withOpacity(.62),
                      size: 15.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// EXPANDED SET PANEL
// ==============================================================================
//
// This is NOT a modal.
// This is NOT centered.
//
// It occupies the exact same right-side position as SET
// and grows upward from the bottom.
//

class _SetPanel extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onHome;
  final VoidCallback onLock;
  final VoidCallback onBoth;

  const _SetPanel({
    required this.onClose,
    required this.onHome,
    required this.onLock,
    required this.onBoth,
  });

  @override
  State<_SetPanel> createState() =>
      _SetPanelState();
}

class _SetPanelState
    extends State<_SetPanel> {
  @override
  Widget build(BuildContext context) {
    return _CustomSquare(
      color:
      const Color(0xFFF7F7F4),
      radius: 32,
      padding:
      EdgeInsets.all(12.w),
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration:
                const BoxDecoration(
                  color:
                  Color(0xFFFFFFFF),
                  shape:
                  BoxShape.circle,
                ),
                child: Icon(
                  Icons.wallpaper_rounded,
                  color:
                  Colors.black
                      .withOpacity(.60),
                  size: 17.sp,
                ),
              ),

              SizedBox(width: 9.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SET WALLPAPER',
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      GoogleFonts.bebasNeue(
                        color:
                        Colors.black
                            .withOpacity(.80),
                        fontSize: 21.sp,
                        height: .88,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'CHOOSE DISPLAY',
                      style:
                      GoogleFonts.manrope(
                        color:
                        Colors.black
                            .withOpacity(.38),
                        fontSize: 6.sp,
                        fontWeight:
                        FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              GestureDetector(
                behavior:
                HitTestBehavior.opaque,
                onTap:
                widget.onClose,
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFFFFFFF,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(
                      14.r,
                    ),
                    border:
                    Border.all(
                      color:
                      Colors.black
                          .withOpacity(
                        .035,
                      ),
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color:
                    Colors.black
                        .withOpacity(.62),
                    size: 17.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 9.h),

          _SetOption(
            number: '01',
            title: 'HOME',
            subtitle: 'HOME SCREEN',
            icon:
            Hicons.home3LightOutline,
            onTap: widget.onHome,
          ),

          SizedBox(height: 6.h),

          _SetOption(
            number: '02',
            title: 'LOCK',
            subtitle: 'LOCK SCREEN',
            icon:
            Hicons.lock2LightOutline,
            onTap: widget.onLock,
          ),

          SizedBox(height: 6.h),

          _SetOption(
            number: '03',
            title: 'BOTH',
            subtitle: 'HOME + LOCK',
            icon:
            Icons.layers_outlined,
            featured: true,
            onTap: widget.onBoth,
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// SET OPTION
// ==============================================================================

class _SetOption
    extends StatefulWidget {
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool featured;

  const _SetOption({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.featured = false,
  });

  @override
  State<_SetOption> createState() =>
      _SetOptionState();
}

class _SetOptionState
    extends State<_SetOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior:
      HitTestBehavior.opaque,

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

        HapticFeedback.mediumImpact();

        widget.onTap();
      },

      child: AnimatedScale(
        scale: _pressed ? .975 : 1,
        duration:
        const Duration(
          milliseconds: 120,
        ),
        curve:
        Curves.easeOutCubic,
        child: Container(
          height: 62.h,
          padding:
          EdgeInsets.symmetric(
            horizontal: 8.w,
          ),
          decoration:
          BoxDecoration(
            color: widget.featured
                ? AppColors.accent
                .withOpacity(.12)
                : Colors.black
                .withOpacity(.035),
            borderRadius:
            BorderRadius.circular(
              18.r,
            ),
            border:
            Border.all(
              color: widget.featured
                  ? AppColors.accent
                  .withOpacity(.28)
                  : Colors.black
                  .withOpacity(.045),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24.w,
                child: Text(
                  widget.number,
                  style:
                  GoogleFonts.bebasNeue(
                    color: Colors.black
                        .withOpacity(.35),
                    fontSize: 13.sp,
                    letterSpacing: .5,
                  ),
                ),
              ),

              Container(
                width: 40.w,
                height: 40.w,
                decoration:
                BoxDecoration(
                  color: widget.featured
                      ? AppColors.accent
                      .withOpacity(.13)
                      : Colors.white,
                  borderRadius:
                  BorderRadius.circular(
                    13.r,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.featured
                      ? AppColors.accent
                      : Colors.black
                      .withOpacity(.62),
                  size: 17.sp,
                ),
              ),

              SizedBox(width: 9.w),

              Expanded(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      GoogleFonts.manrope(
                        color: widget.featured
                            ? AppColors.accent
                            : Colors.black
                            .withOpacity(.75),
                        fontSize: 9.sp,
                        fontWeight:
                        FontWeight.w900,
                        letterSpacing: .7,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      GoogleFonts.manrope(
                        color: Colors.black
                            .withOpacity(.34),
                        fontSize: 5.7.sp,
                        fontWeight:
                        FontWeight.w700,
                        letterSpacing: .55,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 29.w,
                height: 29.w,
                decoration:
                BoxDecoration(
                  color: widget.featured
                      ? AppColors.accent
                      : Colors.white,
                  shape:
                  BoxShape.circle,
                ),
                child: Icon(
                  Icons
                      .arrow_outward_rounded,
                  color: widget.featured
                      ? Colors.white
                      : Colors.black
                      .withOpacity(.55),
                  size: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// SETTING OVERLAY
// ==============================================================================

class _SettingOverlay
    extends StatelessWidget {
  const _SettingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color:
        Colors.black.withOpacity(.30),
        child: Center(
          child: _CustomSquare(
            color:
            const Color(0xFFF7F7F4),
            radius: 28,
            padding:
            EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28.w,
                  height: 28.w,
                  child:
                  const CircularProgressIndicator(
                    strokeWidth: 1.8,
                    color:
                    AppColors.accent,
                  ),
                ),

                SizedBox(height: 13.h),

                Text(
                  'APPLYING',
                  style:
                  GoogleFonts.manrope(
                    color: Colors.black
                        .withOpacity(.78),
                    fontSize: 8.sp,
                    fontWeight:
                    FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),

                SizedBox(height: 5.h),

                Text(
                  'Preparing wallpaper',
                  textAlign:
                  TextAlign.center,
                  style:
                  GoogleFonts.manrope(
                    color: Colors.black
                        .withOpacity(.42),
                    fontSize: 8.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}