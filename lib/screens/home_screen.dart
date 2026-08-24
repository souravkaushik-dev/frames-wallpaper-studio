import 'dart:async';
import 'dart:convert';

import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/preference_screen.dart';
import 'package:dotty/screens/previewscreen.dart';
import 'package:dotty/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../models/category_model.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // STATE
  // ============================================================

  int currentIndex = 0;

  late Future<Map<String, dynamic>>
  _dataFuture;

  Timer? _sliderTimer;

  final PageController
  _heroController =
  PageController();

  final ScrollController
  _scrollController =
  ScrollController();

  double _scrollOffset = 0;

  bool _isUserDraggingHero = false;

  // ============================================================
  // AMBIENT ANIMATION
  // ============================================================

  late AnimationController
  _ambientController;

  // ============================================================
  // COLORS
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

    _dataFuture =
        fetchData();

    _scrollController
        .addListener(
      _onScroll,
    );

    _ambientController =
    AnimationController(
      vsync: this,
      duration:
      const Duration(
        seconds: 12,
      ),
    )..repeat(
      reverse: true,
    );

    WidgetsBinding.instance
        .addPostFrameCallback(
          (_) {
        if (mounted) {
          _updateSystemUi();
        }
      },
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _sliderTimer?.cancel();

    _heroController.dispose();

    _scrollController.dispose();

    _ambientController
        .dispose();

    super.dispose();
  }

  // ============================================================
  // SYSTEM UI
  // ============================================================

  void _updateSystemUi() {
    final dark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    SystemChrome
        .setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome
        .setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor:
        Colors.transparent,
        systemNavigationBarColor:
        Colors.transparent,
        statusBarIconBrightness:
        dark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness:
        dark
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarIconBrightness:
        dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarDividerColor:
        Colors.transparent,
      ),
    );
  }

  // ============================================================
  // SCROLL
  // ============================================================

  void _onScroll() {
    if (!mounted) return;

    setState(() {
      _scrollOffset =
          _scrollController.offset;
    });
  }

  // ============================================================
  // FETCH DATA
  // ============================================================

  Future<Map<String, dynamic>>
  fetchData() async {
    final apiUrl =
    dotenv.env['API_URL'];

    if (apiUrl == null ||
        apiUrl.isEmpty) {
      throw Exception(
        'API_URL is not configured',
      );
    }

    final res =
    await http.get(
      Uri.parse(apiUrl),
    );

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load wallpapers: ${res.statusCode}',
      );
    }

    return jsonDecode(
      res.body,
    );
  }

  // ============================================================
  // AUTO SLIDER
  // ============================================================

  void startAutoSlide(
      int length,
      ) {
    _sliderTimer?.cancel();

    if (length <= 1) return;

    _sliderTimer =
        Timer.periodic(
          const Duration(
            seconds: 5,
          ),
              (_) {
            if (!mounted ||
                _isUserDraggingHero) {
              return;
            }

            final nextIndex =
                (currentIndex + 1) %
                    length;

            if (!_heroController
                .hasClients) {
              return;
            }

            _heroController
                .animateToPage(
              nextIndex,
              duration:
              const Duration(
                milliseconds: 900,
              ),
              curve:
              Curves.easeOutCubic,
            );
          },
        );
  }

  // ============================================================
  // HERO CHANGE
  // ============================================================

  void _onHeroChanged(
      int index,
      ) {
    if (!mounted) return;

    setState(() {
      currentIndex = index;
    });
  }

  // ============================================================
  // OPEN PREVIEW
  // ============================================================

  void _openPreview(
      String image, {
        String category = 'Featured',
      }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration:
        const Duration(
          milliseconds: 650,
        ),
        reverseTransitionDuration:
        const Duration(
          milliseconds: 450,
        ),
        pageBuilder:
            (
            _,
            animation,
            __,
            ) {
          return PreviewScreen(
            imageUrl: image,
            category: category,
          );
        },
        transitionsBuilder:
            (
            _,
            animation,
            __,
            child,
            ) {
          final curve =
          CurvedAnimation(
            parent: animation,
            curve:
            Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curve,
            child:
            ScaleTransition(
              scale:
              Tween<double>(
                begin: .96,
                end: 1,
              ).animate(
                curve,
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final bg = _background;
    final text = _primary;
    final secondary = _secondary;
    final accent = _accent;

    WidgetsBinding.instance
        .addPostFrameCallback(
          (_) {
        if (mounted) {
          _updateSystemUi();
        }
      },
    );

    return Scaffold(
      backgroundColor: bg,
      extendBody: true,
      extendBodyBehindAppBar: true,

      body: Stack(
        children: [
          _buildAmbientBackground(),

          FutureBuilder<
              Map<String, dynamic>>(
            future: _dataFuture,

            builder:
                (
                context,
                snapshot,
                ) {
              // ==================================================
              // LOADING
              // ==================================================

              if (snapshot
                  .connectionState ==
                  ConnectionState
                      .waiting) {
                return _buildLoading(
                  bg,
                );
              }

              // ==================================================
              // ERROR
              // ==================================================

              if (snapshot.hasError) {
                return _buildError(
                  text: text,
                  secondary:
                  secondary,
                  bg: bg,
                );
              }

              // ==================================================
              // NO DATA
              // ==================================================

              if (!snapshot
                  .hasData) {
                return _buildLoading(
                  bg,
                );
              }

              final data =
              snapshot.data!;

              final List<dynamic>
              trending =
                  data['trending'] ??
                      [];

              final Map<String,
                  dynamic>
              categories =
              Map<String,
                  dynamic>.from(
                data['categories'] ??
                    {},
              );

              if (trending
                  .isNotEmpty) {
                WidgetsBinding
                    .instance
                    .addPostFrameCallback(
                      (_) {
                    if (mounted) {
                      startAutoSlide(
                        trending.length,
                      );
                    }
                  },
                );
              }

              final String?
              featuredImage =
              trending.isNotEmpty
                  ? trending[
              currentIndex %
                  trending
                      .length]
                  : null;

              return CustomScrollView(
                controller:
                _scrollController,

                physics:
                const BouncingScrollPhysics(
                  parent:
                  AlwaysScrollableScrollPhysics(),
                ),

                slivers: [
                  // ==================================================
                  // HERO
                  // ==================================================

                  if (featuredImage !=
                      null)
                    SliverToBoxAdapter(
                      child:
                      _buildHero(
                        context:
                        context,
                        trending:
                        trending,
                        featuredImage:
                        featuredImage,
                      ),
                    ),

                  // ==================================================
                  // CATEGORIES HEADER
                  // ==================================================

                  SliverToBoxAdapter(
                    child:
                    _buildSectionHeader(
                      title:
                      'Categories',
                      subtitle:
                      'Explore your mood',
                      text: text,
                      accent:
                      accent,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                            const Duration(
                              milliseconds:
                              500,
                            ),
                            pageBuilder:
                                (
                                _,
                                animation,
                                __,
                                ) {
                              return const CategoriesPage();
                            },
                            transitionsBuilder:
                                (
                                _,
                                animation,
                                __,
                                child,
                                ) {
                              final curve =
                              CurvedAnimation(
                                parent:
                                animation,
                                curve:
                                Curves.easeOutCubic,
                              );

                              return FadeTransition(
                                opacity:
                                curve,
                                child:
                                SlideTransition(
                                  position:
                                  Tween<Offset>(
                                    begin:
                                    const Offset(
                                      .06,
                                      .03,
                                    ),
                                    end:
                                    Offset.zero,
                                  ).animate(
                                    curve,
                                  ),
                                  child:
                                  child,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // ==================================================
                  // CATEGORIES
                  // ==================================================

                  SliverToBoxAdapter(
                    child:
                    _buildCategories(
                      categories,
                      text,
                    ),
                  ),

                  // ==================================================
                  // TRENDING HEADER
                  // ==================================================

                  SliverToBoxAdapter(
                    child:
                    Padding(
                      padding:
                      EdgeInsets.fromLTRB(
                        20.w,
                        44.h,
                        20.w,
                        18.h,
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
                                  'Trending',
                                  style:
                                  GoogleFonts.poppins(
                                    fontSize:
                                    28.sp,
                                    fontWeight:
                                    FontWeight.w800,
                                    color:
                                    text,
                                    height:
                                    1,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                  7.h,
                                ),
                                Text(
                                  'Wallpapers everyone loves',
                                  style:
                                  GoogleFonts.inter(
                                    fontSize:
                                    13.sp,
                                    color:
                                    secondary,
                                    fontWeight:
                                    FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _smallSectionButton(
                            icon: Icons
                                .arrow_forward_rounded,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ==================================================
                  // TRENDING GRID
                  // ==================================================

                  SliverPadding(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal:
                      20.w,
                    ),
                    sliver:
                    SliverToBoxAdapter(
                      child:
                      MasonryGridView.count(
                        physics:
                        const NeverScrollableScrollPhysics(),
                        shrinkWrap:
                        true,
                        crossAxisCount:
                        2,
                        mainAxisSpacing:
                        14.h,
                        crossAxisSpacing:
                        14.w,
                        itemCount:
                        trending.length,
                        itemBuilder:
                            (
                            context,
                            index,
                            ) {
                          final image =
                          trending[
                          index];

                          return _AnimatedWallpaperCard(
                            image:
                            image,
                            index:
                            index,
                            onTap: () {
                              _openPreview(
                                image,
                                category:
                                'Trending',
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // ==================================================
                  // BOTTOM SPACE
                  // ==================================================

                  SliverToBoxAdapter(
                    child:
                    SizedBox(
                      height:
                      150.h,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AMBIENT BACKGROUND
  // ============================================================

  Widget _buildAmbientBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child:
        AnimatedBuilder(
          animation:
          _ambientController,

          builder:
              (
              context,
              child,
              ) {
            final value =
                _ambientController
                    .value;

            return Stack(
              children: [
                Positioned(
                  top:
                  -180.h +
                      value *
                          30.h,
                  right:
                  -190.w +
                      value *
                          24.w,
                  child:
                  _ambientBlob(
                    420.w,
                    _isDark
                        ? .045
                        : .014,
                  ),
                ),

                Positioned(
                  left: -190.w,
                  top:
                  380.h -
                      value *
                          25.h,
                  child:
                  _ambientBlob(
                    360.w,
                    _isDark
                        ? .025
                        : .010,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _ambientBlob(
      double size,
      double opacity,
      ) {
    return Container(
      width: size,
      height: size,
      decoration:
      BoxDecoration(
        shape:
        BoxShape.circle,
        color:
        _accent.withOpacity(
          opacity,
        ),
      ),
    )
        .animate()
        .blurXY(
      begin: 80,
      end: 115,
      duration:
      const Duration(
        seconds: 8,
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading(
      Color bg,
      ) {
    return Container(
      color: bg,
      child:
      Center(
        child:
        Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 58.w,
              height: 58.w,

              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius
                    .circular(
                  20.r,
                ),

                color:
                _accent
                    .withOpacity(
                  .10,
                ),

                border:
                Border.all(
                  color:
                  _accent
                      .withOpacity(
                    .14,
                  ),
                ),
              ),

              child:
              Icon(
                Icons
                    .auto_awesome_rounded,
                color:
                _accent,
                size:
                25.sp,
              ),
            )
                .animate(
              onPlay:
                  (controller) {
                controller
                    .repeat(
                  reverse:
                  true,
                );
              },
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
                1100,
              ),
              curve:
              Curves.easeInOut,
            ),

            SizedBox(
              height: 18.h,
            ),

            Text(
              'Loading wallpapers',
              style:
              GoogleFonts.inter(
                color:
                _secondary,
                fontSize:
                13.sp,
                fontWeight:
                FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError({
    required Color text,
    required Color secondary,
    required Color bg,
  }) {
    return Container(
      color: bg,

      alignment:
      Alignment.center,

      padding:
      EdgeInsets.all(
        24.w,
      ),

      child:
      Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Container(
            width: 72.w,
            height: 72.w,

            decoration:
            BoxDecoration(
              shape:
              BoxShape.circle,
              color:
              _accent
                  .withOpacity(
                .10,
              ),
              border:
              Border.all(
                color:
                _accent
                    .withOpacity(
                  .12,
                ),
              ),
            ),

            child:
            Icon(
              Icons
                  .wifi_off_rounded,
              color:
              _accent,
              size:
              32.sp,
            ),
          ),

          SizedBox(
            height: 22.h,
          ),

          Text(
            'Unable to load wallpapers',
            textAlign:
            TextAlign.center,
            style:
            GoogleFonts.inter(
              color:
              text,
              fontSize:
              18.sp,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          SizedBox(
            height: 8.h,
          ),

          Text(
            'Check your connection and try again.',
            textAlign:
            TextAlign.center,
            style:
            GoogleFonts.inter(
              color:
              secondary,
              fontSize:
              13.sp,
            ),
          ),

          SizedBox(
            height: 24.h,
          ),

          GestureDetector(
            onTap: () {
              HapticFeedback
                  .selectionClick();

              setState(() {
                _dataFuture =
                    fetchData();
              });
            },

            child:
            Container(
              padding:
              EdgeInsets.symmetric(
                horizontal:
                24.w,
                vertical:
                13.h,
              ),

              decoration:
              BoxDecoration(
                color:
                _accent
                    .withOpacity(
                  .10,
                ),

                borderRadius:
                BorderRadius
                    .circular(
                  18.r,
                ),

                border:
                Border.all(
                  color:
                  _accent
                      .withOpacity(
                    .14,
                  ),
                ),
              ),

              child:
              Text(
                'Try Again',
                style:
                GoogleFonts.inter(
                  color:
                  _accent,
                  fontWeight:
                  FontWeight.w700,
                  fontSize:
                  13.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero({
    required BuildContext context,
    required List<dynamic> trending,
    required String featuredImage,
  }) {
    final screenHeight =
        MediaQuery.of(context)
            .size
            .height;

    final heroHeight =
        screenHeight * .82;

    return SizedBox(
      height: heroHeight,

      child:
      Stack(
        fit:
        StackFit.expand,

        children: [
          // ========================================================
          // HERO PAGE VIEW
          // ========================================================

          GestureDetector(
            onTap: () {
              _openPreview(
                featuredImage,
                category:
                'Featured',
              );
            },

            onPanDown: (_) {
              _isUserDraggingHero =
              true;
            },

            onPanCancel: () {
              _isUserDraggingHero =
              false;
            },

            onPanEnd: (_) {
              _isUserDraggingHero =
              false;
            },

            child:
            PageView.builder(
              controller:
              _heroController,

              itemCount:
              trending.length,

              onPageChanged:
              _onHeroChanged,

              physics:
              const BouncingScrollPhysics(),

              itemBuilder:
                  (
                  context,
                  index,
                  ) {
                final image =
                trending[index];

                return Hero(
                  tag:
                  'featured-$image',

                  child:
                  _HeroWallpaper(
                    image:
                    image,
                    scrollOffset:
                    _scrollOffset,
                  ),
                );
              },
            ),
          ),

          // ========================================================
          // TOP GRADIENT
          // ========================================================

          IgnorePointer(
            child:
            Container(
              decoration:
              const BoxDecoration(
                gradient:
                LinearGradient(
                  begin:
                  Alignment.topCenter,
                  end:
                  Alignment.center,
                  colors: [
                    Color(
                      0xB3000000,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ========================================================
          // BOTTOM GRADIENT
          // ========================================================

          IgnorePointer(
            child:
            Container(
              decoration:
              const BoxDecoration(
                gradient:
                LinearGradient(
                  begin:
                  Alignment.center,
                  end:
                  Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(
                      0x26000000,
                    ),
                    Color(
                      0xE0000000,
                    ),
                  ],
                  stops: [
                    0,
                    .55,
                    1,
                  ],
                ),
              ),
            ),
          ),

          // ========================================================
          // HEADER
          // ========================================================

          Positioned(
            top: 0,
            left: 0,
            right: 0,

            child:
            SafeArea(
              bottom:
              false,

              child:
              Padding(
                padding:
                EdgeInsets.fromLTRB(
                  20.w,
                  10.h,
                  20.w,
                  0,
                ),

                child:
                Row(
                  children: [
                    Expanded(
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
                                8.w,
                                height:
                                8.w,
                                decoration:
                                const BoxDecoration(
                                  color:
                                  Colors.white,
                                  shape:
                                  BoxShape.circle,
                                ),
                              ),

                              SizedBox(
                                width:
                                8.w,
                              ),

                              Text(
                                'WALLPAPER STUDIO',
                                style:
                                GoogleFonts.inter(
                                  color:
                                  Colors.white70,
                                  fontSize:
                                  10.sp,
                                  fontWeight:
                                  FontWeight.w700,
                                  letterSpacing:
                                  2,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height:
                            7.h,
                          ),

                          Text(
                            'Frames',
                            style:
                            GoogleFonts.poppins(
                              color:
                              Colors.white,
                              fontSize:
                              32.sp,
                              height:
                              .95,
                              fontWeight:
                              FontWeight.w800,
                              letterSpacing:
                              -1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _glassIconButton(
                      icon:
                      Hicons
                          .search2LightOutline,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
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
                              return const SearchScreen();
                            },
                            transitionsBuilder:
                                (
                                _,
                                animation,
                                __,
                                child,
                                ) {
                              return FadeTransition(
                                opacity:
                                CurvedAnimation(
                                  parent:
                                  animation,
                                  curve:
                                  Curves.easeOutCubic,
                                ),
                                child:
                                child,
                              );
                            },
                          ),
                        );
                      },
                    ),

                    SizedBox(
                      width:
                      10.w,
                    ),

                    _glassIconButton(
                      icon:
                      Hicons
                          .filter5LightOutline,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
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
                              return const PreferencesScreen();
                            },
                            transitionsBuilder:
                                (
                                _,
                                animation,
                                __,
                                child,
                                ) {
                              return FadeTransition(
                                opacity:
                                CurvedAnimation(
                                  parent:
                                  animation,
                                  curve:
                                  Curves.easeOutCubic,
                                ),
                                child:
                                child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ========================================================
          // HERO CONTENT
          // ========================================================

          Positioned(
            left:
            22.w,
            right:
            22.w,
            bottom:
            34.h,

            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                Row(
                  children: [
                    Container(
                      padding:
                      EdgeInsets.symmetric(
                        horizontal:
                        12.w,
                        vertical:
                        7.h,
                      ),

                      decoration:
                      BoxDecoration(
                        color: Colors
                            .white
                            .withOpacity(
                          .12,
                        ),

                        borderRadius:
                        BorderRadius
                            .circular(
                          30.r,
                        ),

                        border:
                        Border.all(
                          color: Colors
                              .white
                              .withOpacity(
                            .15,
                          ),
                        ),
                      ),

                      child:
                      Row(
                        mainAxisSize:
                        MainAxisSize
                            .min,
                        children: [
                          Icon(
                            Icons
                                .auto_awesome_rounded,
                            color:
                            Colors.white,
                            size:
                            13.sp,
                          ),

                          SizedBox(
                            width:
                            6.w,
                          ),

                          Text(
                            'FEATURED',
                            style:
                            GoogleFonts.inter(
                              color:
                              Colors.white,
                              fontSize:
                              10.sp,
                              fontWeight:
                              FontWeight.w800,
                              letterSpacing:
                              1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    _heroPageIndicator(
                      trending.length,
                    ),
                  ],
                ),

                SizedBox(
                  height:
                  17.h,
                ),

                AnimatedSwitcher(
                  duration:
                  const Duration(
                    milliseconds:
                    500,
                  ),

                  switchInCurve:
                  Curves.easeOutCubic,

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
                        Tween<Offset>(
                          begin:
                          const Offset(
                            0,
                            .12,
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
                    getWallpaperName(
                      featuredImage,
                    ),
                    key:
                    ValueKey(
                      featuredImage,
                    ),
                    maxLines:
                    2,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style:
                    GoogleFonts.poppins(
                      color:
                      Colors.white,
                      fontSize:
                      36.sp,
                      fontWeight:
                      FontWeight.w800,
                      height:
                      .98,
                      letterSpacing:
                      -1.2,
                    ),
                  ),
                ),

                SizedBox(
                  height:
                  10.h,
                ),

                Text(
                  'Curated wallpapers designed to make your screen feel different.',
                  maxLines:
                  2,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  GoogleFonts.inter(
                    color:
                    Colors.white70,
                    fontSize:
                    13.sp,
                    height:
                    1.45,
                  ),
                ),

                SizedBox(
                  height:
                  18.h,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO INDICATOR
  // ============================================================

  Widget _heroPageIndicator(
      int count,
      ) {
    if (count <= 1) {
      return const SizedBox
          .shrink();
    }

    final visibleCount =
    count > 5 ? 5 : count;

    return RepaintBoundary(
      child:
      Row(
        mainAxisSize:
        MainAxisSize.min,
        children:
        List.generate(
          visibleCount,
              (index) {
            final active =
                index ==
                    currentIndex;

            return Padding(
              padding:
              EdgeInsets.only(
                left:
                5.w,
              ),

              child:
              TweenAnimationBuilder<
                  double>(
                tween:
                Tween<double>(
                  begin:
                  0,
                  end:
                  active
                      ? 1
                      : 0,
                ),

                duration:
                const Duration(
                  milliseconds:
                  550,
                ),

                curve:
                Curves.easeOutCubic,

                builder:
                    (
                    context,
                    value,
                    child,
                    ) {
                  final width =
                      6.w +
                          (16.w *
                              value);

                  return Container(
                    width:
                    width,
                    height:
                    5.h,

                    decoration:
                    BoxDecoration(
                      color:
                      Color.lerp(
                        Colors
                            .white
                            .withOpacity(
                          .35,
                        ),
                        Colors.white,
                        value,
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
          },
        ),
      ),
    );
  }

  // ============================================================
  // HERO IMAGE
  // ============================================================

  Widget _HeroWallpaper({
    required String image,
    required double scrollOffset,
  }) {
    final double parallax =
    (scrollOffset * .20)
        .clamp(
      0.0,
      80.0,
    )
        .toDouble();

    return ClipRect(
      child:
      Transform.translate(
        offset:
        Offset(
          0,
          parallax,
        ),

        child:
        Transform.scale(
          scale:
          1.04,

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
              return Container(
                color:
                _surfaceSoft,
                child:
                Icon(
                  Icons
                      .broken_image_outlined,
                  color:
                  _muted,
                  size:
                  48.sp,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required Color text,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding:
      EdgeInsets.fromLTRB(
        20.w,
        42.h,
        20.w,
        18.h,
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
                  title,
                  style:
                  GoogleFonts.poppins(
                    fontSize:
                    28.sp,
                    fontWeight:
                    FontWeight.w800,
                    color:
                    text,
                    height:
                    1,
                  ),
                ),

                SizedBox(
                  height:
                  7.h,
                ),

                Text(
                  subtitle,
                  style:
                  GoogleFonts.inter(
                    fontSize:
                    13.sp,
                    color:
                    _secondary,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              HapticFeedback
                  .selectionClick();

              onTap();
            },

            child:
            AnimatedContainer(
              duration:
              const Duration(
                milliseconds:
                220,
              ),

              padding:
              EdgeInsets.symmetric(
                horizontal:
                14.w,
                vertical:
                9.h,
              ),

              decoration:
              BoxDecoration(
                color:
                accent
                    .withOpacity(
                  _isDark
                      ? .09
                      : .07,
                ),

                borderRadius:
                BorderRadius
                    .circular(
                  30.r,
                ),

                border:
                Border.all(
                  color:
                  accent
                      .withOpacity(
                    .12,
                  ),
                ),
              ),

              child:
              Row(
                children: [
                  Text(
                    'Explore',
                    style:
                    GoogleFonts.inter(
                      color:
                      accent,
                      fontSize:
                      12.sp,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  SizedBox(
                    width:
                    4.w,
                  ),

                  Icon(
                    Icons
                        .arrow_forward_rounded,
                    color:
                    accent,
                    size:
                    15.sp,
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
  // CATEGORIES
  // ============================================================

  Widget _buildCategories(
      Map<String, dynamic>
      categories,
      Color text,
      ) {
    return SizedBox(
      height:
      190.h,

      child:
      ListView.builder(
        padding:
        EdgeInsets.symmetric(
          horizontal:
          20.w,
        ),

        scrollDirection:
        Axis.horizontal,

        physics:
        const BouncingScrollPhysics(),

        itemCount:
        categories.length,

        itemBuilder:
            (
            context,
            index,
            ) {
          final categoryName =
          categories.keys
              .toList()[index];

          final category =
          categories[
          categoryName];

          final String
          thumbnail =
          category[
          'thumbnail'];

          final List<dynamic>
          wallpapers =
              category[
              'wallpapers'] ??
                  [];

          return _AnimatedCategoryCard(
            index:
            index,
            thumbnail:
            thumbnail,
            title:
            categoryName,
            count:
            wallpapers.length,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration:
                  const Duration(
                    milliseconds:
                    500,
                  ),

                  pageBuilder:
                      (
                      _,
                      animation,
                      __,
                      ) {
                    return CategoryScreen(
                      title:
                      categoryName,
                      wallpapers:
                      List<String>.from(
                        wallpapers,
                      ),
                    );
                  },

                  transitionsBuilder:
                      (
                      _,
                      animation,
                      __,
                      child,
                      ) {
                    final curve =
                    CurvedAnimation(
                      parent:
                      animation,
                      curve:
                      Curves.easeOutCubic,
                    );

                    return FadeTransition(
                      opacity:
                      curve,
                      child:
                      SlideTransition(
                        position:
                        Tween<Offset>(
                          begin:
                          const Offset(
                            .12,
                            0,
                          ),
                          end:
                          Offset.zero,
                        ).animate(
                          curve,
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
      ),
    );
  }

  // ============================================================
  // GLASS ICON BUTTON
  // ============================================================

  Widget _glassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return _HeroPressButton(
      onTap:
      onTap,

      child:
      Container(
        width:
        48.w,
        height:
        48.w,

        decoration:
        BoxDecoration(
          color:
          Colors.white
              .withOpacity(
            .11,
          ),

          borderRadius:
          BorderRadius
              .circular(
            17.r,
          ),

          border:
          Border.all(
            color:
            Colors.white
                .withOpacity(
              .15,
            ),
          ),
        ),

        child:
        Icon(
          icon,
          color:
          Colors.white,
          size:
          21.sp,
        ),
      ),
    );
  }

  // ============================================================
  // SMALL SECTION BUTTON
  // ============================================================

  Widget _smallSectionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return _PressableButton(
      onTap:
      onTap,

      child:
      Container(
        width:
        40.w,
        height:
        40.w,

        decoration:
        BoxDecoration(
          borderRadius:
          BorderRadius
              .circular(
            14.r,
          ),

          color:
          _accent
              .withOpacity(
            _isDark
                ? .09
                : .07,
          ),

          border:
          Border.all(
            color:
            _accent
                .withOpacity(
              .12,
            ),
          ),
        ),

        child:
        Icon(
          icon,
          color:
          _accent,
          size:
          18.sp,
        ),
      ),
    );
  }

  // ============================================================
  // WALLPAPER NAME
  // ============================================================

  String getWallpaperName(
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

    return fileName
        .split(' ')
        .map(
          (e) => e.isNotEmpty
          ? e[0]
          .toUpperCase() +
          e.substring(1)
          : '',
    )
        .join(' ');
  }
}

// ==================================================================
// ANIMATED CATEGORY CARD
// ==================================================================

class _AnimatedCategoryCard
    extends StatefulWidget {
  final int index;
  final String thumbnail;
  final String title;
  final int count;
  final VoidCallback onTap;

  const _AnimatedCategoryCard({
    required this.index,
    required this.thumbnail,
    required this.title,
    required this.count,
    required this.onTap,
  });

  @override
  State<
      _AnimatedCategoryCard>
  createState() =>
      _AnimatedCategoryCardState();
}

class _AnimatedCategoryCardState
    extends State<
        _AnimatedCategoryCard> {
  bool pressed = false;

  @override
  Widget build(
      BuildContext context,
      ) {
    final isDark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    final surface =
    isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final divider =
    isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          pressed = true;
        });
      },

      onTapCancel: () {
        setState(() {
          pressed = false;
        });
      },

      onTapUp: (_) {
        setState(() {
          pressed = false;
        });

        widget.onTap();
      },

      child:
      AnimatedScale(
        scale:
        pressed ? .94 : 1,

        duration:
        const Duration(
          milliseconds:
          180,
        ),

        curve:
        Curves.easeOutCubic,

        child:
        Container(
          width:
          154.w,

          margin:
          EdgeInsets.only(
            right:
            14.w,
          ),

          decoration:
          BoxDecoration(
            borderRadius:
            BorderRadius
                .circular(
              28.r,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(
                  isDark
                      ? .24
                      : .12,
                ),
                blurRadius:
                22,
                offset:
                const Offset(
                  0,
                  12,
                ),
              ),
            ],
          ),

          child:
          ClipRRect(
            borderRadius:
            BorderRadius
                .circular(
              28.r,
            ),

            child:
            Stack(
              fit:
              StackFit.expand,

              children: [
                Image.network(
                  widget.thumbnail,
                  fit:
                  BoxFit.cover,
                  filterQuality:
                  FilterQuality
                      .medium,

                  errorBuilder:
                      (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return Container(
                      color:
                      surface,
                      child:
                      Icon(
                        Icons
                            .broken_image_outlined,
                        color:
                        AppColors
                            .lightMuted,
                      ),
                    );
                  },
                ),

                Container(
                  decoration:
                  const BoxDecoration(
                    gradient:
                    LinearGradient(
                      begin:
                      Alignment
                          .topCenter,
                      end:
                      Alignment
                          .bottomCenter,
                      colors: [
                        Colors
                            .transparent,
                        Color(
                          0xD1000000,
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding:
                  EdgeInsets.all(
                    15.w,
                  ),

                  child:
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    mainAxisAlignment:
                    MainAxisAlignment
                        .end,

                    children: [
                      Container(
                        padding:
                        EdgeInsets
                            .symmetric(
                          horizontal:
                          9.w,
                          vertical:
                          5.h,
                        ),

                        decoration:
                        BoxDecoration(
                          color: Colors
                              .white
                              .withOpacity(
                            .12,
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(
                            30.r,
                          ),

                          border:
                          Border.all(
                            color: Colors
                                .white
                                .withOpacity(
                              .12,
                            ),
                          ),
                        ),

                        child:
                        Text(
                          '${widget.count} wallpapers',
                          style:
                          GoogleFonts.inter(
                            color:
                            Colors.white,
                            fontSize:
                            9.sp,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),

                      SizedBox(
                        height:
                        8.h,
                      ),

                      Text(
                        widget.title,
                        maxLines:
                        2,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        GoogleFonts.poppins(
                          color:
                          Colors.white,
                          fontSize:
                          19.sp,
                          fontWeight:
                          FontWeight
                              .w800,
                          height:
                          1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
      duration:
      const Duration(
        milliseconds:
        500,
      ),
      delay:
      Duration(
        milliseconds:
        80 *
            widget.index,
      ),
    )
        .moveX(
      begin:
      35,
      end:
      0,
      duration:
      const Duration(
        milliseconds:
        650,
      ),
      curve:
      Curves.easeOutCubic,
    );
  }
}

// ==================================================================
// ANIMATED WALLPAPER CARD
// ==================================================================

class _AnimatedWallpaperCard
    extends StatefulWidget {
  final String image;
  final int index;
  final VoidCallback onTap;

  const _AnimatedWallpaperCard({
    required this.image,
    required this.index,
    required this.onTap,
  });

  @override
  State<
      _AnimatedWallpaperCard>
  createState() =>
      _AnimatedWallpaperCardState();
}

class _AnimatedWallpaperCardState
    extends State<
        _AnimatedWallpaperCard> {
  bool pressed = false;

  @override
  Widget build(
      BuildContext context,
      ) {
    final isDark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          pressed = true;
        });
      },

      onTapCancel: () {
        setState(() {
          pressed = false;
        });
      },

      onTapUp: (_) {
        setState(() {
          pressed = false;
        });

        widget.onTap();
      },

      child:
      AnimatedScale(
        scale:
        pressed ? .96 : 1,

        duration:
        const Duration(
          milliseconds:
          160,
        ),

        curve:
        Curves.easeOutCubic,

        child:
        Hero(
          tag:
          'trending-${widget.image}',

          child:
          ClipRRect(
            borderRadius:
            BorderRadius
                .circular(
              25.r,
            ),

            child:
            Stack(
              children: [
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
                    return Container(
                      height:
                      220.h,

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
                        36.sp,
                      ),
                    );
                  },
                ),

                Positioned.fill(
                  child:
                  IgnorePointer(
                    child:
                    Container(
                      decoration:
                      const BoxDecoration(
                        gradient:
                        LinearGradient(
                          begin:
                          Alignment
                              .topCenter,
                          end:
                          Alignment
                              .bottomCenter,
                          colors: [
                            Colors
                                .transparent,
                            Color(
                              0x4D000000,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
      duration:
      const Duration(
        milliseconds:
        550,
      ),
      delay:
      Duration(
        milliseconds:
        70 *
            widget.index,
      ),
    )
        .moveY(
      begin:
      35,
      end:
      0,
      duration:
      const Duration(
        milliseconds:
        650,
      ),
      curve:
      Curves.easeOutCubic,
    )
        .scale(
      begin:
      const Offset(
        .96,
        .96,
      ),
      end:
      const Offset(
        1,
        1,
      ),
      duration:
      const Duration(
        milliseconds:
        650,
      ),
      curve:
      Curves.easeOutCubic,
    );
  }
}

// ==================================================================
// HERO PRESS BUTTON
// ==================================================================

class _HeroPressButton
    extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HeroPressButton({
    required this.child,
    required this.onTap,
  });

  @override
  State<_HeroPressButton>
  createState() =>
      _HeroPressButtonState();
}

class _HeroPressButtonState
    extends State<
        _HeroPressButton> {
  bool pressed = false;

  @override
  Widget build(
      BuildContext context,
      ) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          pressed = true;
        });
      },

      onTapCancel: () {
        setState(() {
          pressed = false;
        });
      },

      onTapUp: (_) {
        setState(() {
          pressed = false;
        });

        HapticFeedback
            .selectionClick();

        widget.onTap();
      },

      child:
      AnimatedScale(
        scale:
        pressed ? .92 : 1,

        duration:
        const Duration(
          milliseconds:
          170,
        ),

        curve:
        Curves.easeOutCubic,

        child:
        widget.child,
      ),
    );
  }
}

// ==================================================================
// NORMAL PRESS BUTTON
// ==================================================================

class _PressableButton
    extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableButton({
    required this.child,
    required this.onTap,
  });

  @override
  State<_PressableButton>
  createState() =>
      _PressableButtonState();
}

class _PressableButtonState
    extends State<
        _PressableButton> {
  bool pressed = false;

  @override
  Widget build(
      BuildContext context,
      ) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          pressed = true;
        });
      },

      onTapCancel: () {
        setState(() {
          pressed = false;
        });
      },

      onTapUp: (_) {
        setState(() {
          pressed = false;
        });

        HapticFeedback
            .selectionClick();

        widget.onTap();
      },

      child:
      AnimatedScale(
        scale:
        pressed ? .93 : 1,

        duration:
        const Duration(
          milliseconds:
          170,
        ),

        curve:
        Curves.easeOutCubic,

        child:
        widget.child,
      ),
    );
  }
}