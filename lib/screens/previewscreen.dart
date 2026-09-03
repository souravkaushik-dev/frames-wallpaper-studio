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

    final uiAnimation = CurvedAnimation(
      parent: _introController,
      curve: const Interval(
        .08,
        1.0,
        curve: Curves.easeOutCubic,
      ),
    );

    _uiOpacity = uiAnimation;

    _uiSlide = Tween<Offset>(
      begin: const Offset(0, .025),
      end: Offset.zero,
    ).animate(uiAnimation);

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

  ThemeData _expressiveTheme(BuildContext context) {
    final base = Theme.of(context);
    final dark = base.brightness == Brightness.dark;

    final scheme = base.colorScheme.copyWith(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      surface: dark ? AppColors.darkSurface : AppColors.lightSurface,
      onSurface: dark ? AppColors.darkPrimary : AppColors.lightPrimary,
      outline: dark ? AppColors.darkDivider : AppColors.lightDivider,
    );

    return base.copyWith(
      useMaterial3: true,
      colorScheme: scheme,
      splashFactory: InkSparkle.splashFactory,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.paddingOf(context).bottom;

    return Theme(
      data: _expressiveTheme(context),
      child: Scaffold(
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
                    child: SlideTransition(
                      position: _uiSlide,
                      child: Column(
                        children: [
                          _buildTopBar(),

                          const Spacer(),

                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 10.h + bottomInset,
                            ),
                            child: _buildBottomControls(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (_isSettingWallpaper)
              const _SettingOverlay(),
          ],
        ),
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
    return AnimatedSize(
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        reverseDuration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .035),
                end: Offset.zero,
              ).animate(curved),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: .985,
                  end: 1.0,
                ).animate(curved),
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            ),
          );
        },
        child: _showSetPanel
            ? _SetPanel(
          key: const ValueKey('wallpaper-set-panel'),
          onClose: _closeSetPanel,
          onHome: () {
            _applyWallpaper(
              WallpaperManagerPlus.homeScreen,
              'Home Screen',
            );
          },
          onLock: () {
            _applyWallpaper(
              WallpaperManagerPlus.lockScreen,
              'Lock Screen',
            );
          },
          onBoth: () {
            _applyWallpaper(
              WallpaperManagerPlus.bothScreens,
              'Both Screens',
            );
          },
        )
            : _PreviewBottomBar(
          key: const ValueKey('wallpaper-preview-bar'),
          name: getWallpaperName(widget.imageUrl),
          category: widget.category,
          onSet: _openSetPanel,
        ),
      ),
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
  final Color? color;
  final double radius;

  const _CustomSquare({
    required this.child,
    this.color,
    this.padding,
    this.radius = 30,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = color ??
        (isDark
            ? const Color(0xFF202020).withOpacity(.82)
            : const Color(0xFFF7F7F4).withOpacity(.82));

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 16,
          sigmaY: 16,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(radius.r),
            boxShadow: const [],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ==============================================================================
// WALLPAPER NAME BOX
// ==============================================================================

class _PreviewBottomBar extends StatelessWidget {
  final String name;
  final String category;
  final VoidCallback onSet;

  const _PreviewBottomBar({
    super.key,
    required this.name,
    required this.category,
    required this.onSet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 7,
          child: _WallpaperTitleCard(
            name: name,
            category: category,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          flex: 5,
          child: _SetWallpaperButton(onTap: onSet),
        ),
      ],
    );
  }
}

class _WallpaperTitleCard extends StatelessWidget {
  final String name;
  final String category;

  const _WallpaperTitleCard({
    required this.name,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return _CustomSquare(
      color: null,
      radius: 28,
      padding: EdgeInsets.fromLTRB(15.w, 13.w, 15.w, 13.w),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2C2C2C)
                  : const Color(0xFFFFFFFF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Hicons.display4LightOutline,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(.86)
                  : Colors.black54,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOW VIEWING',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.bebasNeue(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(.52) : Colors.black.withOpacity(.42),
                    fontSize: 7.5.sp,
                    height: .95,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.bebasNeue(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(.94) : Colors.black.withOpacity(.86),
                    fontSize: 16.sp,
                    height: .92,
                    letterSpacing: .55,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  category.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.bebasNeue(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(.48) : Colors.black.withOpacity(.40),
                    fontSize: 7.5.sp,
                    height: .95,
                    letterSpacing: .9,
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

class _SetWallpaperButton extends StatefulWidget {
  final VoidCallback onTap;

  const _SetWallpaperButton({
    required this.onTap,
  });

  @override
  State<_SetWallpaperButton> createState() => _SetWallpaperButtonState();
}

class _SetWallpaperButtonState extends State<_SetWallpaperButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? .965 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: _CustomSquare(
          color: null,
          radius: 28,
          padding: EdgeInsets.fromLTRB(15.w, 13.w, 13.w, 13.w),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2C2C2C)
                      : const Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Hicons.imageLightOutline,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(.86)
                      : Colors.black54,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SET',
                      style: GoogleFonts.bebasNeue(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(.92) : Colors.black.withOpacity(.82),
                        fontSize: 25.sp,
                        height: .88,
                        letterSpacing: .95,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'WALLPAPER',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.black38,
                        fontSize: 7.5.sp,
                        height: .95,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .9,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2C2C2C)
                      : const Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Hicons.send3LightOutline,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(.86)
                      : Colors.black54,
                  size: 14.sp,
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
    super.key,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 14.w),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(.58)
                : Colors.white.withOpacity(.72),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF252525)
                          : const Color(0xFFFFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Hicons.imageLightOutline,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(.78)
                          : Colors.black.withOpacity(.60),
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
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(.94)
                                : Colors.black.withOpacity(.80),
                            fontSize: 23.sp,
                            height: .90,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'CHOOSE DISPLAY',
                          style:
                          GoogleFonts.bebasNeue(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(.62)
                                : Colors.black.withOpacity(.48),
                            fontSize: 8.5.sp,
                            height: .95,
                            fontWeight:
                            FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: widget.onClose,
                    tooltip: 'Close',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 36.w,
                      minHeight: 36.w,
                    ),
                    icon: Icon(
                      Hicons.closeLightOutline,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(.68)
                          : Colors.black.withOpacity(.55),
                      size: 19.sp,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15.h),

              _SetOption(
                title: 'HOME',
                subtitle: 'HOME SCREEN',
                icon:
                Hicons.home3LightOutline,
                onTap: widget.onHome,
              ),

              SizedBox(height: 12.h),

              _SetOption(
                title: 'LOCK',
                subtitle: 'LOCK SCREEN',
                icon:
                Hicons.lock2LightOutline,
                onTap: widget.onLock,
              ),

              SizedBox(height: 12.h),

              _SetOption(
                title: 'BOTH',
                subtitle: 'HOME + LOCK',
                icon:
                Icons.layers_outlined,
                onTap: widget.onBoth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// SET OPTION
// ==============================================================================

class _SetOption
    extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool featured;

  const _SetOption({
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
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 11.h),
          child: Row(
            children: [
              SizedBox(
                width: 40.w,
                child: Icon(
                  widget.icon,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(.82)
                      : Colors.black.withOpacity(.62),
                  size: 24.sp,
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
                      GoogleFonts.bebasNeue(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(.96)
                            : Colors.black.withOpacity(.86),
                        fontSize: 15.5.sp,
                        height: .94,
                        letterSpacing: 1.05,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      GoogleFonts.bebasNeue(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(.52)
                            : Colors.black.withOpacity(.42),
                        fontSize: 9.sp,
                        height: .96,
                        letterSpacing: .8,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Hicons.right2LightOutline,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(.46)
                    : Colors.black.withOpacity(.34),
                size: 21.sp,
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