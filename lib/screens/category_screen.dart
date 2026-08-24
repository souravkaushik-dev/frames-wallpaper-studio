import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/previewscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryScreen extends StatelessWidget {
  final String title;
  final List<String> wallpapers;

  const CategoryScreen({
    super.key,
    required this.title,
    required this.wallpapers,
  });

  // ============================================================
  // THEME COLORS
  // ============================================================

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness ==
        Brightness.dark;
  }

  Color _background(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkBackground
        : AppColors.lightBackground;
  }

  Color _surface(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkSurface
        : AppColors.lightSurface;
  }

  Color _surfaceSoft(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkSurfaceSoft
        : AppColors.lightSurfaceSoft;
  }

  Color _primary(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;
  }

  Color _secondary(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;
  }

  Color _muted(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkMuted
        : AppColors.lightMuted;
  }

  Color _divider(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkDivider
        : AppColors.lightDivider;
  }

  Color get _accent => AppColors.accent;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bg =
    _background(context);

    final text =
    _primary(context);

    final secondary =
    _secondary(context);

    final muted =
    _muted(context);

    final divider =
    _divider(context);

    final heights = [
      360.h,
      280.h,
      410.h,
      315.h,
    ];

    return Scaffold(
      backgroundColor: bg,

      body: CustomScrollView(
        physics:
        const BouncingScrollPhysics(
          parent:
          AlwaysScrollableScrollPhysics(),
        ),

        slivers: [
          // ========================================================
          // HEADER
          // ========================================================

          SliverToBoxAdapter(
            child: Padding(
              padding:
              EdgeInsets.fromLTRB(
                20.w,
                62.h,
                20.w,
                10.h,
              ),

              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.center,

                children: [
                  _BackButton(
                    color: text,
                    accent: _accent,
                  ),

                  SizedBox(
                    width: 18.w,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,

                              decoration:
                              BoxDecoration(
                                color:
                                _accent,
                                shape:
                                BoxShape.circle,
                              ),
                            ),

                            SizedBox(
                              width: 8.w,
                            ),

                            Text(
                              'COLLECTION',

                              style:
                              GoogleFonts.inter(
                                color:
                                secondary,
                                fontSize:
                                9.sp,
                                fontWeight:
                                FontWeight.w800,
                                letterSpacing:
                                2,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: 5.h,
                        ),

                        Text(
                          title.toUpperCase(),

                          maxLines: 1,

                          overflow:
                          TextOverflow.ellipsis,

                          style:
                          GoogleFonts.bebasNeue(
                            color:
                            text,
                            fontSize:
                            44.sp,
                            height:
                            .82,
                            letterSpacing:
                            2.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // NUMBER
                  // ==================================================

                  Container(
                    width: 44.w,
                    height: 44.w,

                    decoration:
                    BoxDecoration(
                      color:
                      _accent.withOpacity(
                        .06,
                      ),

                      shape:
                      BoxShape.circle,

                      border:
                      Border.all(
                        color:
                        divider,
                      ),
                    ),

                    child: Center(
                      child: Text(
                        wallpapers.length
                            .toString()
                            .padLeft(
                          2,
                          '0',
                        ),

                        style:
                        GoogleFonts.inter(
                          color:
                          text,
                          fontSize:
                          10.sp,
                          fontWeight:
                          FontWeight.w800,
                          letterSpacing:
                          1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(
              duration:
              const Duration(
                milliseconds: 600,
              ),
            )
                .moveY(
              begin: -25,
              end: 0,
              curve:
              Curves.easeOutExpo,
            ),
          ),

          // ========================================================
          // CINEMATIC INTRO
          // ========================================================

          SliverToBoxAdapter(
            child: Padding(
              padding:
              EdgeInsets.fromLTRB(
                24.w,
                22.h,
                24.w,
                30.h,
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    'A VISUAL WORLD',

                    style:
                    GoogleFonts.bebasNeue(
                      color:
                      text,
                      fontSize:
                      48.sp,
                      height:
                      .82,
                      letterSpacing:
                      2,
                    ),
                  )
                      .animate()
                      .fadeIn(
                    delay:
                    const Duration(
                      milliseconds: 180,
                    ),
                    duration:
                    const Duration(
                      milliseconds: 800,
                    ),
                  )
                      .moveY(
                    begin: 45,
                    end: 0,
                    duration:
                    const Duration(
                      milliseconds: 850,
                    ),
                    curve:
                    Curves.easeOutExpo,
                  ),

                  SizedBox(
                    height: 12.h,
                  ),

                  SizedBox(
                    width: 335.w,

                    child: Text(
                      '${wallpapers.length} curated wallpapers crafted around the atmosphere, mood and visual identity of $title.',

                      style:
                      GoogleFonts.inter(
                        color:
                        secondary,
                        fontSize:
                        13.sp,
                        height:
                        1.7,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                    delay:
                    const Duration(
                      milliseconds: 320,
                    ),
                    duration:
                    const Duration(
                      milliseconds: 700,
                    ),
                  )
                      .moveY(
                    begin: 20,
                    end: 0,
                    curve:
                    Curves.easeOutExpo,
                  ),

                  SizedBox(
                    height: 22.h,
                  ),

                  // ==================================================
                  // META ROW
                  // ==================================================

                  Row(
                    children: [
                      _MetaItem(
                        number:
                        wallpapers.length
                            .toString()
                            .padLeft(
                          2,
                          '0',
                        ),
                        label:
                        'WALLPAPERS',
                        color:
                        text,
                      ),

                      SizedBox(
                        width: 20.w,
                      ),

                      _MetaDivider(
                        color:
                        divider,
                      ),

                      SizedBox(
                        width: 20.w,
                      ),

                      _MetaItem(
                        number:
                        '4K',
                        label:
                        'QUALITY',
                        color:
                        text,
                      ),

                      SizedBox(
                        width: 20.w,
                      ),

                      _MetaDivider(
                        color:
                        divider,
                      ),

                      SizedBox(
                        width: 20.w,
                      ),

                      _MetaItem(
                        number:
                        '∞',
                        label:
                        'MOOD',
                        color:
                        text,
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(
                    delay:
                    const Duration(
                      milliseconds: 450,
                    ),
                  )
                      .moveY(
                    begin: 20,
                    end: 0,
                    curve:
                    Curves.easeOutExpo,
                  ),
                ],
              ),
            ),
          ),

          // ========================================================
          // EMPTY
          // ========================================================

          if (wallpapers.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(
                text:
                text,
                secondary:
                secondary,
                accent:
                _accent,
              ),
            )

          // ========================================================
          // WALLPAPER GRID
          // ========================================================

          else
            SliverPadding(
              padding:
              EdgeInsets.symmetric(
                horizontal: 18.w,
              ),

              sliver:
              SliverMasonryGrid.count(
                crossAxisCount: 2,

                mainAxisSpacing:
                14.h,

                crossAxisSpacing:
                14.w,

                childCount:
                wallpapers.length,

                itemBuilder:
                    (
                    context,
                    index,
                    ) {
                  final image =
                  wallpapers[index];

                  return _CinematicWallpaperCard(
                    image:
                    image,

                    index:
                    index,

                    title:
                    title,

                    height:
                    heights[
                    index % 4],

                    accent:
                    _accent,

                    onTap:
                        () {
                      _openPreview(
                        context,
                        image,
                      );
                    },
                  );
                },
              ),
            ),

          // ========================================================
          // END
          // ========================================================

          SliverToBoxAdapter(
            child: Padding(
              padding:
              EdgeInsets.symmetric(
                vertical: 80.h,
              ),

              child: Column(
                children: [
                  Container(
                    width: 34.w,
                    height: 1,
                    color:
                    divider,
                  ),

                  SizedBox(
                    height: 12.h,
                  ),

                  Text(
                    'END OF COLLECTION',

                    style:
                    GoogleFonts.inter(
                      color:
                      muted.withOpacity(
                        .55,
                      ),
                      fontSize:
                      8.sp,
                      fontWeight:
                      FontWeight.w800,
                      letterSpacing:
                      2.2,
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

  // ============================================================
  // PREVIEW
  // ============================================================

  void _openPreview(
      BuildContext context,
      String image,
      ) {
    HapticFeedback
        .selectionClick();

    Navigator.push(
      context,

      PageRouteBuilder(
        transitionDuration:
        const Duration(
          milliseconds: 850,
        ),

        reverseTransitionDuration:
        const Duration(
          milliseconds: 600,
        ),

        pageBuilder:
            (
            _,
            animation,
            __,
            ) {
          return PreviewScreen(
            imageUrl:
            image,
            category:
            title,
          );
        },

        transitionsBuilder:
            (
            _,
            animation,
            __,
            child,
            ) {
          final curved =
          CurvedAnimation(
            parent:
            animation,
            curve:
            Curves.easeOutExpo,
          );

          return FadeTransition(
            opacity:
            curved,

            child:
            ScaleTransition(
              scale:
              Tween<double>(
                begin:
                .94,
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
  }
}

// ==================================================================
// BACK BUTTON
// ==================================================================

class _BackButton
    extends StatefulWidget {
  final Color color;
  final Color accent;

  const _BackButton({
    required this.color,
    required this.accent,
  });

  @override
  State<_BackButton> createState() =>
      _BackButtonState();
}

class _BackButtonState
    extends State<_BackButton> {
  bool pressed = false;

  @override
  Widget build(
      BuildContext context,
      ) {
    return GestureDetector(
      onTapDown:
          (_) {
        setState(() {
          pressed = true;
        });
      },

      onTapCancel:
          () {
        setState(() {
          pressed = false;
        });
      },

      onTapUp:
          (_) {
        setState(() {
          pressed = false;
        });

        HapticFeedback
            .selectionClick();

        Navigator.pop(context);
      },

      child:
      AnimatedScale(
        scale:
        pressed ? .88 : 1,

        duration:
        const Duration(
          milliseconds: 160,
        ),

        curve:
        Curves.easeOutCubic,

        child:
        AnimatedContainer(
          duration:
          const Duration(
            milliseconds: 250,
          ),

          width: 52.w,
          height: 52.w,

          decoration:
          BoxDecoration(
            shape:
            BoxShape.circle,

            color:
            widget.accent.withOpacity(
              pressed ? .10 : .04,
            ),

            border:
            Border.all(
              color:
              pressed
                  ? widget.accent
                  .withOpacity(
                .25,
              )
                  : widget.color
                  .withOpacity(
                .12,
              ),
            ),
          ),

          child:
          Icon(
            Icons
                .arrow_back_ios_new_rounded,

            color:
            widget.color,

            size:
            18.sp,
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// META ITEM
// ==================================================================

class _MetaItem
    extends StatelessWidget {
  final String number;
  final String label;
  final Color color;

  const _MetaItem({
    required this.number,
    required this.label,
    required this.color,
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
          number,

          style:
          GoogleFonts.bebasNeue(
            color:
            color,
            fontSize:
            25.sp,
            height:
            .8,
            letterSpacing:
            1,
          ),
        ),

        SizedBox(
          height: 5.h,
        ),

        Text(
          label,

          style:
          GoogleFonts.inter(
            color:
            color.withOpacity(
              .42,
            ),
            fontSize:
            7.sp,
            fontWeight:
            FontWeight.w800,
            letterSpacing:
            1.4,
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// META DIVIDER
// ==================================================================

class _MetaDivider
    extends StatelessWidget {
  final Color color;

  const _MetaDivider({
    required this.color,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: 1,
      height: 26.h,
      color: color,
    );
  }
}

// ==================================================================
// CINEMATIC WALLPAPER CARD
// ==================================================================

class _CinematicWallpaperCard
    extends StatefulWidget {
  final String image;
  final int index;
  final String title;
  final double height;
  final Color accent;
  final VoidCallback onTap;

  const _CinematicWallpaperCard({
    required this.image,
    required this.index,
    required this.title,
    required this.height,
    required this.accent,
    required this.onTap,
  });

  @override
  State<
      _CinematicWallpaperCard>
  createState() =>
      _CinematicWallpaperCardState();
}

class _CinematicWallpaperCardState
    extends State<
        _CinematicWallpaperCard>
    with
        SingleTickerProviderStateMixin {
  bool pressed = false;

  late final AnimationController
  _motionController;

  @override
  void initState() {
    super.initState();

    _motionController =
    AnimationController(
      vsync:
      this,

      duration:
      const Duration(
        seconds: 8,
      ),
    )..repeat(
      reverse:
      true,
    );
  }

  @override
  void dispose() {
    _motionController.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final fallback =
    isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final muted =
    isDark
        ? AppColors.darkMuted
        : AppColors.lightMuted;

    return GestureDetector(
      onTapDown:
          (_) {
        setState(() {
          pressed = true;
        });
      },

      onTapCancel:
          () {
        setState(() {
          pressed = false;
        });
      },

      onTapUp:
          (_) {
        setState(() {
          pressed = false;
        });

        widget.onTap();
      },

      child:
      AnimatedScale(
        scale:
        pressed ? .95 : 1,

        duration:
        const Duration(
          milliseconds: 180,
        ),

        curve:
        Curves.easeOutCubic,

        child:
        Hero(
          tag:
          widget.image,

          child:
          ClipRRect(
            borderRadius:
            BorderRadius.circular(
              34.r,
            ),

            child:
            SizedBox(
              height:
              widget.height,

              child:
              Stack(
                fit:
                StackFit.expand,

                children: [
                  // ==================================================
                  // KEN BURNS IMAGE
                  // ==================================================

                  AnimatedBuilder(
                    animation:
                    _motionController,

                    builder:
                        (
                        context,
                        child,
                        ) {
                      final value =
                          _motionController
                              .value;

                      final scale =
                          1.045 +
                              (value * .045);

                      final dx =
                          (value - .5) *
                              7;

                      final dy =
                          (value - .5) *
                              5;

                      return Transform
                          .translate(
                        offset:
                        Offset(
                          dx,
                          dy,
                        ),

                        child:
                        Transform.scale(
                          scale:
                          scale,

                          child:
                          child,
                        ),
                      );
                    },

                    child:
                    Image.network(
                      widget.image,

                      fit:
                      BoxFit.cover,

                      filterQuality:
                      FilterQuality.high,

                      errorBuilder:
                          (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return Container(
                          color:
                          fallback,

                          alignment:
                          Alignment.center,

                          child:
                          Icon(
                            Icons
                                .broken_image_outlined,

                            color:
                            muted,

                            size:
                            28.sp,
                          ),
                        );
                      },
                    ),
                  ),

                  // ==================================================
                  // BOTTOM CINEMATIC GRADIENT
                  // ==================================================

                  const Positioned.fill(
                    child:
                    IgnorePointer(
                      child:
                      DecoratedBox(
                        decoration:
                        BoxDecoration(
                          gradient:
                          LinearGradient(
                            begin:
                            Alignment.topCenter,

                            end:
                            Alignment.bottomCenter,

                            stops: [
                              0,
                              .28,
                              .62,
                              1,
                            ],

                            colors: [
                              Color(
                                0x14000000,
                              ),

                              Colors
                                  .transparent,

                              Color(
                                0x40000000,
                              ),

                              Color(
                                0xF0000000,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // TOP VIGNETTE
                  // ==================================================

                  const Positioned.fill(
                    child:
                    IgnorePointer(
                      child:
                      DecoratedBox(
                        decoration:
                        BoxDecoration(
                          gradient:
                          LinearGradient(
                            begin:
                            Alignment.topCenter,

                            end:
                            Alignment.center,

                            colors: [
                              Color(
                                0x38000000,
                              ),

                              Colors
                                  .transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // INDEX
                  // ==================================================

                  Positioned(
                    top: 17.h,
                    left: 17.w,

                    child:
                    Row(
                      children: [
                        Text(
                          (widget.index +
                              1)
                              .toString()
                              .padLeft(
                            2,
                            '0',
                          ),

                          style:
                          GoogleFonts.inter(
                            color:
                            Colors.white
                                .withOpacity(
                              .72,
                            ),

                            fontSize:
                            9.sp,

                            fontWeight:
                            FontWeight.w800,

                            letterSpacing:
                            1.8,
                          ),
                        ),

                        SizedBox(
                          width: 8.w,
                        ),

                        AnimatedContainer(
                          duration:
                          const Duration(
                            milliseconds:
                            350,
                          ),

                          width:
                          pressed
                              ? 28.w
                              : 18.w,

                          height: 1,

                          color:
                          widget.accent
                              .withOpacity(
                            pressed
                                ? .85
                                : .45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // TOP RIGHT ACCENT
                  // ==================================================

                  Positioned(
                    top: 18.h,
                    right: 18.w,

                    child:
                    AnimatedContainer(
                      duration:
                      const Duration(
                        milliseconds: 400,
                      ),

                      width:
                      pressed
                          ? 11.w
                          : 7.w,

                      height:
                      pressed
                          ? 11.w
                          : 7.w,

                      decoration:
                      BoxDecoration(
                        color:
                        widget.accent,

                        shape:
                        BoxShape.circle,
                      ),
                    ),
                  ),

                  // ==================================================
                  // CONTENT
                  // ==================================================

                  Positioned(
                    left: 18.w,
                    right: 18.w,
                    bottom: 18.h,

                    child:
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [
                        Row(
                          children: [
                            Container(
                              width: 5.w,
                              height: 5.w,

                              decoration:
                              BoxDecoration(
                                color:
                                widget.accent,
                                shape:
                                BoxShape.circle,
                              ),
                            ),

                            SizedBox(
                              width: 7.w,
                            ),

                            Expanded(
                              child:
                              Text(
                                '4K • ${widget.title.toUpperCase()}',

                                maxLines: 1,

                                overflow:
                                TextOverflow
                                    .ellipsis,

                                style:
                                GoogleFonts.inter(
                                  color:
                                  Colors.white.withOpacity(
                                    .70,
                                  ),

                                  fontSize:
                                  8.sp,

                                  fontWeight:
                                  FontWeight.w800,

                                  letterSpacing:
                                  1.2,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: 8.h,
                        ),

                        Text(
                          'FRAME ${(widget.index + 1).toString().padLeft(2, '0')}',

                          style:
                          GoogleFonts.bebasNeue(
                            color:
                            Colors.white,

                            fontSize:
                            40.sp,

                            height:
                            .8,

                            letterSpacing:
                            1.8,
                          ),
                        ),

                        SizedBox(
                          height: 11.h,
                        ),

                        Row(
                          children: [
                            Expanded(
                              child:
                              AnimatedContainer(
                                duration:
                                const Duration(
                                  milliseconds:
                                  500,
                                ),

                                height: 1,

                                color:
                                widget.accent
                                    .withOpacity(
                                  pressed
                                      ? .75
                                      : .32,
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 10.w,
                            ),

                            AnimatedRotation(
                              turns:
                              pressed
                                  ? .12
                                  : 0,

                              duration:
                              const Duration(
                                milliseconds:
                                300,
                              ),

                              child:
                              Icon(
                                Icons
                                    .arrow_outward_rounded,

                                color:
                                Colors.white
                                    .withOpacity(
                                  .78,
                                ),

                                size:
                                15.sp,
                              ),
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
        ),
      ),
    )
        .animate()
        .fadeIn(
      delay:
      Duration(
        milliseconds:
        widget.index * 100,
      ),

      duration:
      const Duration(
        milliseconds: 900,
      ),
    )
        .moveY(
      begin: 90,
      end: 0,

      delay:
      Duration(
        milliseconds:
        widget.index * 100,
      ),

      duration:
      const Duration(
        milliseconds: 950,
      ),

      curve:
      Curves.easeOutExpo,
    )
        .scale(
      begin:
      const Offset(
        .90,
        .90,
      ),

      end:
      const Offset(
        1,
        1,
      ),

      duration:
      const Duration(
        milliseconds: 950,
      ),

      curve:
      Curves.easeOutExpo,
    )
        .blurXY(
      begin: 4,
      end: 0,

      duration:
      const Duration(
        milliseconds: 800,
      ),
    );
  }
}

// ==================================================================
// EMPTY STATE
// ==================================================================

class _EmptyState
    extends StatelessWidget {
  final Color text;
  final Color secondary;
  final Color accent;

  const _EmptyState({
    required this.text,
    required this.secondary,
    required this.accent,
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
          SizedBox(
            width: 110.w,
            height: 110.w,

            child:
            Stack(
              alignment:
              Alignment.center,

              children: [
                Container(
                  width: 110.w,
                  height: 110.w,

                  decoration:
                  BoxDecoration(
                    shape:
                    BoxShape.circle,

                    color:
                    accent.withOpacity(
                      .035,
                    ),

                    border:
                    Border.all(
                      color:
                      accent.withOpacity(
                        .14,
                      ),
                    ),
                  ),
                ),

                Icon(
                  Icons
                      .wallpaper_rounded,

                  color:
                  accent.withOpacity(
                    .55,
                  ),

                  size:
                  42.sp,
                ),
              ],
            ),
          )
              .animate(
            onPlay:
                (controller) =>
                controller.repeat(
                  reverse: true,
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
            const Duration(
              milliseconds: 1800,
            ),

            curve:
            Curves.easeInOut,
          ),

          SizedBox(
            height: 28.h,
          ),

          Text(
            'NO WALLPAPERS',

            style:
            GoogleFonts.bebasNeue(
              color:
              text,

              fontSize:
              34.sp,

              letterSpacing:
              2,
            ),
          ),

          SizedBox(
            height: 10.h,
          ),

          Text(
            'New wallpapers will appear here soon.',

            style:
            GoogleFonts.inter(
              color:
              secondary,

              fontSize:
              13.sp,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
      duration:
      const Duration(
        milliseconds: 800,
      ),
    )
        .moveY(
      begin: 30,
      end: 0,
      curve:
      Curves.easeOutExpo,
    );
  }
}