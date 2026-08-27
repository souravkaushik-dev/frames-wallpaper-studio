import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../../core/theme/app_theme.dart';

class FleckCreditsScreen extends StatelessWidget {
  const FleckCreditsScreen({
    super.key,
  });

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
            // ===============================================================
            // APP BAR
            // ===============================================================

            SliverAppBar(
              pinned: true,
              backgroundColor: colors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
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
                'Credits',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.4,
                ),
              ),
              centerTitle: false,
            ),

            // ===============================================================
            // HERO
            // ===============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  18.h,
                  20.w,
                  0,
                ),
                child: const _CreditsHero(),
              ),
            ),

            // ===============================================================
            // INTRO
            // ===============================================================

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
                      'Made possible by many.',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.7,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Fleck does not create the wallpapers in its '
                          'collection. We discover, curate, and bring '
                          'great wallpaper work together in one place.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===============================================================
            // CREATOR MESSAGE
            // ===============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  28.h,
                  20.w,
                  0,
                ),
                child: const _CreatorMessage(),
              ),
            ),

            // ===============================================================
            // FEATURED SOURCES
            // ===============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  30.h,
                  20.w,
                  0,
                ),
                child: const _CreditsSection(
                  title: 'Creators & sources',
                  subtitle:
                  'A few of the places and creators that inspire '
                      'and contribute to the wallpaper world.',
                  children: [
                    _CreditCard(
                      icon: Icons.apple,
                      name: 'Basic Apple Guy',
                      description:
                      'Independent creator known for original '
                          'Apple-inspired wallpapers, graphics, '
                          'and design work.',
                      url: 'basicappleguy.com',
                    ),
                    _CreditCard(
                      icon: Icons.wallpaper_outlined,
                      name: '4K Wallpapers',
                      description:
                      'Wallpaper source and discovery community '
                          'for high-resolution backgrounds.',
                      url: '4kwallpapers.com',
                    ),
                    _CreditCard(
                      icon: Icons.devices_outlined,
                      name: 'Pixel Wallpapers',
                      description:
                      'Wallpaper discovery and collections '
                          'for modern devices.',
                      url: 'Pixel Wallpapers',
                    ),
                  ],
                ),
              ),
            ),

            // ===============================================================
            // DISCOVERY
            // ===============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  30.h,
                  20.w,
                  0,
                ),
                child: const _CreditsSection(
                  title: 'And everyone behind the pixels',
                  subtitle:
                  'Fleck would not exist without the wider '
                      'wallpaper community.',
                  children: [
                    _CreditCard(
                      icon: Icons.palette_outlined,
                      name: 'Wallpaper artists',
                      description:
                      'Designers, illustrators, photographers, '
                          '3D artists, and creators who make '
                          'beautiful backgrounds.',
                    ),
                    _CreditCard(
                      icon: Icons.search_rounded,
                      name: 'Curators & finders',
                      description:
                      'People and communities who discover, '
                          'share, archive, and surface great '
                          'wallpapers.',
                    ),
                    _CreditCard(
                      icon: Icons.groups_outlined,
                      name: 'Wallpaper communities',
                      description:
                      'The communities that continuously share '
                          'ideas, recommendations, and discoveries.',
                    ),
                  ],
                ),
              ),
            ),

            // ===============================================================
            // ATTRIBUTION
            // ===============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  30.h,
                  20.w,
                  0,
                ),
                child: const _AttributionCard(),
              ),
            ),

            // ===============================================================
            // RESPECT
            // ===============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  30.h,
                  20.w,
                  0,
                ),
                child: const _RespectCard(),
              ),
            ),

            // ===============================================================
            // FOOTER
            // ===============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  34.h,
                  20.w,
                  110.h,
                ),
                child: _CreditsFooter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// HERO
// =============================================================================

class _CreditsHero extends StatelessWidget {
  const _CreditsHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 225.h,
      decoration: BoxDecoration(
        color: FleckTheme.primarySoft,
        borderRadius:
        BorderRadius.circular(30.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -50.w,
            top: -58.h,
            child: Container(
              width: 180.w,
              height: 180.w,
              decoration: BoxDecoration(
                color: FleckTheme.seedColor
                    .withValues(alpha: .07),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            left: -60.w,
            bottom: -70.h,
            child: Container(
              width: 180.w,
              height: 180.w,
              decoration: BoxDecoration(
                color: FleckTheme.seedColor
                    .withValues(alpha: .055),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Small floating cards.
          Positioned(
            left: 28.w,
            top: 38.h,
            child: _FloatingCreditCard(
              icon: Icons.palette_outlined,
              rotation: -.10,
            ),
          ),

          Positioned(
            right: 30.w,
            bottom: 40.h,
            child: _FloatingCreditCard(
              icon: Icons.photo_outlined,
              rotation: .10,
            ),
          ),

          Center(
            child: Container(
              width: 78.w,
              height: 78.w,
              decoration: BoxDecoration(
                color: FleckTheme.seedColor,
                borderRadius:
                BorderRadius.circular(27.r),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 39.sp,
                color: FleckTheme.onPrimary,
              ),
            ),
          ),

          Positioned(
            left: 18.w,
            bottom: 17.h,
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
                'THE WALLPAPER COMMUNITY',
                style: TextStyle(
                  color: FleckTheme.seedColor,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .75,
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
// FLOATING CREDIT CARD
// =============================================================================

class _FloatingCreditCard extends StatelessWidget {
  const _FloatingCreditCard({
    required this.icon,
    required this.rotation,
  });

  final IconData icon;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 46.w,
        height: 46.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: .72,
          ),
          borderRadius:
          BorderRadius.circular(15.r),
        ),
        child: Icon(
          icon,
          size: 21.sp,
          color: FleckTheme.seedColor,
        ),
      ),
    );
  }
}

// =============================================================================
// CREATOR MESSAGE
// =============================================================================

class _CreatorMessage extends StatelessWidget {
  const _CreatorMessage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: FleckTheme.seedColor,
      borderRadius:
      BorderRadius.circular(25.r),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -40.w,
            top: -50.h,
            child: Container(
              width: 150.w,
              height: 150.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: .055,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(18.w),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: .12,
                    ),
                    borderRadius:
                    BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.favorite_border_rounded,
                    color: FleckTheme.onPrimary,
                    size: 22.sp,
                  ),
                ),

                SizedBox(width: 13.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Credit where it belongs.',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(
                          color:
                          FleckTheme.onPrimary,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        'Every wallpaper has a creator, '
                            'photographer, designer, curator, '
                            'or community behind it. We are '
                            'grateful for their work.',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(
                          color: FleckTheme.onPrimary
                              .withValues(alpha: .76),
                          height: 1.4,
                        ),
                      ),
                    ],
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
// SECTION
// =============================================================================

class _CreditsSection extends StatelessWidget {
  const _CreditsSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -.35,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant
                .withValues(alpha: .68),
            height: 1.35,
          ),
        ),
        SizedBox(height: 12.h),
        Material(
          color: colors.surfaceContainerLow,
          borderRadius:
          BorderRadius.circular(24.r),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0;
              i < children.length;
              i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    indent: 72.w,
                    endIndent: 14.w,
                    color: colors.outlineVariant
                        .withValues(alpha: .20),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// CREDIT CARD
// =============================================================================

class _CreditCard extends StatelessWidget {
  const _CreditCard({
    required this.icon,
    required this.name,
    required this.description,
    this.url,
  });

  final IconData icon;
  final String name;
  final String description;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 13.w,
        vertical: 13.h,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: FleckTheme.primarySoft,
              borderRadius:
              BorderRadius.circular(15.r),
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: FleckTheme.seedColor,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  description,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(
                    color: colors.onSurfaceVariant
                        .withValues(alpha: .72),
                    height: 1.4,
                  ),
                ),
                if (url != null) ...[
                  SizedBox(height: 5.h),
                  Text(
                    url!,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(
                      color: FleckTheme.seedColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ATTRIBUTION
// =============================================================================

class _AttributionCard extends StatelessWidget {
  const _AttributionCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius:
      BorderRadius.circular(25.r),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: FleckTheme.primarySoft,
                    borderRadius:
                    BorderRadius.circular(15.r),
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    color: FleckTheme.seedColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Attribution matters',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 13.h),

            Text(
              'Where the original creator or source is '
                  'known, Fleck aims to identify and credit '
                  'them appropriately. If you believe a '
                  'wallpaper is missing attribution or should '
                  'not be included, please contact us.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// RESPECT
// =============================================================================

class _RespectCard extends StatelessWidget {
  const _RespectCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: FleckTheme.primarySoft,
      borderRadius:
      BorderRadius.circular(25.r),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.handshake_outlined,
              color: FleckTheme.seedColor,
              size: 27.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Respect the creators.',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(
                      color: FleckTheme.seedColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'If you love a wallpaper, visit the '
                        'original creator and support their work '
                        'when you can.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                      color: FleckTheme.seedColor
                          .withValues(alpha: .76),
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
// FOOTER
// =============================================================================

class _CreditsFooter extends StatelessWidget {
  const _CreditsFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Icon(
          Icons.auto_awesome_outlined,
          size: 28.sp,
          color: FleckTheme.seedColor,
        ),
        SizedBox(height: 10.h),
        Text(
          'Thank you, creators.',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -.35,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Fleck is a place to discover great work. '
              'The creativity belongs to the people who made it.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        SizedBox(height: 18.h),
        Container(
          width: 42.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: FleckTheme.primarySoft,
            borderRadius:
            BorderRadius.circular(999),
          ),
        ),
        SizedBox(height: 13.h),
        Text(
          'Fleck • Wallpaper, your way.',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.onSurfaceVariant
                .withValues(alpha: .55),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}