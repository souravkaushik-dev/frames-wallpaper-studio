import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/favorites/presentation/widgets/ffav_store.dart';

class FoliageProfileScreen extends StatefulWidget {
  const FoliageProfileScreen({
    super.key,
    this.onAbout,
  });

  final VoidCallback? onAbout;

  @override
  State<FoliageProfileScreen> createState() =>
      _FoliageProfileScreenState();
}

class _FoliageProfileScreenState
    extends State<FoliageProfileScreen> {
  String _name = 'Foliage';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs =
    await SharedPreferences.getInstance();

    final stored =
        prefs.getString(
          'foliage_user_name',
        ) ??
            '';

    if (!mounted) {
      return;
    }

    setState(() {
      _name = stored.trim().isEmpty
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

  int get _favoriteCount {
    return FleckFavoritesStore
        .urls
        .value
        .length;
  }

  @override
  Widget build(BuildContext context) {
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

        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),

        title: Text(
          'Profile',
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
      ),

      body: ValueListenableBuilder<Set<String>>(
        valueListenable:
        FleckFavoritesStore.urls,
        builder: (
            context,
            favorites,
            _,
            ) {
          return ListView(
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
              // ===============================================================
              // PROFILE HEADER
              // ===============================================================

              Container(
                padding:
                EdgeInsets.all(20.w),
                decoration:
                BoxDecoration(
                  color: colors
                      .surfaceContainerHigh,
                  borderRadius:
                  BorderRadius.circular(
                    28.r,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 68.w,
                      height: 68.w,
                      decoration:
                      BoxDecoration(
                        color: colors
                            .primaryContainer,
                        borderRadius:
                        BorderRadius.circular(
                          23.r,
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
                      width: 15.w,
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
                              FontWeight.w700,
                              letterSpacing:
                              -.7,
                            ),
                          ),

                          SizedBox(
                            height: 4.h,
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
                  ],
                ),
              ),

              SizedBox(
                height: 16.h,
              ),

              // ===============================================================
              // FAVORITES STAT
              // ===============================================================

              Container(
                padding:
                EdgeInsets.all(20.w),
                decoration:
                BoxDecoration(
                  color: colors
                      .surfaceContainerHigh,
                  borderRadius:
                  BorderRadius.circular(
                    24.r,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46.w,
                      height: 46.w,
                      decoration:
                      BoxDecoration(
                        color: colors
                            .primaryContainer,
                        borderRadius:
                        BorderRadius.circular(
                          16.r,
                        ),
                      ),
                      child: Icon(
                        Icons
                            .favorite_rounded,
                        size: 21.sp,
                        color: colors
                            .onPrimaryContainer,
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
                            '${favorites.length}',
                            style: theme
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                              fontWeight:
                              FontWeight.w800,
                              letterSpacing:
                              -.6,
                            ),
                          ),
                          Text(
                            favorites.length == 1
                                ? 'favorite wallpaper'
                                : 'favorite wallpapers',
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
                      size: 21.sp,
                      color: colors
                          .onSurfaceVariant
                          .withValues(
                        alpha: .45,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 24.h,
              ),

              // ===============================================================
              // FOLIAGE
              // ===============================================================

              _SectionLabel(
                text: 'FOLIAGE',
              ),

              _ProfileAction(
                icon:
                Icons.info_outline_rounded,
                title:
                'About Foliage',
                subtitle:
                'Learn about the app',
                onTap:
                widget.onAbout ??
                        () {
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (_) =>
                          const FoliageAboutScreen(),
                        ),
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
                  _showChangelog(context);
                },
              ),

              SizedBox(
                height: 16.h,
              ),

              // ===============================================================
              // FEEDBACK
              // ===============================================================

              _SectionLabel(
                text: 'FEEDBACK',
              ),

              _ProfileAction(
                icon:
                Icons.flag_outlined,
                title:
                'Report an issue',
                subtitle:
                'Tell us when something is wrong',
                onTap: () {
                  _openMail(
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
                Icons.lightbulb_outline_rounded,
                title:
                'Request a feature',
                subtitle:
                'Suggest something for Foliage',
                onTap: () {
                  _openMail(
                    subject:
                    'Foliage — Feature request',
                    body:
                    'Hi Foliage,\n\n'
                        'I would like to request a feature.\n\n'
                        'Feature idea:\n\n'
                        'Why would it be useful?\n\n',
                  );
                },
              ),

              SizedBox(
                height: 24.h,
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
                      alpha: .55,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openMail({
    required String subject,
    required String body,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path:
      'souravkaushik.dev@gmail.com',
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    // Use your existing mail helper here
    // if you already have one.
  }

  void _showChangelog(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final colors =
        theme.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor:
      Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          decoration:
          BoxDecoration(
            color: colors
                .surfaceContainerHigh,
            borderRadius:
            BorderRadius.vertical(
              top: Radius.circular(
                28.r,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding:
              EdgeInsets.fromLTRB(
                20.w,
                12.h,
                20.w,
                24.h,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 34.w,
                      height: 4.h,
                      decoration:
                      BoxDecoration(
                        color: colors
                            .onSurfaceVariant
                            .withValues(
                          alpha: .2,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          99.r,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 22.h,
                  ),

                  Text(
                    "What's new",
                    style: theme
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w700,
                      letterSpacing:
                      -.6,
                    ),
                  ),

                  SizedBox(
                    height: 4.h,
                  ),

                  Text(
                    'Latest Foliage updates',
                    style: theme
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: colors
                          .onSurfaceVariant,
                    ),
                  ),

                  SizedBox(
                    height: 22.h,
                  ),

                  const _ChangelogRow(
                    version: '1.0',
                    title:
                    'Welcome to Foliage',
                    description:
                    'Discover beautiful wallpapers and make your screen yours.',
                    latest: true,
                  ),

                  const _ChangelogRow(
                    version: '1.0',
                    title:
                    'Personalized experience',
                    description:
                    'Your chosen name makes Foliage feel more personal.',
                  ),

                  const _ChangelogRow(
                    version: '1.0',
                    title:
                    'Wallpaper tools',
                    description:
                    'Download wallpapers and apply them directly to your device.',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// ABOUT
// ============================================================================

class FoliageAboutScreen
    extends StatelessWidget {
  const FoliageAboutScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme =
    Theme.of(context);

    final colors =
        theme.colorScheme;

    return Scaffold(
      backgroundColor:
      colors.surface,

      appBar: AppBar(
        title:
        const Text('About Foliage'),
        backgroundColor:
        Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      body: ListView(
        physics:
        const BouncingScrollPhysics(),
        padding:
        EdgeInsets.fromLTRB(
          20.w,
          16.h,
          20.w,
          32.h,
        ),
        children: [
          Container(
            padding:
            EdgeInsets.all(24.w),
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
                  alignment:
                  Alignment.center,
                  child: Icon(
                    Icons
                        .eco_rounded,
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
                    letterSpacing:
                    -1,
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
            height: 20.h,
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
              color: colors
                  .onSurfaceVariant,
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
                'need access to your gallery or your personal '
                'files for this personalization.',
            style: theme
                .textTheme
                .bodyLarge
                ?.copyWith(
              color: colors
                  .onSurfaceVariant,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ACTION
// ============================================================================

class _ProfileAction
    extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme =
    Theme.of(context);

    final colors =
        theme.colorScheme;

    return ListTile(
      contentPadding:
      EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 3.h,
      ),

      leading: Container(
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
          icon,
          size: 20.sp,
          color:
          colors.onSurfaceVariant,
        ),
      ),

      title: Text(
        title,
        style: theme
            .textTheme
            .titleSmall
            ?.copyWith(
          fontWeight:
          FontWeight.w600,
        ),
      ),

      subtitle: Text(
        subtitle,
        style: theme
            .textTheme
            .bodySmall
            ?.copyWith(
          color:
          colors.onSurfaceVariant,
        ),
      ),

      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colors
            .onSurfaceVariant
            .withValues(
          alpha: .45,
        ),
      ),

      onTap: onTap,
    );
  }
}

// ============================================================================
// SECTION LABEL
// ============================================================================

class _SectionLabel
    extends StatelessWidget {
  const _SectionLabel({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
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
            alpha: .58,
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

// ============================================================================
// CHANGELOG ROW
// ============================================================================

class _ChangelogRow
    extends StatelessWidget {
  const _ChangelogRow({
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
  Widget build(BuildContext context) {
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
                  ? colors.primaryContainer
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