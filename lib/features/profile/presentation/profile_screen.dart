import 'package:fleck/features/profile/presentation/widgets/about.dart' hide FoliageAboutScreen;
import 'package:fleck/features/profile/presentation/widgets/credits.dart';
import 'package:fleck/features/profile/presentation/widgets/privacy.dart'
    show FleckPrivacyScreen;
import 'package:fleck/features/profile/presentation/widgets/terms.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fleck_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.favoriteCount,
    required this.themeMode,
    this.onFavorites,
    this.onThemeModeChanged,
  });

  final ValueListenable<int> favoriteCount;

  final ThemeMode themeMode;

  final VoidCallback? onFavorites;

  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  // ===========================================================================
  // ANIMATION
  // ===========================================================================

  late final AnimationController _animationController;

  // ===========================================================================
  // STATE
  // ===========================================================================

  bool _appearanceExpanded = false;

  String _userName = 'Foliage';

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _animationController =
    AnimationController(
      vsync: this,
      duration:
      const Duration(
        milliseconds: 700,
      ),
    )..forward();

    _loadUserName();
  }

  // ===========================================================================
  // LOAD USER NAME
  // ===========================================================================

  Future<void> _loadUserName() async {
    try {
      final prefs =
      await SharedPreferences
          .getInstance();

      final storedName =
          prefs.getString(
            'foliage_user_name',
          ) ??
              '';

      final name =
      storedName.trim();

      if (!mounted) {
        return;
      }

      setState(() {
        _userName =
        name.isEmpty
            ? 'Foliage'
            : name;
      });
    } catch (error) {
      debugPrint(
        'Foliage profile name error: $error',
      );
    }
  }

  // ===========================================================================
  // SECTION ANIMATION
  // ===========================================================================

  Animation<double> _section(
      double begin,
      double end,
      ) {
    return CurvedAnimation(
      parent:
      _animationController,
      curve: Interval(
        begin,
        end,
        curve:
        Curves.easeOutCubic,
      ),
    );
  }

  // ===========================================================================
  // APPEARANCE
  // ===========================================================================

  void _toggleAppearance() {
    HapticFeedback.selectionClick();

    setState(() {
      _appearanceExpanded =
      !_appearanceExpanded;
    });
  }

  void _changeThemeMode(
      ThemeMode mode,
      ) {
    if (widget.themeMode == mode) {
      return;
    }

    HapticFeedback.selectionClick();

    widget.onThemeModeChanged?.call(
      mode,
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final colors =
        theme.colorScheme;

    return Scaffold(
      backgroundColor:
      colors.surface,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // =================================================================
            // APP BAR
            // =================================================================

            FleckAppBar(
              title: 'Profile',
              searchHint:
              'Search wallpapers',
              onSearchChanged: (_) {},
            ),

            // =================================================================
            // CONTENT
            // =================================================================

            Expanded(
              child:
              CustomScrollView(
                physics:
                const BouncingScrollPhysics(
                  parent:
                  AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // ===========================================================
                  // PROFILE HEADER
                  // ===========================================================

                  SliverToBoxAdapter(
                    child:
                    _AnimatedSection(
                      animation:
                      _section(
                        .00,
                        .22,
                      ),
                      child:
                      _ProfileHero(
                        userName:
                        _userName,
                        favoriteCount:
                        widget
                            .favoriteCount,
                        onTap:
                        widget
                            .onFavorites,
                      ),
                    ),
                  ),

                  // ===========================================================
                  // LIBRARY
                  // ===========================================================

                  SliverToBoxAdapter(
                    child:
                    _AnimatedSection(
                      animation:
                      _section(
                        .18,
                        .38,
                      ),
                      child:
                      const _SectionHeader(
                        title:
                        'Your library',
                        subtitle:
                        'Everything you have saved.',
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child:
                    _AnimatedSection(
                      animation:
                      _section(
                        .25,
                        .46,
                      ),
                      child:
                      _ExpressiveGroup(
                        children: [
                          _ProfileAction(
                            icon: Hicons
                                .heart2LightOutline,
                            title:
                            'Favorites',
                            subtitle:
                            'Your saved wallpapers',
                            onTap:
                            widget
                                .onFavorites,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ===========================================================
                  // PERSONALIZE
                  // ===========================================================

                  SliverToBoxAdapter(
                    child:
                    _AnimatedSection(
                      animation:
                      _section(
                        .34,
                        .50,
                      ),
                      child:
                      const _SectionHeader(
                        title:
                        'Personalize',
                        subtitle:
                        'Make Foliage feel like yours.',
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child:
                    _AnimatedSection(
                      animation:
                      _section(
                        .40,
                        .70,
                      ),
                      child:
                      _ExpressiveGroup(
                        children: [
                          // ---------------------------------------------------
                          // APPEARANCE
                          // ---------------------------------------------------

                          _ProfileAction(
                            icon: Hicons
                                .sun2LightOutline,
                            title:
                            'Appearance',
                            subtitle:
                            _themeDescription(
                              widget
                                  .themeMode,
                            ),
                            trailing:
                            AnimatedRotation(
                              turns:
                              _appearanceExpanded
                                  ? .5
                                  : 0,
                              duration:
                              const Duration(
                                milliseconds:
                                240,
                              ),
                              curve:
                              Curves
                                  .easeOutCubic,
                              child:
                              Icon(
                                Hicons
                                    .down2LightOutline,
                                size:
                                18.sp,
                                color:
                                colors
                                    .onSurfaceVariant,
                              ),
                            ),
                            onTap:
                            _toggleAppearance,
                          ),

                          AnimatedSize(
                            duration:
                            const Duration(
                              milliseconds:
                              300,
                            ),
                            curve:
                            Curves
                                .easeOutCubic,
                            alignment:
                            Alignment
                                .topCenter,
                            child:
                            _appearanceExpanded
                                ? _AppearanceOptions(
                              themeMode:
                              widget
                                  .themeMode,
                              onChanged:
                              _changeThemeMode,
                            )
                                : const SizedBox
                                .shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ===========================================================
                  // ABOUT
                  // ===========================================================

                  SliverToBoxAdapter(
                    child:
                    _AnimatedSection(
                      animation:
                      _section(
                        .56,
                        .72,
                      ),
                      child:
                      const _SectionHeader(
                        title:
                        'About Foliage',
                        subtitle:
                        'Simple wallpaper discovery, designed with care.',
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child:
                    _AnimatedSection(
                      animation:
                      _section(
                        .62,
                        .88,
                      ),
                      child:
                      _ExpressiveGroup(
                        children: [
                          _ProfileAction(
                            icon: Hicons
                                .informationSquareLightOutline,
                            title:
                            'About Foliage',
                            subtitle:
                            'Learn more about Foliage',
                            onTap:
                            _openAbout,
                          ),

                          _ProfileAction(
                            icon: Hicons
                                .tickLightOutline,
                            title:
                            'Privacy',
                            subtitle:
                            'Your privacy and data',
                            onTap:
                            _openPrivacy,
                          ),

                          _ProfileAction(
                            icon: Hicons
                                .documentAlignCenter3LightOutline,
                            title:
                            'Terms',
                            subtitle:
                            'Terms of use',
                            onTap:
                            _openTerms,
                          ),

                          _ProfileAction(
                            icon: Hicons
                                .linkLightOutline,
                            title:
                            'Credits',
                            subtitle:
                            'Creators, sources and contributors',
                            onTap:
                            _openCredits,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ===========================================================
                  // FOOTER
                  // ===========================================================

                  SliverToBoxAdapter(
                    child:
                    Padding(
                      padding:
                      EdgeInsets.fromLTRB(
                        20.w,
                        28.h,
                        20.w,
                        104.h,
                      ),
                      child:
                      Text(
                        'Foliage • Wallpaper, your way.',
                        textAlign:
                        TextAlign.center,
                        style: theme
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                          color: colors
                              .onSurfaceVariant
                              .withValues(
                            alpha:
                            .58,
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
    );
  }

  // ===========================================================================
  // INFORMATION SCREENS
  // ===========================================================================

  void _openAbout() {
    HapticFeedback.lightImpact();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
        const FoliageAboutScreen(),
      ),
    );
  }

  void _openPrivacy() {
    HapticFeedback.lightImpact();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
        const FleckPrivacyScreen(),
      ),
    );
  }

  void _openTerms() {
    HapticFeedback.lightImpact();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
        const FleckTermsScreen(),
      ),
    );
  }

  void _openCredits() {
    HapticFeedback.lightImpact();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
        const FleckCreditsScreen(),
      ),
    );
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }
}

// =============================================================================
// THEME DESCRIPTION
// =============================================================================

String _themeDescription(
    ThemeMode mode,
    ) {
  switch (mode) {
    case ThemeMode.system:
      return 'Follows your device';

    case ThemeMode.light:
      return 'Light appearance';

    case ThemeMode.dark:
      return 'Dark appearance';
  }
}

// =============================================================================
// ANIMATED SECTION
// =============================================================================

class _AnimatedSection
    extends StatelessWidget {
  const _AnimatedSection({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;

  final Widget child;

  @override
  Widget build(
      BuildContext context,
      ) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (
          _,
          child,
          ) {
        final value =
            animation.value;

        return Opacity(
          opacity: value,
          child:
          Transform.translate(
            offset: Offset(
              0,
              14.h *
                  (1 - value),
            ),
            child:
            Transform.scale(
              scale:
              .985 +
                  (value *
                      .015),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// PROFILE HERO
// =============================================================================

class _ProfileHero
    extends StatelessWidget {
  const _ProfileHero({
    required this.userName,
    required this.favoriteCount,
    this.onTap,
  });

  final String userName;

  final ValueListenable<int>
  favoriteCount;

  final VoidCallback? onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final colors =
        theme.colorScheme;

    final initial =
    userName.trim().isEmpty
        ? 'F'
        : userName
        .trim()
        .characters
        .first
        .toUpperCase();

    return Padding(
      padding:
      EdgeInsets.fromLTRB(
        20.w,
        18.h,
        20.w,
        0,
      ),
      child: _Pressable(
        onTap: onTap,
        radius: 26.r,
        child: Material(
          color:
          colors.primaryContainer,
          borderRadius:
          BorderRadius.circular(
            26.r,
          ),
          clipBehavior:
          Clip.antiAlias,
          child: Padding(
            padding:
            EdgeInsets.all(
              16.w,
            ),
            child: Row(
              children: [
                // =============================================================
                // AVATAR
                // =============================================================

                AnimatedSwitcher(
                  duration:
                  const Duration(
                    milliseconds:
                    280,
                  ),
                  switchInCurve:
                  Curves
                      .easeOutBack,
                  switchOutCurve:
                  Curves
                      .easeInCubic,
                  transitionBuilder:
                      (
                      child,
                      animation,
                      ) {
                    return FadeTransition(
                      opacity:
                      animation,
                      child:
                      ScaleTransition(
                        scale:
                        Tween<
                            double>(
                          begin:
                          .82,
                          end:
                          1,
                        ).animate(
                          animation,
                        ),
                        child:
                        child,
                      ),
                    );
                  },
                  child:
                  Container(
                    key: ValueKey(
                      initial,
                    ),
                    width: 58.w,
                    height: 58.w,
                    decoration:
                    BoxDecoration(
                      color: colors
                          .onPrimaryContainer
                          .withValues(
                        alpha:
                        .09,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        19.r,
                      ),
                    ),
                    alignment:
                    Alignment
                        .center,
                    child:
                    Text(
                      initial,
                      style: theme
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        color: colors
                            .onPrimaryContainer,
                        fontWeight:
                        FontWeight
                            .w800,
                        letterSpacing:
                        -.8,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  width: 13.w,
                ),

                // =============================================================
                // CONTENT
                // =============================================================

                Expanded(
                  child:
                  ValueListenableBuilder<
                      int>(
                    valueListenable:
                    favoriteCount,
                    builder:
                        (
                        _,
                        count,
                        __,
                        ) {
                      return Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          // -------------------------------------------------
                          // USER NAME
                          // -------------------------------------------------

                          AnimatedSwitcher(
                            duration:
                            const Duration(
                              milliseconds:
                              280,
                            ),
                            switchInCurve:
                            Curves
                                .easeOutCubic,
                            switchOutCurve:
                            Curves
                                .easeInCubic,
                            transitionBuilder:
                                (
                                child,
                                animation,
                                ) {
                              return FadeTransition(
                                opacity:
                                animation,
                                child:
                                SlideTransition(
                                  position:
                                  Tween<
                                      Offset>(
                                    begin:
                                    const Offset(
                                      0,
                                      .06,
                                    ),
                                    end:
                                    Offset.zero,
                                  ).animate(
                                    animation,
                                  ),
                                  child:
                                  child,
                                ),
                              );
                            },
                            child:
                            Text(
                              userName,
                              key:
                              ValueKey(
                                userName,
                              ),
                              maxLines:
                              1,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              theme
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                color:
                                colors
                                    .onPrimaryContainer,
                                fontWeight:
                                FontWeight
                                    .w700,
                                letterSpacing:
                                -.5,
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 3.h,
                          ),

                          // -------------------------------------------------
                          // FAVORITES
                          // -------------------------------------------------

                          AnimatedSwitcher(
                            duration:
                            const Duration(
                              milliseconds:
                              220,
                            ),
                            switchInCurve:
                            Curves
                                .easeOutCubic,
                            switchOutCurve:
                            Curves
                                .easeInCubic,
                            transitionBuilder:
                                (
                                child,
                                animation,
                                ) {
                              return FadeTransition(
                                opacity:
                                animation,
                                child:
                                SlideTransition(
                                  position:
                                  Tween<
                                      Offset>(
                                    begin:
                                    const Offset(
                                      0,
                                      .04,
                                    ),
                                    end:
                                    Offset.zero,
                                  ).animate(
                                    animation,
                                  ),
                                  child:
                                  child,
                                ),
                              );
                            },
                            child:
                            Text(
                              key:
                              ValueKey(
                                count,
                              ),
                              count == 0
                                  ? 'Start your collection'
                                  : '$count saved wallpaper${count == 1 ? '' : 's'}',
                              maxLines:
                              1,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              theme
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color:
                                colors
                                    .onPrimaryContainer
                                    .withValues(
                                  alpha:
                                  .72,
                                ),
                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // =============================================================
                // ARROW
                // =============================================================

                if (onTap != null) ...[
                  SizedBox(
                    width: 8.w,
                  ),
                  Icon(
                    Hicons
                        .right2LightOutline,
                    size: 19.sp,
                    color: colors
                        .onPrimaryContainer
                        .withValues(
                      alpha:
                      .72,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SECTION HEADER
// =============================================================================

class _SectionHeader
    extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;

  final String subtitle;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final colors =
        theme.colorScheme;

    return Padding(
      padding:
      EdgeInsets.fromLTRB(
        20.w,
        28.h,
        20.w,
        10.h,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          Text(
            title,
            style: theme
                .textTheme
                .titleLarge
                ?.copyWith(
              fontWeight:
              FontWeight.w700,
              letterSpacing:
              -.4,
            ),
          ),
          SizedBox(
            height: 3.h,
          ),
          Text(
            subtitle,
            style: theme
                .textTheme
                .bodySmall
                ?.copyWith(
              color: colors
                  .onSurfaceVariant
                  .withValues(
                alpha: .68,
              ),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EXPRESSIVE GROUP
// =============================================================================

class _ExpressiveGroup
    extends StatelessWidget {
  const _ExpressiveGroup({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Padding(
      padding:
      EdgeInsets.symmetric(
        horizontal: 20.w,
      ),
      child: Material(
        color:
        colors.surfaceContainerLow,
        borderRadius:
        BorderRadius.circular(
          24.r,
        ),
        clipBehavior:
        Clip.antiAlias,
        child: Column(
          children: [
            for (
            int i = 0;
            i < children.length;
            i++
            ) ...[
              children[i],
              if (i <
                  children.length - 1)
                Divider(
                  height: 1,
                  indent: 68.w,
                  endIndent: 14.w,
                  color: colors
                      .outlineVariant
                      .withValues(
                    alpha: .24,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PROFILE ACTION
// =============================================================================

class _ProfileAction
    extends StatefulWidget {
  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;

  final String title;

  final String subtitle;

  final VoidCallback? onTap;

  final Widget? trailing;

  @override
  State<_ProfileAction> createState() =>
      _ProfileActionState();
}

class _ProfileActionState
    extends State<_ProfileAction> {
  bool _pressed = false;

  void _setPressed(
      bool value,
      ) {
    if (!mounted ||
        widget.onTap == null) {
      return;
    }

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final colors =
        theme.colorScheme;

    return AnimatedScale(
      scale:
      _pressed ? .987 : 1,
      duration:
      const Duration(
        milliseconds: 120,
      ),
      curve:
      Curves.easeOutCubic,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown:
        widget.onTap == null
            ? null
            : (_) =>
            _setPressed(
              true,
            ),
        onTapCancel:
        widget.onTap == null
            ? null
            : () =>
            _setPressed(
              false,
            ),
        onTapUp:
        widget.onTap == null
            ? null
            : (_) =>
            _setPressed(
              false,
            ),
        child: Padding(
          padding:
          EdgeInsets.symmetric(
            horizontal: 13.w,
            vertical: 11.h,
          ),
          child: Row(
            children: [
              // ===============================================================
              // ICON
              // ===============================================================

              AnimatedContainer(
                duration:
                const Duration(
                  milliseconds: 180,
                ),
                width: 44.w,
                height: 44.w,
                decoration:
                BoxDecoration(
                  color: _pressed
                      ? colors
                      .primaryContainer
                      : colors
                      .secondaryContainer,
                  borderRadius:
                  BorderRadius.circular(
                    15.r,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  size: 20.sp,
                  color: _pressed
                      ? colors
                      .onPrimaryContainer
                      : colors
                      .onSecondaryContainer,
                ),
              ),

              SizedBox(
                width: 12.w,
              ),

              // ===============================================================
              // TEXT
              // ===============================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      widget.title,
                      style: theme
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style: theme
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: colors
                            .onSurfaceVariant
                            .withValues(
                          alpha: .72,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: 8.w,
              ),

              // ===============================================================
              // TRAILING
              // ===============================================================

              if (widget.trailing !=
                  null)
                widget.trailing!
              else if (widget.onTap !=
                  null)
                Icon(
                  Hicons
                      .right2LightOutline,
                  size: 17.sp,
                  color: colors
                      .onSurfaceVariant
                      .withValues(
                    alpha: .58,
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
// APPEARANCE OPTIONS
// =============================================================================

class _AppearanceOptions
    extends StatelessWidget {
  const _AppearanceOptions({
    required this.themeMode,
    required this.onChanged,
  });

  final ThemeMode themeMode;

  final ValueChanged<ThemeMode>
  onChanged;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      EdgeInsets.fromLTRB(
        13.w,
        2.h,
        13.w,
        15.h,
      ),
      child: Column(
        children: [
          _ThemePreview(
            mode:
            ThemeMode.system,
            title: 'System',
            subtitle:
            'Follows your device',
            selected:
            themeMode ==
                ThemeMode.system,
            onTap: () =>
                onChanged(
                  ThemeMode.system,
                ),
            wide: true,
          ),
          SizedBox(
            height: 9.h,
          ),
          Row(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              Expanded(
                child:
                _ThemePreview(
                  mode:
                  ThemeMode.light,
                  title: 'Light',
                  subtitle:
                  'Bright',
                  selected:
                  themeMode ==
                      ThemeMode.light,
                  onTap: () =>
                      onChanged(
                        ThemeMode.light,
                      ),
                ),
              ),
              SizedBox(
                width: 9.w,
              ),
              Expanded(
                child:
                _ThemePreview(
                  mode:
                  ThemeMode.dark,
                  title: 'Dark',
                  subtitle:
                  'Dim',
                  selected:
                  themeMode ==
                      ThemeMode.dark,
                  onTap: () =>
                      onChanged(
                        ThemeMode.dark,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// THEME PREVIEW
// =============================================================================

class _ThemePreview
    extends StatefulWidget {
  const _ThemePreview({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.wide = false,
  });

  final ThemeMode mode;

  final String title;

  final String subtitle;

  final bool selected;

  final VoidCallback onTap;

  final bool wide;

  @override
  State<_ThemePreview> createState() =>
      _ThemePreviewState();
}

class _ThemePreviewState
    extends State<_ThemePreview> {
  bool _pressed = false;

  Color get _background {
    switch (widget.mode) {
      case ThemeMode.light:
        return const Color(
          0xFFF7F7FA,
        );

      case ThemeMode.dark:
        return const Color(
          0xFF15161A,
        );

      case ThemeMode.system:
        return const Color(
          0xFFECECF1,
        );
    }
  }

  Color get _surface {
    switch (widget.mode) {
      case ThemeMode.light:
        return Colors.white;

      case ThemeMode.dark:
        return const Color(
          0xFF25262C,
        );

      case ThemeMode.system:
        return Colors.white;
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final colors =
        theme.colorScheme;

    return AnimatedScale(
      scale:
      _pressed ? .975 : 1,
      duration:
      const Duration(
        milliseconds: 140,
      ),
      curve:
      Curves.easeOutCubic,
      child: Material(
        color: widget.selected
            ? FleckTheme
            .primarySoft
            : colors
            .surfaceContainerLow,
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            widget.wide
                ? 23.r
                : 21.r,
          ),
          side: widget.selected
              ? BorderSide(
            color: FleckTheme
                .seedColor
                .withValues(
              alpha: .22,
            ),
            width: 1,
          )
              : BorderSide.none,
        ),
        clipBehavior:
        Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius:
          BorderRadius.circular(
            widget.wide
                ? 23.r
                : 21.r,
          ),
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
          },
          child: Padding(
            padding:
            EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                _ThemeMiniature(
                  mode:
                  widget.mode,
                  background:
                  _background,
                  surface:
                  _surface,
                  wide:
                  widget.wide,
                ),
                SizedBox(
                  height: 9.h,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                          fontWeight:
                          FontWeight
                              .w700,
                          letterSpacing:
                          -.15,
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration:
                      const Duration(
                        milliseconds:
                        220,
                      ),
                      transitionBuilder:
                          (
                          child,
                          animation,
                          ) {
                        return ScaleTransition(
                          scale:
                          animation,
                          child:
                          FadeTransition(
                            opacity:
                            animation,
                            child:
                            child,
                          ),
                        );
                      },
                      child:
                      widget.selected
                          ? Container(
                        key:
                        const ValueKey(
                          'selected',
                        ),
                        width:
                        24.w,
                        height:
                        24.w,
                        decoration:
                        const BoxDecoration(
                          color:
                          FleckTheme
                              .seedColor,
                          shape:
                          BoxShape.circle,
                        ),
                        child:
                        Icon(
                          Icons
                              .check_rounded,
                          size:
                          15.sp,
                          color:
                          FleckTheme
                              .onPrimary,
                        ),
                      )
                          : SizedBox(
                        key:
                        const ValueKey(
                          'empty',
                        ),
                        width:
                        24.w,
                        height:
                        24.w,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 1.h,
                ),
                Text(
                  widget.subtitle,
                  maxLines: 1,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: colors
                        .onSurfaceVariant
                        .withValues(
                      alpha: .68,
                    ),
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

// =============================================================================
// THEME MINIATURE
// =============================================================================

class _ThemeMiniature
    extends StatelessWidget {
  const _ThemeMiniature({
    required this.mode,
    required this.background,
    required this.surface,
    required this.wide,
  });

  final ThemeMode mode;

  final Color background;

  final Color surface;

  final bool wide;

  @override
  Widget build(
      BuildContext context,
      ) {
    if (mode ==
        ThemeMode.system) {
      return SizedBox(
        height: 96.h,
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(
            16.r,
          ),
          child: Row(
            children: [
              Expanded(
                child:
                _MiniThemePanel(
                  background:
                  const Color(
                    0xFFF7F7FA,
                  ),
                  surface:
                  Colors.white,
                  dark: false,
                  side: 'Light',
                ),
              ),
              Expanded(
                child:
                _MiniThemePanel(
                  background:
                  const Color(
                    0xFF15161A,
                  ),
                  surface:
                  const Color(
                    0xFF25262C,
                  ),
                  dark: true,
                  side: 'Dark',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height:
      wide ? 96.h : 88.h,
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(
          16.r,
        ),
        child:
        _MiniThemePanel(
          background:
          background,
          surface:
          surface,
          dark:
          mode ==
              ThemeMode.dark,
          side:
          mode ==
              ThemeMode.dark
              ? 'Dark'
              : 'Light',
        ),
      ),
    );
  }
}

// =============================================================================
// MINI THEME PANEL
// =============================================================================

class _MiniThemePanel
    extends StatelessWidget {
  const _MiniThemePanel({
    required this.background,
    required this.surface,
    required this.dark,
    required this.side,
  });

  final Color background;

  final Color surface;

  final bool dark;

  final String side;

  @override
  Widget build(
      BuildContext context,
      ) {
    final foreground =
    dark
        ? Colors.white
        : const Color(
      0xFF252631,
    );

    final muted = dark
        ? Colors.white
        .withValues(
      alpha: .48,
    )
        : const Color(
      0xFF5D5F69,
    )
        .withValues(
      alpha: .48,
    );

    return Container(
      color:
      background,
      padding:
      EdgeInsets.all(9.w),
      child: Stack(
        children: [
          // ===================================================================
          // MINI APP BAR
          // ===================================================================

          Align(
            alignment:
            Alignment.topCenter,
            child: Row(
              children: [
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration:
                  BoxDecoration(
                    color:
                    surface,
                    borderRadius:
                    BorderRadius
                        .circular(
                      9.r,
                    ),
                  ),
                  child:
                  Icon(
                    Icons
                        .person_outline_rounded,
                    size: 12.sp,
                    color:
                    foreground,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 40.w,
                  height: 5.h,
                  decoration:
                  BoxDecoration(
                    color:
                    foreground,
                    borderRadius:
                    BorderRadius
                        .circular(
                      5.r,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration:
                  BoxDecoration(
                    color: FleckTheme
                        .primarySoft,
                    borderRadius:
                    BorderRadius
                        .circular(
                      9.r,
                    ),
                  ),
                  child:
                  Icon(
                    Icons
                        .search_rounded,
                    size: 12.sp,
                    color: FleckTheme
                        .seedColor,
                  ),
                ),
              ],
            ),
          ),

          // ===================================================================
          // MINI WALLPAPER
          // ===================================================================

          Positioned(
            left: 0,
            right: 0,
            top: 34.h,
            child:
            Container(
              height: 42.h,
              decoration:
              BoxDecoration(
                color:
                surface,
                borderRadius:
                BorderRadius
                    .circular(
                  12.r,
                ),
              ),
              clipBehavior:
              Clip.antiAlias,
              child:
              CustomPaint(
                painter:
                _MiniWallpaperPainter(
                  dark: dark,
                ),
              ),
            ),
          ),

          // ===================================================================
          // MODE LABEL
          // ===================================================================

          Positioned(
            top: 5.h,
            left: 36.w,
            child:
            Container(
              padding:
              EdgeInsets
                  .symmetric(
                horizontal:
                5.w,
                vertical:
                2.h,
              ),
              decoration:
              BoxDecoration(
                color: dark
                    ? Colors.white
                    .withValues(
                  alpha: .08,
                )
                    : Colors.black
                    .withValues(
                  alpha: .045,
                ),
                borderRadius:
                BorderRadius
                    .circular(
                  999,
                ),
              ),
              child:
              Text(
                side,
                style:
                TextStyle(
                  color:
                  muted,
                  fontSize:
                  5.5.sp,
                  fontWeight:
                  FontWeight
                      .w700,
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
// MINI WALLPAPER PAINTER
// =============================================================================

class _MiniWallpaperPainter
    extends CustomPainter {
  const _MiniWallpaperPainter({
    required this.dark,
  });

  final bool dark;

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final paint =
    Paint();

    paint.color = dark
        ? const Color(
      0xFF343844,
    )
        : const Color(
      0xFFDDE0E9,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
      paint,
    );

    paint.color = dark
        ? const Color(
      0xFF6678A6,
    ).withValues(
      alpha: .68,
    )
        : FleckTheme
        .seedColor
        .withValues(
      alpha: .32,
    );

    final mountain =
    Path()
      ..moveTo(
        0,
        size.height *
            .78,
      )
      ..lineTo(
        size.width *
            .26,
        size.height *
            .38,
      )
      ..lineTo(
        size.width *
            .48,
        size.height *
            .68,
      )
      ..lineTo(
        size.width *
            .68,
        size.height *
            .30,
      )
      ..lineTo(
        size.width,
        size.height *
            .72,
      )
      ..lineTo(
        size.width,
        size.height,
      )
      ..lineTo(
        0,
        size.height,
      )
      ..close();

    canvas.drawPath(
      mountain,
      paint,
    );

    paint.color = dark
        ? Colors.white
        .withValues(
      alpha: .18,
    )
        : Colors.white
        .withValues(
      alpha: .68,
    );

    canvas.drawCircle(
      Offset(
        size.width * .77,
        size.height * .25,
      ),
      size.height * .13,
      paint,
    );
  }

  @override
  bool shouldRepaint(
      covariant
      _MiniWallpaperPainter
      oldDelegate,
      ) {
    return oldDelegate.dark !=
        dark;
  }
}

// =============================================================================
// PRESSABLE
// =============================================================================

class _Pressable
    extends StatefulWidget {
  const _Pressable({
    required this.child,
    required this.radius,
    this.onTap,
  });

  final Widget child;

  final double radius;

  final VoidCallback? onTap;

  @override
  State<_Pressable> createState() =>
      _PressableState();
}

class _PressableState
    extends State<_Pressable> {
  bool _pressed = false;

  void _setPressed(
      bool value,
      ) {
    if (!mounted ||
        widget.onTap == null) {
      return;
    }

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return AnimatedScale(
      scale:
      _pressed ? .987 : 1,
      duration:
      const Duration(
        milliseconds: 120,
      ),
      curve:
      Curves.easeOutCubic,
      child: Material(
        color:
        Colors.transparent,
        borderRadius:
        BorderRadius.circular(
          widget.radius,
        ),
        clipBehavior:
        Clip.antiAlias,
        child: InkWell(
          onTap:
          widget.onTap,
          borderRadius:
          BorderRadius.circular(
            widget.radius,
          ),
          onTapDown:
          widget.onTap == null
              ? null
              : (_) =>
              _setPressed(
                true,
              ),
          onTapCancel:
          widget.onTap == null
              ? null
              : () =>
              _setPressed(
                false,
              ),
          onTapUp:
          widget.onTap == null
              ? null
              : (_) =>
              _setPressed(
                false,
              ),
          child:
          widget.child,
        ),
      ),
    );
  }
}