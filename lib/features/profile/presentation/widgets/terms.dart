import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../../core/theme/app_theme.dart';

class FleckTermsScreen extends StatelessWidget {
  const FleckTermsScreen({
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
                'Terms',
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
                child: const _TermsHero(),
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
                      'Simple terms. Clear expectations.',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.7,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'By using Fleck, you agree to use the app '
                          'responsibly and respect the wallpapers, '
                          'content, and people behind them.',
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
            // ACCEPTANCE
            // ===============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  28.h,
                  20.w,
                  0,
                ),
                child: const _TermsSection(
                  title: 'Using Fleck',
                  subtitle:
                  'A few things to keep in mind.',
                  children: [
                    _TermsCard(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Accepting these terms',
                      description:
                      'By accessing or using Fleck, you '
                          'agree to these Terms of Use. If you '
                          'do not agree, please do not use the app.',
                      accent: true,
                    ),
                  ],
                ),
              ),
            ),

            // ===============================================================
            // WALLPAPERS
            // ===============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  30.h,
                  20.w,
                  0,
                ),
                child: const _TermsSection(
                  title: 'Wallpaper content',
                  subtitle:
                  'Important when saving and using wallpapers.',
                  children: [
                    _TermsCard(
                      icon: Icons.image_outlined,
                      title: 'Wallpaper rights',
                      description:
                      'Wallpapers available through Fleck may '
                          'belong to their respective creators or '
                          'rights holders. Fleck does not claim '
                          'ownership of third-party content.',
                    ),
                    _TermsCard(
                      icon: Icons.copyright_outlined,
                      title: 'Personal use',
                      description:
                      'Unless otherwise stated by the content '
                          'owner, wallpapers should be treated as '
                          'personal-use content. You are responsible '
                          'for respecting applicable copyright and '
                          'licensing rules.',
                    ),
                    _TermsCard(
                      icon: Icons.share_outlined,
                      title: 'Do not redistribute',
                      description:
                      'Do not use Fleck to reproduce, sell, '
                          'redistribute, or commercially exploit '
                          'wallpapers when you do not have the '
                          'necessary rights to do so.',
                    ),
                  ],
                ),
              ),
            ),

            // ===============================================================
            // YOUR ACCOUNT / PREFERENCES
            // ===============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  30.h,
                  20.w,
                  0,
                ),
                child: const _TermsSection(
                  title: 'Your Fleck experience',
                  subtitle:
                  'Your preferences belong to your experience.',
                  children: [
                    _TermsCard(
                      icon: Icons.tune_rounded,
                      title: 'Custom preferences',
                      description:
                      'You are responsible for the information '
                          'and preferences you choose to provide '
                          'inside Fleck.',
                    ),
                    _TermsCard(
                      icon: Icons.favorite_border_rounded,
                      title: 'Favorites',
                      description:
                      'Favorites and other in-app preferences '
                          'are features intended to personalize '
                          'your Fleck experience.',
                    ),
                  ],
                ),
              ),
            ),

            // ===============================================================
            // RESPONSIBLE USE
            // ===============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  30.h,
                  20.w,
                  0,
                ),
                child: const _TermsSection(
                  title: 'Responsible use',
                  subtitle:
                  'Keep Fleck useful and respectful.',
                  children: [
                    _TermsCard(
                      icon: Icons.block_outlined,
                      title: 'No misuse',
                      description:
                      'Do not attempt to interfere with Fleck, '
                          'abuse its services, bypass security, or '
                          'use the app for unlawful activity.',
                    ),
                    _TermsCard(
                      icon: Icons.security_outlined,
                      title: 'Keep your device secure',
                      description:
                      'You are responsible for keeping your '
                          'device and operating system reasonably '
                          'secure when using Fleck.',
                    ),
                  ],
                ),
              ),
            ),

            // ===============================================================
            // AVAILABILITY
            // ===============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  30.h,
                  20.w,
                  0,
                ),
                child: const _TermsSection(
                  title: 'Availability',
                  subtitle:
                  'Fleck may change over time.',
                  children: [
                    _TermsCard(
                      icon: Icons.cloud_outlined,
                      title: 'Service changes',
                      description:
                      'We may update, improve, change, suspend, '
                          'or discontinue parts of Fleck when '
                          'necessary.',
                    ),
                    _TermsCard(
                      icon: Icons.sync_rounded,
                      title: 'Updates',
                      description:
                      'Features, wallpaper collections, and '
                          'the app itself may change as Fleck '
                          'continues to evolve.',
                    ),
                  ],
                ),
              ),
            ),

            // ===============================================================
            // DISCLAIMER
            // ===============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  30.h,
                  20.w,
                  0,
                ),
                child: const _TermsHighlight(),
              ),
            ),

            // ===============================================================
            // FINAL
            // ===============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  32.h,
                  20.w,
                  110.h,
                ),
                child: _TermsFooter(),
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

class _TermsHero extends StatelessWidget {
  const _TermsHero();

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
            right: -48.w,
            top: -60.h,
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
            bottom: -75.h,
            child: Container(
              width: 185.w,
              height: 185.w,
              decoration: BoxDecoration(
                color: FleckTheme.seedColor
                    .withValues(alpha: .055),
                shape: BoxShape.circle,
              ),
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
                Icons.description_outlined,
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
                'TERMS OF USE',
                style: TextStyle(
                  color: FleckTheme.seedColor,
                  fontSize: 8.5.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .9,
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
// SECTION
// =============================================================================

class _TermsSection extends StatelessWidget {
  const _TermsSection({
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
// CARD
// =============================================================================

class _TermsCard extends StatelessWidget {
  const _TermsCard({
    required this.icon,
    required this.title,
    required this.description,
    this.accent = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 13.w,
        vertical: 12.h,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: accent
                  ? FleckTheme.primarySoft
                  : colors.surfaceContainerHighest,
              borderRadius:
              BorderRadius.circular(15.r),
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: accent
                  ? FleckTheme.seedColor
                  : colors.onSurfaceVariant,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HIGHLIGHT
// =============================================================================

class _TermsHighlight extends StatelessWidget {
  const _TermsHighlight();

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
            right: -38.w,
            top: -52.h,
            child: Container(
              width: 155.w,
              height: 155.w,
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
                    Icons.handshake_outlined,
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
                        'Keep it simple.',
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
                        'Use Fleck respectfully, respect '
                            'content ownership, and enjoy '
                            'your wallpapers.',
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
// FOOTER
// =============================================================================

class _TermsFooter extends StatelessWidget {
  const _TermsFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          size: 28.sp,
          color: FleckTheme.seedColor,
        ),
        SizedBox(height: 10.h),
        Text(
          'Thanks for using Fleck.',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -.35,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'These terms are here to keep the '
              'Fleck experience clear and respectful.',
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