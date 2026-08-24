import 'dart:async';

import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/previewscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryScreen extends StatefulWidget {
  final String title;
  final List<String> wallpapers;

  const CategoryScreen({
    super.key,
    required this.title,
    required this.wallpapers,
  });

  @override
  State<CategoryScreen> createState() =>
      _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver {
  // ============================================================
  // HERO
  // ============================================================

  late final PageController _heroController;
  late final AnimationController _heroMotionController;

  Timer? _heroTimer;

  int _heroIndex = 0;

  bool _screenActive = true;
  bool _backPressed = false;

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

    WidgetsBinding.instance
        .addObserver(this);

    _heroController =
        PageController();

    _heroMotionController =
    AnimationController(
      vsync: this,
      duration:
      const Duration(seconds: 7),
    )..repeat(reverse: true);

    _startHeroRotation();
  }

  // ============================================================
  // APP LIFECYCLE
  // ============================================================

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    _screenActive =
        state ==
            AppLifecycleState.resumed;

    if (_screenActive) {
      _startHeroRotation();
    } else {
      _heroTimer?.cancel();
      _heroTimer = null;
    }
  }

  // ============================================================
  // HERO AUTO ROTATION
  // ============================================================

  void _startHeroRotation() {
    _heroTimer?.cancel();
    _heroTimer = null;

    if (widget.wallpapers.length <= 1) {
      return;
    }

    if (!_screenActive) {
      return;
    }

    _heroTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) {
        if (!mounted ||
            !_screenActive ||
            !_heroController.hasClients) {
          return;
        }

        final nextIndex =
            (_heroIndex + 1) %
                widget.wallpapers.length;

        _heroController.animateToPage(
          nextIndex,
          duration:
          const Duration(
            milliseconds: 1200,
          ),
          curve:
          Curves.easeInOutCubic,
        );
      },
    );
  }

  // ============================================================
  // HERO PAGE CHANGE
  // ============================================================

  void _onHeroChanged(
      int index,
      ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _heroIndex = index;
    });

    _heroMotionController
        .forward(from: 0);
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    WidgetsBinding.instance
        .removeObserver(this);

    _heroTimer?.cancel();

    _heroController.dispose();
    _heroMotionController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final heights = [
      360.h,
      280.h,
      410.h,
      315.h,
    ];

    return Scaffold(
      backgroundColor:
      _background,

      body:
      CustomScrollView(
        physics:
        const BouncingScrollPhysics(
          parent:
          AlwaysScrollableScrollPhysics(),
        ),

        slivers: [
          // ========================================================
          // CINEMATIC HERO
          // ========================================================

          SliverAppBar(
            expandedHeight:
            510.h,

            pinned: true,
            stretch: true,

            elevation: 0,
            scrolledUnderElevation: 0,

            backgroundColor:
            _background,

            automaticallyImplyLeading:
            false,

            leading:
            Padding(
              padding:
              EdgeInsets.all(10.w),

              child:
              _HeroBackButton(
                pressed:
                _backPressed,

                accent:
                _accent,

                onPressedChanged:
                    (value) {
                  setState(() {
                    _backPressed =
                        value;
                  });
                },

                onTap: () {
                  HapticFeedback
                      .selectionClick();

                  Navigator.pop(
                    context,
                  );
                },
              ),
            ),

            flexibleSpace:
            FlexibleSpaceBar(
              stretchModes: const [
                StretchMode
                    .zoomBackground,
              ],

              background:
              Stack(
                fit:
                StackFit.expand,

                children: [
                  // ==================================================
                  // HERO IMAGE CAROUSEL
                  // ==================================================

                  if (widget
                      .wallpapers
                      .isNotEmpty)
                    PageView.builder(
                      controller:
                      _heroController,

                      physics:
                      const BouncingScrollPhysics(),

                      itemCount:
                      widget.wallpapers
                          .length,

                      onPageChanged:
                      _onHeroChanged,

                      itemBuilder:
                          (
                          context,
                          index,
                          ) {
                        return _AnimatedHeroImage(
                          image:
                          widget.wallpapers[
                          index],

                          animation:
                          _heroMotionController,
                        );
                      },
                    )
                  else
                    Container(
                      color:
                      _surface,

                      alignment:
                      Alignment.center,

                      child:
                      Icon(
                        Icons
                            .wallpaper_rounded,

                        color:
                        _muted.withOpacity(
                          .40,
                        ),

                        size:
                        80.sp,
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

                            stops: [
                              0,
                              .65,
                              1,
                            ],

                            colors: [
                              Color(
                                0xA0000000,
                              ),
                              Color(
                                0x20000000,
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
                  // SIDE VIGNETTE
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
                            Alignment.centerLeft,

                            end:
                            Alignment.centerRight,

                            colors: [
                              Color(
                                0x30000000,
                              ),
                              Colors
                                  .transparent,
                              Color(
                                0x18000000,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // BOTTOM GRADIENT
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
                              .35,
                              .65,
                              1,
                            ],

                            colors: [
                              Colors
                                  .transparent,

                              Color(
                                0x14000000,
                              ),

                              Color(
                                0x99000000,
                              ),

                              Color(
                                0xF5000000,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // HERO CONTENT
                  // ==================================================

                  Positioned(
                    left:
                    24.w,

                    right:
                    24.w,

                    bottom:
                    38.h,

                    child:
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [
                        // ------------------------------------------
                        // LABEL
                        // ------------------------------------------

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
                              'COLLECTION',

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
                                2.2,
                              ),
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(
                          duration:
                          const Duration(
                            milliseconds:
                            650,
                          ),
                        )
                            .moveX(
                          begin:
                          -18,
                          end:
                          0,
                          curve:
                          Curves.easeOutExpo,
                        ),

                        SizedBox(
                          height:
                          10.h,
                        ),

                        // ------------------------------------------
                        // TITLE
                        // ------------------------------------------

                        Text(
                          widget.title
                              .toUpperCase(),

                          maxLines:
                          2,

                          overflow:
                          TextOverflow
                              .ellipsis,

                          style:
                          GoogleFonts.bebasNeue(
                            color:
                            Colors.white,

                            fontSize:
                            72.sp,

                            height:
                            .78,

                            letterSpacing:
                            2.6,
                          ),
                        )
                            .animate()
                            .fadeIn(
                          delay:
                          const Duration(
                            milliseconds:
                            100,
                          ),

                          duration:
                          const Duration(
                            milliseconds:
                            850,
                          ),
                        )
                            .moveY(
                          begin:
                          55,
                          end:
                          0,

                          duration:
                          const Duration(
                            milliseconds:
                            900,
                          ),

                          curve:
                          Curves.easeOutExpo,
                        )
                            .scale(
                          begin:
                          const Offset(
                            .92,
                            .92,
                          ),

                          end:
                          const Offset(
                            1,
                            1,
                          ),

                          duration:
                          const Duration(
                            milliseconds:
                            900,
                          ),

                          curve:
                          Curves.easeOutExpo,
                        ),

                        SizedBox(
                          height:
                          10.h,
                        ),

                        // ------------------------------------------
                        // DESCRIPTION
                        // ------------------------------------------

                        Text(
                          widget.wallpapers
                              .isEmpty
                              ? 'No wallpapers available right now.'
                              : '${widget.wallpapers.length} immersive wallpapers crafted with cinematic visuals and premium minimal aesthetics.',

                          maxLines:
                          2,

                          overflow:
                          TextOverflow
                              .ellipsis,

                          style:
                          GoogleFonts.inter(
                            color:
                            Colors.white.withOpacity(
                              .68,
                            ),

                            fontSize:
                            12.sp,

                            height:
                            1.6,

                            fontWeight:
                            FontWeight.w500,
                          ),
                        )
                            .animate()
                            .fadeIn(
                          delay:
                          const Duration(
                            milliseconds:
                            300,
                          ),

                          duration:
                          const Duration(
                            milliseconds:
                            700,
                          ),
                        )
                            .moveY(
                          begin:
                          20,
                          end:
                          0,
                          curve:
                          Curves.easeOutExpo,
                        ),

                        SizedBox(
                          height:
                          18.h,
                        ),

                        // ------------------------------------------
                        // META
                        // ------------------------------------------

                        Row(
                          children: [
                            _HeroMeta(
                              number:
                              widget.wallpapers
                                  .length
                                  .toString()
                                  .padLeft(
                                2,
                                '0',
                              ),

                              label:
                              'WALLPAPERS',
                            ),

                            SizedBox(
                              width:
                              20.w,
                            ),

                            _heroDivider(),

                            SizedBox(
                              width:
                              20.w,
                            ),

                            const _HeroMeta(
                              number:
                              '4K',

                              label:
                              'QUALITY',
                            ),

                            SizedBox(
                              width:
                              20.w,
                            ),

                            _heroDivider(),

                            SizedBox(
                              width:
                              20.w,
                            ),

                            _HeroMeta(
                              number:
                              '${_heroIndex + 1}',

                              label:
                              'FRAME',
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(
                          delay:
                          const Duration(
                            milliseconds:
                            450,
                          ),
                        )
                            .moveY(
                          begin:
                          18,
                          end:
                          0,
                          curve:
                          Curves.easeOutExpo,
                        ),

                        SizedBox(
                          height:
                          18.h,
                        ),

                        // ------------------------------------------
                        // INDICATOR
                        // ------------------------------------------

                        _HeroIndicator(
                          count:
                          widget.wallpapers
                              .length,

                          current:
                          _heroIndex,

                          accent:
                          _accent,
                        )
                            .animate()
                            .fadeIn(
                          delay:
                          const Duration(
                            milliseconds:
                            550,
                          ),

                          duration:
                          const Duration(
                            milliseconds:
                            500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ========================================================
          // WALLPAPER HEADER
          // ========================================================

          SliverToBoxAdapter(
            child:
            Padding(
              padding:
              EdgeInsets.fromLTRB(
                22.w,
                28.h,
                22.w,
                22.h,
              ),

              child:
              Row(
                crossAxisAlignment:
                CrossAxisAlignment
                    .end,

                children: [
                  Expanded(
                    child:
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [
                        Text(
                          'WALLPAPERS',

                          style:
                          GoogleFonts.bebasNeue(
                            color:
                            _primary,

                            fontSize:
                            42.sp,

                            height:
                            .82,

                            letterSpacing:
                            2.6,
                          ),
                        ),

                        SizedBox(
                          height:
                          8.h,
                        ),

                        Row(
                          children: [
                            Container(
                              width:
                              25.w,

                              height:
                              2,

                              color:
                              _accent,
                            ),

                            SizedBox(
                              width:
                              9.w,
                            ),

                            Text(
                              'THE COLLECTION',

                              style:
                              GoogleFonts.inter(
                                color:
                                _secondary,

                                fontSize:
                                8.sp,

                                fontWeight:
                                FontWeight.w800,

                                letterSpacing:
                                1.7,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width:
                    42.w,

                    height:
                    42.w,

                    decoration:
                    BoxDecoration(
                      color:
                      _accent.withOpacity(
                        .08,
                      ),

                      shape:
                      BoxShape
                          .circle,

                      border:
                      Border.all(
                        color:
                        _divider,
                      ),
                    ),

                    child:
                    Center(
                      child:
                      Text(
                        widget.wallpapers
                            .length
                            .toString()
                            .padLeft(
                          2,
                          '0',
                        ),

                        style:
                        GoogleFonts.inter(
                          color:
                          _primary,

                          fontSize:
                          10.sp,

                          fontWeight:
                          FontWeight.w800,
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
                milliseconds:
                700,
              ),
            )
                .moveY(
              begin:
              25,
              end:
              0,
              curve:
              Curves.easeOutExpo,
            ),
          ),

          // ========================================================
          // EMPTY
          // ========================================================

          if (widget.wallpapers.isEmpty)
            SliverFillRemaining(
              child:
              _EmptyState(
                text:
                _primary,

                secondary:
                _secondary,

                accent:
                _accent,
              ),
            )

          // ========================================================
          // GRID
          // ========================================================

          else
            SliverPadding(
              padding:
              EdgeInsets.symmetric(
                horizontal:
                18.w,
              ),

              sliver:
              SliverMasonryGrid.count(
                crossAxisCount:
                2,

                mainAxisSpacing:
                14.h,

                crossAxisSpacing:
                14.w,

                childCount:
                widget.wallpapers
                    .length,

                itemBuilder:
                    (
                    context,
                    index,
                    ) {
                  final image =
                  widget.wallpapers[
                  index];

                  return _CinematicWallpaperCard(
                    image:
                    image,

                    index:
                    index,

                    height:
                    heights[
                    index %
                        4],

                    category:
                    widget.title,

                    accent:
                    _accent,

                    onTap: () {
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
            child:
            Padding(
              padding:
              EdgeInsets.symmetric(
                vertical:
                80.h,
              ),

              child:
              Column(
                children: [
                  Container(
                    width:
                    34.w,

                    height:
                    1,

                    color:
                    _divider,
                  ),

                  SizedBox(
                    height:
                    12.h,
                  ),

                  Text(
                    'END OF COLLECTION',

                    style:
                    GoogleFonts.inter(
                      color:
                      _muted.withOpacity(
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
  // OPEN PREVIEW
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
          milliseconds:
          800,
        ),

        reverseTransitionDuration:
        const Duration(
          milliseconds:
          550,
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
            widget.title,
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

  // ============================================================
  // HERO DIVIDER
  // ============================================================

  Widget _heroDivider() {
    return Container(
      width:
      1,

      height:
      25.h,

      color:
      Colors.white
          .withOpacity(.18),
    );
  }
}

// ==================================================================
// ANIMATED HERO IMAGE
// ==================================================================

class _AnimatedHeroImage
    extends StatelessWidget {
  final String image;
  final Animation<double>
  animation;

  const _AnimatedHeroImage({
    required this.image,
    required this.animation,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return AnimatedBuilder(
      animation:
      animation,

      builder:
          (
          context,
          child,
          ) {
        final value =
        Curves.easeInOut
            .transform(
          animation.value,
        );

        final scale =
            1.035 +
                (value * .055);

        final dx =
            (value - .5) * 10;

        final dy =
            (value - .5) * 6;

        return Transform.translate(
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
        image,

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
          final isDark =
              Theme.of(
                context,
              ).brightness ==
                  Brightness.dark;

          return Container(
            color:
            isDark
                ? AppColors
                .darkSurface
                : AppColors
                .lightSurface,

            alignment:
            Alignment.center,

            child:
            Icon(
              Icons
                  .broken_image_outlined,

              color:
              isDark
                  ? AppColors
                  .darkMuted
                  : AppColors
                  .lightMuted,

              size:
              60.sp,
            ),
          );
        },
      ),
    );
  }
}

// ==================================================================
// HERO INDICATOR
// ==================================================================

class _HeroIndicator
    extends StatelessWidget {
  final int count;
  final int current;
  final Color accent;

  const _HeroIndicator({
    required this.count,
    required this.current,
    required this.accent,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    if (count <= 1) {
      return const SizedBox
          .shrink();
    }

    final visible =
    count > 7
        ? 7
        : count;

    return Row(
      mainAxisSize:
      MainAxisSize.min,

      children:
      List.generate(
        visible,
            (index) {
          final active =
              index == current;

          return AnimatedContainer(
            duration:
            const Duration(
              milliseconds:
              650,
            ),

            curve:
            Curves.easeOutExpo,

            margin:
            EdgeInsets.only(
              right:
              5.w,
            ),

            width:
            active
                ? 30.w
                : 6.w,

            height:
            active
                ? 4.h
                : 3.h,

            decoration:
            BoxDecoration(
              color:
              active
                  ? accent
                  : Colors.white
                  .withOpacity(
                .28,
              ),

              borderRadius:
              BorderRadius
                  .circular(
                100.r,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================================================================
// HERO META
// ==================================================================

class _HeroMeta
    extends StatelessWidget {
  final String number;
  final String label;

  const _HeroMeta({
    required this.number,
    required this.label,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment
          .start,

      children: [
        Text(
          number,

          style:
          GoogleFonts.bebasNeue(
            color:
            Colors.white,

            fontSize:
            24.sp,

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
            Colors.white
                .withOpacity(
              .45,
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
// HERO BACK BUTTON
// ==================================================================

class _HeroBackButton
    extends StatelessWidget {
  final bool pressed;
  final Color accent;
  final ValueChanged<bool>
  onPressedChanged;
  final VoidCallback onTap;

  const _HeroBackButton({
    required this.pressed,
    required this.accent,
    required this.onPressedChanged,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return GestureDetector(
      onTapDown:
          (_) {
        onPressedChanged(
          true,
        );
      },

      onTapCancel:
          () {
        onPressedChanged(
          false,
        );
      },

      onTapUp:
          (_) {
        onPressedChanged(
          false,
        );

        onTap();
      },

      child:
      AnimatedScale(
        scale:
        pressed
            ? .86
            : 1,

        duration:
        const Duration(
          milliseconds:
          170,
        ),

        curve:
        Curves.easeOutCubic,

        child:
        Container(
          width:
          46.w,

          height:
          46.w,

          decoration:
          BoxDecoration(
            shape:
            BoxShape.circle,

            color:
            Colors.black
                .withOpacity(
              .25,
            ),

            border:
            Border.all(
              color:
              Colors.white
                  .withOpacity(
                .16,
              ),
            ),
          ),

          child:
          Icon(
            Icons
                .arrow_back_ios_new_rounded,

            color:
            Colors.white,

            size:
            18.sp,
          ),
        ),
      ),
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
  final double height;
  final String category;
  final Color accent;
  final VoidCallback onTap;

  const _CinematicWallpaperCard({
    required this.image,
    required this.index,
    required this.height,
    required this.category,
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
  bool _pressed = false;

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
        seconds:
        8,
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
            ? .95
            : 1,

        duration:
        const Duration(
          milliseconds:
          180,
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
            BorderRadius
                .circular(
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
                  // IMAGE
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

                      return Transform
                          .translate(
                        offset:
                        Offset(
                          (value -
                              .5) *
                              7,

                          (value -
                              .5) *
                              5,
                        ),

                        child:
                        Transform.scale(
                          scale:
                          1.045 +
                              value *
                                  .045,

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
                      FilterQuality
                          .high,

                      errorBuilder:
                          (
                          context,
                          error,
                          stackTrace,
                          ) {
                        final isDark =
                            Theme.of(
                              context,
                            ).brightness ==
                                Brightness
                                    .dark;

                        return Container(
                          color:
                          isDark
                              ? AppColors
                              .darkSurface
                              : AppColors
                              .lightSurface,

                          alignment:
                          Alignment
                              .center,

                          child:
                          Icon(
                            Icons
                                .broken_image_outlined,

                            color:
                            isDark
                                ? AppColors
                                .darkMuted
                                : AppColors
                                .lightMuted,

                            size:
                            28.sp,
                          ),
                        );
                      },
                    ),
                  ),

                  // ==================================================
                  // CINEMATIC GRADIENT
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
                              .30,
                              .65,
                              1,
                            ],

                            colors: [
                              Color(
                                0x1A000000,
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
                  // INDEX
                  // ==================================================

                  Positioned(
                    top:
                    17.h,

                    left:
                    17.w,

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
                          width:
                          8.w,
                        ),

                        Container(
                          width:
                          18.w,

                          height:
                          1,

                          color:
                          widget.accent
                              .withOpacity(
                            .75,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // ACCENT DOT
                  // ==================================================

                  Positioned(
                    top:
                    18.h,

                    right:
                    18.w,

                    child:
                    AnimatedContainer(
                      duration:
                      const Duration(
                        milliseconds:
                        350,
                      ),

                      width:
                      _pressed
                          ? 10.w
                          : 7.w,

                      height:
                      _pressed
                          ? 10.w
                          : 7.w,

                      decoration:
                      BoxDecoration(
                        color:
                        widget.accent,

                        shape:
                        BoxShape
                            .circle,
                      ),
                    ),
                  ),

                  // ==================================================
                  // CONTENT
                  // ==================================================

                  Positioned(
                    left:
                    18.w,

                    right:
                    18.w,

                    bottom:
                    18.h,

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
                              5.w,

                              height:
                              5.w,

                              decoration:
                              BoxDecoration(
                                color:
                                widget.accent,

                                shape:
                                BoxShape
                                    .circle,
                              ),
                            ),

                            SizedBox(
                              width:
                              7.w,
                            ),

                            Expanded(
                              child:
                              Text(
                                '4K • ${widget.category.toUpperCase()}',

                                maxLines:
                                1,

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
                                  1.1,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height:
                          8.h,
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
                          height:
                          11.h,
                        ),

                        Row(
                          children: [
                            Expanded(
                              child:
                              AnimatedContainer(
                                duration:
                                const Duration(
                                  milliseconds:
                                  450,
                                ),

                                height:
                                1,

                                color:
                                widget.accent.withOpacity(
                                  _pressed
                                      ? .75
                                      : .35,
                                ),
                              ),
                            ),

                            SizedBox(
                              width:
                              10.w,
                            ),

                            AnimatedRotation(
                              turns:
                              _pressed
                                  ? .12
                                  : 0,

                              duration:
                              const Duration(
                                milliseconds:
                                280,
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
        widget.index *
            90,
      ),

      duration:
      const Duration(
        milliseconds:
        900,
      ),
    )
        .moveY(
      begin:
      90,

      end:
      0,

      delay:
      Duration(
        milliseconds:
        widget.index *
            90,
      ),

      duration:
      const Duration(
        milliseconds:
        950,
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
        milliseconds:
        950,
      ),

      curve:
      Curves.easeOutExpo,
    )
        .blurXY(
      begin:
      4,

      end:
      0,

      duration:
      const Duration(
        milliseconds:
        800,
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
        MainAxisAlignment
            .center,

        children: [
          Container(
            width:
            110.w,

            height:
            110.w,

            decoration:
            BoxDecoration(
              shape:
              BoxShape.circle,

              border:
              Border.all(
                color:
                accent.withOpacity(
                  .16,
                ),
              ),

              color:
              accent.withOpacity(
                .04,
              ),
            ),

            child:
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
            const Duration(
              milliseconds:
              1800,
            ),

            curve:
            Curves.easeInOut,
          ),

          SizedBox(
            height:
            28.h,
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
            height:
            10.h,
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
        milliseconds:
        800,
      ),
    )
        .moveY(
      begin:
      30,

      end:
      0,

      curve:
      Curves.easeOutExpo,
    );
  }
}