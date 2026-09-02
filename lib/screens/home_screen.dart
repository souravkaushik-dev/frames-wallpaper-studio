import 'dart:async';
import 'dart:convert';

import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/preference_screen.dart';
import 'package:dotty/screens/previewscreen.dart';
import 'package:dotty/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../models/category_model.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  late final PageController _featuredController;
  late final ScrollController _scrollController;

  Timer? _featuredTimer;

  // ============================================================
  // DATA
  // ============================================================

  late Future<Map<String, dynamic>> _dataFuture;

  int _featuredIndex = 0;
  bool _isDraggingFeatured = false;
  bool _sliderStarted = false;

  // ============================================================
  // THEME
  // ============================================================

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _background => _isDark
      ? AppColors.darkBackground
      : AppColors.lightBackground;

  Color get _surface => _isDark
      ? AppColors.darkSurface
      : AppColors.lightSurface;

  Color get _surfaceSoft => _isDark
      ? AppColors.darkSurfaceSoft
      : AppColors.lightSurfaceSoft;

  Color get _primary => _isDark
      ? AppColors.darkPrimary
      : AppColors.lightPrimary;

  Color get _secondary => _isDark
      ? AppColors.darkSecondary
      : AppColors.lightSecondary;

  Color get _muted => _isDark
      ? AppColors.darkMuted
      : AppColors.lightMuted;

  Color get _accent => AppColors.accent;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _featuredController = PageController();

    _scrollController = ScrollController();

    _dataFuture = fetchData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateSystemUi();
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _featuredTimer?.cancel();
    _featuredController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // SYSTEM UI
  // ============================================================

  void _updateSystemUi() {
    final dark =
        Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness:
        dark ? Brightness.light : Brightness.dark,
        statusBarBrightness:
        dark ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness:
        dark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor:
        Colors.transparent,
      ),
    );
  }

  // ============================================================
  // API
  // ============================================================

  Future<Map<String, dynamic>> fetchData() async {
    final apiUrl = dotenv.env['API_URL'];

    if (apiUrl == null || apiUrl.isEmpty) {
      throw Exception(
        'API_URL is not configured',
      );
    }

    final response = await http.get(
      Uri.parse(apiUrl),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load wallpapers: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Invalid wallpaper API response',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    HapticFeedback.selectionClick();

    _stopFeaturedSlider();

    setState(() {
      _featuredIndex = 0;
      _dataFuture = fetchData();
    });

    await _dataFuture;
  }

  // ============================================================
  // FEATURED AUTO SLIDER
  // ============================================================

  void _startFeaturedSlider(int length) {
    if (_sliderStarted || length <= 1) {
      return;
    }

    _sliderStarted = true;

    _featuredTimer?.cancel();

    _featuredTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) {
        if (!mounted ||
            _isDraggingFeatured ||
            !_featuredController.hasClients) {
          return;
        }

        final next =
            (_featuredIndex + 1) % length;

        _featuredController.animateToPage(
          next,
          duration: const Duration(
            milliseconds: 650,
          ),
          curve: Curves.easeOutCubic,
        );
      },
    );
  }

  void _stopFeaturedSlider() {
    _featuredTimer?.cancel();
    _featuredTimer = null;
    _sliderStarted = false;
  }

  void _onFeaturedChanged(int index) {
    if (!mounted) return;

    setState(() {
      _featuredIndex = index;
    });
  }

  // ============================================================
  // OPEN PREVIEW
  // ============================================================

  void _openPreview(
      String image, {
        String category = 'Featured',
      }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration:
        const Duration(milliseconds: 380),
        reverseTransitionDuration:
        const Duration(milliseconds: 280),
        pageBuilder: (
            context,
            animation,
            secondaryAnimation,
            ) {
          return PreviewScreen(
            imageUrl: image,
            category: category,
          );
        },
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: .975,
                end: 1,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _openSearch() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration:
        const Duration(milliseconds: 300),
        reverseTransitionDuration:
        const Duration(milliseconds: 220),
        pageBuilder: (
            context,
            animation,
            secondaryAnimation,
            ) {
          return const SearchScreen();
        },
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
  }

  // ============================================================
  // PREFERENCES
  // ============================================================

  void _openPreferences() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration:
        const Duration(milliseconds: 300),
        reverseTransitionDuration:
        const Duration(milliseconds: 220),
        pageBuilder: (
            context,
            animation,
            secondaryAnimation,
            ) {
          return const PreferencesScreen();
        },
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  void _openCategories() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration:
        const Duration(milliseconds: 350),
        reverseTransitionDuration:
        const Duration(milliseconds: 250),
        pageBuilder: (
            context,
            animation,
            secondaryAnimation,
            ) {
          return const CategoriesPage();
        },
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(.035, 0),
                end: Offset.zero,
              ).animate(curved),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dataFuture,
          builder: (
              context,
              snapshot,
              ) {
            // ------------------------------------------------
            // LOADING
            // ------------------------------------------------

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return _buildLoading();
            }

            // ------------------------------------------------
            // ERROR
            // ------------------------------------------------

            if (snapshot.hasError) {
              return _buildError();
            }

            // ------------------------------------------------
            // EMPTY
            // ------------------------------------------------

            if (!snapshot.hasData) {
              return _buildLoading();
            }

            final data = snapshot.data!;

            final List<dynamic> trending =
            List<dynamic>.from(
              data['trending'] ?? const [],
            );

            final Map<String, dynamic> categories =
            Map<String, dynamic>.from(
              data['categories'] ?? const {},
            );

            if (trending.isNotEmpty) {
              _startFeaturedSlider(
                trending.length,
              );
            }

            return _buildContent(
              trending: trending,
              categories: categories,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent({
    required List<dynamic> trending,
    required Map<String, dynamic> categories,
  }) {
    return RefreshIndicator(
      color: _accent,
      backgroundColor: _surface,
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent:
          AlwaysScrollableScrollPhysics(),
        ),
        cacheExtent: 1000,
        slivers: [
          // ==================================================
          // HEADER
          // ==================================================

          SliverToBoxAdapter(
            child: _buildHeader(),
          ),

          // ==================================================
          // SMALL INTRO
          // ==================================================

          SliverToBoxAdapter(
            child: _buildIntro(),
          ),

          // ==================================================
          // FEATURED CARD
          // ==================================================

          if (trending.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildFeatured(
                trending,
              ),
            ),

          // ==================================================
          // EXPLORE SECTION
          // ==================================================

          if (categories.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildExploreHeader(),
            ),

          // ==================================================
          // CATEGORIES
          // ==================================================

          if (categories.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildCategories(
                categories,
              ),
            ),

          // ==================================================
          // TRENDING HEADER
          // ==================================================

          if (trending.length > 1)
            SliverToBoxAdapter(
              child: _buildTrendingHeader(),
            ),

          // ==================================================
          // TRENDING CARDS
          // ==================================================

          if (trending.length > 1)
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
              ),
              sliver: SliverList.builder(
                itemCount: trending.length - 1,
                itemBuilder: (
                    context,
                    index,
                    ) {
                  final realIndex =
                      index + 1;

                  final image =
                  trending[realIndex]
                      .toString();

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: 8.h,
                    ),
                    child:
                    _FeedWallpaperCard(
                      image: image,
                      title:
                      getWallpaperName(
                        image,
                      ),
                      index: realIndex,
                      height:
                      _feedCardHeight(
                        realIndex,
                      ),
                      onTap: () {
                        _openPreview(
                          image,
                          category:
                          'Trending',
                        );
                      },
                    ),
                  );
                },
              ),
            ),

          // ==================================================
          // BOTTOM
          // ==================================================

          SliverToBoxAdapter(
            child: SizedBox(
              height: 120.h,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18.w,
        10.h,
        18.w,
        0,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'WALLPAPER STUDIO',
                  style: GoogleFonts.manrope(
                    color: _secondary,
                    fontSize: 8.5.sp,
                    fontWeight:
                    FontWeight.w800,
                    letterSpacing: 1.7,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Frames',
                  style:
                  GoogleFonts.bebasNeue(
                    color: _primary,
                    fontSize: 30.sp,
                    fontWeight:
                    FontWeight.w400,
                    height: .95,
                    letterSpacing: -1.2,
                  ),
                ),
              ],
            ),
          ),

          _HeaderButton(
            icon: Icons.search_rounded,
            onTap: _openSearch,
          ),

          SizedBox(width: 7.w),

          _HeaderButton(
            icon: Icons.tune_rounded,
            onTap: _openPreferences,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INTRO
  // ============================================================

  Widget _buildIntro() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        19.w,
        20.h,
        19.w,
        4.h,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              'Something beautiful\nfor your screen.',
              style:
              GoogleFonts.bebasNeue(
                color: _primary,
                fontSize: 25.sp,
                fontWeight:
                FontWeight.w300,
                height: .98,
                letterSpacing: .4,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              bottom: 2.h,
            ),
            child: Icon(
              Icons.arrow_downward_rounded,
              color: _muted,
              size: 18.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FEATURED
  // ============================================================

  Widget _buildFeatured(
      List<dynamic> trending,
      ) {
    final height =
        MediaQuery.sizeOf(context).height *
            .57;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        12.w,
        14.h,
        12.w,
        0,
      ),
      child: SizedBox(
        height: height.clamp(
          390.h,
          540.h,
        ),
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(31.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ============================================
              // PAGE VIEW
              // ============================================

              GestureDetector(
                onPanDown: (_) {
                  _isDraggingFeatured =
                  true;
                },
                onPanEnd: (_) {
                  _isDraggingFeatured =
                  false;
                },
                onPanCancel: () {
                  _isDraggingFeatured =
                  false;
                },
                child: PageView.builder(
                  controller:
                  _featuredController,
                  itemCount:
                  trending.length,
                  onPageChanged:
                  _onFeaturedChanged,
                  physics:
                  const BouncingScrollPhysics(),
                  itemBuilder: (
                      context,
                      index,
                      ) {
                    final image =
                    trending[index]
                        .toString();

                    return Hero(
                      tag:
                      'featured-$image',
                      child:
                      _FeaturedImage(
                        image: image,
                      ),
                    );
                  },
                ),
              ),

              // ============================================
              // IMAGE GRADIENT
              // ============================================

              const IgnorePointer(
                child: DecoratedBox(
                  decoration:
                  BoxDecoration(
                    gradient:
                    LinearGradient(
                      begin:
                      Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [
                        0,
                        .45,
                        .72,
                        1,
                      ],
                      colors: [
                        Color(0x28000000),
                        Colors.transparent,
                        Color(0x30000000),
                        Color(0xE6000000),
                      ],
                    ),
                  ),
                ),
              ),

              // ============================================
              // TOP LABEL
              // ============================================

              Positioned(
                top: 16.h,
                left: 16.w,
                child: Container(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration:
                  BoxDecoration(
                    color: Colors.black
                        .withOpacity(.20),
                    borderRadius:
                    BorderRadius.circular(
                      50.r,
                    ),
                    border: Border.all(
                      color: Colors.white
                          .withOpacity(.13),
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Container(
                        width: 5.w,
                        height: 5.w,
                        decoration:
                        const BoxDecoration(
                          color: Colors.white,
                          shape:
                          BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'FEATURED',
                        style:
                        GoogleFonts.manrope(
                          color:
                          Colors.white,
                          fontSize: 8.sp,
                          fontWeight:
                          FontWeight.w800,
                          letterSpacing:
                          1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ============================================
              // PAGE COUNTER
              // ============================================

              if (trending.length > 1)
                Positioned(
                  top: 16.h,
                  right: 16.w,
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration:
                    BoxDecoration(
                      color: Colors.black
                          .withOpacity(.20),
                      borderRadius:
                      BorderRadius.circular(
                        50.r,
                      ),
                      border: Border.all(
                        color: Colors.white
                            .withOpacity(.13),
                      ),
                    ),
                    child: Text(
                      '${_featuredIndex + 1} / ${trending.length}',
                      style:
                      GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              // ============================================
              // BOTTOM CONTENT
              // ============================================

              Positioned(
                left: 19.w,
                right: 19.w,
                bottom: 18.h,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration:
                      const Duration(
                        milliseconds: 280,
                      ),
                      transitionBuilder: (
                          child,
                          animation,
                          ) {
                        return FadeTransition(
                          opacity: animation,
                          child:
                          SlideTransition(
                            position:
                            Tween<
                                Offset>(
                              begin:
                              const Offset(
                                0,
                                .08,
                              ),
                              end:
                              Offset.zero,
                            ).animate(
                              animation,
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        getWallpaperName(
                          trending[
                          _featuredIndex %
                              trending.length
                          ].toString(),
                        ),
                        key: ValueKey(
                          trending[
                          _featuredIndex %
                              trending.length
                          ],
                        ),
                        maxLines: 2,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        GoogleFonts.bebasNeue(
                          color:
                          Colors.white,
                          fontSize: 29.sp,
                          fontWeight:
                          FontWeight.w400,
                          height: .94,
                          letterSpacing:
                          -1,
                        ),
                      ),
                    ),

                    SizedBox(height: 7.h),

                    Text(
                      'Tap to explore this wallpaper',
                      style:
                      GoogleFonts.manrope(
                        color: Colors.white
                            .withOpacity(.65),
                        fontSize: 10.sp,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 13.h),

                    _FeaturedIndicator(
                      count: trending.length,
                      current:
                      _featuredIndex,
                    ),
                  ],
                ),
              ),

              // ============================================
              // TAP OVERLAY
              // ============================================

              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius:
                    BorderRadius.circular(
                      31.r,
                    ),
                    onTap: () {
                      final image =
                      trending[
                      _featuredIndex %
                          trending.length
                      ].toString();

                      _openPreview(
                        image,
                        category:
                        'Featured',
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EXPLORE HEADER
  // ============================================================

  Widget _buildExploreHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        19.w,
        32.h,
        19.w,
        14.h,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore',
                  style:
                  GoogleFonts.bebasNeue(
                    color: _primary,
                    fontSize: 24.sp,
                    fontWeight:
                    FontWeight.w400,
                    height: 1,
                    letterSpacing: -.5,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Find something that feels like you',
                  style: GoogleFonts.manrope(
                    color: _secondary,
                    fontSize: 11.sp,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ================================================
          // ROUNDED PILL
          // ================================================

          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _openCategories();
            },
            child: Container(
              padding:
              EdgeInsets.symmetric(
                horizontal: 15.w,
                vertical: 9.h,
              ),
              decoration:
              BoxDecoration(
                color: _surfaceSoft,
                borderRadius:
                BorderRadius.circular(
                  100.r,
                ),
                border: Border.all(
                  color: _isDark
                      ? Colors.white
                      .withOpacity(.07)
                      : Colors.black
                      .withOpacity(.05),
                ),
              ),
              child: Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Text(
                    'Explore',
                    style:
                    GoogleFonts.manrope(
                      color: _primary,
                      fontSize: 10.sp,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Icon(
                    Icons
                        .arrow_forward_rounded,
                    color: _primary,
                    size: 13.sp,
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
      Map<String, dynamic> categories,
      ) {
    final entries =
    categories.entries.toList();

    return SizedBox(
      height: 125.h,
      child: ListView.builder(
        padding:
        EdgeInsets.symmetric(
          horizontal: 12.w,
        ),
        scrollDirection:
        Axis.horizontal,
        physics:
        const BouncingScrollPhysics(),
        itemCount: entries.length,
        itemBuilder: (
            context,
            index,
            ) {
          final entry =
          entries[index];

          final categoryName =
              entry.key;

          final category =
          Map<String, dynamic>.from(
            entry.value,
          );

          final thumbnail =
              category['thumbnail']
                  ?.toString() ??
                  '';

          final wallpapers =
          List<dynamic>.from(
            category['wallpapers'] ??
                const [],
          );

          return Padding(
            padding: EdgeInsets.only(
              right: 8.w,
            ),
            child: _CategoryTile(
              title: categoryName,
              thumbnail: thumbnail,
              count:
              wallpapers.length,
              onTap: () {
                HapticFeedback
                    .selectionClick();

                Navigator.of(context)
                    .push(
                  PageRouteBuilder(
                    transitionDuration:
                    const Duration(
                      milliseconds: 320,
                    ),
                    reverseTransitionDuration:
                    const Duration(
                      milliseconds: 230,
                    ),
                    pageBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
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
                    transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                        ) {
                      final curved =
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves
                            .easeOutCubic,
                      );

                      return FadeTransition(
                        opacity: curved,
                        child:
                        SlideTransition(
                          position:
                          Tween<Offset>(
                            begin:
                            const Offset(
                              .035,
                              0,
                            ),
                            end:
                            Offset.zero,
                          ).animate(
                            curved,
                          ),
                          child: child,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // TRENDING HEADER
  // ============================================================

  Widget _buildTrendingHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        19.w,
        35.h,
        19.w,
        13.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Frame Spotlight',
                  style:
                  GoogleFonts.bebasNeue(
                    color: _primary,
                    fontSize: 24.sp,
                    fontWeight:
                    FontWeight.w400,
                    height: 1,
                    letterSpacing: -.5,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'A few people are loving right now',
                  style: GoogleFonts.manrope(
                    color: _secondary,
                    fontSize: 11.sp,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARD HEIGHTS
  // ============================================================

  double _feedCardHeight(int index) {
    final heights = [
      265.h,
      205.h,
      290.h,
      230.h,
      275.h,
      215.h,
    ];

    return heights[
    index % heights.length];
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration:
            BoxDecoration(
              color:
              _accent.withOpacity(.10),
              borderRadius:
              BorderRadius.circular(
                20.r,
              ),
              border: Border.all(
                color:
                _accent.withOpacity(.14),
              ),
            ),
            child: Icon(
              Icons
                  .auto_awesome_rounded,
              color: _accent,
              size: 25.sp,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            'Loading wallpapers',
            style: GoogleFonts.manrope(
              color: _secondary,
              fontSize: 13.sp,
              fontWeight:
              FontWeight.w500,
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
    return Center(
      child: Padding(
        padding:
        EdgeInsets.all(24.w),
        child: Column(
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
                _accent.withOpacity(.10),
                border: Border.all(
                  color:
                  _accent.withOpacity(.12),
                ),
              ),
              child: Icon(
                Icons
                    .wifi_off_rounded,
                color: _accent,
                size: 32.sp,
              ),
            ),

            SizedBox(height: 22.h),

            Text(
              'Unable to load wallpapers',
              textAlign:
              TextAlign.center,
              style:
              GoogleFonts.manrope(
                color: _primary,
                fontSize: 18.sp,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              'Check your connection and try again.',
              textAlign:
              TextAlign.center,
              style:
              GoogleFonts.manrope(
                color: _secondary,
                fontSize: 13.sp,
              ),
            ),

            SizedBox(height: 24.h),

            _Pressable(
              onTap: _refresh,
              scale: .95,
              child: Container(
                padding:
                EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 13.h,
                ),
                decoration:
                BoxDecoration(
                  color:
                  _accent.withOpacity(.10),
                  borderRadius:
                  BorderRadius.circular(
                    18.r,
                  ),
                  border: Border.all(
                    color:
                    _accent.withOpacity(.14),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style:
                  GoogleFonts.manrope(
                    color: _accent,
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          ],
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
            caseSensitive: false,
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
          (word) {
        if (word.isEmpty) {
          return '';
        }

        return word[0]
            .toUpperCase() +
            word.substring(1);
      },
    )
        .join(' ');
  }
}

// ==================================================================
// FEATURED IMAGE
// ==================================================================

class _FeaturedImage
    extends StatelessWidget {
  final String image;

  const _FeaturedImage({
    required this.image,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Image.network(
      image,
      fit: BoxFit.cover,
      filterQuality:
      FilterQuality.medium,
      cacheWidth: 1100,
      errorBuilder: (
          context,
          error,
          stackTrace,
          ) {
        final dark =
            Theme.of(context)
                .brightness ==
                Brightness.dark;

        return Container(
          color: dark
              ? AppColors
              .darkSurface
              : AppColors
              .lightSurface,
          child: Icon(
            Icons
                .broken_image_outlined,
            color: dark
                ? AppColors
                .darkMuted
                : AppColors
                .lightMuted,
            size: 48.sp,
          ),
        );
      },
    );
  }
}

// ==================================================================
// FEATURED INDICATOR
// ==================================================================

class _FeaturedIndicator
    extends StatelessWidget {
  final int count;
  final int current;

  const _FeaturedIndicator({
    required this.count,
    required this.current,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final visible =
    count > 6 ? 6 : count;

    return Row(
      children:
      List.generate(
        visible,
            (index) {
          final active =
              index == current;

          return AnimatedContainer(
            duration:
            const Duration(
              milliseconds: 240,
            ),
            curve:
            Curves.easeOutCubic,
            margin:
            EdgeInsets.only(
              right: 5.w,
            ),
            width:
            active ? 22.w : 6.w,
            height: 4.h,
            decoration:
            BoxDecoration(
              color: active
                  ? Colors.white
                  : Colors.white
                  .withOpacity(.30),
              borderRadius:
              BorderRadius.circular(
                50.r,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================================================================
// FEED WALLPAPER CARD
// ==================================================================

class _FeedWallpaperCard
    extends StatelessWidget {
  final String image;
  final String title;
  final int index;
  final double height;
  final VoidCallback onTap;

  const _FeedWallpaperCard({
    required this.image,
    required this.title,
    required this.index,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return _Pressable(
      onTap: onTap,
      scale: .985,
      child: Hero(
        tag: 'feed-$image',
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(
            28.r,
          ),
          child: SizedBox(
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ==========================================
                // IMAGE
                // ==========================================

                Image.network(
                  image,
                  fit: BoxFit.cover,
                  filterQuality:
                  FilterQuality.low,
                  cacheWidth: 900,
                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return Container(
                      color: Theme.of(
                        context,
                      ).brightness ==
                          Brightness.dark
                          ? AppColors
                          .darkSurface
                          : AppColors
                          .lightSurface,
                      child: Icon(
                        Icons
                            .broken_image_outlined,
                        color: AppColors
                            .accent,
                        size: 40.sp,
                      ),
                    );
                  },
                ),

                // ==========================================
                // OVERLAY
                // ==========================================

                const DecoratedBox(
                  decoration:
                  BoxDecoration(
                    gradient:
                    LinearGradient(
                      begin:
                      Alignment.topCenter,
                      end:
                      Alignment.bottomCenter,
                      colors: [
                        Color(0x05000000),
                        Color(0x16000000),
                        Color(0xD9000000),
                      ],
                      stops: [
                        0,
                        .48,
                        1,
                      ],
                    ),
                  ),
                ),

                // ==========================================
                // NUMBER
                // ==========================================

                Positioned(
                  top: 15.h,
                  left: 15.w,
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 6.h,
                    ),
                    decoration:
                    BoxDecoration(
                      color: Colors.black
                          .withOpacity(.18),
                      borderRadius:
                      BorderRadius.circular(
                        50.r,
                      ),
                      border: Border.all(
                        color: Colors.white
                            .withOpacity(.10),
                      ),
                    ),
                    child: Text(
                      '#${index.toString().padLeft(2, '0')}',
                      style:
                      GoogleFonts.manrope(
                        color: Colors.white
                            .withOpacity(.85),
                        fontSize: 8.sp,
                        fontWeight:
                        FontWeight.w800,
                        letterSpacing: .8,
                      ),
                    ),
                  ),
                ),

                // ==========================================
                // ARROW
                // ==========================================

                Positioned(
                  top: 15.h,
                  right: 15.w,
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration:
                    BoxDecoration(
                      color: Colors.black
                          .withOpacity(.18),
                      shape:
                      BoxShape.circle,
                      border: Border.all(
                        color: Colors.white
                            .withOpacity(.10),
                      ),
                    ),
                    child: Icon(
                      Icons
                          .arrow_outward_rounded,
                      color:
                      Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),

                // ==========================================
                // TEXT
                // ==========================================

                Positioned(
                  left: 17.w,
                  right: 17.w,
                  bottom: 17.h,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        title.isEmpty
                            ? 'Wallpaper'
                            : title,
                        maxLines: 2,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        GoogleFonts.bebasNeue(
                          color:
                          Colors.white,
                          fontSize: 23.sp,
                          fontWeight:
                          FontWeight.w400,
                          height: .95,
                          letterSpacing:
                          -.7,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        'Tap to preview',
                        style:
                        GoogleFonts.manrope(
                          color: Colors.white
                              .withOpacity(
                            .62,
                          ),
                          fontSize: 9.sp,
                          fontWeight:
                          FontWeight.w500,
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
    );
  }
}

// ==================================================================
// CATEGORY TILE
// ==================================================================

class _CategoryTile
    extends StatelessWidget {
  final String title;
  final String thumbnail;
  final int count;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.title,
    required this.thumbnail,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final dark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    return _Pressable(
      onTap: onTap,
      scale: .96,
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(
          23.r,
        ),
        child: SizedBox(
          width: 145.w,
          height: 125.h,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                thumbnail,
                fit: BoxFit.cover,
                filterQuality:
                FilterQuality.low,
                cacheWidth: 450,
                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return Container(
                    color: dark
                        ? AppColors
                        .darkSurface
                        : AppColors
                        .lightSurface,
                    child: Icon(
                      Icons
                          .image_not_supported_outlined,
                      color: dark
                          ? AppColors
                          .darkMuted
                          : AppColors
                          .lightMuted,
                    ),
                  );
                },
              ),

              const DecoratedBox(
                decoration:
                BoxDecoration(
                  gradient:
                  LinearGradient(
                    begin:
                    Alignment.topCenter,
                    end:
                    Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xD9000000),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 13.w,
                right: 13.w,
                bottom: 12.h,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      GoogleFonts.bebasNeue(
                        color:
                        Colors.white,
                        fontSize: 16.sp,
                        fontWeight:
                        FontWeight.w400,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$count wallpapers',
                      style:
                      GoogleFonts.manrope(
                        color: Colors.white
                            .withOpacity(
                          .60,
                        ),
                        fontSize: 8.sp,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// HEADER BUTTON
// ==================================================================

class _HeaderButton
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final dark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    return _Pressable(
      onTap: onTap,
      scale: .90,
      child: Container(
        width: 43.w,
        height: 43.w,
        decoration:
        BoxDecoration(
          color: dark
              ? Colors.white
              .withOpacity(.055)
              : Colors.black
              .withOpacity(.045),
          borderRadius:
          BorderRadius.circular(
            15.r,
          ),
          border: Border.all(
            color: dark
                ? Colors.white
                .withOpacity(.06)
                : Colors.black
                .withOpacity(.05),
          ),
        ),
        child: Icon(
          icon,
          color: dark
              ? Colors.white
              : Colors.black,
          size: 19.sp,
        ),
      ),
    );
  }
}

// ==================================================================
// PRESSABLE
// ==================================================================

class _Pressable
    extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scale;

  const _Pressable({
    required this.child,
    required this.onTap,
    this.scale = .96,
  });

  @override
  State<_Pressable> createState() =>
      _PressableState();
}

class _PressableState
    extends State<_Pressable> {
  bool pressed = false;

  void _setPressed(
      bool value,
      ) {
    if (pressed == value) {
      return;
    }

    setState(() {
      pressed = value;
    });
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return GestureDetector(
      behavior:
      HitTestBehavior.opaque,

      onTapDown: (_) {
        _setPressed(true);
      },

      onTapCancel: () {
        _setPressed(false);
      },

      onTapUp: (_) {
        _setPressed(false);
        widget.onTap();
      },

      child: AnimatedScale(
        scale: pressed
            ? widget.scale
            : 1.0,
        duration:
        const Duration(
          milliseconds: 120,
        ),
        curve:
        Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}