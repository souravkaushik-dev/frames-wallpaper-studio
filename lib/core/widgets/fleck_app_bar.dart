import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/favorites/presentation/widgets/ffav_store.dart';

/// =============================================================================
/// FLECK APP BAR
/// =============================================================================
///
/// Minimal Material 3 inspired app bar for Foliage.
///
/// Profile button:
///   Opens the Foliage profile as an expressive bottom sheet.
///
/// Search button:
///   Expands into an animated search field.
///
class FleckAppBar extends StatefulWidget {
  const FleckAppBar({
    super.key,
    this.title = 'Foliage',
    this.searchHint = 'Search wallpapers',
    this.onSearchChanged,
    this.onProfilePressed,
    this.showProfile = true,
    this.showSearch = true,
  });

  final String title;

  final String searchHint;

  final ValueChanged<String>? onSearchChanged;

  final VoidCallback? onProfilePressed;

  final bool showProfile;

  final bool showSearch;

  @override
  State<FleckAppBar> createState() =>
      _FleckAppBarState();
}

class _FleckAppBarState
    extends State<FleckAppBar> {
  final TextEditingController
  _searchController =
  TextEditingController();

  final FocusNode _searchFocusNode =
  FocusNode();

  bool _searchOpen = false;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _handleSearchChanged,
    );
  }

  void _handleSearchChanged() {
    widget.onSearchChanged?.call(
      _searchController.text.trim(),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(
      _handleSearchChanged,
    );

    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  // ===========================================================================
  // SEARCH
  // ===========================================================================

  void _openSearch() {
    if (_searchOpen) {
      return;
    }

    HapticFeedback.selectionClick();

    setState(() {
      _searchOpen = true;
    });

    WidgetsBinding.instance
        .addPostFrameCallback(
          (_) {
        if (!mounted || !_searchOpen) {
          return;
        }

        _searchFocusNode.requestFocus();
      },
    );
  }

  void _closeSearch() {
    if (!_searchOpen) {
      return;
    }

    HapticFeedback.selectionClick();

    _searchFocusNode.unfocus();

    setState(() {
      _searchOpen = false;
    });

    _searchController.clear();
  }

  // ===========================================================================
  // PROFILE
  // ===========================================================================

  void _openProfile() {
    HapticFeedback.mediumImpact();

    if (widget.onProfilePressed != null) {
      widget.onProfilePressed!();
      return;
    }

    showFleckExpressiveBottomSheet<void>(
      context: context,
      child: const _FoliageProfileSheet(),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        10.h,
        20.w,
        8.h,
      ),
      child: SizedBox(
        height: 68.h,
        child: AnimatedSwitcher(
          duration:
          const Duration(
            milliseconds: 360,
          ),
          reverseDuration:
          const Duration(
            milliseconds: 280,
          ),
          switchInCurve:
          Curves.easeOutCubic,
          switchOutCurve:
          Curves.easeInCubic,
          transitionBuilder: (
              child,
              animation,
              ) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                Tween<Offset>(
                  begin:
                  const Offset(
                    .035,
                    0,
                  ),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _searchOpen
              ? _FleckSearchField(
            key: const ValueKey(
              'fleck-search',
            ),
            controller:
            _searchController,
            focusNode:
            _searchFocusNode,
            hintText:
            widget.searchHint,
            onClose:
            _closeSearch,
          )
              : _FleckNormalHeader(
            key: const ValueKey(
              'fleck-header',
            ),
            title:
            widget.title,
            showProfile:
            widget.showProfile,
            showSearch:
            widget.showSearch,
            onProfile:
            _openProfile,
            onSearch:
            _openSearch,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// NORMAL HEADER
// =============================================================================

class _FleckNormalHeader
    extends StatelessWidget {
  const _FleckNormalHeader({
    super.key,
    required this.title,
    required this.showProfile,
    required this.showSearch,
    required this.onProfile,
    required this.onSearch,
  });

  final String title;

  final bool showProfile;

  final bool showSearch;

  final VoidCallback onProfile;

  final VoidCallback onSearch;

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Row(
      children: [
        if (showProfile)
          _FleckAppBarButton(
            icon:
            Hicons
                .profile1LightOutline,
            background:
            colors
                .surfaceContainerHigh,
            foreground:
            colors
                .onSurfaceVariant,
            onTap: onProfile,
          )
        else
          SizedBox(
            width: 56.w,
          ),

        const Spacer(),

        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
            fontWeight:
            FontWeight.w800,
            letterSpacing:
            -1.15,
          ),
        ),

        const Spacer(),

        if (showSearch)
          _FleckAppBarButton(
            icon:
            Hicons
                .search1LightOutline,
            background:
            colors
                .primaryContainer,
            foreground:
            colors
                .onPrimaryContainer,
            onTap: onSearch,
          )
        else
          SizedBox(
            width: 56.w,
          ),
      ],
    );
  }
}

// =============================================================================
// SEARCH FIELD
// =============================================================================

class _FleckSearchField
    extends StatelessWidget {
  const _FleckSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onClose,
  });

  final TextEditingController
  controller;

  final FocusNode focusNode;

  final String hintText;

  final VoidCallback onClose;

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Material(
      color:
      colors.surfaceContainerHigh,
      borderRadius:
      BorderRadius.circular(
        20.r,
      ),
      clipBehavior:
      Clip.antiAlias,
      child: SizedBox(
        height: 56.w,
        child: Padding(
          padding:
          EdgeInsets.symmetric(
            horizontal: 6.w,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40.w,
                height: 44.w,
                child: Center(
                  child: Icon(
                    Hicons
                        .search1LightOutline,
                    size: 21.sp,
                    color: colors
                        .onSurfaceVariant,
                  ),
                ),
              ),

              SizedBox(
                width: 3.w,
              ),

              Expanded(
                child: TextField(
                  controller:
                  controller,
                  focusNode:
                  focusNode,
                  autofocus:
                  true,
                  maxLines: 1,
                  textInputAction:
                  TextInputAction
                      .search,
                  decoration:
                  InputDecoration(
                    hintText:
                    hintText,
                    border:
                    InputBorder.none,
                    enabledBorder:
                    InputBorder.none,
                    focusedBorder:
                    InputBorder.none,
                    isDense: true,
                    contentPadding:
                    EdgeInsets.zero,
                    hintStyle:
                    Theme.of(
                      context,
                    )
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                      color: colors
                          .onSurfaceVariant,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ),
              ),

              SizedBox(
                width: 3.w,
              ),

              Material(
                color: colors
                    .surfaceContainerHighest,
                shape:
                const CircleBorder(),
                child: InkWell(
                  customBorder:
                  const CircleBorder(),
                  onTap: onClose,
                  child: SizedBox(
                    width: 44.w,
                    height: 44.w,
                    child: Center(
                      child: Icon(
                        Hicons
                            .closeLightOutline,
                        size: 19.sp,
                        color: colors
                            .onSurfaceVariant,
                      ),
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

// =============================================================================
// APP BAR BUTTON
// =============================================================================

class _FleckAppBarButton
    extends StatefulWidget {
  const _FleckAppBarButton({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;

  final Color background;

  final Color foreground;

  final VoidCallback onTap;

  @override
  State<_FleckAppBarButton>
  createState() =>
      _FleckAppBarButtonState();
}

class _FleckAppBarButtonState
    extends State<_FleckAppBarButton> {
  bool _pressed = false;

  @override
  Widget build(
      BuildContext context,
      ) {
    return AnimatedScale(
      scale:
      _pressed ? .93 : 1,
      duration:
      const Duration(
        milliseconds: 150,
      ),
      curve:
      Curves.easeOutCubic,
      child: Material(
        color:
        widget.background,
        borderRadius:
        BorderRadius.circular(
          18.r,
        ),
        child: InkWell(
          borderRadius:
          BorderRadius.circular(
            18.r,
          ),
          onTap:
          widget.onTap,
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
          child: SizedBox(
            width: 56.w,
            height: 56.w,
            child: Center(
              child: Icon(
                widget.icon,
                size: 22.sp,
                color:
                widget.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// FOLIAGE PROFILE BOTTOM SHEET
// =============================================================================

class _FoliageProfileSheet
    extends StatefulWidget {
  const _FoliageProfileSheet();

  @override
  State<_FoliageProfileSheet>
  createState() =>
      _FoliageProfileSheetState();
}

class _FoliageProfileSheetState
    extends State<_FoliageProfileSheet>
    with SingleTickerProviderStateMixin {
  String _name = 'Foliage';

  late final AnimationController
  _animationController;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(
          vsync: this,
          duration:
          const Duration(
            milliseconds: 560,
          ),
        );

    _loadName();

    WidgetsBinding.instance
        .addPostFrameCallback(
          (_) {
        if (mounted) {
          _animationController
              .forward();
        }
      },
    );
  }

  Future<void> _loadName() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    final stored =
        prefs.getString(
          'foliage_user_name',
        ) ??
            '';

    if (!mounted) {
      return;
    }

    setState(() {
      _name =
      stored.trim().isEmpty
          ? 'Foliage'
          : stored.trim();
    });
  }

  String get _initial {
    final value = _name.trim();

    if (value.isEmpty) {
      return 'F';
    }

    return value.characters
        .first
        .toUpperCase();
  }

  @override
  void dispose() {
    _animationController
        .dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final colors =
        theme.colorScheme;

    return ValueListenableBuilder<
        Set<String>>(
      valueListenable:
      FleckFavoritesStore.urls,
      builder: (
          context,
          favorites,
          _,
          ) {
        return AnimatedBuilder(
          animation:
          _animationController,

          builder: (
              context,
              child,
              ) {
            final curve =
            CurvedAnimation(
              parent:
              _animationController,
              curve:
              Curves.easeOutBack,
            );

            final value =
                curve.value;

            return Transform.translate(
              offset: Offset(
                0,
                28 *
                    (1 - value),
              ),
              child: Transform.scale(
                alignment:
                Alignment.bottomCenter,
                scale:
                .97 +
                    (.03 * value),
                child: Opacity(
                  opacity:
                  value.clamp(
                    0,
                    1,
                  ),
                  child: child,
                ),
              ),
            );
          },

          child: SingleChildScrollView(
            physics:
            const BouncingScrollPhysics(),

            child: Column(
              mainAxisSize:
              MainAxisSize.min,

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                // =============================================================
                // PROFILE HEADER
                // =============================================================

                Row(
                  children: [
                    Container(
                      width: 62.w,
                      height: 62.w,

                      decoration:
                      BoxDecoration(
                        color: colors
                            .primaryContainer,

                        borderRadius:
                        BorderRadius
                            .circular(
                          22.r,
                        ),
                      ),

                      alignment:
                      Alignment.center,

                      child: Text(
                        _initial,

                        style: theme
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                          color: colors
                              .onPrimaryContainer,
                          fontWeight:
                          FontWeight.w800,
                          letterSpacing:
                          -.8,
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 14.w,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [
                          Text(
                            _name,

                            maxLines: 1,

                            overflow:
                            TextOverflow
                                .ellipsis,

                            style: theme
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                              fontWeight:
                              FontWeight.w800,
                              letterSpacing:
                              -.7,
                            ),
                          ),

                          SizedBox(
                            height: 3.h,
                          ),

                          Text(
                            'Your Foliage',

                            style: theme
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              color: colors
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Material(
                      color: colors
                          .surfaceContainerHighest,
                      shape:
                      const CircleBorder(),
                      child: InkWell(
                        customBorder:
                        const CircleBorder(),
                        onTap: () {
                          HapticFeedback
                              .selectionClick();

                          Navigator.pop(
                            context,
                          );
                        },
                        child: SizedBox(
                          width: 44.w,
                          height: 44.w,
                          child: Center(
                            child: Icon(
                              Icons
                                  .close_rounded,
                              size: 20.sp,
                              color: colors
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 18.h,
                ),

                // =============================================================
                // FAVORITES
                // =============================================================

                _FleckProfileCard(
                  icon:
                  Icons.favorite_rounded,

                  iconBackground:
                  colors.primaryContainer,

                  iconColor:
                  colors.onPrimaryContainer,

                  title:
                  '${favorites.length}',

                  subtitle:
                  favorites.length == 1
                      ? 'favorite wallpaper'
                      : 'favorite wallpapers',

                  onTap: () {
                    HapticFeedback
                        .selectionClick();

                    Navigator.pop(
                      context,
                    );
                  },
                ),

                SizedBox(
                  height: 22.h,
                ),

                const _ProfileSectionLabel(
                  'FOLIAGE',
                ),

                _ProfileAction(
                  icon:
                  Icons.info_outline_rounded,

                  title:
                  'About Foliage',

                  subtitle:
                  'Learn more about the app',

                  onTap: () {
                    Navigator.pop(
                      context,
                    );

                    Future.delayed(
                      const Duration(
                        milliseconds: 250,
                      ),
                          () {
                        if (!context
                            .mounted) {
                          return;
                        }

                        Navigator.of(
                          context,
                        ).push(
                          MaterialPageRoute(
                            builder: (_) =>
                            const FoliageAboutScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),

                _ProfileAction(
                  icon:
                  Icons.auto_awesome_rounded,

                  title:
                  "What's new",

                  subtitle:
                  'See the latest changes',

                  onTap: () {
                    _showChangelog(
                      context,
                    );
                  },
                ),

                SizedBox(
                  height: 14.h,
                ),

                const _ProfileSectionLabel(
                  'FEEDBACK',
                ),

                _ProfileAction(
                  icon:
                  Icons.flag_outlined,

                  title:
                  'Report an issue',

                  subtitle:
                  'Tell us when something is wrong',

                  onTap: () {
                    _openEmail(
                      subject:
                      'Foliage — Report an issue',
                      body:
                      'Hi Foliage,\n\n'
                          'I would like to report an issue.\n\n'
                          'Issue:\n\n'
                          'Device / Android version:\n\n',
                    );
                  },
                ),

                _ProfileAction(
                  icon:
                  Icons
                      .lightbulb_outline_rounded,

                  title:
                  'Request a feature',

                  subtitle:
                  'Suggest something for Foliage',

                  onTap: () {
                    _openEmail(
                      subject:
                      'Foliage — Feature request',
                      body:
                      'Hi Foliage,\n\n'
                          'I would like to request a feature.\n\n'
                          'Feature:\n\n'
                          'Why would it be useful?\n\n',
                    );
                  },
                ),

                SizedBox(
                  height: 14.h,
                ),

                Center(
                  child: Text(
                    'Foliage • Wallpaper, your way.',
                    style: theme
                        .textTheme
                        .labelSmall
                        ?.copyWith(
                      color: colors
                          .onSurfaceVariant
                          .withValues(
                        alpha: .5,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 4.h,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // CHANGELOG
  // ===========================================================================

  void _showChangelog(
      BuildContext context,
      ) {
    HapticFeedback.selectionClick();

    showFleckExpressiveBottomSheet<void>(
      context: context,
      child:
      const _ChangelogContent(),
    );
  }

  // ===========================================================================
  // EMAIL
  // ===========================================================================

  Future<void> _openEmail({
    required String subject,
    required String body,
  }) async {
    HapticFeedback.mediumImpact();

    final uri = Uri(
      scheme: 'mailto',
      path:
      'souravkaushik.dev@gmail.com',
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      await launchUrl(
        uri,
        mode:
        LaunchMode
            .externalApplication,
      );
    } catch (error) {
      debugPrint(
        'Foliage email error: $error',
      );
    }
  }
}

// =============================================================================
// PROFILE CARD
// =============================================================================

class _FleckProfileCard
    extends StatefulWidget {
  const _FleckProfileCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;

  final Color iconBackground;

  final Color iconColor;

  final String title;

  final String subtitle;

  final VoidCallback onTap;

  @override
  State<_FleckProfileCard>
  createState() =>
      _FleckProfileCardState();
}

class _FleckProfileCardState
    extends State<_FleckProfileCard> {
  bool _pressed = false;

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return AnimatedScale(
      scale:
      _pressed ? .985 : 1,

      duration:
      const Duration(
        milliseconds: 140,
      ),

      curve:
      Curves.easeOutCubic,

      child: Material(
        color:
        colors.surfaceContainerHigh,

        borderRadius:
        BorderRadius.circular(
          22.r,
        ),

        child: InkWell(
          borderRadius:
          BorderRadius.circular(
            22.r,
          ),

          onTap:
          widget.onTap,

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
            EdgeInsets.all(
              16.w,
            ),

            child: Row(
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,

                  decoration:
                  BoxDecoration(
                    color:
                    widget.iconBackground,

                    borderRadius:
                    BorderRadius
                        .circular(
                      16.r,
                    ),
                  ),

                  child: Icon(
                    widget.icon,
                    size: 21.sp,
                    color:
                    widget.iconColor,
                  ),
                ),

                SizedBox(
                  width: 13.w,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [
                      Text(
                        widget.title,

                        style: Theme.of(
                          context,
                        )
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          fontWeight:
                          FontWeight.w800,
                          letterSpacing:
                          -.4,
                        ),
                      ),

                      Text(
                        widget.subtitle,

                        style: Theme.of(
                          context,
                        )
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: colors
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons
                      .chevron_right_rounded,
                  size: 21.sp,
                  color: colors
                      .onSurfaceVariant
                      .withValues(
                    alpha: .42,
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
// PROFILE SECTION LABEL
// =============================================================================

class _ProfileSectionLabel
    extends StatelessWidget {
  const _ProfileSectionLabel(
      this.text,
      );

  final String text;

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Padding(
      padding:
      EdgeInsets.only(
        left: 6.w,
        bottom: 6.h,
      ),

      child: Text(
        text,

        style: TextStyle(
          color: colors
              .onSurfaceVariant
              .withValues(
            alpha: .55,
          ),
          fontSize: 10.sp,
          fontWeight:
          FontWeight.w800,
          letterSpacing: .8,
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
    required this.onTap,
  });

  final IconData icon;

  final String title;

  final String subtitle;

  final VoidCallback onTap;

  @override
  State<_ProfileAction>
  createState() =>
      _ProfileActionState();
}

class _ProfileActionState
    extends State<_ProfileAction> {
  bool _pressed = false;

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
      _pressed ? .985 : 1,

      duration:
      const Duration(
        milliseconds: 130,
      ),

      child: Material(
        color:
        Colors.transparent,

        child: InkWell(
          borderRadius:
          BorderRadius.circular(
            18.r,
          ),

          onTap:
          widget.onTap,

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
            EdgeInsets.symmetric(
              horizontal: 5.w,
              vertical: 6.h,
            ),

            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,

                  decoration:
                  BoxDecoration(
                    color: colors
                        .surfaceContainerHighest,

                    borderRadius:
                    BorderRadius.circular(
                      15.r,
                    ),
                  ),

                  child: Icon(
                    widget.icon,
                    size: 20.sp,
                    color: colors
                        .onSurfaceVariant,
                  ),
                ),

                SizedBox(
                  width: 12.w,
                ),

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
                          FontWeight.w600,
                        ),
                      ),

                      SizedBox(
                        height: 2.h,
                      ),

                      Text(
                        widget.subtitle,

                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: colors
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons
                      .chevron_right_rounded,
                  size: 20.sp,
                  color: colors
                      .onSurfaceVariant
                      .withValues(
                    alpha: .42,
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
// CHANGELOG
// =============================================================================

class _ChangelogContent
    extends StatelessWidget {
  const _ChangelogContent();

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final colors =
        theme.colorScheme;

    return SingleChildScrollView(
      physics:
      const BouncingScrollPhysics(),

      child: Column(
        mainAxisSize:
        MainAxisSize.min,

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            "What's new",

            style: theme
                .textTheme
                .headlineSmall
                ?.copyWith(
              fontWeight:
              FontWeight.w800,
              letterSpacing: -.7,
            ),
          ),

          SizedBox(
            height: 5.h,
          ),

          Text(
            'Latest Foliage updates',

            style: theme
                .textTheme
                .bodyMedium
                ?.copyWith(
              color:
              colors.onSurfaceVariant,
            ),
          ),

          SizedBox(
            height: 22.h,
          ),

          const _ChangelogItem(
            version: '1.0',
            title:
            'Welcome to Foliage',
            description:
            'Discover beautiful wallpapers and make your screen feel yours.',
            latest: true,
          ),

          const _ChangelogItem(
            version: '1.0',
            title:
            'Personalized experience',
            description:
            'Your chosen name makes Foliage feel more personal.',
          ),

          const _ChangelogItem(
            version: '1.0',
            title:
            'Wallpaper tools',
            description:
            'Download wallpapers and apply them directly to your device.',
          ),
        ],
      ),
    );
  }
}

class _ChangelogItem
    extends StatelessWidget {
  const _ChangelogItem({
    required this.version,
    required this.title,
    required this.description,
    this.latest = false,
  });

  final String version;

  final String title;

  final String description;

  final bool latest;

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
      EdgeInsets.only(
        bottom: 20.h,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Container(
            width: 40.w,
            height: 40.w,

            decoration:
            BoxDecoration(
              color: latest
                  ? colors
                  .primaryContainer
                  : colors
                  .surfaceContainerHighest,

              borderRadius:
              BorderRadius.circular(
                13.r,
              ),
            ),

            alignment:
            Alignment.center,

            child: Text(
              version,

              style: TextStyle(
                color: latest
                    ? colors
                    .onPrimaryContainer
                    : colors
                    .onSurfaceVariant,

                fontSize: 9.sp,

                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),

          SizedBox(
            width: 12.w,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: theme
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                SizedBox(
                  height: 4.h,
                ),

                Text(
                  description,

                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: colors
                        .onSurfaceVariant,
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
// ABOUT SCREEN
// =============================================================================

class FoliageAboutScreen
    extends StatelessWidget {
  const FoliageAboutScreen({
    super.key,
  });

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

      appBar: AppBar(
        backgroundColor:
        Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,

        title: const Text(
          'About Foliage',
        ),
      ),

      body: ListView(
        physics:
        const BouncingScrollPhysics(),

        padding:
        EdgeInsets.fromLTRB(
          20.w,
          12.h,
          20.w,
          32.h,
        ),

        children: [
          Container(
            padding:
            EdgeInsets.all(
              24.w,
            ),

            decoration:
            BoxDecoration(
              color: colors
                  .surfaceContainerHigh,

              borderRadius:
              BorderRadius.circular(
                28.r,
              ),
            ),

            child: Column(
              children: [
                Container(
                  width: 72.w,
                  height: 72.w,

                  decoration:
                  BoxDecoration(
                    color: colors
                        .primaryContainer,

                    borderRadius:
                    BorderRadius.circular(
                      25.r,
                    ),
                  ),

                  child: Icon(
                    Icons.eco_rounded,
                    size: 34.sp,
                    color: colors
                        .onPrimaryContainer,
                  ),
                ),

                SizedBox(
                  height: 16.h,
                ),

                Text(
                  'Foliage',

                  style: theme
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),

                SizedBox(
                  height: 6.h,
                ),

                Text(
                  'Wallpaper, your way.',

                  textAlign:
                  TextAlign.center,

                  style: theme
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                    color: colors
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 24.h,
          ),

          Text(
            'About',

            style: theme
                .textTheme
                .titleLarge
                ?.copyWith(
              fontWeight:
              FontWeight.w700,
            ),
          ),

          SizedBox(
            height: 8.h,
          ),

          Text(
            'Foliage is a simple and expressive '
                'wallpaper experience designed to make '
                'discovering, saving and enjoying wallpapers '
                'feel calm and personal.',

            style: theme
                .textTheme
                .bodyLarge
                ?.copyWith(
              color:
              colors.onSurfaceVariant,
              height: 1.55,
            ),
          ),

          SizedBox(
            height: 24.h,
          ),

          Text(
            'Privacy',

            style: theme
                .textTheme
                .titleLarge
                ?.copyWith(
              fontWeight:
              FontWeight.w700,
            ),
          ),

          SizedBox(
            height: 8.h,
          ),

          Text(
            'Foliage only uses your name to personalize '
                'your experience inside the app. We do not '
                'need access to your gallery or personal files '
                'for this personalization.',

            style: theme
                .textTheme
                .bodyLarge
                ?.copyWith(
              color:
              colors.onSurfaceVariant,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EXPRESSIVE BOTTOM SHEET
// =============================================================================

Future<T?>
showFleckExpressiveBottomSheet<T>({
  required BuildContext context,
  Widget? child,
  WidgetBuilder? builder,
}) {
  assert(
  child != null ||
      builder != null,
  'Provide either child or builder.',
  );

  return showModalBottomSheet<T>(
    context: context,

    useSafeArea: true,

    isScrollControlled: true,

    backgroundColor:
    Colors.transparent,

    barrierColor:
    Colors.black.withValues(
      alpha: .32,
    ),

    elevation: 0,

    enableDrag: true,

    isDismissible: true,

    showDragHandle: false,

    builder: (
        sheetContext,
        ) {
      final content =
      builder != null
          ? builder(
        sheetContext,
      )
          : child!;

      return _FleckExpressiveBottomSheet(
        child: content,
      );
    },
  );
}

// =============================================================================
// BOTTOM SHEET CONTAINER
// =============================================================================

class _FleckExpressiveBottomSheet
    extends StatefulWidget {
  const _FleckExpressiveBottomSheet({
    required this.child,
  });

  final Widget child;

  @override
  State<_FleckExpressiveBottomSheet>
  createState() =>
      _FleckExpressiveBottomSheetState();
}

class _FleckExpressiveBottomSheetState
    extends State<
        _FleckExpressiveBottomSheet>
    with
        SingleTickerProviderStateMixin {
  late final AnimationController
  _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(
          vsync: this,

          duration:
          const Duration(
            milliseconds: 560,
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    final animation =
    CurvedAnimation(
      parent: _controller,
      curve:
      Curves.easeOutBack,
      reverseCurve:
      Curves.easeInCubic,
    );

    return AnimatedBuilder(
      animation: animation,

      builder: (
          context,
          child,
          ) {
        final value =
            animation.value;

        return Transform.translate(
          offset: Offset(
            0,
            36 * (1 - value),
          ),

          child: Transform.scale(
            alignment:
            Alignment.bottomCenter,

            scale:
            .965 +
                (.035 * value),

            child: Opacity(
              opacity:
              value.clamp(
                0,
                1,
              ),

              child: child,
            ),
          ),
        );
      },

      child: Material(
        color: colors
            .surfaceContainerLow,

        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(
            32.r,
          ),
        ),

        clipBehavior:
        Clip.antiAlias,

        child: Padding(
          padding:
          EdgeInsets.fromLTRB(
            20.w,
            9.h,
            20.w,
            20.h,
          ),

          child: Column(
            mainAxisSize:
            MainAxisSize.min,

            children: [
              Container(
                width: 38.w,
                height: 4.h,

                decoration:
                BoxDecoration(
                  color: colors
                      .onSurfaceVariant
                      .withValues(
                    alpha: .30,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    100.r,
                  ),
                ),
              ),

              SizedBox(
                height: 18.h,
              ),

              widget.child,
            ],
          ),
        ),
      ),
    );
  }
}