import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/previewscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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

  @override
  void initState() {
    super.initState();

    _favoritesFuture = FavoritesService.getFavorites();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _introController.forward();
      }
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  // ============================================================
  // THEME
  // ============================================================

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

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    HapticFeedback.selectionClick();

    final future = FavoritesService.getFavorites();

    setState(() {
      _favoritesFuture = future;
    });

    await future;

    if (mounted) {
      _introController
        ..reset()
        ..forward();
    }
  }

  void _retry() {
    HapticFeedback.selectionClick();

    setState(() {
      _favoritesFuture = FavoritesService.getFavorites();
    });
  }

  // ============================================================
  // PREVIEW
  // ============================================================

  void _openPreview(String image, String category) {
    if (image.isEmpty) return;

    HapticFeedback.selectionClick();

    // Warm the exact same NetworkImage used by the card. This means the
    // preview can reuse Flutter's image cache instead of starting a second
    // network decode when the user taps. We intentionally do NOT await this
    // call: navigation must happen immediately.
    final imageProvider = NetworkImage(image);
    precacheImage(imageProvider, context);

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1),
        reverseTransitionDuration: const Duration(milliseconds: 1),
        pageBuilder: (_, animation, __) {
          // The card and destination use the same Hero tag. The destination
          // Hero wraps the existing PreviewScreen so the already-visible
          // wallpaper can travel directly into the preview instead of
          // disappearing during a fade/scale route animation.
          return Hero(
            tag: image,
            flightShuttleBuilder:
                (
                  flightContext,
                  animation,
                  flightDirection,
                  fromHeroContext,
                  toHeroContext,
                ) {
                  return Material(
                    color: Colors.transparent,
                    child: toHeroContext.widget,
                  );
                },
            child: PreviewScreen(imageUrl: image, category: category),
          );
        },
        transitionsBuilder: (_, animation, __, child) {
          // No fade/scale delay. Hero handles the visual movement.
          return child;
        },
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return _LoadingState(background: _background, accent: _accent);
          }

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

          if (favorites.isEmpty) {
            return _EmptyState(
              background: _background,
              primary: _primary,
              secondary: _secondary,
              accent: _accent,
            );
          }

          return RefreshIndicator(
            color: _accent,
            backgroundColor: _surface,
            displacement: 60.h,
            strokeWidth: 1.5,
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              cacheExtent: 800,
              slivers: [
                // ==================================================
                // HEADER
                // ==================================================

                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                      child: _SavedHeader(
                        count: favorites.length,
                        surface: _surface,
                        surfaceSoft: _surfaceSoft,
                        divider: _divider,
                        primary: _primary,
                        secondary: _secondary,
                        accent: _accent,
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // HERO
                // ==================================================
                SliverToBoxAdapter(
                  child: _IntroAnimation(
                    controller: _introController,
                    child: _SavedHero(
                      item: favorites.first,
                      count: favorites.length,
                      background: _background,
                      surface: _surface,
                      primary: _primary,
                      secondary: _secondary,
                      muted: _muted,
                      divider: _divider,
                      accent: _accent,
                      onTap: () {
                        final image =
                            favorites.first['imageUrl']?.toString() ?? '';

                        final category =
                            favorites.first['category']?.toString() ?? 'Saved';

                        _openPreview(image, category);
                      },
                    ),
                  ),
                ),

                // ==================================================
                // COLLECTION LABEL
                // ==================================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 14.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'SAVED',
                          style: GoogleFonts.bebasNeue(
                            color: _primary,
                            fontSize: 29.sp,
                            height: .9,
                            letterSpacing: .3,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: _accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 7.w),
                        Text(
                          favorites.length.toString().padLeft(2, '0'),
                          style: GoogleFonts.manrope(
                            color: _muted,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // GRID
                // ==================================================
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 70.h),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10.h,
                    crossAxisSpacing: 10.w,
                    childCount: favorites.length,
                    itemBuilder: (context, index) {
                      final item = favorites[index];

                      final image = item['imageUrl']?.toString() ?? '';

                      final category = item['category']?.toString() ?? 'Saved';

                      const heights = [
                        320.0,
                        275.0,
                        360.0,
                        300.0,
                        340.0,
                        285.0,
                      ];

                      return RepaintBoundary(
                        key: ValueKey('$image-$category-$index'),
                        child: _SavedWallpaperCard(
                          image: image,
                          category: category,
                          index: index,
                          height: heights[index % heights.length].h,
                          accent: _accent,
                          surface: _surface,
                          primary: _primary,
                          muted: _muted,
                          divider: _divider,
                          onTap: () {
                            _openPreview(image, category);
                          },
                        ),
                      );
                    },
                  ),
                ),

                // ==================================================
                // END
                // ==================================================
                SliverToBoxAdapter(
                  child: _EndMark(divider: _divider, muted: _muted),
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
// HEADER
// ============================================================================

class _SavedHeader extends StatelessWidget {
  final int count;

  final Color surface;
  final Color surfaceSoft;
  final Color divider;
  final Color primary;
  final Color secondary;
  final Color accent;

  const _SavedHeader({
    required this.count,
    required this.surface,
    required this.surfaceSoft,
    required this.divider,
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46.w,
          height: 46.w,
          decoration: BoxDecoration(
            color: surfaceSoft,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: divider),
          ),
          child: Icon(Icons.bookmark_rounded, color: primary, size: 17.sp),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 5.w,
                    height: 5.w,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 7.w),
                  Text(
                    'PERSONAL',
                    style: GoogleFonts.manrope(
                      color: secondary,
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.7,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                'SAVED WALLPAPERS',
                style: GoogleFonts.manrope(
                  color: primary,
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.4,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(13.r),
            border: Border.all(color: divider),
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
      ],
    );
  }
}

// ============================================================================
// HERO
// ============================================================================

class _SavedHero extends StatelessWidget {
  final Map<String, dynamic> item;
  final int count;

  final Color background;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color muted;
  final Color divider;
  final Color accent;

  final VoidCallback onTap;

  const _SavedHero({
    required this.item,
    required this.count,
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.muted,
    required this.divider,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = item['imageUrl']?.toString() ?? '';

    final category = item['category']?.toString() ?? 'Saved';

    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 25.h),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.r),
          child: SizedBox(
            height: 450.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ==================================================
                // IMAGE
                // ==================================================

                image.isEmpty
                    ? Container(color: surface)
                    : Image.network(
                        image,
                        fit: BoxFit.cover,
                        cacheWidth: 1000,
                        filterQuality: FilterQuality.medium,
                        gaplessPlayback: true,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: surface,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: muted,
                              size: 28.sp,
                            ),
                          );
                        },
                      ),

                // ==================================================
                // DEPTH
                // ==================================================
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0, .46, 1],
                          colors: [
                            background.withOpacity(.10),
                            background.withOpacity(.04),
                            background.withOpacity(.96),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // TOP
                // ==================================================
                Positioned(
                  top: 16.h,
                  left: 16.w,
                  right: 16.w,
                  child: Row(
                    children: [
                      _HeroPill(
                        text: 'SAVED',
                        background: surface.withOpacity(.72),
                        foreground: primary,
                        border: divider,
                      ),
                      const Spacer(),
                      _HeroPill(
                        text: '4K',
                        background: surface.withOpacity(.72),
                        foreground: primary,
                        border: divider,
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // SIDE INDEX
                // ==================================================
                Positioned(
                  right: 17.w,
                  top: 76.h,
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      'FRAME 01',
                      style: GoogleFonts.manrope(
                        color: primary.withOpacity(.42),
                        fontSize: 6.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // CONTENT
                // ==================================================
                Positioned(
                  left: 18.w,
                  right: 18.w,
                  bottom: 18.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              category.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                color: primary.withOpacity(.68),
                                fontSize: 7.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6.h),

                      Text(
                        'YOUR\nFAVOURITE',
                        style: GoogleFonts.bebasNeue(
                          color: primary,
                          fontSize: 54.sp,
                          height: .82,
                          letterSpacing: .3,
                        ),
                      ),

                      SizedBox(height: 10.h),

                      Row(
                        children: [
                          Text(
                            '${count.toString().padLeft(2, '0')} SAVED',
                            style: GoogleFonts.manrope(
                              color: primary.withOpacity(.56),
                              fontSize: 7.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            width: 1,
                            height: 12.h,
                            color: primary.withOpacity(.22),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            '4K',
                            style: GoogleFonts.manrope(
                              color: primary.withOpacity(.56),
                              fontSize: 7.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 13.h),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: primary.withOpacity(.18),
                            ),
                          ),
                          SizedBox(width: 9.w),
                          Container(
                            width: 32.w,
                            height: 32.w,
                            decoration: BoxDecoration(
                              color: surface.withOpacity(.78),
                              shape: BoxShape.circle,
                              border: Border.all(color: divider),
                            ),
                            child: Icon(
                              Icons.arrow_outward_rounded,
                              color: primary,
                              size: 14.sp,
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
    );
  }
}

// ============================================================================
// HERO PILL
// ============================================================================

class _HeroPill extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;
  final Color border;

  const _HeroPill({
    required this.text,
    required this.background,
    required this.foreground,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          color: foreground,
          fontSize: 6.5.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ============================================================================
// SAVED WALLPAPER CARD
// ============================================================================

class _SavedWallpaperCard extends StatefulWidget {
  final String image;
  final String category;
  final int index;
  final double height;

  final Color accent;
  final Color surface;
  final Color primary;
  final Color muted;
  final Color divider;

  final VoidCallback onTap;

  const _SavedWallpaperCard({
    required this.image,
    required this.category,
    required this.index,
    required this.height,
    required this.accent,
    required this.surface,
    required this.primary,
    required this.muted,
    required this.divider,
    required this.onTap,
  });

  @override
  State<_SavedWallpaperCard> createState() => _SavedWallpaperCardState();
}

class _SavedWallpaperCardState extends State<_SavedWallpaperCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (!_pressed) {
          setState(() {
            _pressed = true;
          });
        }
      },
      onTapCancel: () {
        if (_pressed) {
          setState(() {
            _pressed = false;
          });
        }
      },
      onTapUp: (_) {
        if (_pressed) {
          setState(() {
            _pressed = false;
          });
        }

        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? .96 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: Hero(
          tag: widget.image,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22.r),
            child: SizedBox(
              height: widget.height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ==================================================
                  // IMAGE
                  // ==================================================

                  _SavedImage(
                    image: widget.image,
                    fallback: widget.surface,
                    muted: widget.muted,
                  ),

                  // ==================================================
                  // DEPTH
                  // ==================================================
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0, .50, 1],
                            colors: [
                              widget.surface.withOpacity(.05),
                              widget.surface.withOpacity(.01),
                              widget.surface.withOpacity(.92),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // NUMBER
                  // ==================================================
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: widget.surface.withOpacity(.70),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: widget.divider.withOpacity(.7),
                        ),
                      ),
                      child: Text(
                        (widget.index + 1).toString().padLeft(2, '0'),
                        style: GoogleFonts.manrope(
                          color: widget.primary,
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .8,
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // BOOKMARK
                  // ==================================================
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: widget.surface.withOpacity(.68),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.divider.withOpacity(.7),
                        ),
                      ),
                      child: Icon(
                        Icons.bookmark_rounded,
                        color: widget.accent,
                        size: 15.sp,
                      ),
                    ),
                  ),

                  // ==================================================
                  // BOTTOM
                  // ==================================================
                  Positioned(
                    left: 14.w,
                    right: 14.w,
                    bottom: 14.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            Expanded(
                              child: Text(
                                widget.category.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  color: widget.primary.withOpacity(.58),
                                  fontSize: 6.5.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .85,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 5.h),

                        Text(
                          'FRAME ${(widget.index + 1).toString().padLeft(2, '0')}',
                          style: GoogleFonts.bebasNeue(
                            color: widget.primary,
                            fontSize: 25.sp,
                            height: .9,
                            letterSpacing: .2,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        Row(
                          children: [
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                height: 1,
                                color: widget.primary.withOpacity(
                                  _pressed ? .40 : .18,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_outward_rounded,
                              color: widget.primary.withOpacity(.65),
                              size: 13.sp,
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
// IMAGE
// ============================================================================

class _SavedImage extends StatelessWidget {
  final String image;
  final Color fallback;
  final Color muted;

  const _SavedImage({
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
        child: Icon(Icons.broken_image_outlined, color: muted, size: 26.sp),
      );
    }

    return Image.network(
      image,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
      cacheWidth: 700,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: fallback,
          alignment: Alignment.center,
          child: Icon(Icons.broken_image_outlined, color: muted, size: 26.sp),
        );
      },
    );
  }
}

// ============================================================================
// EMPTY
// ============================================================================

class _EmptyState extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(28.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 78.w,
                  height: 78.w,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(.07),
                    shape: BoxShape.circle,
                    border: Border.all(color: accent.withOpacity(.14)),
                  ),
                  child: Icon(
                    Icons.bookmark_border_rounded,
                    color: accent,
                    size: 30.sp,
                  ),
                ),

                SizedBox(height: 18.h),

                Text(
                  'NOTHING SAVED',
                  style: GoogleFonts.bebasNeue(
                    color: primary,
                    fontSize: 32.sp,
                    letterSpacing: .5,
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  'Save a wallpaper to see it here.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: secondary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
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

// ============================================================================
// LOADING
// ============================================================================

class _LoadingState extends StatelessWidget {
  final Color background;
  final Color accent;

  const _LoadingState({required this.background, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      alignment: Alignment.center,
      child: SizedBox(
        width: 34.w,
        height: 34.w,
        child: CircularProgressIndicator(strokeWidth: 1.5, color: accent),
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
    return Container(
      color: background,
      alignment: Alignment.center,
      padding: EdgeInsets.all(28.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68.w,
            height: 68.w,
            decoration: BoxDecoration(
              color: accent.withOpacity(.07),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cloud_off_rounded, color: accent, size: 29.sp),
          ),

          SizedBox(height: 16.h),

          Text(
            'SAVES UNAVAILABLE',
            style: GoogleFonts.bebasNeue(
              color: primary,
              fontSize: 29.sp,
              letterSpacing: .8,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            'Try again.',
            style: GoogleFonts.manrope(
              color: secondary,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 17.h),

          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: accent.withOpacity(.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'RETRY',
                style: GoogleFonts.manrope(
                  color: accent,
                  fontSize: 7.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// END
// ============================================================================

class _EndMark extends StatelessWidget {
  final Color divider;
  final Color muted;

  const _EndMark({required this.divider, required this.muted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 15.h, bottom: 100.h),
      child: Column(
        children: [
          Container(width: 30.w, height: 1, color: divider),
          SizedBox(height: 10.h),
          Text(
            'END',
            style: GoogleFonts.manrope(
              color: muted.withOpacity(.35),
              fontSize: 6.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
