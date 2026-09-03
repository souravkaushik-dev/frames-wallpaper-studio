import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/previewscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/fav_service.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _favoritesFuture;

  late final AnimationController _introController;

  int? _expandedIndex;

  @override
  void initState() {
    super.initState();

    _favoritesFuture = FavoritesService.getFavorites();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _introController.forward();
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // THEME
  // ===========================================================================

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _background =>
      _isDark ? AppColors.darkBackground : AppColors.lightBackground;

  Color get _surface =>
      _isDark ? AppColors.darkSurface : AppColors.lightSurface;

  Color get _surfaceSoft =>
      _isDark ? AppColors.darkSurfaceSoft : AppColors.lightSurfaceSoft;

  Color get _primary =>
      _isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

  Color get _secondary =>
      _isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

  Color get _muted => _isDark ? AppColors.darkMuted : AppColors.lightMuted;

  Color get _divider =>
      _isDark ? AppColors.darkDivider : AppColors.lightDivider;

  Color get _accent => AppColors.accent;

  // ===========================================================================
  // REFRESH
  // ===========================================================================

  Future<void> _refresh() async {
    HapticFeedback.selectionClick();

    setState(() {
      _favoritesFuture = FavoritesService.getFavorites();
      _expandedIndex = null;
    });

    await _favoritesFuture;

    if (!mounted) return;

    _introController
      ..reset()
      ..forward();
  }

  // ===========================================================================
  // RETRY
  // ===========================================================================

  void _retry() {
    HapticFeedback.selectionClick();

    setState(() {
      _favoritesFuture = FavoritesService.getFavorites();
    });

    _introController
      ..reset()
      ..forward();
  }

  // ===========================================================================
  // GET WALLPAPER NAME
  //
  // IMPORTANT:
  // We intentionally DON'T use category as the displayed name.
  //
  // Supported keys:
  // name
  // title
  // wallpaperName
  // wallpaperTitle
  // displayName
  // ===========================================================================

  String _getWallpaperName(Map<String, dynamic> item) {
    const possibleKeys = [
      'name',
      'title',
      'wallpaperName',
      'wallpaperTitle',
      'displayName',
      'wallpaper_name',
      'wallpaper_title',
      'display_name',
      'originalName',
      'original_name',
      'fileName',
      'filename',
    ];

    for (final key in possibleKeys) {
      final value = item[key];
      if (value == null) continue;

      final cleaned = _removeResolutionFromName(value.toString());

      if (cleaned.isNotEmpty &&
          cleaned.toLowerCase() != 'wallpaper' &&
          cleaned.toLowerCase() != 'saved wallpaper') {
        return cleaned;
      }
    }

    final image = item['imageUrl']?.toString().trim() ?? '';
    final uri = Uri.tryParse(image);

    if (uri != null && uri.pathSegments.isNotEmpty) {
      final filename = Uri.decodeComponent(
        uri.pathSegments.last,
      ).replaceFirst(RegExp(r'\.[a-z0-9]{2,5}$', caseSensitive: false), '');

      final cleaned = _removeResolutionFromName(filename);
      if (cleaned.isNotEmpty) return cleaned;
    }

    return 'Untitled Frame';
  }

  String _removeResolutionFromName(String value) {
    var title = value.trim();

    // 1080x1920 / 1080 x 1920 / 1080×1920 / 1080-1920 / 1080_1920
    title = title.replaceAll(
      RegExp(r'\b\d{3,5}\s*[x×*]\s*\d{3,5}\b', caseSensitive: false),
      ' ',
    );
    title = title.replaceAll(
      RegExp(r'\b\d{3,5}\s*[-_]\s*\d{3,5}\b', caseSensitive: false),
      ' ',
    );

    // 4K, 8K, HD, FHD, QHD, UHD, 1080p, etc.
    title = title.replaceAll(
      RegExp(r'\b(?:8k|6k|5k|4k|2k|uhd|qhd|fhd|hd)\b', caseSensitive: false),
      ' ',
    );
    title = title.replaceAll(
      RegExp(r'\b\d{3,5}\s*p\b', caseSensitive: false),
      ' ',
    );

    title = title
        .replaceAll(RegExp(r'[_\-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return title;
  }

  void _toggleExpand(int index) {
    HapticFeedback.selectionClick();

    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  // ===========================================================================
  // PREVIEW
  //
  // DO NOT wrap PreviewScreen with another Hero.
  // PreviewScreen already has its own Hero.
  // ===========================================================================

  void _openPreview(String image, String name) {
    if (image.isEmpty) return;

    HapticFeedback.selectionClick();

    final imageProvider = NetworkImage(image);

    // Warm image cache without blocking navigation.
    precacheImage(imageProvider, context);

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1),
        reverseTransitionDuration: const Duration(milliseconds: 1),

        pageBuilder: (context, animation, secondaryAnimation) {
          return PreviewScreen(imageUrl: image, category: name);
        },

        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Hero performs the actual image movement.
          // Keep route transition almost instant.
          return child;
        },
      ),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _favoritesFuture,

        builder: (context, snapshot) {
          // -------------------------------------------------------------------
          // LOADING
          // -------------------------------------------------------------------

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return _LoadingState(background: _background, accent: _accent);
          }

          // -------------------------------------------------------------------
          // ERROR
          // -------------------------------------------------------------------

          if (snapshot.hasError && !snapshot.hasData) {
            return _ErrorState(
              background: _background,
              primary: _primary,
              secondary: _secondary,
              accent: _accent,
              onRetry: _retry,
            );
          }

          final favorites = snapshot.data ?? const [];

          // -------------------------------------------------------------------
          // EMPTY
          // -------------------------------------------------------------------

          if (favorites.isEmpty) {
            return _EmptyState(
              background: _background,
              primary: _primary,
              secondary: _secondary,
              accent: _accent,
            );
          }

          // -------------------------------------------------------------------
          // MAIN CONTENT
          // -------------------------------------------------------------------

          return RefreshIndicator(
            color: _accent,
            backgroundColor: _surface,
            strokeWidth: 2,
            displacement: 45.h,
            onRefresh: _refresh,

            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),

              // Keep some images ready before they appear.
              cacheExtent: 1000,

              slivers: [
                // =============================================================
                // HEADER
                // =============================================================

                // =============================================================
                // BIG HEADING
                // =============================================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 78.h, 20.w, 18.h),
                    child: _IntroAnimation(
                      controller: _introController,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          _MovingCollectionsHeading(
                            primary: _primary,
                            muted: _muted,
                            accent: _accent,
                            count: favorites.length,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // =============================================================
                // FULL WIDTH VERTICAL FEED
                // =============================================================
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 100.h),

                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = favorites[index];

                      final image = item['imageUrl']?.toString() ?? '';

                      final name = _getWallpaperName(item);

                      return Padding(
                        padding: EdgeInsets.only(bottom: 11.h),

                        child: _AnimatedWallpaperItem(
                          controller: _introController,
                          index: index,

                          child: RepaintBoundary(
                            key: ValueKey('$image-$index'),

                            child: _FullWidthWallpaperCard(
                              image: image,
                              name: name,
                              index: index,
                              expanded: _expandedIndex == index,
                              primary: _primary,
                              muted: _muted,
                              accent: _accent,
                              surface: _surface,
                              divider: _divider,

                              onExpand: () {
                                _toggleExpand(index);
                              },

                              onTap: () {
                                _openPreview(image, name);
                              },
                            ),
                          ),
                        ),
                      );
                    }, childCount: favorites.length),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// INTRO ANIMATION
// ============================================================================

class _IntroAnimation extends StatelessWidget {
  final AnimationController controller;
  final Widget child;

  const _IntroAnimation({required this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,

      builder: (context, child) {
        final value = Curves.easeOutCubic.transform(controller.value);

        return Opacity(
          opacity: value,

          child: Transform.translate(
            offset: Offset(0, 18.h * (1 - value)),

            child: child,
          ),
        );
      },
    );
  }
}

// ============================================================================
// ITEM INTRO
// ============================================================================

class _AnimatedWallpaperItem extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;

  const _AnimatedWallpaperItem({
    required this.controller,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * .035).clamp(0.0, .5);

    final end = (start + .42).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,

      builder: (context, child) {
        final value = animation.value;

        return Opacity(
          opacity: value,

          child: Transform.translate(
            offset: Offset(0, 22.h * (1 - value)),

            child: child,
          ),
        );
      },
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================

class _SavedHeader extends StatelessWidget {
  final int count;

  final Color primary;
  final Color muted;
  final Color accent;
  final Color surface;
  final Color divider;

  final VoidCallback onRefresh;

  const _SavedHeader({
    required this.count,
    required this.primary,
    required this.muted,
    required this.accent,
    required this.surface,
    required this.divider,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Bookmark
        Container(
          width: 44.w,
          height: 44.w,

          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: divider.withOpacity(.65)),
          ),

          child: Icon(Icons.bookmark_rounded, color: accent, size: 19.sp),
        ),

        SizedBox(width: 11.w),

        // Personal
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PERSONAL',
                style: GoogleFonts.manrope(
                  color: muted,
                  fontSize: 6.5.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),

              SizedBox(height: 2.h),

              Text(
                'Collection',
                style: GoogleFonts.manrope(
                  color: primary,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.4,
                ),
              ),
            ],
          ),
        ),

        // Count
        Container(
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),

          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(13.r),
            border: Border.all(color: divider.withOpacity(.65)),
          ),

          child: Text(
            count.toString().padLeft(2, '0'),
            style: GoogleFonts.manrope(
              color: primary,
              fontSize: 8.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        SizedBox(width: 7.w),

        // Refresh
        _HeaderButton(
          icon: Icons.refresh_rounded,
          color: primary,
          background: surface,
          border: divider,
          onTap: onRefresh,
        ),
      ],
    );
  }
}

// ============================================================================
// FULL WIDTH WALLPAPER CARD
// ============================================================================

class _FullWidthWallpaperCard extends StatefulWidget {
  final String image;
  final String name;
  final int index;

  final bool expanded;

  final Color primary;
  final Color muted;
  final Color accent;
  final Color surface;
  final Color divider;

  final VoidCallback onExpand;
  final VoidCallback onTap;

  const _FullWidthWallpaperCard({
    required this.image,
    required this.name,
    required this.index,
    required this.expanded,
    required this.primary,
    required this.muted,
    required this.accent,
    required this.surface,
    required this.divider,
    required this.onExpand,
    required this.onTap,
  });

  @override
  State<_FullWidthWallpaperCard> createState() =>
      _FullWidthWallpaperCardState();
}

class _FullWidthWallpaperCardState extends State<_FullWidthWallpaperCard> {
  bool _pressed = false;

  double get _normalHeight {
    const heights = [200.0, 180.0, 150.0, 200.0, 180.0, 150.0];

    return heights[widget.index % heights.length];
  }

  double _expandedHeight(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return screenHeight * .42;
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final targetHeight = widget.expanded
        ? _expandedHeight(context)
        : _normalHeight.h;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      // -----------------------------------------------------------------------
      // PRESS
      // -----------------------------------------------------------------------
      onTapDown: (_) {
        _setPressed(true);
      },

      onTapCancel: () {
        _setPressed(false);
      },

      onTapUp: (_) {
        _setPressed(false);

        widget.onTap();
      },

      child: AnimatedScale(
        scale: _pressed ? .985 : 1.0,

        duration: const Duration(milliseconds: 110),

        curve: Curves.easeOutCubic,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 430),

          curve: Curves.easeOutCubic,

          height: targetHeight,

          child: Hero(
            tag: widget.image,

            child: ClipRRect(
              borderRadius: BorderRadius.circular(27.r),

              child: Stack(
                fit: StackFit.expand,

                children: [
                  // ==========================================================
                  // IMAGE
                  // ==========================================================

                  _WallpaperImage(
                    image: widget.image,
                    fallback: widget.surface,
                    muted: widget.muted,
                  ),

                  // ==========================================================
                  // TOP DARKNESS
                  // ==========================================================
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,

                            stops: const [0, .25, .62, 1],

                            colors: [
                              Colors.black.withOpacity(.38),

                              Colors.transparent,

                              Colors.black.withOpacity(.08),

                              Colors.black.withOpacity(.82),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ==========================================================
                  // TOP LEFT NUMBER
                  // ==========================================================
                  Positioned(
                    top: 13.h,
                    left: 14.w,

                    child: _NumberPill(index: widget.index),
                  ),

                  // ==========================================================
                  // TOP RIGHT EXTEND
                  // ==========================================================
                  Positioned(
                    top: 13.h,
                    right: 14.w,

                    child: _ExtendButton(
                      expanded: widget.expanded,
                      onTap: widget.onExpand,
                    ),
                  ),

                  // ==========================================================
                  // WALLPAPER NAME
                  // ==========================================================
                  Positioned(
                    left: 17.w,
                    right: 17.w,
                    bottom: 17.h,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          widget.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,

                          style: GoogleFonts.bebasNeue(
                            color: Colors.white,

                            fontSize: widget.expanded ? 29.sp : 23.sp,

                            height: .9,

                            letterSpacing: .15,

                            shadows: const [
                              Shadow(blurRadius: 12, color: Colors.black54),
                            ],
                          ),
                        ),

                        SizedBox(height: 5.h),

                        Row(
                          children: [
                            Text(
                              'Tap to preview',
                              style: GoogleFonts.manrope(
                                color: Colors.white.withOpacity(.72),
                                fontSize: 7.5.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const Spacer(),

                            if (widget.expanded)
                              Text(
                                'EXPANDED',
                                style: GoogleFonts.manrope(
                                  color: Colors.white.withOpacity(.62),
                                  fontSize: 6.5.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// NUMBER
// ============================================================================

class _NumberPill extends StatelessWidget {
  final int index;

  const _NumberPill({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),

      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.24),

        borderRadius: BorderRadius.circular(20.r),

        border: Border.all(color: Colors.white.withOpacity(.15)),
      ),

      child: Text(
        '#${(index + 1).toString().padLeft(2, '0')}',
        style: GoogleFonts.manrope(
          color: Colors.white,
          fontSize: 7.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: .6,
        ),
      ),
    );
  }
}

// ============================================================================
// EXTEND
// ============================================================================

class _ExtendButton extends StatefulWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _ExtendButton({required this.expanded, required this.onTap});

  @override
  State<_ExtendButton> createState() => _ExtendButtonState();
}

class _ExtendButtonState extends State<_ExtendButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

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

        widget.onTap();
      },

      child: AnimatedScale(
        scale: _pressed ? .91 : 1,

        duration: const Duration(milliseconds: 110),

        curve: Curves.easeOutCubic,

        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),

          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.24),

            borderRadius: BorderRadius.circular(22.r),

            border: Border.all(color: Colors.white.withOpacity(.17)),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              // Animated arrow
              AnimatedRotation(
                turns: widget.expanded ? .5 : 0,

                duration: const Duration(milliseconds: 360),

                curve: Curves.easeOutCubic,

                child: Icon(
                  Icons.unfold_more_rounded,
                  color: Colors.white,
                  size: 15.sp,
                ),
              ),

              SizedBox(width: 4.w),

              // Animated text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),

                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },

                child: Text(
                  widget.expanded ? 'Collapse' : 'Extend',

                  key: ValueKey(widget.expanded),

                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 7.5.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .2,
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

// ============================================================================
// WALLPAPER IMAGE
// ============================================================================

class _WallpaperImage extends StatelessWidget {
  final String image;
  final Color fallback;
  final Color muted;

  const _WallpaperImage({
    required this.image,
    required this.fallback,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) {
      return Container(
        color: fallback,

        alignment: Alignment.center,

        child: Icon(
          Icons.image_not_supported_outlined,
          color: muted,
          size: 30.sp,
        ),
      );
    }

    return Image.network(
      image,

      fit: BoxFit.cover,

      // Good balance for scrolling.
      cacheWidth: 1200,

      filterQuality: FilterQuality.low,

      gaplessPlayback: true,

      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: fallback,

          alignment: Alignment.center,

          child: Icon(Icons.broken_image_outlined, color: muted, size: 30.sp),
        );
      },
    );
  }
}

// ============================================================================
// HEADER BUTTON
// ============================================================================

class _HeaderButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final Color border;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.color,
    required this.background,
    required this.border,
    required this.onTap,
  });

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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

        widget.onTap();
      },

      child: AnimatedScale(
        scale: _pressed ? .9 : 1,

        duration: const Duration(milliseconds: 120),

        child: Container(
          width: 43.w,
          height: 43.w,

          decoration: BoxDecoration(
            color: widget.background,

            borderRadius: BorderRadius.circular(15.r),

            border: Border.all(color: widget.border.withOpacity(.65)),
          ),

          child: Icon(widget.icon, color: widget.color, size: 18.sp),
        ),
      ),
    );
  }
}

// ============================================================================
// LOADING
// ============================================================================

class _LoadingState extends StatelessWidget {
  final Color background;
  final Color accent;

  const _LoadingState({required this.background, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            SizedBox(
              width: 28.w,
              height: 28.w,

              child: CircularProgressIndicator(strokeWidth: 2, color: accent),
            ),

            SizedBox(height: 14.h),

            Text(
              'LOADING',
              style: GoogleFonts.manrope(
                color: accent,
                fontSize: 7.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY
// ============================================================================

class _EmptyState extends StatefulWidget {
  final Color background;
  final Color primary;
  final Color secondary;
  final Color accent;

  const _EmptyState({
    required this.background,
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final value = Curves.easeInOutCubic.transform(
                  _controller.value,
                );
                return Opacity(
                  opacity: .88 + (.12 * value),
                  child: Transform.translate(
                    offset: Offset(0, -5.h * value),
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _EmptyFrameIcon(
                    accent: widget.accent,
                    controller: _controller,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'NO COLLECTIONS YET',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(
                      color: widget.primary,
                      fontSize: 35.sp,
                      letterSpacing: .5,
                      height: .92,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Save a Frame and it will appear here.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: widget.secondary,
                      fontSize: 10.sp,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyFrameIcon extends StatelessWidget {
  final Color accent;
  final Animation<double> controller;

  const _EmptyFrameIcon({required this.accent, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = Curves.easeInOutCubic.transform(controller.value);
        return Transform.rotate(
          angle: -.035 + (.07 * value),
          child: Transform.scale(
            scale: .96 + (.06 * value),
            child: Container(
              width: 92.w,
              height: 116.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: accent.withOpacity(.30 + (.16 * value)),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(.04 + (.08 * value)),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 62.w,
                  height: 82.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17.r),
                    color: accent.withOpacity(.07),
                    border: Border.all(color: accent.withOpacity(.15)),
                  ),
                  child: Icon(
                    Icons.wallpaper_rounded,
                    color: accent.withOpacity(.78),
                    size: 29.sp,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MovingCollectionsHeading extends StatefulWidget {
  final Color primary;
  final Color muted;
  final Color accent;
  final int count;

  const _MovingCollectionsHeading({
    required this.primary,
    required this.muted,
    required this.accent,
    required this.count,
  });

  @override
  State<_MovingCollectionsHeading> createState() =>
      _MovingCollectionsHeadingState();
}

class _MovingCollectionsHeadingState extends State<_MovingCollectionsHeading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 55.h,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                minWidth: 0,
                maxWidth: double.infinity,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final width = MediaQuery.sizeOf(context).width;
                    final travel = width * .55;
                    final x = -travel + (travel * 2 * _controller.value);

                    return Transform.translate(
                      offset: Offset(x, 0),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _collectionWord(widget.primary),
                      _collectionSymbol(widget.accent),
                      _collectionWord(widget.primary),
                      _collectionSymbol(widget.accent),
                      _collectionWord(widget.primary),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // Minimal count at the bottom-left.
          Row(
            children: [
              Container(
                width: 5.w,
                height: 5.w,
                decoration: BoxDecoration(
                  color: widget.accent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 7.w),
              Text(
                '${widget.count.toString().padLeft(2, '0')} FRAMES',
                style: GoogleFonts.manrope(
                  color: widget.muted,
                  fontSize: 7.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _collectionWord(Color color) {
    return Text(
      'COLLECTIONS',
      style: GoogleFonts.bebasNeue(
        color: color,
        fontSize: 64.sp,
        height: .88,
        letterSpacing: .6,
      ),
    );
  }

  Widget _collectionSymbol(Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Text(
        '✦',
        style: GoogleFonts.manrope(
          color: color.withOpacity(.78),
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ============================================================================
// ERROR
// ============================================================================

class _ErrorState extends StatelessWidget {
  final Color background;
  final Color primary;
  final Color secondary;
  final Color accent;

  final VoidCallback onRetry;

  const _ErrorState({
    required this.background,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(28.w),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Icon(Icons.cloud_off_rounded, color: accent, size: 36.sp),

              SizedBox(height: 17.h),

              Text(
                'COULD NOT LOAD',
                style: GoogleFonts.bebasNeue(color: primary, fontSize: 31.sp),
              ),

              SizedBox(height: 7.h),

              Text(
                'Something went wrong while loading your wallpapers.',
                textAlign: TextAlign.center,

                style: GoogleFonts.manrope(
                  color: secondary,
                  fontSize: 9.sp,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 18.h),

              GestureDetector(
                onTap: onRetry,

                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 11.h,
                  ),

                  decoration: BoxDecoration(
                    color: accent.withOpacity(.1),

                    borderRadius: BorderRadius.circular(13.r),
                  ),

                  child: Text(
                    'TRY AGAIN',
                    style: GoogleFonts.manrope(
                      color: accent,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
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
