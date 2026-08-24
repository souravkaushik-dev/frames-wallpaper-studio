import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/previewscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/fav_service.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() =>
      _SavedScreenState();
}

class _SavedScreenState
    extends State<SavedScreen> {
  // ============================================================
  // DATA
  // ============================================================

  Future<List<Map<String, dynamic>>>
  fetchFavorites() {
    return FavoritesService
        .getFavorites();
  }

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
      FutureBuilder<
          List<Map<String, dynamic>>>(
        future:
        fetchFavorites(),

        builder:
            (
            context,
            snapshot,
            ) {
          // ========================================================
          // LOADING
          // ========================================================

          if (snapshot
              .connectionState ==
              ConnectionState
                  .waiting) {
            return _buildLoading();
          }

          // ========================================================
          // ERROR
          // ========================================================

          if (snapshot.hasError) {
            return _buildError();
          }

          final favorites =
              snapshot.data ?? [];

          // ========================================================
          // EMPTY
          // ========================================================

          if (favorites.isEmpty) {
            return _buildEmptyState();
          }

          // ========================================================
          // MAIN
          // ========================================================

          return RefreshIndicator(
            color:
            _accent,

            backgroundColor:
            _surface,

            displacement:
            70.h,

            strokeWidth:
            1.8,

            onRefresh:
                () async {
              HapticFeedback
                  .selectionClick();

              setState(() {});

              await fetchFavorites();
            },

            child:
            CustomScrollView(
              physics:
              const BouncingScrollPhysics(
                parent:
                AlwaysScrollableScrollPhysics(),
              ),

              slivers: [
                // ==================================================
                // HERO
                // ==================================================

                SliverToBoxAdapter(
                  child:
                  _buildHero(
                    count:
                    favorites.length,
                  ),
                ),

                // ==================================================
                // SECTION HEADER
                // ==================================================

                SliverToBoxAdapter(
                  child:
                  _buildArchiveHeader(
                    count:
                    favorites.length,
                  ),
                ),

                // ==================================================
                // GRID
                // ==================================================

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
                    favorites.length,

                    itemBuilder:
                        (
                        context,
                        index,
                        ) {
                      final item =
                      favorites[index];

                      final String image =
                          item['imageUrl']
                              ?.toString() ??
                              '';

                      final String
                      category =
                          item['category']
                              ?.toString() ??
                              'Saved';

                      final heights = [
                        360.h,
                        280.h,
                        410.h,
                        315.h,
                      ];

                      return _SavedWallpaperCard(
                        index:
                        index,

                        image:
                        image,

                        category:
                        category,

                        height:
                        heights[
                        index %
                            4],

                        onTap:
                            () {
                          _openPreview(
                            context,
                            image,
                            category,
                          );
                        },
                      );
                    },
                  ),
                ),

                // ==================================================
                // END
                // ==================================================

                SliverToBoxAdapter(
                  child:
                  _buildEndArchive(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // PREVIEW NAVIGATION
  // ============================================================

  void _openPreview(
      BuildContext context,
      String image,
      String category,
      ) {
    if (image.isEmpty) return;

    HapticFeedback
        .selectionClick();

    Navigator.push(
      context,

      PageRouteBuilder(
        transitionDuration:
        const Duration(
          milliseconds:
          700,
        ),

        reverseTransitionDuration:
        const Duration(
          milliseconds:
          450,
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
            category,
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
  // HERO
  // ============================================================

  Widget _buildHero({
    required int count,
  }) {
    return Padding(
      padding:
      EdgeInsets.fromLTRB(
        22.w,
        82.h,
        22.w,
        28.h,
      ),

      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,

        children: [
          // ------------------------------------------------------
          // LABEL
          // ------------------------------------------------------

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
                'FRAME / PERSONAL ARCHIVE',

                style:
                GoogleFonts.inter(
                  color:
                  _secondary,
                  fontSize:
                  9.sp,
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
              500,
            ),
          )
              .moveX(
            begin:
            -20,
            end:
            0,
            curve:
            Curves.easeOutExpo,
          ),

          SizedBox(
            height:
            12.h,
          ),

          // ------------------------------------------------------
          // TITLE
          // ------------------------------------------------------

          Text(
            'SAVED',

            style:
            GoogleFonts.bebasNeue(
              color:
              _primary,
              fontSize:
              94.sp,
              height:
              .75,
              letterSpacing:
              3,
            ),
          )
              .animate()
              .fadeIn(
            duration:
            const Duration(
              milliseconds:
              900,
            ),
          )
              .moveY(
            begin:
            80,
            end:
            0,
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
              950,
            ),
            curve:
            Curves.easeOutExpo,
          ),

          SizedBox(
            height:
            18.h,
          ),

          // ------------------------------------------------------
          // DESCRIPTION
          // ------------------------------------------------------

          SizedBox(
            width:
            335.w,

            child:
            Text(
              'A personal archive of wallpapers that captured your attention, mood and aesthetic.',

              style:
              GoogleFonts.inter(
                color:
                _secondary,
                fontSize:
                13.sp,
                height:
                1.65,
                fontWeight:
                FontWeight.w500,
              ),
            ),
          )
              .animate()
              .fadeIn(
            delay:
            const Duration(
              milliseconds:
              250,
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
            22.h,
          ),

          // ------------------------------------------------------
          // META
          // ------------------------------------------------------

          Row(
            children: [
              _ArchiveMeta(
                number:
                count
                    .toString()
                    .padLeft(
                  2,
                  '0',
                ),
                label:
                'SAVED',
                color:
                _primary,
              ),

              SizedBox(
                width:
                22.w,
              ),

              _verticalDivider(),

              SizedBox(
                width:
                22.w,
              ),

              _ArchiveMeta(
                number:
                '4K',
                label:
                'READY',
                color:
                _primary,
              ),

              SizedBox(
                width:
                22.w,
              ),

              _verticalDivider(),

              SizedBox(
                width:
                22.w,
              ),

              _ArchiveMeta(
                number:
                '∞',
                label:
                'MOODS',
                color:
                _primary,
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
        ],
      ),
    );
  }

  // ============================================================
  // ARCHIVE HEADER
  // ============================================================

  Widget _buildArchiveHeader({
    required int count,
  }) {
    return Padding(
      padding:
      EdgeInsets.fromLTRB(
        22.w,
        12.h,
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
                  'ARCHIVE',

                  style:
                  GoogleFonts.bebasNeue(
                    color:
                    _primary,
                    fontSize:
                    43.sp,
                    height:
                    .82,
                    letterSpacing:
                    2.8,
                  ),
                ),

                SizedBox(
                  height:
                  9.h,
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
                      'YOUR VISUAL COLLECTION',

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

          // COUNT
          Container(
            width:
            42.w,
            height:
            42.w,

            decoration:
            BoxDecoration(
              color:
              _accent.withOpacity(
                _isDark
                    ? .10
                    : .07,
              ),

              shape:
              BoxShape.circle,

              border:
              Border.all(
                color:
                _accent.withOpacity(
                  .16,
                ),
              ),
            ),

            child:
            Center(
              child:
              Text(
                count
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
                  11.sp,
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
        milliseconds:
        600,
      ),
    )
        .moveY(
      begin:
      20,
      end:
      0,
      curve:
      Curves.easeOutExpo,
    );
  }

  // ============================================================
  // END ARCHIVE
  // ============================================================

  Widget _buildEndArchive() {
    return Padding(
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
            'END OF ARCHIVE',

            style:
            GoogleFonts.inter(
              color:
              _muted.withOpacity(
                .65,
              ),
              fontSize:
              8.sp,
              fontWeight:
              FontWeight.w700,
              letterSpacing:
              2.2,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child:
      Padding(
        padding:
        EdgeInsets.all(
          28.w,
        ),

        child:
        Column(
          mainAxisAlignment:
          MainAxisAlignment
              .center,

          children: [
            // Cinematic icon
            SizedBox(
              width:
              110.w,
              height:
              110.w,

              child:
              Stack(
                alignment:
                Alignment
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
                      BoxShape
                          .circle,

                      border:
                      Border.all(
                        color:
                        _accent
                            .withOpacity(
                          .18,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width:
                    78.w,
                    height:
                    78.w,

                    decoration:
                    BoxDecoration(
                      shape:
                      BoxShape
                          .circle,

                      color:
                      _accent
                          .withOpacity(
                        .07,
                      ),
                    ),

                    child:
                    Icon(
                      Icons
                          .favorite_border_rounded,
                      color:
                      _accent
                          .withOpacity(
                        .65,
                      ),
                      size:
                      32.sp,
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
              const Duration(
                milliseconds:
                1800,
              ),
              curve:
              Curves.easeInOut,
            ),

            SizedBox(
              height:
              30.h,
            ),

            Text(
              'NOTHING SAVED',

              style:
              GoogleFonts.bebasNeue(
                color:
                _primary,
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
              'Your visual archive is waiting.\nSave wallpapers you want to keep.',

              textAlign:
              TextAlign.center,

              style:
              GoogleFonts.inter(
                color:
                _secondary,
                fontSize:
                13.sp,
                height:
                1.7,
              ),
            ),
          ],
        ),
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
      35,
      end:
      0,
      curve:
      Curves.easeOutExpo,
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return Container(
      color:
      _background,

      alignment:
      Alignment.center,

      child:
      Column(
        mainAxisSize:
        MainAxisSize.min,

        children: [
          Container(
            width:
            54.w,
            height:
            54.w,

            decoration:
            BoxDecoration(
              color:
              _accent.withOpacity(
                .08,
              ),

              shape:
              BoxShape.circle,

              border:
              Border.all(
                color:
                _accent.withOpacity(
                  .12,
                ),
              ),
            ),

            child:
            Padding(
              padding:
              EdgeInsets.all(
                15.w,
              ),

              child:
              CircularProgressIndicator(
                strokeWidth:
                1.5,

                color:
                _accent,
              ),
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
              1200,
            ),
          ),

          SizedBox(
            height:
            18.h,
          ),

          Text(
            'LOADING ARCHIVE',

            style:
            GoogleFonts.inter(
              color:
              _secondary.withOpacity(
                .65,
              ),
              fontSize:
              8.sp,
              fontWeight:
              FontWeight.w800,
              letterSpacing:
              2.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Container(
      color:
      _background,

      alignment:
      Alignment.center,

      padding:
      EdgeInsets.all(
        28.w,
      ),

      child:
      Column(
        mainAxisSize:
        MainAxisSize.min,

        children: [
          Container(
            width:
            70.w,
            height:
            70.w,

            decoration:
            BoxDecoration(
              color:
              _accent.withOpacity(
                .08,
              ),

              shape:
              BoxShape.circle,

              border:
              Border.all(
                color:
                _accent.withOpacity(
                  .13,
                ),
              ),
            ),

            child:
            Icon(
              Icons
                  .cloud_off_rounded,
              color:
              _accent,
              size:
              32.sp,
            ),
          ),

          SizedBox(
            height:
            18.h,
          ),

          Text(
            'ARCHIVE UNAVAILABLE',

            textAlign:
            TextAlign.center,

            style:
            GoogleFonts.bebasNeue(
              color:
              _primary,
              fontSize:
              30.sp,
              letterSpacing:
              1.8,
            ),
          ),

          SizedBox(
            height:
            8.h,
          ),

          Text(
            'Check your connection and try again.',

            textAlign:
            TextAlign.center,

            style:
            GoogleFonts.inter(
              color:
              _secondary,
              fontSize:
              12.sp,
            ),
          ),

          SizedBox(
            height:
            22.h,
          ),

          GestureDetector(
            onTap: () {
              HapticFeedback
                  .selectionClick();

              setState(() {});
            },

            child:
            Container(
              padding:
              EdgeInsets.symmetric(
                horizontal:
                20.w,
                vertical:
                11.h,
              ),

              decoration:
              BoxDecoration(
                color:
                _accent.withOpacity(
                  .09,
                ),

                borderRadius:
                BorderRadius
                    .circular(
                  15.r,
                ),

                border:
                Border.all(
                  color:
                  _accent.withOpacity(
                    .13,
                  ),
                ),
              ),

              child:
              Text(
                'TRY AGAIN',

                style:
                GoogleFonts.inter(
                  color:
                  _accent,
                  fontSize:
                  10.sp,
                  fontWeight:
                  FontWeight.w800,
                  letterSpacing:
                  1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _verticalDivider() {
    return Container(
      width:
      1,
      height:
      26.h,
      color:
      _divider,
    );
  }
}

// ==================================================================
// ARCHIVE META
// ==================================================================

class _ArchiveMeta
    extends StatelessWidget {
  final String number;
  final String label;
  final Color color;

  const _ArchiveMeta({
    required this.number,
    required this.label,
    required this.color,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final isDark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    final muted =
    isDark
        ? AppColors.darkMuted
        : AppColors.lightMuted;

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
          height:
          5.h,
        ),

        Text(
          label,

          style:
          GoogleFonts.inter(
            color:
            muted,
            fontSize:
            7.sp,
            fontWeight:
            FontWeight.w800,
            letterSpacing:
            1.5,
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// SAVED WALLPAPER CARD
// ==================================================================

class _SavedWallpaperCard
    extends StatefulWidget {
  final int index;
  final String image;
  final String category;
  final double height;
  final VoidCallback onTap;

  const _SavedWallpaperCard({
    required this.index,
    required this.image,
    required this.category,
    required this.height,
    required this.onTap,
  });

  @override
  State<_SavedWallpaperCard>
  createState() =>
      _SavedWallpaperCardState();
}

class _SavedWallpaperCardState
    extends State<
        _SavedWallpaperCard>
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
    _motionController
        .dispose();

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
                  // MOVING IMAGE
                  // ==================================================

                  AnimatedBuilder(
                    animation:
                    _motionController,

                    builder:
                        (
                        context,
                        child,
                        ) {
                      final progress =
                          _motionController
                              .value;

                      final scale =
                          1.05 +
                              (progress *
                                  .045);

                      final dx =
                          (progress -
                              .5) *
                              7;

                      final dy =
                          (progress -
                              .5) *
                              5;

                      return Transform
                          .translate(
                        offset:
                        Offset(
                          dx,
                          dy,
                        ),

                        child:
                        Transform
                            .scale(
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
                            Alignment
                                .topCenter,
                            end:
                            Alignment
                                .bottomCenter,
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
                                0xE6000000,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // TOP INDEX
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
                            Colors.white.withOpacity(
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
                          Colors.white.withOpacity(
                            .45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // SAVED HEART
                  // ==================================================

                  Positioned(
                    top:
                    15.h,
                    right:
                    15.w,

                    child:
                    AnimatedScale(
                      scale:
                      _pressed
                          ? .82
                          : 1,

                      duration:
                      const Duration(
                        milliseconds:
                        200,
                      ),

                      child:
                      Container(
                        width:
                        34.w,
                        height:
                        34.w,

                        decoration:
                        BoxDecoration(
                          color:
                          Colors.black.withOpacity(
                            .20,
                          ),
                          shape:
                          BoxShape
                              .circle,
                        ),

                        child:
                        const Icon(
                          Icons
                              .favorite_rounded,
                          color:
                          Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // BOTTOM CONTENT
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
                              const BoxDecoration(
                                color:
                                Colors.white,
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
                                widget
                                    .category
                                    .toUpperCase(),

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
                                  1.4,
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
                          _getName(
                            widget.image,
                          ).toUpperCase(),

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
                            42.sp,
                            height:
                            .80,
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
                                  500,
                                ),

                                height:
                                1,

                                color:
                                Colors.white.withOpacity(
                                  _pressed
                                      ? .55
                                      : .22,
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
                                300,
                              ),

                              child:
                              Icon(
                                Icons
                                    .arrow_outward_rounded,
                                color:
                                Colors.white.withOpacity(
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
            110,
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
            110,
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

  // ============================================================
  // WALLPAPER NAME
  // ============================================================

  String _getName(
      String url,
      ) {
    String fileName =
        url.split('/').last;

    fileName =
        fileName.replaceAll(
          RegExp(
            r'\.(jpg|jpeg|png|webp)$',
          ),
          '',
        );

    fileName =
        fileName.replaceAll(
          RegExp(
            r'-\d+x\d+-\d+$',
          ),
          '',
        );

    fileName =
        fileName.replaceAll(
          '-',
          ' ',
        );

    return fileName;
  }
}