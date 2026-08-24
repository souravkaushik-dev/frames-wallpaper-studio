import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/previewscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api_servie/wallpaper_Api.dart';

class RecentPage extends StatefulWidget {
  final List<Wallpaper> recentWallpapers;

  const RecentPage({
    super.key,
    required this.recentWallpapers,
  });

  @override
  State<RecentPage> createState() =>
      _RecentPageState();
}

class _RecentPageState
    extends State<RecentPage>
    with SingleTickerProviderStateMixin {
  late List<Wallpaper> _wallpapers;

  bool _isRefreshing = false;

  // ============================================================
  // THEME
  // ============================================================

  bool get _isDark =>
      Theme.of(context).brightness ==
          Brightness.dark;

  Color get _background =>
      _isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground;

  Color get _surface =>
      _isDark
          ? AppColors.darkSurface
          : AppColors.lightSurface;

  Color get _surfaceSoft =>
      _isDark
          ? AppColors.darkSurfaceSoft
          : AppColors.lightSurfaceSoft;

  Color get _primary =>
      _isDark
          ? AppColors.darkPrimary
          : AppColors.lightPrimary;

  Color get _secondary =>
      _isDark
          ? AppColors.darkSecondary
          : AppColors.lightSecondary;

  Color get _muted =>
      _isDark
          ? AppColors.darkMuted
          : AppColors.lightMuted;

  Color get _divider =>
      _isDark
          ? AppColors.darkDivider
          : AppColors.lightDivider;

  Color get _accent =>
      AppColors.accent;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _wallpapers =
        _filterLastSevenDays(
          widget.recentWallpapers,
        );
  }

  @override
  void didUpdateWidget(
      covariant RecentPage oldWidget,
      ) {
    super.didUpdateWidget(
      oldWidget,
    );

    if (oldWidget.recentWallpapers !=
        widget.recentWallpapers) {
      _wallpapers =
          _filterLastSevenDays(
            widget.recentWallpapers,
          );
    }
  }

  // ============================================================
  // LAST 7 DAYS FILTER
  // ============================================================

  List<Wallpaper> _filterLastSevenDays(
      List<Wallpaper> wallpapers,
      ) {
    final now =
    DateTime.now();

    final sevenDaysAgo =
    now.subtract(
      const Duration(
        days: 7,
      ),
    );

    final filtered =
    wallpapers.where(
          (wallpaper) {
        final addedAt =
            wallpaper.addedAt;

        return !addedAt.isAfter(
          now,
        ) &&
            !addedAt.isBefore(
              sevenDaysAgo,
            );
      },
    ).toList();

    filtered.sort(
          (a, b) =>
          b.addedAt.compareTo(
            a.addedAt,
          ),
    );

    return filtered;
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    if (_isRefreshing) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(
      const Duration(
        milliseconds: 450,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _wallpapers =
          _filterLastSevenDays(
            widget.recentWallpapers,
          );

      _isRefreshing = false;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      _background,

      body:
      RefreshIndicator(
        color:
        _accent,

        backgroundColor:
        _surface,

        strokeWidth:
        2.2,

        onRefresh:
        _refresh,

        child:
        CustomScrollView(
          physics:
          const BouncingScrollPhysics(
            parent:
            AlwaysScrollableScrollPhysics(),
          ),

          slivers: [
            // ======================================================
            // HEADER
            // ======================================================

            SliverToBoxAdapter(
              child:
              Padding(
                padding:
                EdgeInsets.fromLTRB(
                  20.w,
                  22.h,
                  20.w,
                  0,
                ),

                child:
                Row(
                  children: [
                    _BackButton(
                      primary:
                      _primary,

                      surface:
                      _surface,

                      divider:
                      _divider,

                      accent:
                      _accent,
                    ),

                    SizedBox(
                      width:
                      15.w,
                    ),

                    Expanded(
                      child:
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [
                          Text(
                            'FRAMES',

                            style:
                            GoogleFonts.inter(
                              color:
                              _secondary,

                              fontSize:
                              8.sp,

                              fontWeight:
                              FontWeight.w800,

                              letterSpacing:
                              2.1,
                            ),
                          ),

                          SizedBox(
                            height:
                            3.h,
                          ),

                          Text(
                            'Recent',

                            style:
                            GoogleFonts.inter(
                              color:
                              _primary,

                              fontSize:
                              23.sp,

                              fontWeight:
                              FontWeight.w800,

                              letterSpacing:
                              -.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _CountBadge(
                      count:
                      _wallpapers.length,

                      primary:
                      _primary,

                      accent:
                      _accent,

                      divider:
                      _divider,
                    ),
                  ],
                ),
              ),
            ),

            // ======================================================
            // HERO
            // ======================================================

            SliverToBoxAdapter(
              child:
              Padding(
                padding:
                EdgeInsets.fromLTRB(
                  22.w,
                  44.h,
                  22.w,
                  28.h,
                ),

                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    Row(
                      children: [
                        Container(
                          width:
                          7.w,

                          height:
                          7.w,

                          decoration:
                          BoxDecoration(
                            color:
                            _accent,

                            shape:
                            BoxShape
                                .circle,
                          ),
                        ),

                        SizedBox(
                          width:
                          9.w,
                        ),

                        Text(
                          'FRESHLY ADDED',

                          style:
                          GoogleFonts.inter(
                            color:
                            _secondary,

                            fontSize:
                            8.sp,

                            fontWeight:
                            FontWeight.w800,

                            letterSpacing:
                            1.8,
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(
                      duration:
                      550.ms,
                    )
                        .moveX(
                      begin:
                      -18,

                      end:
                      0,

                      curve:
                      Curves
                          .easeOutExpo,
                    ),

                    SizedBox(
                      height:
                      13.h,
                    ),

                    Text(
                      'LAST 7 DAYS',

                      style:
                      GoogleFonts.bebasNeue(
                        color:
                        _primary,

                        fontSize:
                        76.sp,

                        height:
                        .76,

                        letterSpacing:
                        2.5,
                      ),
                    )
                        .animate()
                        .fadeIn(
                      delay:
                      100.ms,

                      duration:
                      850.ms,
                    )
                        .moveY(
                      begin:
                      60,

                      end:
                      0,

                      duration:
                      900.ms,

                      curve:
                      Curves
                          .easeOutExpo,
                    )
                        .scale(
                      begin:
                      const Offset(
                        .93,
                        .93,
                      ),

                      end:
                      const Offset(
                        1,
                        1,
                      ),

                      duration:
                      900.ms,

                      curve:
                      Curves
                          .easeOutExpo,
                    ),

                    SizedBox(
                      height:
                      15.h,
                    ),

                    Text(
                      _wallpapers.isEmpty
                          ? 'Nothing new has landed in Frames during the last seven days.'
                          : 'A cinematic collection of wallpapers added to Frames within the last seven days.',

                      style:
                      GoogleFonts.inter(
                        color:
                        _secondary,

                        fontSize:
                        13.5.sp,

                        height:
                        1.75,

                        fontWeight:
                        FontWeight.w500,
                      ),
                    )
                        .animate()
                        .fadeIn(
                      delay:
                      300.ms,

                      duration:
                      700.ms,
                    )
                        .moveY(
                      begin:
                      20,

                      end:
                      0,

                      curve:
                      Curves
                          .easeOutExpo,
                    ),

                    SizedBox(
                      height:
                      24.h,
                    ),

                    Row(
                      children: [
                        _HeroStat(
                          value:
                          '${_wallpapers.length}',

                          label:
                          'NEW',

                          primary:
                          _primary,

                          secondary:
                          _secondary,
                        ),

                        SizedBox(
                          width:
                          20.w,
                        ),

                        Container(
                          width:
                          1,

                          height:
                          28.h,

                          color:
                          _divider,
                        ),

                        SizedBox(
                          width:
                          20.w,
                        ),

                        _HeroStat(
                          value:
                          '7',

                          label:
                          'DAYS',

                          primary:
                          _primary,

                          secondary:
                          _secondary,
                        ),

                        SizedBox(
                          width:
                          20.w,
                        ),

                        Container(
                          width:
                          1,

                          height:
                          28.h,

                          color:
                          _divider,
                        ),

                        SizedBox(
                          width:
                          20.w,
                        ),

                        _HeroStat(
                          value:
                          '4K',

                          label:
                          'QUALITY',

                          primary:
                          _primary,

                          secondary:
                          _secondary,
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(
                      delay:
                      450.ms,

                      duration:
                      700.ms,
                    )
                        .moveY(
                      begin:
                      18,

                      end:
                      0,

                      curve:
                      Curves
                          .easeOutExpo,
                    ),
                  ],
                ),
              ),
            ),

            // ======================================================
            // EMPTY STATE
            // ======================================================

            if (_wallpapers.isEmpty)
              SliverFillRemaining(
                hasScrollBody:
                false,

                child:
                Padding(
                  padding:
                  EdgeInsets.fromLTRB(
                    20.w,
                    10.h,
                    20.w,
                    80.h,
                  ),

                  child:
                  _EmptyState(
                    primary:
                    _primary,

                    secondary:
                    _secondary,

                    muted:
                    _muted,

                    surface:
                    _surface,

                    divider:
                    _divider,

                    accent:
                    _accent,

                    onRefresh:
                    _refresh,
                  ),
                ),
              )

            // ======================================================
            // WALLPAPER GRID
            // ======================================================

            else
              SliverPadding(
                padding:
                EdgeInsets.fromLTRB(
                  18.w,
                  0,
                  18.w,
                  100.h,
                ),

                sliver:
                SliverGrid(
                  delegate:
                  SliverChildBuilderDelegate(
                        (
                        context,
                        index,
                        ) {
                      final wallpaper =
                      _wallpapers[index];

                      return _WallpaperCard(
                        wallpaper:
                        wallpaper,

                        index:
                        index,

                        primary:
                        _primary,

                        secondary:
                        _secondary,

                        divider:
                        _divider,

                        accent:
                        _accent,

                        surface:
                        _surface,

                        onTap:
                            () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                              const Duration(
                                milliseconds:
                                600,
                              ),
                              reverseTransitionDuration:
                              const Duration(
                                milliseconds:
                                450,
                              ),
                              pageBuilder:
                                  (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  ) {
                                return PreviewScreen(
                                  imageUrl:
                                  wallpaper.image,
                                  category:
                                  wallpaper.category,
                                );
                              },
                              transitionsBuilder:
                                  (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                  ) {
                                final curved =
                                CurvedAnimation(
                                  parent:
                                  animation,
                                  curve:
                                  Curves.easeOutCubic,
                                );

                                return FadeTransition(
                                  opacity:
                                  curved,
                                  child:
                                  ScaleTransition(
                                    scale:
                                    Tween<double>(
                                      begin:
                                      .975,
                                      end:
                                      1,
                                    ).animate(
                                      curved,
                                    ),
                                    child:
                                    child,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    childCount:
                    _wallpapers.length,
                  ),

                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                    2,

                    crossAxisSpacing:
                    13.w,

                    mainAxisSpacing:
                    15.h,

                    childAspectRatio:
                    .66,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// BACK BUTTON
// ==================================================================

class _BackButton
    extends StatefulWidget {
  final Color primary;
  final Color surface;
  final Color divider;
  final Color accent;

  const _BackButton({
    required this.primary,
    required this.surface,
    required this.divider,
    required this.accent,
  });

  @override
  State<_BackButton> createState() =>
      _BackButtonState();
}

class _BackButtonState
    extends State<_BackButton> {
  bool _pressed =
  false;

  @override
  Widget build(
      BuildContext context,
      ) {
    return GestureDetector(
      onTapDown:
          (_) {
        setState(() {
          _pressed =
          true;
        });
      },

      onTapCancel:
          () {
        setState(() {
          _pressed =
          false;
        });
      },

      onTapUp:
          (_) {
        setState(() {
          _pressed =
          false;
        });

        Navigator.pop(
          context,
        );
      },

      child:
      AnimatedScale(
        scale:
        _pressed
            ? .88
            : 1,

        duration:
        160.ms,

        child:
        AnimatedContainer(
          duration:
          220.ms,

          width:
          50.w,

          height:
          50.w,

          decoration:
          BoxDecoration(
            color:
            _pressed
                ? widget.accent
                .withOpacity(
              .07,
            )
                : widget.surface,

            shape:
            BoxShape.circle,

            border:
            Border.all(
              color:
              _pressed
                  ? widget.accent
                  .withOpacity(
                .2,
              )
                  : widget.divider,
            ),
          ),

          child:
          Icon(
            Icons
                .arrow_back_ios_new_rounded,

            color:
            widget.primary,

            size:
            17.sp,
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// COUNT BADGE
// ==================================================================

class _CountBadge
    extends StatelessWidget {
  final int count;
  final Color primary;
  final Color accent;
  final Color divider;

  const _CountBadge({
    required this.count,
    required this.primary,
    required this.accent,
    required this.divider,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      EdgeInsets.symmetric(
        horizontal:
        12.w,

        vertical:
        9.h,
      ),

      decoration:
      BoxDecoration(
        color:
        accent.withOpacity(
          .05,
        ),

        borderRadius:
        BorderRadius.circular(
          16.r,
        ),

        border:
        Border.all(
          color:
          divider,
        ),
      ),

      child:
      Row(
        mainAxisSize:
        MainAxisSize.min,

        children: [
          Container(
            width:
            6.w,

            height:
            6.w,

            decoration:
            BoxDecoration(
              color:
              accent,

              shape:
              BoxShape.circle,
            ),
          ),

          SizedBox(
            width:
            7.w,
          ),

          Text(
            '$count',

            style:
            GoogleFonts.inter(
              color:
              primary,

              fontSize:
              10.sp,

              fontWeight:
              FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// HERO STAT
// ==================================================================

class _HeroStat
    extends StatelessWidget {
  final String value;
  final String label;
  final Color primary;
  final Color secondary;

  const _HeroStat({
    required this.value,
    required this.label,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Text(
          value,

          style:
          GoogleFonts.bebasNeue(
            color:
            primary,

            fontSize:
            20.sp,

            height:
            .8,

            letterSpacing:
            1,
          ),
        ),

        SizedBox(
          height:
          5.h,
        ),

        Text(
          label,

          style:
          GoogleFonts.inter(
            color:
            secondary.withOpacity(
              .55,
            ),

            fontSize:
            6.5.sp,

            fontWeight:
            FontWeight.w800,

            letterSpacing:
            1.2,
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// WALLPAPER CARD
// ==================================================================

class _WallpaperCard
    extends StatefulWidget {
  final Wallpaper wallpaper;
  final int index;
  final Color primary;
  final Color secondary;
  final Color divider;
  final Color accent;
  final Color surface;
  final VoidCallback onTap;

  const _WallpaperCard({
    required this.wallpaper,
    required this.index,
    required this.primary,
    required this.secondary,
    required this.divider,
    required this.accent,
    required this.surface,
    required this.onTap,
  });

  @override
  State<_WallpaperCard> createState() =>
      _WallpaperCardState();
}

class _WallpaperCardState
    extends State<_WallpaperCard> {
  bool _pressed =
  false;

  @override
  Widget build(
      BuildContext context,
      ) {
    final wallpaper =
        widget.wallpaper;

    return GestureDetector(
      onTapDown:
          (_) {
        setState(() {
          _pressed =
          true;
        });
      },

      onTapCancel:
          () {
        setState(() {
          _pressed =
          false;
        });
      },

      onTapUp:
          (_) {
        setState(() {
          _pressed =
          false;
        });

        widget.onTap();
      },

      child:
      AnimatedScale(
        scale:
        _pressed
            ? .965
            : 1,

        duration:
        180.ms,

        curve:
        Curves.easeOutCubic,

        child:
        ClipRRect(
          borderRadius:
          BorderRadius.circular(
            27.r,
          ),

          child:
          Stack(
            fit:
            StackFit.expand,

            children: [
              // ====================================================
              // IMAGE
              // ====================================================

              Hero(
                tag:
                'recent_${wallpaper.id}',

                child:
                Image.network(
                  wallpaper.image,

                  fit:
                  BoxFit.cover,

                  filterQuality:
                  FilterQuality.medium,

                  errorBuilder:
                      (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return Container(
                      color:
                      widget.surface,

                      alignment:
                      Alignment.center,

                      child:
                      Icon(
                        Icons
                            .image_not_supported_outlined,

                        color:
                        widget.secondary
                            .withOpacity(
                          .5,
                        ),

                        size:
                        28.sp,
                      ),
                    );
                  },

                  loadingBuilder:
                      (
                      context,
                      child,
                      progress,
                      ) {
                    if (progress ==
                        null) {
                      return child;
                    }

                    return Container(
                      color:
                      widget.surface,

                      alignment:
                      Alignment.center,

                      child:
                      SizedBox(
                        width:
                        20.w,

                        height:
                        20.w,

                        child:
                        CircularProgressIndicator(
                          strokeWidth:
                          1.6,

                          value:
                          progress
                              .expectedTotalBytes !=
                              null
                              ? progress
                              .cumulativeBytesLoaded /
                              progress
                                  .expectedTotalBytes!
                              : null,

                          color:
                          widget.accent,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ====================================================
              // CINEMATIC GRADIENT
              // ====================================================

              DecoratedBox(
                decoration:
                BoxDecoration(
                  gradient:
                  LinearGradient(
                    begin:
                    Alignment.topCenter,

                    end:
                    Alignment.bottomCenter,

                    stops: const [
                      0,
                      .45,
                      1,
                    ],

                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black
                          .withOpacity(
                        .72,
                      ),
                    ],
                  ),
                ),
              ),

              // ====================================================
              // TOP LABEL
              // ====================================================

              Positioned(
                top:
                12.h,

                left:
                12.w,

                child:
                Container(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal:
                    10.w,

                    vertical:
                    6.h,
                  ),

                  decoration:
                  BoxDecoration(
                    color:
                    Colors.black
                        .withOpacity(
                      .28,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      13.r,
                    ),

                    border:
                    Border.all(
                      color:
                      Colors.white
                          .withOpacity(
                        .12,
                      ),
                    ),
                  ),

                  child:
                  Text(
                    'NEW',

                    style:
                    GoogleFonts.inter(
                      color:
                      Colors.white,

                      fontSize:
                      7.sp,

                      fontWeight:
                      FontWeight.w800,

                      letterSpacing:
                      1.2,
                    ),
                  ),
                ),
              ),

              // ====================================================
              // BOTTOM CONTENT
              // ====================================================

              Positioned(
                left:
                14.w,

                right:
                14.w,

                bottom:
                14.h,

                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    Text(
                      wallpaper.title,

                      maxLines:
                      1,

                      overflow:
                      TextOverflow.ellipsis,

                      style:
                      GoogleFonts.inter(
                        color:
                        Colors.white,

                        fontSize:
                        13.sp,

                        fontWeight:
                        FontWeight.w800,

                        letterSpacing:
                        -.2,
                      ),
                    ),

                    SizedBox(
                      height:
                      4.h,
                    ),

                    Text(
                      wallpaper.category,

                      maxLines:
                      1,

                      overflow:
                      TextOverflow.ellipsis,

                      style:
                      GoogleFonts.inter(
                        color:
                        Colors.white
                            .withOpacity(
                          .68,
                        ),

                        fontSize:
                        8.sp,

                        fontWeight:
                        FontWeight.w600,

                        letterSpacing:
                        .6,
                      ),
                    ),

                    SizedBox(
                      height:
                      9.h,
                    ),

                    Row(
                      children: [
                        _GlassTag(
                          text:
                          '4K',

                          accent:
                          widget.accent,
                        ),

                        SizedBox(
                          width:
                          6.w,
                        ),

                        _GlassTag(
                          text:
                          _relativeDate(
                            wallpaper.addedAt,
                          ),

                          accent:
                          widget.accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
      delay:
      Duration(
        milliseconds:
        70 *
            (widget.index %
                8),
      ),

      duration:
      650.ms,
    )
        .moveY(
      begin:
      35,

      end:
      0,

      duration:
      700.ms,

      curve:
      Curves.easeOutExpo,
    )
        .scale(
      begin:
      const Offset(
        .94,
        .94,
      ),

      end:
      const Offset(
        1,
        1,
      ),

      duration:
      700.ms,

      curve:
      Curves.easeOutExpo,
    );
  }

  String _relativeDate(
      DateTime date,
      ) {
    final now =
    DateTime.now();

    final difference =
    now.difference(date);

    if (difference.inDays <=
        0) {
      if (difference.inHours <=
          0) {
        return 'JUST NOW';
      }

      return '${difference.inHours}H AGO';
    }

    if (difference.inDays ==
        1) {
      return 'YESTERDAY';
    }

    return '${difference.inDays}D AGO';
  }
}

// ==================================================================
// GLASS TAG
// ==================================================================

class _GlassTag
    extends StatelessWidget {
  final String text;
  final Color accent;

  const _GlassTag({
    required this.text,
    required this.accent,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      EdgeInsets.symmetric(
        horizontal:
        8.w,

        vertical:
        5.h,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.black
            .withOpacity(
          .27,
        ),

        borderRadius:
        BorderRadius.circular(
          10.r,
        ),

        border:
        Border.all(
          color:
          Colors.white
              .withOpacity(
            .11,
          ),
        ),
      ),

      child:
      Text(
        text,

        style:
        GoogleFonts.inter(
          color:
          Colors.white
              .withOpacity(
            .9,
          ),

          fontSize:
          6.5.sp,

          fontWeight:
          FontWeight.w800,

          letterSpacing:
          .7,
        ),
      ),
    );
  }
}

// ==================================================================
// EMPTY STATE
// ==================================================================

class _EmptyState
    extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final Color muted;
  final Color surface;
  final Color divider;
  final Color accent;
  final VoidCallback onRefresh;

  const _EmptyState({
    required this.primary,
    required this.secondary,
    required this.muted,
    required this.surface,
    required this.divider,
    required this.accent,
    required this.onRefresh,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Center(
      child:
      Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          // ========================================================
          // ICON
          // ========================================================

          Container(
            width:
            82.w,

            height:
            82.w,

            decoration:
            BoxDecoration(
              color:
              surface,

              shape:
              BoxShape.circle,

              border:
              Border.all(
                color:
                divider,
              ),
            ),

            child:
            Stack(
              alignment:
              Alignment.center,

              children: [
                Icon(
                  Icons
                      .auto_awesome_outlined,

                  color:
                  muted.withOpacity(
                    .55,
                  ),

                  size:
                  32.sp,
                ),

                Positioned(
                  top:
                  20.h,

                  right:
                  20.w,

                  child:
                  Container(
                    width:
                    7.w,

                    height:
                    7.w,

                    decoration:
                    BoxDecoration(
                      color:
                      accent,

                      shape:
                      BoxShape
                          .circle,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate(
            onPlay:
                (controller) =>
                controller.repeat(
                  reverse:
                  true,
                ),
          )
              .scale(
            begin:
            const Offset(
              .94,
              .94,
            ),

            end:
            const Offset(
              1.04,
              1.04,
            ),

            duration:
            1600.ms,

            curve:
            Curves
                .easeInOut,
          ),

          SizedBox(
            height:
            24.h,
          ),

          Text(
            'NOTHING NEW YET',

            textAlign:
            TextAlign.center,

            style:
            GoogleFonts.bebasNeue(
              color:
              primary,

              fontSize:
              34.sp,

              letterSpacing:
              1.5,
            ),
          )
              .animate()
              .fadeIn(
            duration:
            600.ms,
          )
              .moveY(
            begin:
            20,

            end:
            0,

            curve:
            Curves
                .easeOutExpo,
          ),

          SizedBox(
            height:
            8.h,
          ),

          Padding(
            padding:
            EdgeInsets.symmetric(
              horizontal:
              40.w,
            ),

            child:
            Text(
              'No wallpapers have been added to Frames during the last seven days.',

              textAlign:
              TextAlign.center,

              style:
              GoogleFonts.inter(
                color:
                secondary,

                fontSize:
                12.sp,

                height:
                1.65,

                fontWeight:
                FontWeight.w500,
              ),
            ),
          ),

          SizedBox(
            height:
            22.h,
          ),

          GestureDetector(
            onTap:
            onRefresh,

            child:
            Container(
              padding:
              EdgeInsets.symmetric(
                horizontal:
                17.w,

                vertical:
                11.h,
              ),

              decoration:
              BoxDecoration(
                color:
                accent.withOpacity(
                  .06,
                ),

                borderRadius:
                BorderRadius.circular(
                  16.r,
                ),

                border:
                Border.all(
                  color:
                  divider,
                ),
              ),

              child:
              Row(
                mainAxisSize:
                MainAxisSize.min,

                children: [
                  Icon(
                    Icons
                        .refresh_rounded,

                    color:
                    primary,

                    size:
                    16.sp,
                  ),

                  SizedBox(
                    width:
                    7.w,
                  ),

                  Text(
                    'CHECK AGAIN',

                    style:
                    GoogleFonts.inter(
                      color:
                      primary,

                      fontSize:
                      8.sp,

                      fontWeight:
                      FontWeight.w800,

                      letterSpacing:
                      1,
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(
            delay:
            400.ms,

            duration:
            500.ms,
          )
              .moveY(
            begin:
            12,

            end:
            0,

            curve:
            Curves
                .easeOutExpo,
          ),
        ],
      ),
    );
  }
}