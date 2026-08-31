import 'dart:math' as math;

import 'package:fleck/features/favorites/presentation/widgets/ffav_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_3_expressive/foundations/m3e_shape_container.dart';

import '../../../core/widgets/fleck_app_bar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/wallpaper.dart';
import '../../../data/repositories/wallpaper_repository.dart';
import '../../categories/{presentation/widgets}/preview.dart';

/// Fleck Favorites.
///
/// Material 3 Expressive redesign:
/// - Minimal visual hierarchy
/// - One primary favorite count treatment
/// - Tonal M3 surfaces
/// - Softer expressive shapes
/// - Subtle, intentional motion
/// - Cleaner wallpaper cards
/// - Reduced decorative UI
/// - Smooth loading / empty / error states
class FleckFavoritesScreen extends StatefulWidget {
  const FleckFavoritesScreen({super.key});

  @override
  State<FleckFavoritesScreen> createState() => _FleckFavoritesScreenState();
}

class _FleckFavoritesScreenState extends State<FleckFavoritesScreen>
    with SingleTickerProviderStateMixin {
  // ===========================================================================
  // DATA
  // ===========================================================================

  final WallpaperRepository _repository = WallpaperRepository();

  late Future<WallpaperData> _future;

  // ===========================================================================
  // PAGE ANIMATION
  // ===========================================================================

  late final AnimationController _pageController;

  @override
  void initState() {
    super.initState();

    _future = _repository.getAll();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _repository.dispose();

    super.dispose();
  }

  // ===========================================================================
  // REFRESH
  // ===========================================================================

  Future<void> _refresh() async {
    HapticFeedback.lightImpact();

    final future = _repository.getAll();

    setState(() {
      _future = future;
    });

    await future;

    if (!mounted) {
      return;
    }

    _pageController
      ..reset()
      ..forward();
  }

  // ===========================================================================
  // SAVED WALLPAPERS
  // ===========================================================================

  List<Wallpaper> _saved(WallpaperData data, Set<String> favoriteUrls) {
    final result = <Wallpaper>[];
    final seen = <String>{};

    final all = <Wallpaper>[
      ...data.trending,
      ...data.categories.expand((category) => category.wallpapers),
    ];

    for (final wallpaper in all) {
      if (favoriteUrls.contains(wallpaper.url) && seen.add(wallpaper.url)) {
        result.add(wallpaper);
      }
    }

    return result;
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ColoredBox(
      color: scheme.surface,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            FleckAppBar(
              title: 'foliage',
              searchHint: 'Search favorites',
            ),
            Expanded(
              child: ValueListenableBuilder<Set<String>>(
                valueListenable: FleckFavoritesStore.urls,
                builder: (context, favoriteUrls, _) {
                  return FutureBuilder<WallpaperData>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _FavoritesLoading();
                      }

                      if (snapshot.hasError || snapshot.data == null) {
                        return _FavoritesError(onRetry: _refresh);
                      }

                      final wallpapers = _saved(snapshot.data!, favoriteUrls);

                      return RefreshIndicator(
                        onRefresh: _refresh,
                        displacement: 56.h,
                        edgeOffset: 4.h,
                        color: FleckTheme.seedColor,
                        backgroundColor: scheme.surfaceContainerHigh,
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          slivers: [
                            // --------------------------------------------------
                            // HEADER
                            // --------------------------------------------------

                            SliverToBoxAdapter(
                              child: _FavoritesHeader(
                                controller: _pageController,
                                count: wallpapers.length,
                              ),
                            ),

                            // --------------------------------------------------
                            // CONTENT
                            // --------------------------------------------------
                            if (wallpapers.isEmpty)
                              const SliverFillRemaining(
                                hasScrollBody: false,
                                child: _EmptyFavorites(),
                              )
                            else
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  16.w,
                                  22.h,
                                  16.w,
                                  112.h,
                                ),
                                sliver: SliverGrid(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    return _FavoriteWallpaperCard(
                                      wallpaper: wallpapers[index],
                                      index: index,
                                    );
                                  }, childCount: wallpapers.length),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10.w,
                                        mainAxisSpacing: 10.h,
                                        childAspectRatio: .70,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// FAVORITES HEADER
// =============================================================================

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader({required this.controller, required this.count});

  final AnimationController controller;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroReveal(
            controller: controller,
            start: 0,
            end: .45,
            offset: 12.h,
            child: Text(
              'Favorites',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 32.sp,
                height: 1.05,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.25,
              ),
            ),
          ),

          SizedBox(height: 14.h),

          _HeroReveal(
            controller: controller,
            start: .08,
            end: .65,
            scaleBegin: .96,
            offset: 8.h,
            child: _FavoriteSummary(count: count),
          ),

          SizedBox(height: 12.h),

          _HeroReveal(
            controller: controller,
            start: .18,
            end: .82,
            offset: 8.h,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, .04),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                key: ValueKey(count),
                count == 0
                    ? 'Save wallpapers you want to keep close.'
                    : 'Your personal collection, all in one place.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: .70),
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FAVORITE SUMMARY
// =============================================================================

class _FavoriteSummary extends StatelessWidget {
  const _FavoriteSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: .94, end: 1),
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          alignment: Alignment.centerLeft,
          child: child,
        );
      },
      child: Material(
        color: FleckTheme.primarySoft,
        borderRadius: BorderRadius.circular(22.r),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 11.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: FleckTheme.primaryDark.withValues(alpha: .10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Hicons.heart2Bold,
                  size: 18.sp,
                  color: FleckTheme.primaryDark,
                ),
              ),

              SizedBox(width: 10.w),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Text(
                  '$count ${count == 1 ? 'wallpaper' : 'wallpapers'}',
                  key: ValueKey(count),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: FleckTheme.primaryDark,
                    letterSpacing: -.1,
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
// HERO REVEAL
// =============================================================================

class _HeroReveal extends StatelessWidget {
  const _HeroReveal({
    required this.controller,
    required this.start,
    required this.end,
    required this.child,
    this.scaleBegin = .98,
    this.offset = 10,
  });

  final AnimationController controller;
  final double start;
  final double end;
  final Widget child;
  final double scaleBegin;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final safeStart = start.clamp(0.0, 1.0).toDouble();

    final safeEnd = end.clamp(safeStart + .001, 1.0).toDouble();

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(safeStart, safeEnd, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final value = animation.value.clamp(0.0, 1.0).toDouble();

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, offset * (1 - value)),
            child: Transform.scale(
              scale: scaleBegin + ((1 - scaleBegin) * value),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// FAVORITE WALLPAPER CARD
// =============================================================================

class _FavoriteWallpaperCard extends StatefulWidget {
  const _FavoriteWallpaperCard({required this.wallpaper, required this.index});

  final Wallpaper wallpaper;
  final int index;

  @override
  State<_FavoriteWallpaperCard> createState() => _FavoriteWallpaperCardState();
}

class _FavoriteWallpaperCardState extends State<_FavoriteWallpaperCard> {
  bool _pressed = false;
  bool _removing = false;

  // ===========================================================================
  // OPEN
  // ===========================================================================

  Future<void> _openPreview() async {
    if (_removing) {
      return;
    }

    HapticFeedback.selectionClick();

    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return WallpaperPreviewScreen(wallpaper: widget.wallpaper);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: .985, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // REMOVE
  // ===========================================================================

  void _removeFavorite() {
    if (_removing) {
      return;
    }

    HapticFeedback.lightImpact();

    setState(() {
      _removing = true;
    });

    FleckFavoritesStore.toggle(widget.wallpaper);
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final delay = math.min(widget.index, 7);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: .97, end: 1),
      duration: Duration(milliseconds: 280 + (delay * 42)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10.h * (1 - value)),
            child: Transform.scale(scale: .985 + (.015 * value), child: child),
          ),
        );
      },
      child: _FavoriteCardSurface(
        wallpaper: widget.wallpaper,
        removing: _removing,
        pressed: _pressed,
        onOpen: _openPreview,
        onRemove: _removeFavorite,
        onPressedChanged: (value) {
          if (!mounted || _removing) {
            return;
          }

          setState(() {
            _pressed = value;
          });
        },
      ),
    );
  }
}

// =============================================================================
// FAVORITE CARD SURFACE
// =============================================================================

class _FavoriteCardSurface extends StatelessWidget {
  const _FavoriteCardSurface({
    required this.wallpaper,
    required this.removing,
    required this.pressed,
    required this.onOpen,
    required this.onRemove,
    required this.onPressedChanged,
  });

  final Wallpaper wallpaper;
  final bool removing;
  final bool pressed;

  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final ValueChanged<bool> onPressedChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedScale(
      scale: pressed ? .985 : 1,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOutCubic,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // -----------------------------------------------------------------
            // WALLPAPER
            // -----------------------------------------------------------------

            Hero(
              tag: 'wallpaper-preview-${wallpaper.url}',
              child: Image.network(
                wallpaper.url,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }

                  return _WallpaperLoading(progress: progress);
                },
                errorBuilder: (context, error, stackTrace) {
                  return ColoredBox(
                    color: scheme.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        Hicons.imageLightOutline,
                        size: 24.sp,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),

            // -----------------------------------------------------------------
            // SUBTLE SCRIM
            // -----------------------------------------------------------------
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 64.h,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: .28),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // TAP SURFACE
            // -----------------------------------------------------------------
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: removing ? null : onOpen,
                  splashColor: scheme.onSurface.withValues(alpha: .08),
                  highlightColor: scheme.onSurface.withValues(alpha: .04),
                  onTapDown: removing
                      ? null
                      : (_) {
                          onPressedChanged(true);
                        },
                  onTapCancel: removing
                      ? null
                      : () {
                          onPressedChanged(false);
                        },
                  onTapUp: removing
                      ? null
                      : (_) {
                          onPressedChanged(false);
                        },
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // REMOVE
            // -----------------------------------------------------------------
            Positioned(
              right: 8.w,
              bottom: 8.h,
              child: _FavoriteRemoveButton(
                removing: removing,
                onPressed: onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// WALLPAPER LOADING
// =============================================================================

class _WallpaperLoading extends StatelessWidget {
  const _WallpaperLoading({required this.progress});

  final ImageChunkEvent? progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final expected = progress?.expectedTotalBytes;

    final value = expected == null
        ? null
        : progress!.cumulativeBytesLoaded / expected;

    return ColoredBox(
      color: scheme.surfaceContainerLow,
      child: Center(
        child: SizedBox(
          width: 22.w,
          height: 22.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: FleckTheme.seedColor,
            value: value,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// REMOVE BUTTON
// =============================================================================

class _FavoriteRemoveButton extends StatefulWidget {
  const _FavoriteRemoveButton({
    required this.removing,
    required this.onPressed,
  });

  final bool removing;
  final VoidCallback onPressed;

  @override
  State<_FavoriteRemoveButton> createState() => _FavoriteRemoveButtonState();
}

class _FavoriteRemoveButtonState extends State<_FavoriteRemoveButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedScale(
      scale: _pressed ? .92 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      child: Material(
        color: scheme.surfaceContainerHigh.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(15.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.removing ? null : widget.onPressed,
          onTapDown: widget.removing
              ? null
              : (_) {
                  setState(() {
                    _pressed = true;
                  });
                },
          onTapCancel: widget.removing
              ? null
              : () {
                  setState(() {
                    _pressed = false;
                  });
                },
          onTapUp: widget.removing
              ? null
              : (_) {
                  setState(() {
                    _pressed = false;
                  });
                },
          child: SizedBox(
            width: 40.w,
            height: 40.w,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: widget.removing
                    ? SizedBox(
                        key: const ValueKey('removing'),
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: FleckTheme.seedColor,
                        ),
                      )
                    : Icon(
                        Hicons.heart2Bold,
                        key: const ValueKey('favorite'),
                        size: 18.sp,
                        color: FleckTheme.seedColor,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY FAVORITES
// =============================================================================

class _EmptyFavorites extends StatefulWidget {
  const _EmptyFavorites();

  @override
  State<_EmptyFavorites> createState() => _EmptyFavoritesState();
}

class _EmptyFavoritesState extends State<_EmptyFavorites>
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

  void _explore() {
    HapticFeedback.lightImpact();

    // Connect this action to the Home
    // destination when the shell callback
    // is exposed to this screen.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(28.w, 12.h, 28.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // -----------------------------------------------------------------
            // SINGLE EXPRESSIVE SHAPE
            // -----------------------------------------------------------------

            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final value = Curves.easeInOutCubic.transform(
                  _controller.value,
                );

                return Transform.translate(
                  offset: Offset(0, -4.h * value),
                  child: Transform.rotate(
                    angle: .018 * math.sin(value * math.pi),
                    child: child,
                  ),
                );
              },
              child: M3EShapeContainer.clover4Leaf(
                width: 92.w,
                height: 92.w,
                color: FleckTheme.primarySoft,
                child: Center(
                  child: Icon(
                    Hicons.heart2Bold,
                    size: 30.sp,
                    color: FleckTheme.primaryDark,
                  ),
                ),
              ),
            ),

            SizedBox(height: 22.h),

            // -----------------------------------------------------------------
            // TITLE
            // -----------------------------------------------------------------
            Text(
              'Nothing saved yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -.5,
              ),
            ),

            SizedBox(height: 7.h),

            // -----------------------------------------------------------------
            // DESCRIPTION
            // -----------------------------------------------------------------
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300.w),
              child: Text(
                'Save wallpapers you love and they’ll '
                'appear here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: .68),
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // -----------------------------------------------------------------
            // ACTION
            // -----------------------------------------------------------------
            FilledButton.icon(
              onPressed: _explore,
              icon: Icon(Hicons.folder1LightOutline, size: 18.sp),
              label: const Text('Explore wallpapers'),
              style: FilledButton.styleFrom(
                minimumSize: Size(0, 48.h),
                padding: EdgeInsets.symmetric(horizontal: 19.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// LOADING
// =============================================================================

class _FavoritesLoading extends StatefulWidget {
  const _FavoritesLoading();

  @override
  State<_FavoritesLoading> createState() => _FavoritesLoadingState();
}

class _FavoritesLoadingState extends State<_FavoritesLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1350),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            // ---------------------------------------------------------------
            // HEADER
            // ---------------------------------------------------------------

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Shimmer(
                      width: 142.w,
                      height: 36.h,
                      radius: 14.r,
                      value: _controller.value,
                    ),
                    SizedBox(height: 14.h),
                    _Shimmer(
                      width: 156.w,
                      height: 56.h,
                      radius: 20.r,
                      value: _controller.value,
                    ),
                    SizedBox(height: 12.h),
                    _Shimmer(
                      width: 230.w,
                      height: 14.h,
                      radius: 8.r,
                      value: _controller.value,
                    ),
                  ],
                ),
              ),
            ),

            // ---------------------------------------------------------------
            // GRID
            // ---------------------------------------------------------------
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 0),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _Shimmer(
                    width: double.infinity,
                    height: double.infinity,
                    radius: 22.r,
                    value: (_controller.value + (index * .07)) % 1,
                  );
                }, childCount: 6),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: .70,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// SHIMMER
// =============================================================================

class _Shimmer extends StatelessWidget {
  const _Shimmer({
    required this.width,
    required this.height,
    required this.radius,
    required this.value,
  });

  final double width;
  final double height;
  final double radius;
  final double value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(-1.2 + (value * 2.4), 0),
          end: Alignment(-.15 + (value * 2.4), 0),
          colors: [
            scheme.surfaceContainerLow,
            scheme.surfaceContainer,
            scheme.surfaceContainerLow,
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ERROR
// =============================================================================

class _FavoritesError extends StatelessWidget {
  const _FavoritesError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // -----------------------------------------------------------------
            // ERROR ICON
            // -----------------------------------------------------------------

            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Hicons.closeBold,
                size: 28.sp,
                color: scheme.onErrorContainer,
              ),
            ),

            SizedBox(height: 18.h),

            Text(
              'Couldn’t load favorites',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -.4,
              ),
            ),

            SizedBox(height: 7.h),

            Text(
              'Something went wrong while loading '
              'your saved wallpapers.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),

            SizedBox(height: 18.h),

            FilledButton.icon(
              onPressed: onRetry,
              icon: Icon(Hicons.refresh1LightOutline, size: 18.sp),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(
                minimumSize: Size(0, 46.h),
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
