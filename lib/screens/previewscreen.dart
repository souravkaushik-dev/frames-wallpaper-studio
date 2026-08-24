import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/models/fav_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  State<PreviewScreen> createState() =>
      _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver {
  bool _isFavorite = false;
  bool _favoriteLoading = false;

  bool _isDownloading = false;
  bool _isSettingWallpaper = false;

  late final AnimationController _ambientController;

  // ============================================================
  // THEME
  // ============================================================

  bool get _isDark =>
      Theme.of(context).brightness ==
          Brightness.dark;

  Color get _background =>
      _isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground;

  Color get _surface =>
      _isDark
          ? AppColors.darkSurface
          : AppColors.lightSurface;

  Color get _surfaceSoft =>
      _isDark
          ? AppColors.darkSurfaceSoft
          : AppColors.lightSurfaceSoft;

  Color get _primary =>
      _isDark
          ? AppColors.darkPrimary
          : AppColors.lightPrimary;

  Color get _secondary =>
      _isDark
          ? AppColors.darkSecondary
          : AppColors.lightSecondary;

  Color get _muted =>
      _isDark
          ? AppColors.darkMuted
          : AppColors.lightMuted;

  Color get _divider =>
      _isDark
          ? AppColors.darkDivider
          : AppColors.lightDivider;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addObserver(this);

    _ambientController =
    AnimationController(
      vsync: this,
      duration:
      const Duration(seconds: 7),
    )..repeat(reverse: true);

    _loadFavorite();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) return;

      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );

      _updateSystemBars();
    });
  }

  void _updateSystemBars() {
    SystemChrome
        .setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor:
        Colors.transparent,
        systemNavigationBarColor:
        Colors.transparent,
        statusBarIconBrightness:
        Brightness.light,
        systemNavigationBarIconBrightness:
        Brightness.light,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    if (state ==
        AppLifecycleState.resumed) {
      _ambientController.repeat(
        reverse: true,
      );
    } else {
      _ambientController.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance
        .removeObserver(this);

    _ambientController.dispose();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    super.dispose();
  }

  // ============================================================
  // FAVORITE
  // ============================================================

  Future<void> _loadFavorite() async {
    try {
      final result =
      await FavoritesService
          .isFavorite(
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

    try {
      await FavoritesService
          .toggleFavorite(
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildWallpaper(),
          _buildCinematicOverlay(),
          _buildAmbientGlow(),

          SafeArea(
            child: Padding(
              padding:
              EdgeInsets.fromLTRB(
                18.w,
                16.h,
                18.w,
                14.h,
              ),
              child: Column(
                children: [
                  _buildTopBar(),

                  const Spacer(),

                  _buildBottomContent(),
                ],
              ),
            ),
          ),

          if (_isSettingWallpaper)
            const _SettingOverlay(),
        ],
      ),
    );
  }

  // ============================================================
  // WALLPAPER
  // ============================================================

  Widget _buildWallpaper() {
    return Positioned.fill(
      child: Hero(
        tag: widget.imageUrl,
        child: AnimatedBuilder(
          animation:
          _ambientController,
          builder:
              (context, child) {
            final value =
            Curves.easeInOut.transform(
              _ambientController.value,
            );

            return Transform.translate(
              offset: Offset(
                (value - .5) * 5,
                (value - .5) * 4,
              ),
              child: Transform.scale(
                scale:
                1.015 + (value * .025),
                child: child,
              ),
            );
          },
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
            filterQuality:
            FilterQuality.high,
            errorBuilder:
                (
                context,
                error,
                stackTrace,
                ) {
              return Container(
                color:
                const Color(0xFF08090D),
                alignment:
                Alignment.center,
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Icon(
                      Icons
                          .image_not_supported_outlined,
                      color:
                      Colors.white24,
                      size: 50.sp,
                    ),
                    SizedBox(
                      height: 14.h,
                    ),
                    Text(
                      'IMAGE UNAVAILABLE',
                      style:
                      GoogleFonts.inter(
                        color:
                        Colors.white54,
                        fontSize: 9.sp,
                        fontWeight:
                        FontWeight.w800,
                        letterSpacing:
                        1.8,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CINEMATIC OVERLAY
  // ============================================================

  Widget _buildCinematicOverlay() {
    return Positioned.fill(
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
              stops: const [
                0,
                .18,
                .52,
                .78,
                1,
              ],
              colors: [
                Colors.black
                    .withOpacity(.42),
                Colors.transparent,
                Colors.black
                    .withOpacity(.08),
                Colors.black
                    .withOpacity(.54),
                Colors.black
                    .withOpacity(.97),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AMBIENT ACCENT
  // ============================================================

  Widget _buildAmbientGlow() {
    return Positioned(
      left: -110.w,
      bottom: -130.h,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation:
          _ambientController,
          builder:
              (context, child) {
            final value =
                _ambientController.value;

            return Transform.scale(
              scale:
              1 + value * .10,
              child: child,
            );
          },
          child: Container(
            width: 350.w,
            height: 350.w,
            decoration:
            BoxDecoration(
              shape:
              BoxShape.circle,
              color: AppColors.accent
                  .withOpacity(
                _isDark ? .035 : .018,
              ),
            ),
          ).animate(
            onPlay: (controller) =>
                controller.repeat(
                  reverse: true,
                ),
          ).blurXY(
            begin: 70,
            end: 110,
            duration:
            const Duration(
              seconds: 5,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment
          .spaceBetween,
      children: [
        _CinematicButton(
          icon:
          Hicons.left2LightOutline,
          onTap: () {
            Navigator.pop(context);
          },
        ),
        Row(
          children: [
            _CinematicButton(
              icon: _isFavorite
                  ? Hicons.heart3Bold
                  : Hicons
                  .heart3LightOutline,
              iconColor: _isFavorite
                  ? Colors.redAccent
                  : Colors.white,
              loading:
              _favoriteLoading,
              onTap:
              _toggleFavorite,
            ),
            SizedBox(width: 10.w),
            _CinematicButton(
              icon:
              Hicons.downloadLightOutline,
              loading:
              _isDownloading,
              onTap:
              _isDownloading
                  ? null
                  : _downloadWallpaper,
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(
      duration:
      const Duration(
        milliseconds: 700,
      ),
    )
        .moveY(
      begin: -25,
      end: 0,
      curve:
      Curves.easeOutExpo,
    );
  }

  // ============================================================
  // BOTTOM CONTENT
  // ============================================================

  Widget _buildBottomContent() {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(
        38.r,
      ),
      child: BackdropFilter(
        filter:
        ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          width: double.infinity,
          padding:
          EdgeInsets.fromLTRB(
            22.w,
            22.h,
            22.w,
            22.h,
          ),
          decoration:
          BoxDecoration(
            color: Colors.black
                .withOpacity(.28),
            borderRadius:
            BorderRadius.circular(
              38.r,
            ),
            border:
            Border.all(
              color: Colors.white
                  .withOpacity(.10),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration:
                    BoxDecoration(
                      color:
                      AppColors.accent,
                      shape:
                      BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    widget.category
                        .toUpperCase(),
                    style:
                    GoogleFonts.inter(
                      color: Colors.white
                          .withOpacity(.62),
                      fontSize: 8.sp,
                      fontWeight:
                      FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(
                delay:
                const Duration(
                  milliseconds: 100,
                ),
              )
                  .moveX(
                begin: -18,
                end: 0,
                curve:
                Curves
                    .easeOutExpo,
              ),

              SizedBox(height: 14.h),

              Text(
                getWallpaperName(
                  widget.imageUrl,
                ),
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                style:
                GoogleFonts.bebasNeue(
                  color: Colors.white,
                  fontSize: 38.sp,
                  height: .88,
                  letterSpacing: 1.5,
                ),
              )
                  .animate()
                  .fadeIn(
                delay:
                const Duration(
                  milliseconds: 180,
                ),
                duration:
                const Duration(
                  milliseconds: 700,
                ),
              )
                  .moveY(
                begin: 35,
                end: 0,
                curve:
                Curves
                    .easeOutExpo,
              ),

              SizedBox(height: 9.h),

              Text(
                'Immersive premium wallpaper crafted with cinematic visuals and a clean modern aesthetic.',
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                style:
                GoogleFonts.inter(
                  color: Colors.white
                      .withOpacity(.58),
                  fontSize: 12.sp,
                  height: 1.6,
                  fontWeight:
                  FontWeight.w500,
                ),
              )
                  .animate()
                  .fadeIn(
                delay:
                const Duration(
                  milliseconds: 300,
                ),
              )
                  .moveY(
                begin: 15,
                end: 0,
                curve:
                Curves
                    .easeOutExpo,
              ),

              SizedBox(height: 19.h),

              _buildInfoRow()
                  .animate()
                  .fadeIn(
                delay:
                const Duration(
                  milliseconds: 400,
                ),
              )
                  .moveY(
                begin: 15,
                end: 0,
                curve:
                Curves
                    .easeOutExpo,
              ),

              SizedBox(height: 22.h),

              _buildSetWallpaperButton()
                  .animate()
                  .fadeIn(
                delay:
                const Duration(
                  milliseconds: 500,
                ),
              )
                  .moveY(
                begin: 25,
                end: 0,
                duration:
                const Duration(
                  milliseconds: 750,
                ),
                curve:
                Curves
                    .easeOutExpo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFO
  // ============================================================

  Widget _buildInfoRow() {
    return Row(
      children: [
        _InfoItem(
          icon: Icons.hd_rounded,
          value:
          getResolution(
            widget.imageUrl,
          ),
          label: 'RESOLUTION',
        ),
        SizedBox(width: 10.w),
        _InfoItem(
          icon: Icons.bolt_rounded,
          value: 'ULTRA',
          label: 'QUALITY',
        ),
        SizedBox(width: 10.w),
        _InfoItem(
          icon:
          Hicons.imageLightOutline,
          value: 'AMOLED',
          label: 'DISPLAY',
        ),
      ],
    );
  }

  // ============================================================
  // SET BUTTON
  // ============================================================

  Widget _buildSetWallpaperButton() {
    return _PremiumSetButton(
      loading:
      _isSettingWallpaper,
      onTap:
      _isSettingWallpaper
          ? null
          : _showWallpaperChooser,
    );
  }

  // ============================================================
  // WALLPAPER CHOOSER
  // ============================================================

  Future<void>
  _showWallpaperChooser() async {
    if (_isSettingWallpaper) {
      return;
    }

    HapticFeedback.selectionClick();

    await showModalBottomSheet(
      context: context,

      backgroundColor:
      Colors.transparent,

      barrierColor:
      _isDark
          ? Colors.black
          .withOpacity(.72)
          : Colors.black
          .withOpacity(.28),

      isScrollControlled: true,

      enableDrag: true,

      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
            EdgeInsets.fromLTRB(
              12.w,
              0,
              12.w,
              12.h,
            ),
            child:
            _WallpaperPickerSheet(
              onHome: () {
                Navigator.pop(
                  sheetContext,
                );

                _applyWallpaper(
                  WallpaperManagerPlus
                      .homeScreen,
                  'Home Screen',
                );
              },
              onLock: () {
                Navigator.pop(
                  sheetContext,
                );

                _applyWallpaper(
                  WallpaperManagerPlus
                      .lockScreen,
                  'Lock Screen',
                );
              },
              onBoth: () {
                Navigator.pop(
                  sheetContext,
                );

                _applyWallpaper(
                  WallpaperManagerPlus
                      .bothScreens,
                  'Both Screens',
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SAFE SET WALLPAPER
  // ============================================================

  Future<void> _applyWallpaper(
      int location,
      String locationName,
      ) async {
    if (_isSettingWallpaper) {
      return;
    }

    final uri =
    Uri.tryParse(
      widget.imageUrl,
    );

    if (uri == null ||
        !uri.hasScheme) {
      _showMessage(
        'Invalid wallpaper URL',
        error: true,
      );
      return;
    }

    setState(() {
      _isSettingWallpaper = true;
    });

    HapticFeedback.mediumImpact();

    File? wallpaperFile;

    try {
      final response =
      await http.get(
        uri,
        headers: const {
          'Accept': 'image/*',
        },
      ).timeout(
        const Duration(
          seconds: 30,
        ),
      );

      if (response.statusCode <
          200 ||
          response.statusCode >=
              300) {
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

      if (bytes.length <
          10 * 1024) {
        throw Exception(
          'Downloaded image is invalid',
        );
      }

      final directory =
      await getTemporaryDirectory();

      final timestamp = DateTime
          .now()
          .microsecondsSinceEpoch;

      wallpaperFile = File(
        '${directory.path}/dotty_wallpaper_$timestamp.jpg',
      );

      await wallpaperFile
          .writeAsBytes(
        bytes,
        flush: true,
      );

      if (!await wallpaperFile
          .exists()) {
        throw Exception(
          'Temporary wallpaper file was not created',
        );
      }

      final fileSize =
      await wallpaperFile
          .length();

      if (fileSize <= 0) {
        throw Exception(
          'Temporary wallpaper file is empty',
        );
      }

      final manager =
      WallpaperManagerPlus();

      await manager
          .setWallpaper(
        wallpaperFile,
        location,
      )
          .timeout(
        const Duration(
          seconds: 30,
        ),
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
            await wallpaperFile
                .exists()) {
          await wallpaperFile
              .delete();
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

  // ============================================================
  // DOWNLOAD
  // ============================================================

  Future<void>
  _downloadWallpaper() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    HapticFeedback.mediumImpact();

    File? file;

    try {
      final permission =
      await Permission.photos
          .request();

      if (!permission.isGranted &&
          !permission.isLimited) {
        throw Exception(
          'Photos permission denied',
        );
      }

      final uri =
      Uri.tryParse(
        widget.imageUrl,
      );

      if (uri == null ||
          !uri.hasScheme) {
        throw Exception(
          'Invalid wallpaper URL',
        );
      }

      final response =
      await http.get(
        uri,
        headers: const {
          'Accept': 'image/*',
        },
      ).timeout(
        const Duration(
          seconds: 30,
        ),
      );

      if (response.statusCode <
          200 ||
          response.statusCode >=
              300) {
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

      final timestamp = DateTime
          .now()
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

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message, {
        bool error = false,
      }) {
    if (!mounted) return;

    final messenger =
    ScaffoldMessenger.of(
      context,
    );

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior:
        SnackBarBehavior.floating,

        backgroundColor:
        _isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,

        margin:
        EdgeInsets.fromLTRB(
          16.w,
          0,
          16.w,
          18.h,
        ),

        elevation: 0,

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            22.r,
          ),
          side:
          BorderSide(
            color:
            error
                ? Colors.red
                .withOpacity(.25)
                : _divider,
          ),
        ),

        content: Row(
          children: [
            Icon(
              error
                  ? Icons
                  .error_outline_rounded
                  : Icons
                  .check_circle_outline_rounded,
              color:
              error
                  ? Colors.redAccent
                  : AppColors.accent,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                message,
                style:
                GoogleFonts.inter(
                  color: _primary,
                  fontSize: 12.sp,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String getResolution(
      String url,
      ) {
    final match =
    RegExp(
      r'(\d+x\d+)',
    ).firstMatch(url);

    return match?.group(0) ??
        'HD';
  }

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

    return fileName
        .split(' ')
        .where(
          (word) =>
      word.isNotEmpty,
    )
        .map(
          (word) =>
      word[0].toUpperCase() +
          word.substring(1),
    )
        .join(' ');
  }
}

class _PremiumSetButton extends StatefulWidget {
  final bool loading;
  final VoidCallback? onTap;

  const _PremiumSetButton({
    required this.loading,
    required this.onTap,
  });

  @override
  State<_PremiumSetButton> createState() =>
      _PremiumSetButtonState();
}

class _PremiumSetButtonState
    extends State<_PremiumSetButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        scale: _pressed ? .965 : 1,
        duration: const Duration(
          milliseconds: 160,
        ),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 250,
          ),
          curve: Curves.easeOutCubic,

          // Smaller than before
          height: 56.h,

          // Slightly narrower
          margin: EdgeInsets.symmetric(
            horizontal: 18.w,
          ),

          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius:
            BorderRadius.circular(20.r),

            // Very subtle depth instead of glow
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  _isDark(context)
                      ? .22
                      : .12,
                ),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),

          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 220,
                ),
                child: widget.loading
                    ? SizedBox(
                  key: const ValueKey(
                    'loading',
                  ),
                  width: 18.w,
                  height: 18.w,
                  child:
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Row(
                  key: const ValueKey(
                    'button',
                  ),
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Text(
                      'SET WALLPAPER',
                      style:
                      GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight:
                        FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),

                    SizedBox(width: 9.w),

                    // Unique little arrow capsule
                    Container(
                      width: 29.w,
                      height: 29.w,
                      decoration:
                      BoxDecoration(
                        color: Colors.white
                            .withOpacity(.16),
                        shape:
                        BoxShape.circle,
                        border: Border.all(
                          color: Colors.white
                              .withOpacity(.18),
                          width: .7,
                        ),
                      ),
                      child: Icon(
                        Icons
                            .arrow_outward_rounded,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness ==
        Brightness.dark;
  }
}

// ==================================================================
// WALLPAPER PICKER
// ==================================================================

class _WallpaperPickerSheet
    extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onLock;
  final VoidCallback onBoth;

  const _WallpaperPickerSheet({
    required this.onHome,
    required this.onLock,
    required this.onBoth,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final surface = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final surfaceSoft = isDark
        ? AppColors.darkSurfaceSoft
        : AppColors.lightSurfaceSoft;

    final primary = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final secondary = isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final muted = isDark
        ? AppColors.darkMuted
        : AppColors.lightMuted;

    final divider = isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(
        38.r,
      ),
      child: BackdropFilter(
        filter:
        ImageFilter.blur(
          sigmaX: 25,
          sigmaY: 25,
        ),
        child: Container(
          padding:
          EdgeInsets.fromLTRB(
            20.w,
            12.h,
            20.w,
            24.h,
          ),
          decoration:
          BoxDecoration(
            color:
            surface.withOpacity(
              isDark ? .97 : .98,
            ),
            borderRadius:
            BorderRadius.circular(
              38.r,
            ),
            border:
            Border.all(
              color: divider,
            ),
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Container(
                width: 42.w,
                height: 4.h,
                decoration:
                BoxDecoration(
                  color:
                  muted.withOpacity(
                    .45,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    100,
                  ),
                ),
              ),

              SizedBox(height: 25.h),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          'SET WALLPAPER',
                          style:
                          GoogleFonts
                              .bebasNeue(
                            color: primary,
                            fontSize:
                            34.sp,
                            height: .85,
                            letterSpacing:
                            2,
                          ),
                        ),
                        SizedBox(
                          height: 8.h,
                        ),
                        Text(
                          'CHOOSE YOUR DISPLAY',
                          style:
                          GoogleFonts
                              .inter(
                            color:
                            secondary,
                            fontSize:
                            8.sp,
                            fontWeight:
                            FontWeight
                                .w800,
                            letterSpacing:
                            1.8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration:
                    BoxDecoration(
                      color:
                      surfaceSoft,
                      shape:
                      BoxShape.circle,
                      border:
                      Border.all(
                        color:
                        divider,
                      ),
                    ),
                    child: Icon(
                      Hicons
                          .imageLightOutline,
                      color:
                      secondary,
                      size: 19.sp,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28.h),

              _CinematicWallpaperChoice(
                number: '01',
                title: 'HOME',
                subtitle:
                'HOME SCREEN ONLY',
                icon:
                Hicons.home3LightOutline,
                onTap: onHome,
              ),

              SizedBox(height: 10.h),

              _CinematicWallpaperChoice(
                number: '02',
                title: 'LOCK',
                subtitle:
                'LOCK SCREEN ONLY',
                icon: Hicons
                    .lock2LightOutline,
                onTap: onLock,
              ),

              SizedBox(height: 10.h),

              _CinematicWallpaperChoice(
                number: '03',
                title: 'BOTH',
                subtitle:
                'HOME + LOCK SCREEN',
                icon: Icons
                    .layers_outlined,
                featured: true,
                onTap: onBoth,
              ),

              SizedBox(height: 12.h),

              Text(
                'YOUR WALLPAPER • YOUR SPACE',
                style:
                GoogleFonts.inter(
                  color: muted,
                  fontSize: 7.sp,
                  fontWeight:
                  FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// WALLPAPER CHOICE
// ==================================================================

class _CinematicWallpaperChoice
    extends StatefulWidget {
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool featured;

  const _CinematicWallpaperChoice({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.featured = false,
  });

  @override
  State<
      _CinematicWallpaperChoice>
  createState() =>
      _CinematicWallpaperChoiceState();
}

class _CinematicWallpaperChoiceState
    extends State<
        _CinematicWallpaperChoice> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final surface = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final surfaceSoft = isDark
        ? AppColors.darkSurfaceSoft
        : AppColors.lightSurfaceSoft;

    final primary = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final secondary = isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final muted = isDark
        ? AppColors.darkMuted
        : AppColors.lightMuted;

    final divider = isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          pressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          pressed = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          pressed = false;
        });

        HapticFeedback.mediumImpact();

        widget.onTap();
      },
      child: AnimatedScale(
        scale:
        pressed ? .975 : 1,
        duration:
        const Duration(
          milliseconds: 180,
        ),
        curve:
        Curves.easeOutCubic,
        child:
        AnimatedContainer(
          duration:
          const Duration(
            milliseconds: 280,
          ),
          height: 78.h,
          padding:
          EdgeInsets.symmetric(
            horizontal: 14.w,
          ),
          decoration:
          BoxDecoration(
            color: widget.featured
                ? AppColors.accent
                .withOpacity(
              isDark ? .12 : .08,
            )
                : surfaceSoft.withOpacity(
              isDark ? .72 : .92,
            ),
            borderRadius:
            BorderRadius.circular(
              26.r,
            ),
            border:
            Border.all(
              color: widget.featured
                  ? AppColors.accent
                  .withOpacity(
                .28,
              )
                  : divider,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30.w,
                child: Text(
                  widget.number,
                  style:
                  GoogleFonts
                      .bebasNeue(
                    color: muted
                        .withOpacity(.65),
                    fontSize: 18.sp,
                    letterSpacing: 1,
                  ),
                ),
              ),

              AnimatedContainer(
                duration:
                const Duration(
                  milliseconds: 280,
                ),
                width: 48.w,
                height: 48.w,
                decoration:
                BoxDecoration(
                  color:
                  widget.featured
                      ? AppColors
                      .accent
                      .withOpacity(
                    isDark
                        ? .18
                        : .12,
                  )
                      : surface,
                  borderRadius:
                  BorderRadius.circular(
                    17.r,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color:
                  widget.featured
                      ? AppColors
                      .accent
                      : secondary,
                  size: 21.sp,
                ),
              ),

              SizedBox(width: 13.w),

              Expanded(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      widget.title,
                      style:
                      GoogleFonts
                          .inter(
                        color: primary,
                        fontSize: 13.sp,
                        fontWeight:
                        FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    Text(
                      widget.subtitle,
                      style:
                      GoogleFonts
                          .inter(
                        color: secondary,
                        fontSize: 8.sp,
                        fontWeight:
                        FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              AnimatedContainer(
                duration:
                const Duration(
                  milliseconds: 250,
                ),
                width: 34.w,
                height: 34.w,
                decoration:
                BoxDecoration(
                  shape:
                  BoxShape.circle,
                  color:
                  widget.featured
                      ? AppColors
                      .accent
                      : surface,
                ),
                child:
                AnimatedRotation(
                  turns:
                  pressed ? .12 : 0,
                  duration:
                  const Duration(
                    milliseconds: 250,
                  ),
                  child: Icon(
                    Icons
                        .arrow_outward_rounded,
                    color:
                    widget.featured
                        ? Colors.white
                        : muted,
                    size: 16.sp,
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

// ==================================================================
// CINEMATIC BUTTON
// ==================================================================

class _CinematicButton
    extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool loading;

  const _CinematicButton({
    required this.icon,
    required this.onTap,
    this.iconColor =
        Colors.white,
    this.loading = false,
  });

  @override
  State<_CinematicButton>
  createState() =>
      _CinematicButtonState();
}

class _CinematicButtonState
    extends State<_CinematicButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:
      widget.onTap == null
          ? null
          : (_) {
        setState(() {
          pressed = true;
        });
      },
      onTapCancel:
      widget.onTap == null
          ? null
          : () {
        setState(() {
          pressed = false;
        });
      },
      onTapUp:
      widget.onTap == null
          ? null
          : (_) {
        setState(() {
          pressed = false;
        });

        widget.onTap!();
      },
      child: AnimatedScale(
        scale:
        pressed ? .88 : 1,
        duration:
        const Duration(
          milliseconds: 170,
        ),
        curve:
        Curves.easeOutCubic,
        child: Container(
          width: 54.w,
          height: 54.w,
          decoration:
          BoxDecoration(
            shape:
            BoxShape.circle,
            color: Colors.black
                .withOpacity(.24),
            border:
            Border.all(
              color: Colors.white
                  .withOpacity(.13),
            ),
          ),
          child:
          AnimatedSwitcher(
            duration:
            const Duration(
              milliseconds: 250,
            ),
            child: widget.loading
                ? SizedBox(
              key:
              const ValueKey(
                'loading',
              ),
              width: 19.w,
              height: 19.w,
              child:
              const CircularProgressIndicator(
                strokeWidth: 2,
                color:
                Colors.white,
              ),
            )
                : Icon(
              widget.icon,
              key: ValueKey(
                widget.icon,
              ),
              color:
              widget.iconColor,
              size: 21.sp,
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// INFO ITEM
// ==================================================================

class _InfoItem
    extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _InfoItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Expanded(
      child: Container(
        height: 58.h,
        padding:
        EdgeInsets.symmetric(
          horizontal: 9.w,
        ),
        decoration:
        BoxDecoration(
          color: Colors.white
              .withOpacity(.055),
          borderRadius:
          BorderRadius.circular(
            19.r,
          ),
          border:
          Border.all(
            color: Colors.white
                .withOpacity(.07),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
              Colors.white70,
              size: 17.sp,
            ),
            SizedBox(
              width: 7.w,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style:
                    GoogleFonts
                        .inter(
                      color:
                      Colors.white,
                      fontSize: 9.sp,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style:
                    GoogleFonts
                        .inter(
                      color: Colors.white
                          .withOpacity(
                        .35,
                      ),
                      fontSize: 6.sp,
                      fontWeight:
                      FontWeight.w700,
                      letterSpacing:
                      .8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// SETTING OVERLAY
// ==================================================================

class _SettingOverlay
    extends StatelessWidget {
  const _SettingOverlay();

  @override
  Widget build(
      BuildContext context,
      ) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final surface = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final primary = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final secondary = isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final divider = isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black
            .withOpacity(
          isDark ? .58 : .35,
        ),
        child: Center(
          child: ClipRRect(
            borderRadius:
            BorderRadius.circular(
              30.r,
            ),
            child: BackdropFilter(
              filter:
              ImageFilter.blur(
                sigmaX: 20,
                sigmaY: 20,
              ),
              child: Container(
                width: 215.w,
                padding:
                EdgeInsets.all(
                  25.w,
                ),
                decoration:
                BoxDecoration(
                  color:
                  surface.withOpacity(
                    .96,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    30.r,
                  ),
                  border:
                  Border.all(
                    color: divider,
                  ),
                ),
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 34.w,
                      height: 34.w,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color:
                        AppColors
                            .accent,
                      ),
                    ),

                    SizedBox(
                      height: 18.h,
                    ),

                    Text(
                      'APPLYING',
                      style:
                      GoogleFonts
                          .inter(
                        color: primary,
                        fontSize: 11.sp,
                        fontWeight:
                        FontWeight.w800,
                        letterSpacing:
                        1.8,
                      ),
                    ),

                    SizedBox(
                      height: 6.h,
                    ),

                    Text(
                      'Preparing your wallpaper...',
                      textAlign:
                      TextAlign.center,
                      style:
                      GoogleFonts
                          .inter(
                        color:
                        secondary,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}