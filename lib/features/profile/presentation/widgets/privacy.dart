import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../../core/theme/app_theme.dart';

class FleckPrivacyScreen extends StatelessWidget {
  const FleckPrivacyScreen({
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
            // =================================================================
            // APP BAR
            // =================================================================

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
                'Privacy',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.4,
                ),
              ),

              centerTitle: false,
            ),

            // =================================================================
            // PRIVACY HERO
            // =================================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  18.h,
                  20.w,
                  0,
                ),
                child: const _PrivacyHero(),
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
                      'Your privacy stays yours.',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.7,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Fleck is designed to keep the wallpaper '
                          'experience simple without asking for '
                          'unnecessary access to your personal data.',
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
            // WHAT WE USE
            // =================================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  28.h,
                  20.w,
                  0,
                ),
                child: _PrivacySection(
                  title: 'What Fleck uses',
                  subtitle:
                  'Only information needed for a personal experience.',
                  child: const _PrivacyCard(
                    icon: Icons.person_outline_rounded,
                    title: 'Your name',
                    description:
                    'Your name may be used to personalize '
                        'Fleck and your in-app preferences.',
                    accent: true,
                  ),
                ),
              ),
            ),

            // =================================================================
            // WHAT WE DON'T ACCESS
            // =================================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  30.h,
                  20.w,
                  0,
                ),
                child: _PrivacySection(
                  title: 'What Fleck doesn’t access',
                  subtitle:
                  'Fleck does not need your personal content to work.',
                  child: const _PrivacyGroup(
                    children: [
                      _PrivacyCard(
                        icon: Icons.photo_library_outlined,
                        title: 'Photo gallery',
                        description:
                        'Fleck does not need access to your '
                            'personal photos or videos.',
                      ),
                      _PrivacyCard(
                        icon: Icons.contacts_outlined,
                        title: 'Contacts',
                        description:
                        'Your contacts are not needed for '
                            'the wallpaper experience.',
                      ),
                      _PrivacyCard(
                        icon: Icons.location_on_outlined,
                        title: 'Location',
                        description:
                        'Fleck does not need your location '
                            'to browse wallpapers.',
                      ),
                      _PrivacyCard(
                        icon: Icons.mic_none_rounded,
                        title: 'Microphone & camera',
                        description:
                        'Fleck does not need microphone or '
                            'camera access.',
                      ),
                      _PrivacyCard(
                        icon: Icons.folder_outlined,
                        title: 'Personal files',
                        description:
                        'Fleck does not need access to your '
                            'private files or documents.',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // =================================================================
            // NO UNNECESSARY PERMISSIONS
            // =================================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  30.h,
                  20.w,
                  0,
                ),
                child: const _PrivacyHighlight(),
              ),
            ),

            // =================================================================
            // PRIVACY PRINCIPLE
            // =================================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  32.h,
                  20.w,
                  0,
                ),
                child: _PrivacyPrinciple(),
              ),
            ),

            // =================================================================
            // FOOTER
            // =================================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  32.h,
                  20.w,
                  110.h,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 42.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: FleckTheme.primarySoft,
                        borderRadius:
                        BorderRadius.circular(999),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'Fleck • Wallpaper, your way.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium
                          ?.copyWith(
                        color: colors.onSurfaceVariant
                            .withValues(alpha: .55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
// PRIVACY HERO
// =============================================================================

class _PrivacyHero extends StatelessWidget {
  const _PrivacyHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 225.h,
      decoration: BoxDecoration(
        color: FleckTheme.primarySoft,
        borderRadius: BorderRadius.circular(30.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ---------------------------------------------------------------
          // Decorative circles
          // ---------------------------------------------------------------

          Positioned(
            right: -42.w,
            top: -58.h,
            child: Container(
              width: 175.w,
              height: 175.w,
              decoration: BoxDecoration(
                color: FleckTheme.seedColor.withValues(
                  alpha: .07,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            left: -55.w,
            bottom: -75.h,
            child: Container(
              width: 180.w,
              height: 180.w,
              decoration: BoxDecoration(
                color: FleckTheme.seedColor.withValues(
                  alpha: .055,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ---------------------------------------------------------------
          // Shield
          // ---------------------------------------------------------------

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
                Icons.shield_outlined,
                size: 40.sp,
                color: FleckTheme.onPrimary,
              ),
            ),
          ),

          // ---------------------------------------------------------------
          // Status label
          // ---------------------------------------------------------------

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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: const BoxDecoration(
                      color: FleckTheme.seedColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'PRIVACY FIRST',
                    style: TextStyle(
                      color: FleckTheme.seedColor,
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .9,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PRIVACY SECTION
// =============================================================================

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

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
        child,
      ],
    );
  }
}

// =============================================================================
// PRIVACY GROUP
// =============================================================================

class _PrivacyGroup extends StatelessWidget {
  const _PrivacyGroup({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius:
      BorderRadius.circular(24.r),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
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
    );
  }
}

// =============================================================================
// PRIVACY CARD
// =============================================================================

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({
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
          AnimatedContainer(
            duration: const Duration(
              milliseconds: 180,
            ),
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
                    height: 1.35,
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
// PRIVACY HIGHLIGHT
// =============================================================================

class _PrivacyHighlight extends StatelessWidget {
  const _PrivacyHighlight();

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
            right: -35.w,
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
                    Icons.lock_outline_rounded,
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
                        'No unnecessary permissions.',
                        style: theme
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          color:
                          FleckTheme.onPrimary,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        'Fleck is designed to give you '
                            'wallpapers without requiring '
                            'access to your personal content.',
                        style: theme
                            .textTheme
                            .bodyMedium
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
// PRIVACY PRINCIPLE
// =============================================================================

class _PrivacyPrinciple extends StatelessWidget {
  const _PrivacyPrinciple();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 28.sp,
          color: FleckTheme.seedColor,
        ),

        SizedBox(height: 10.h),

        Text(
          'Privacy is a baseline.',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -.35,
          ),
        ),

        SizedBox(height: 6.h),

        Text(
          'We aim to collect only what is needed '
              'to make Fleck useful and personal.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}