import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../../core/theme/app_theme.dart';

class FoliageAboutScreen extends StatelessWidget {
  const FoliageAboutScreen({
    super.key,
    this.onExplore,
  });

  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // =================================================================
            // TOP BAR
            // =================================================================

            SliverAppBar(
              backgroundColor: colors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              pinned: true,
              leading: Padding(
                padding: EdgeInsets.only(
                  left: 12.w,
                ),
                child: IconButton(
                  tooltip: 'Back',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.maybePop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                  ),
                ),
              ),
              title: Text(
                'Foliage',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.4,
                ),
              ),
              centerTitle: false,
              actions: [
                Padding(
                  padding: EdgeInsets.only(
                    right: 12.w,
                  ),
                  child: IconButton.filledTonal(
                    tooltip: 'Explore',
                    onPressed: onExplore,
                    style: IconButton.styleFrom(
                      backgroundColor:
                      FleckTheme.primarySoft,
                      foregroundColor:
                      FleckTheme.seedColor,
                    ),
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                    ),
                  ),
                ),
              ],
            ),

            // =================================================================
            // HERO
            // =================================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  18.h,
                  20.w,
                  0,
                ),
                child: _FoliageHero(),
              ),
            ),

            // =================================================================
            // INTRO
            // =================================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  28.h,
                  20.w,
                  0,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A quieter kind of wallpaper.',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.7,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Foliage brings together leaves, plants, '
                          'and botanical textures for a calm '
                          'natural feel.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =================================================================
            // CHARACTER
            // =================================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  26.h,
                  20.w,
                  0,
                ),
                child: _FoliageInfoCard(),
              ),
            ),

            // =================================================================
            // TAGS
            // =================================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  24.h,
                  20.w,
                  0,
                ),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: const [
                    _FoliageTag(
                      icon: Icons.eco_outlined,
                      label: 'Botanical',
                    ),
                    _FoliageTag(
                      icon: Icons.spa_outlined,
                      label: 'Natural',
                    ),
                    _FoliageTag(
                      icon: Icons.blur_on_outlined,
                      label: 'Soft',
                    ),
                  ],
                ),
              ),
            ),

            // =================================================================
            // CTA
            // =================================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  30.h,
                  20.w,
                  110.h,
                ),
                child: FilledButton.icon(
                  onPressed: onExplore,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                    FleckTheme.seedColor,
                    foregroundColor:
                    FleckTheme.onPrimary,
                    minimumSize: Size(
                      double.infinity,
                      52.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(18.r),
                    ),
                  ),
                  icon: const Icon(
                    Icons.explore_outlined,
                  ),
                  label: const Text(
                    'Explore Foliage',
                  ),
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
// FOLIAGE HERO
// =============================================================================

class _FoliageHero extends StatelessWidget {
  const _FoliageHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.h,
      decoration: BoxDecoration(
        color: FleckTheme.primarySoft,
        borderRadius: BorderRadius.circular(30.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Soft botanical shapes.
          Positioned(
            right: -34.w,
            top: -32.h,
            child: _LeafCluster(
              size: 170.w,
              rotation: -.28,
            ),
          ),

          Positioned(
            left: -42.w,
            bottom: -46.h,
            child: _LeafCluster(
              size: 150.w,
              rotation: .35,
            ),
          ),

          // Brand mark.
          Center(
            child: Container(
              width: 82.w,
              height: 82.w,
              decoration: BoxDecoration(
                color: FleckTheme.seedColor,
                borderRadius:
                BorderRadius.circular(28.r),
              ),
              child: Icon(
                Icons.eco_rounded,
                size: 43.sp,
                color: FleckTheme.onPrimary,
              ),
            ),
          ),

          Positioned(
            left: 20.w,
            bottom: 18.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: .82,
                ),
                borderRadius:
                BorderRadius.circular(999),
              ),
              child: Text(
                'FOLIAGE',
                style: TextStyle(
                  color: FleckTheme.seedColor,
                  fontSize: 9.sp,
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

// =============================================================================
// LEAF CLUSTER
// =============================================================================

class _LeafCluster extends StatelessWidget {
  const _LeafCluster({
    required this.size,
    required this.rotation,
  });

  final double size;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _Leaf(
              size: size * .42,
              angle: -.55,
              offset: Offset(
                -size * .14,
                -size * .13,
              ),
            ),
            _Leaf(
              size: size * .34,
              angle: .25,
              offset: Offset(
                size * .15,
                -size * .02,
              ),
            ),
            _Leaf(
              size: size * .30,
              angle: .72,
              offset: Offset(
                -size * .02,
                size * .19,
              ),
            ),
            _Leaf(
              size: size * .25,
              angle: -.95,
              offset: Offset(
                size * .19,
                size * .22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// LEAF
// =============================================================================

class _Leaf extends StatelessWidget {
  const _Leaf({
    required this.size,
    required this.angle,
    required this.offset,
  });

  final double size;
  final double angle;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: size * .62,
          height: size,
          decoration: BoxDecoration(
            color: FleckTheme.seedColor.withValues(
              alpha: .10,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(
                size,
              ),
              topRight: Radius.circular(
                size,
              ),
              bottomLeft: Radius.circular(
                size * .18,
              ),
              bottomRight: Radius.circular(
                size * .18,
              ),
            ),
          ),
          child: Center(
            child: Container(
              width: 1.2,
              height: size * .68,
              color: FleckTheme.seedColor.withValues(
                alpha: .18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// INFO CARD
// =============================================================================

class _FoliageInfoCard extends StatelessWidget {
  const _FoliageInfoCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(17.w),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: FleckTheme.primarySoft,
                borderRadius:
                BorderRadius.circular(16.r),
              ),
              child: const Icon(
                Icons.forest_outlined,
                color: FleckTheme.seedColor,
                size: 22,
              ),
            ),
            SizedBox(width: 13.w),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'What you’ll find',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Leaf patterns, botanical details, '
                        'deep greens, soft shadows and '
                        'organic forms.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                      color:
                      colors.onSurfaceVariant,
                      height: 1.4,
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

// =============================================================================
// TAG
// =============================================================================

class _FoliageTag extends StatelessWidget {
  const _FoliageTag({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FleckTheme.primarySoft,
      shape: const StadiumBorder(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 11.w,
          vertical: 7.h,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15.sp,
              color: FleckTheme.seedColor,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(
                color: FleckTheme.seedColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}