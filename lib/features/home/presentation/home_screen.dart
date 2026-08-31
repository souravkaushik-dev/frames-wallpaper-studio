import 'dart:ui';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fleck_app_bar.dart';
import '../../../data/models/wallpaper.dart';
import '../../../data/repositories/wallpaper_repository.dart';
import '../../categories/{presentation/widgets}/preview.dart';
import '../../favorites/presentation/widgets/ffav_store.dart';

class FleckHomeScreen extends StatefulWidget {
  const FleckHomeScreen({super.key});

  @override
  State<FleckHomeScreen> createState() => _FleckHomeScreenState();
}

class _FleckHomeScreenState extends State<FleckHomeScreen> {
  final WallpaperRepository _repository = WallpaperRepository();
  late Future<WallpaperData> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.getAll();
  }

  Future<void> _refresh() async {
    final future = _repository.getAll();
    setState(() {
      _future = future;
    });
    await future;
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<WallpaperData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _ExpressiveLoadingView();
            }

            if (snapshot.hasError || snapshot.data == null) {
              return _ExpressiveErrorView(onRetry: _refresh);
            }

            return _HomeContent(data: snapshot.data!, onRefresh: _refresh);
          },
        ),
      ),
    );
  }
}

// =============================================================================
// HOME CONTENT
// =============================================================================

class _HomeContent extends StatefulWidget {
  const _HomeContent({required this.data, required this.onRefresh});

  final WallpaperData data;
  final Future<void> Function() onRefresh;

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
    with SingleTickerProviderStateMixin {
  String _query = '';
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  List<Wallpaper> get _allWallpapers {
    final wallpapers = <Wallpaper>[];
    final seen = <String>{};

    final source = [
      ...widget.data.trending,
      ...widget.data.categories.expand((category) => category.wallpapers),
    ];

    for (final wallpaper in source) {
      if (seen.add(wallpaper.url)) {
        wallpapers.add(wallpaper);
      }
    }

    return wallpapers;
  }

  List<Wallpaper> get _filteredWallpapers {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.data.trending;

    final terms = query
        .split(RegExp(r'[^a-z0-9]+'))
        .where((term) => term.isNotEmpty)
        .toList();

    return _allWallpapers.where((wallpaper) {
      final url = wallpaper.url.toLowerCase();
      final category = wallpaper.category?.trim().toLowerCase() ?? '';
      final title = _wallpaperTitle(wallpaper.url);
      final searchableText = [title, category, url].join(' ');

      return terms.every(searchableText.contains);
    }).toList();
  }

  String _wallpaperTitle(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.pathSegments.isEmpty) return '';

    var filename = uri.pathSegments.last.split('?').first.split('#').first;
    filename = filename.replaceFirst(
      RegExp(r'\.(jpg|jpeg|png|webp|avif|gif)$', caseSensitive: false),
      '',
    );
    return filename.replaceAll(RegExp(r'[_\-]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
  }

  void _onSearch(String value) {
    final nextQuery = value.trim();
    if (_query == nextQuery) return;
    setState(() {
      _query = nextQuery;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final searching = _query.isNotEmpty;
    final wallpapers = _filteredWallpapers;

    return RefreshIndicator.adaptive(
      color: colors.primary,
      backgroundColor: colors.surfaceContainerHigh,
      onRefresh: widget.onRefresh,
      displacement: 36.h,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: DynamicExpressiveEntrance(
              controller: _entranceController,
              delayRatio: 0.0,
              child: FleckAppBar(
                title: 'foliage',
                searchHint: 'Search wallpapers',
                onSearchChanged: _onSearch,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              reverseDuration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInQuad,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1.0,
                    child: child,
                  ),
                );
              },
              child: _ExpressiveDiscoverHeader(
                key: ValueKey('${searching}_$_query'),
                title: searching ? 'Results' : 'Discover',
                count: searching ? wallpapers.length : widget.data.trending.length,
                searching: searching,
              ),
            ),
          ),
          if (searching)
            if (wallpapers.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _ExpressiveEmptySearch(),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                sliver: _ExpressiveWallpaperGrid(wallpapers: wallpapers),
              )
          else ...[
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: _ExpressiveWallpaperGrid(wallpapers: widget.data.trending),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 48.h, 20.w, 20.h),
                child: _ExpressiveCollectionHeader(
                  count: widget.data.categories.length,
                  onPressed: () {
                    if (widget.data.categories.isEmpty) return;
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 600),
                        reverseTransitionDuration: const Duration(milliseconds: 400),
                        pageBuilder: (_, animation, __) => _CollectionWallpapersScreen(
                          category: widget.data.categories.first,
                        ),
                        transitionsBuilder: (_, animation, __, child) => SharedAxisTransition(
                          animation: animation,
                          secondaryAnimation: __,
                          transitionType: SharedAxisTransitionType.horizontal,
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _ExpressiveCollectionsList(categories: widget.data.categories),
            ),
          ],
          SliverToBoxAdapter(child: SizedBox(height: 120.h)),
        ],
      ),
    );
  }
}

// =============================================================================
// MATERIAL 3 EXPRESSIVE DISCOVER HEADER & BADGE
// =============================================================================

class _ExpressiveDiscoverHeader extends StatelessWidget {
  const _ExpressiveDiscoverHeader({
    super.key,
    required this.title,
    required this.count,
    required this.searching,
  });

  final String title;
  final int count;
  final bool searching;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontSize: 42.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2.0,
                  height: 1.0,
                  color: colors.onSurface,
                ),
              ),
              SizedBox(width: 14.w),
              _ExpressiveCountBadge(count: count),
            ],
          ),
          SizedBox(height: 8.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Text(
              searching
                  ? 'Found matching wallpapers from your collection.'
                  : 'Curated wall art crafted for your devices.',
              key: ValueKey(searching),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpressiveCountBadge extends StatelessWidget {
  const _ExpressiveCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
        child: child,
      ),
      child: Container(
        key: ValueKey(count),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: ShapeDecoration(
          color: colors.primaryContainer,
          shape: const StadiumBorder(),
        ),
        child: Text(
          '$count',
          style: TextStyle(
            color: colors.onPrimaryContainer,
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// EXPRESSIVE WALLPAPER GRID & CARD
// =============================================================================

class _ExpressiveWallpaperGrid extends StatelessWidget {
  const _ExpressiveWallpaperGrid({required this.wallpapers});

  final List<Wallpaper> wallpapers;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
            (context, index) => _ExpressiveWallpaperCard(
          wallpaper: wallpapers[index],
          index: index,
        ),
        childCount: wallpapers.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 18.h,
        childAspectRatio: 0.65,
      ),
    );
  }
}

class _ExpressiveWallpaperCard extends StatefulWidget {
  const _ExpressiveWallpaperCard({
    required this.wallpaper,
    required this.index,
  });

  final Wallpaper wallpaper;
  final int index;

  @override
  State<_ExpressiveWallpaperCard> createState() => _ExpressiveWallpaperCardState();
}

class _ExpressiveWallpaperCardState extends State<_ExpressiveWallpaperCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _touchController;
  late final Animation<double> _scaleAnimation;
  late final Animation<BorderRadius?> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    _touchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      reverseDuration: const Duration(milliseconds: 240),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(
        parent: _touchController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.elasticOut,
      ),
    );

    _radiusAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(28.r),
      end: BorderRadius.circular(40.r),
    ).animate(_touchController);
  }

  @override
  void dispose() {
    _touchController.dispose();
    super.dispose();
  }

  void _openPreview() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return WallpaperPreviewScreen(wallpaper: widget.wallpaper);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeScaleTransition(
            animation: CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final delay = (widget.index % 6) * 60;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 36.h * (1 - opacity)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.selectionClick();
          _touchController.forward();
        },
        onTapCancel: () => _touchController.reverse(),
        onTapUp: (_) => _touchController.reverse(),
        onTap: _openPreview,
        child: AnimatedBuilder(
          animation: _touchController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Material(
                color: colors.surfaceContainerLow,
                borderRadius: _radiusAnimation.value,
                clipBehavior: Clip.antiAlias,
                elevation: _touchController.value * 8,
                shadowColor: colors.shadow.withValues(alpha: 0.2),
                child: child,
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'wallpaper-preview-${widget.wallpaper.url}',
                child: Image.network(
                  widget.wallpaper.url,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return ColoredBox(
                      color: colors.surfaceContainerLow,
                      child: Center(
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(colors.primary),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: colors.surfaceContainerHighest,
                    child: Icon(
                      Hicons.imageLightOutline,
                      color: colors.onSurfaceVariant,
                      size: 32.sp,
                    ),
                  ),
                ),
              ),

              // Glassmorphic Gradient Overlay
              const Positioned.fill(child: _ExpressiveGlassScrim()),

              // Expressive Action Overlay Button
              Positioned(
                right: 12.w,
                bottom: 12.h,
                child: ValueListenableBuilder<Set<String>>(
                  valueListenable: FleckFavoritesStore.urls,
                  builder: (context, favoriteUrls, _) {
                    return _ExpressiveFavoriteIconButton(
                      liked: favoriteUrls.contains(widget.wallpaper.url),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        FleckFavoritesStore.toggle(widget.wallpaper);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpressiveGlassScrim extends StatelessWidget {
  const _ExpressiveGlassScrim();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.6, 1.0],
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.05),
            Colors.black.withValues(alpha: 0.65),
          ],
        ),
      ),
    );
  }
}

class _ExpressiveFavoriteIconButton extends StatefulWidget {
  const _ExpressiveFavoriteIconButton({
    required this.liked,
    required this.onPressed,
  });

  final bool liked;
  final VoidCallback onPressed;

  @override
  State<_ExpressiveFavoriteIconButton> createState() =>
      __ExpressiveFavoriteIconButtonState();
}

class __ExpressiveFavoriteIconButtonState
    extends State<_ExpressiveFavoriteIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.82 : (widget.liked ? 1.08 : 1.0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.elasticOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: widget.liked
                    ? colors.primary
                    : colors.surfaceContainerHighest.withValues(alpha: 0.65),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(
                  widget.liked ? 22.r : 16.r, // Morphing shape radius
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.elasticOut,
                  ),
                  child: child,
                ),
                child: Icon(
                  widget.liked ? Hicons.heart2Bold : Hicons.heart2LightOutline,
                  key: ValueKey(widget.liked),
                  size: 22.sp,
                  color: widget.liked
                      ? colors.onPrimary
                      : colors.onSurfaceVariant,
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
// COLLECTIONS LIST & CARDS
// =============================================================================

class _ExpressiveCollectionHeader extends StatelessWidget {
  const _ExpressiveCollectionHeader({
    required this.count,
    required this.onPressed,
  });

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Collections',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 32.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              '$count curated albums',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        IconButton.filledTonal(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
            ),
            minimumSize: Size(52.w, 52.w),
          ),
          icon: Icon(Hicons.right2LightOutline, size: 24.sp),
        ),
      ],
    );
  }
}

class _ExpressiveCollectionsList extends StatelessWidget {
  const _ExpressiveCollectionsList({required this.categories});

  final List<dynamic> categories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 16.w),
        itemBuilder: (context, index) {
          return _ExpressiveCollectionCard(category: categories[index]);
        },
      ),
    );
  }
}

class _ExpressiveCollectionCard extends StatefulWidget {
  const _ExpressiveCollectionCard({required this.category});

  final dynamic category;

  @override
  State<_ExpressiveCollectionCard> createState() =>
      __ExpressiveCollectionCardState();
}

class __ExpressiveCollectionCardState extends State<_ExpressiveCollectionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      curve: Curves.elasticOut,
      scale: _pressed ? 0.94 : 1.0,
      child: SizedBox(
        width: 300.w,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).push(
              PageRouteBuilder<void>(
                transitionDuration: const Duration(milliseconds: 550),
                pageBuilder: (_, __, ___) =>
                    _CollectionWallpapersScreen(category: widget.category),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeScaleTransition(animation: animation, child: child),
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_pressed ? 38.r : 30.r),
            ),
            child: Material(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(30.r),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.category.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: colors.surfaceContainerHighest,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20.w,
                    right: 18.w,
                    bottom: 18.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.category.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              color: Colors.white.withValues(alpha: 0.25),
                              child: Text(
                                '${widget.category.wallpapers.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
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

// =============================================================================
// AUXILIARY EXPRESSIVE VIEWS (Collection Screen, Loading & States)
// =============================================================================

class _CollectionWallpapersScreen extends StatelessWidget {
  const _CollectionWallpapersScreen({required this.category});

  final dynamic category;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final List<Wallpaper> wallpapers = List<Wallpaper>.from(category.wallpapers);

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            FleckAppBar(
              title: category.name,
              searchHint: 'Search in ${category.name}',
              onSearchChanged: (_) {},
            ),
            Expanded(
              child: wallpapers.isEmpty
                  ? const _ExpressiveEmptyState(
                icon: Hicons.imageLightOutline,
                title: 'Collection Empty',
                subtitle: 'No wallpapers found in this category yet.',
              )
                  : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 110.h),
                    sliver: _ExpressiveWallpaperGrid(wallpapers: wallpapers),
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

class _ExpressiveEmptySearch extends StatelessWidget {
  const _ExpressiveEmptySearch();

  @override
  Widget build(BuildContext context) {
    return const _ExpressiveEmptyState(
      icon: Hicons.search1LightOutline,
      title: 'No Matches Found',
      subtitle: 'Try searching with different keywords.',
    );
  }
}

class _ExpressiveEmptyState extends StatelessWidget {
  const _ExpressiveEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Icon(icon, size: 36.sp, color: colors.onSecondaryContainer),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpressiveLoadingView extends StatelessWidget {
  const _ExpressiveLoadingView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: 80.w,
        height: 80.w,
        decoration: ShapeDecoration(
          color: colors.primaryContainer,
          shape: const StadiumBorder(),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: CircularProgressIndicator.adaptive(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(colors.onPrimaryContainer),
          ),
        ),
      ),
    );
  }
}

class _ExpressiveErrorView extends StatelessWidget {
  const _ExpressiveErrorView({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86.w,
              height: 86.w,
              decoration: BoxDecoration(
                color: colors.errorContainer,
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Icon(
                Hicons.informationSquareLightOutline,
                size: 36.sp,
                color: colors.onErrorContainer,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Unable to Load',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Something went wrong while retrieving wallpapers.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24.h),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                shape: const StadiumBorder(),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
              ),
              icon: Icon(Hicons.refresh1LightOutline, size: 20.sp),
              label: const Text('Retry Loading'),
            ),
          ],
        ),
      ),
    );
  }
}

class DynamicExpressiveEntrance extends StatelessWidget {
  const DynamicExpressiveEntrance({
    super.key,
    required this.controller,
    required this.delayRatio,
    required this.child,
  });

  final AnimationController controller;
  final double delayRatio;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        delayRatio.clamp(0.0, 0.8),
        1.0,
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final val = animation.value;
        return Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, 30.h * (1 - val)),
            child: child,
          ),
        );
      },
    );
  }
}