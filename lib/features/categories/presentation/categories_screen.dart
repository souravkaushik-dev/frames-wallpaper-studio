import 'package:animations/animations.dart';
import 'package:fleck/features/categories/presentation/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../core/widgets/fleck_app_bar.dart';
import '../../../data/models/wallpaper_category.dart';
import '../../../core/theme/app_theme.dart';

/// Fleck Collections
///
/// Material 3 Expressive (Minimal & Refined):
/// - Clean, lightweight typography scale
/// - Uncluttered container shapes with dynamic fluid response
/// - Subtle surface container tonality
/// - Gentle stagger transitions and haptic micro-feedback
class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({
    super.key,
    required this.categories,
    this.onProfileTap,
  });

  final List<WallpaperCategory> categories;
  final VoidCallback? onProfileTap;

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  String _query = '';
  CollectionFilter _filter = CollectionFilter.all;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (!mounted) return;
    setState(() => _query = value.trim());
    _restartEntrance();
  }

  List<WallpaperCategory> get _filteredCategories {
    Iterable<WallpaperCategory> result = widget.categories;
    final query = _query.toLowerCase();

    if (query.isNotEmpty) {
      result = result.where(
            (category) => category.name.toLowerCase().contains(query),
      );
    }

    switch (_filter) {
      case CollectionFilter.all:
        break;
      case CollectionFilter.popular:
        result = result.toList()
          ..sort((a, b) => b.wallpapers.length.compareTo(a.wallpapers.length));
        break;
      case CollectionFilter.small:
        result = result.where((category) => category.wallpapers.length < 30);
        break;
      case CollectionFilter.large:
        result = result.where((category) => category.wallpapers.length >= 30);
        break;
    }

    return result.toList();
  }

  Future<void> _openFilter() async {
    HapticFeedback.selectionClick();
    final selected = await showFleckExpressiveBottomSheet<CollectionFilter>(
      context: context,
      child: _FilterSheet(selected: _filter),
    );

    if (!mounted || selected == null || selected == _filter) return;

    HapticFeedback.selectionClick();
    setState(() => _filter = selected);
    _restartEntrance();
  }

  void _restartEntrance() {
    _entrance
      ..reset()
      ..forward();
  }

  void _openCategory(WallpaperCategory category) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, secondaryAnimation) {
          return CategoryWallpapersScreen(category: category);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeThroughTransition(
            animation: curve,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final categories = _filteredCategories;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            FleckAppBar(
              title: 'foliage',
              searchHint: 'Search collections',
              onSearchChanged: _onSearchChanged,
              onProfilePressed: widget.onProfileTap,
            ),
            Expanded(
              child: _CollectionsBody(
                controller: _entrance,
                categories: categories,
                filter: _filter,
                query: _query,
                onFilter: _openFilter,
                onCategory: _openCategory,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum CollectionFilter { all, popular, small, large }

// =============================================================================
// BODY
// =============================================================================

class _CollectionsBody extends StatelessWidget {
  const _CollectionsBody({
    required this.controller,
    required this.categories,
    required this.filter,
    required this.query,
    required this.onFilter,
    required this.onCategory,
  });

  final AnimationController controller;
  final List<WallpaperCategory> categories;
  final CollectionFilter filter;
  final String query;

  final VoidCallback onFilter;
  final ValueChanged<WallpaperCategory> onCategory;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      clipBehavior: Clip.none,
      slivers: [
        SliverToBoxAdapter(
          child: _Stagger(
            controller: controller,
            begin: 0,
            end: .35,
            offset: 12.h,
            child: const _HeroCarousel(),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 14.h),
          sliver: SliverToBoxAdapter(
            child: _Stagger(
              controller: controller,
              begin: .08,
              end: .40,
              offset: 10.h,
              child: _CollectionsHeading(
                filter: filter,
                query: query,
                count: categories.length,
                onFilter: onFilter,
              ),
            ),
          ),
        ),
        if (categories.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyCollections(query: query),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
            sliver: SliverList.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final begin = (.12 + index * .035).clamp(0.0, .75);
                final end = (.40 + index * .035).clamp(.01, 1.0);

                return _Stagger(
                  controller: controller,
                  begin: begin,
                  end: end,
                  offset: 14.h,
                  child: _CollectionCard(
                    category: category,
                    index: index,
                    onTap: () => onCategory(category),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// HERO CAROUSEL
// =============================================================================

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  late final PageController _controller;
  int _current = 0;

  static const List<_FleckFeature> _features = [
    _FleckFeature(
      title: 'Weekly Drops',
      subtitle: 'Fresh wallpapers added',
      icon: Hicons.calender2LightOutline,
      body: 'Fleck keeps the collection updated with fresh wallpaper picks every week.',
    ),
    _FleckFeature(
      title: 'Curated Picks',
      subtitle: 'Designed for screens',
      icon: Hicons.star2LightOutline,
      body: 'Explore dynamic styles, vibrant gradients, and minimal wallpaper art.',
    ),
    _FleckFeature(
      title: 'Quick Preview',
      subtitle: 'Find your aesthetic',
      icon: Hicons.imageLightOutline,
      body: 'Preview wallpaper styles instantly and organize your favorite themes.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (!mounted) return;
    HapticFeedback.selectionClick();
    setState(() => _current = index);
  }

  Future<void> _showFeature(_FleckFeature feature) async {
    HapticFeedback.selectionClick();

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withValues(alpha: .28),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _FeatureInfoPopup(feature: feature);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: .96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 98.h,
          width: double.infinity,
          child: PageView.builder(
            controller: _controller,
            itemCount: _features.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _FeatureCard(
                  feature: _features[index],
                  onTap: () => _showFeature(_features[index]),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
        _FeatureIndicator(count: _features.length, current: _current),
      ],
    );
  }
}

class _FleckFeature {
  const _FleckFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.body,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String body;
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({required this.feature, required this.onTap});

  final _FleckFeature feature;
  final VoidCallback onTap;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AnimatedScale(
      scale: _pressed ? .985 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    widget.feature.icon,
                    size: 20.sp,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.feature.title,
                        maxLines: 1,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          letterSpacing: -.2,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        widget.feature.subtitle,
                        maxLines: 1,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: .7),
                          fontWeight: FontWeight.w400,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Hicons.right2LightOutline,
                  size: 16.sp,
                  color: colors.onSurfaceVariant.withValues(alpha: .4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureInfoPopup extends StatelessWidget {
  const _FeatureInfoPopup({required this.feature});

  final _FleckFeature feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Material(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24.r),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400.w),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Icon(
                            feature.icon,
                            size: 20.sp,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feature.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                feature.subtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          visualDensity: VisualDensity.compact,
                          icon: Icon(Hicons.closeLightOutline, size: 18.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      feature.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.4,
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

class _FeatureIndicator extends StatelessWidget {
  const _FeatureIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final selected = index == current;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          width: selected ? 14.w : 4.w,
          height: 4.w,
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.outlineVariant.withValues(alpha: .5),
            borderRadius: BorderRadius.circular(99.r),
          ),
        );
      }),
    );
  }
}

// =============================================================================
// HEADING
// =============================================================================

class _CollectionsHeading extends StatelessWidget {
  const _CollectionsHeading({
    required this.filter,
    required this.query,
    required this.count,
    required this.onFilter,
  });

  final CollectionFilter filter;
  final String query;
  final int count;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Collections',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.5,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                query.isEmpty ? '$count available' : 'Results for “$query”',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant.withValues(alpha: .7),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        _FilterButton(active: filter != CollectionFilter.all, onTap: onFilter),
      ],
    );
  }
}

class _FilterButton extends StatefulWidget {
  const _FilterButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  State<_FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<_FilterButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedScale(
      scale: _pressed ? .94 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Material(
        color: widget.active ? colors.secondaryContainer : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: SizedBox(
            width: 44.w,
            height: 44.w,
            child: Center(
              child: Icon(
                Hicons.filter4LightOutline,
                size: 18.sp,
                color: widget.active ? colors.onSecondaryContainer : colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// COLLECTION CARD
// =============================================================================

class _CollectionCard extends StatefulWidget {
  const _CollectionCard({
    required this.category,
    required this.index,
    required this.onTap,
  });

  final WallpaperCategory category;
  final int index;
  final VoidCallback onTap;

  @override
  State<_CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<_CollectionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final category = widget.category;

    final imageUrl = _imageUrl(
      category.wallpapers.isNotEmpty ? category.wallpapers.first : null,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: AnimatedScale(
        scale: _pressed ? .98 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Material(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20.r),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            child: SizedBox(
              height: 160.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'collection-${category.name}-${widget.index}',
                    child: _NetworkImage(
                      url: imageUrl,
                      fallback: colors.surfaceContainerHighest,
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: .5),
                          ],
                          stops: const [.4, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16.w,
                    right: 16.w,
                    bottom: 14.h,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -.3,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${category.wallpapers.length} items',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: .75),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Hicons.right2LightOutline,
                          size: 16.sp,
                          color: Colors.white70,
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
// FILTER SHEET & EMPTY
// =============================================================================

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({required this.selected});

  final CollectionFilter selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter Collections',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 14.h),
        _FilterOption(
          title: 'All collections',
          selected: selected == CollectionFilter.all,
          onTap: () => Navigator.pop(context, CollectionFilter.all),
        ),
        _FilterOption(
          title: 'Most items',
          selected: selected == CollectionFilter.popular,
          onTap: () => Navigator.pop(context, CollectionFilter.popular),
        ),
        _FilterOption(
          title: 'Compact (< 30)',
          selected: selected == CollectionFilter.small,
          onTap: () => Navigator.pop(context, CollectionFilter.small),
        ),
        _FilterOption(
          title: 'Large (30+)',
          selected: selected == CollectionFilter.large,
          onTap: () => Navigator.pop(context, CollectionFilter.large),
        ),
      ],
    );
  }
}

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Material(
        color: selected ? colors.secondaryContainer : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? colors.onSecondaryContainer : colors.onSurface,
                  ),
                ),
                if (selected)
                  Icon(Hicons.tickLightOutline, size: 18.sp, color: colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCollections extends StatelessWidget {
  const _EmptyCollections({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Hicons.categoryLightOutline, size: 28.sp, color: colors.onSurfaceVariant),
          SizedBox(height: 12.h),
          Text(
            query.isNotEmpty ? 'No matches' : 'No collections',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Stagger extends StatelessWidget {
  const _Stagger({
    required this.controller,
    required this.begin,
    required this.end,
    required this.offset,
    required this.child,
  });

  final AnimationController controller;
  final double begin;
  final double end;
  final double offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(begin.clamp(0.0, .99), end.clamp(begin + .01, 1.0), curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (_, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, offset * (1 - animation.value)),
          child: child,
        ),
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.url, required this.fallback});

  final String url;
  final Color fallback;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return ColoredBox(color: fallback);

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => ColoredBox(color: fallback),
    );
  }
}

String _imageUrl(dynamic wallpaper) {
  if (wallpaper == null) return '';
  try { return wallpaper.imageUrl ?? wallpaper.url ?? wallpaper.thumbnail ?? ''; } catch (_) {}
  return '';
}