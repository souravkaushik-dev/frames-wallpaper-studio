import 'dart:convert';
import 'dart:ui';

import 'package:dotty/screens/previewscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../constants/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
  });

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller =
  TextEditingController();

  final FocusNode _searchFocus =
  FocusNode();

  late final AnimationController
  _ambientController;

  List<Map<String, dynamic>> wallpapers =
  [];

  List<Map<String, dynamic>> filtered =
  [];

  bool isLoading = true;
  bool hasError = false;

  final List<double> _cardHeights = [
    345,
    265,
    390,
    305,
  ];

  @override
  void initState() {
    super.initState();

    _ambientController =
    AnimationController(
      vsync: this,
      duration:
      const Duration(seconds: 10),
    )..repeat(reverse: true);

    _controller.addListener(
      _onSearchChanged,
    );

    loadData();
  }

  @override
  void dispose() {
    _controller.removeListener(
      _onSearchChanged,
    );

    _controller.dispose();
    _searchFocus.dispose();
    _ambientController.dispose();

    super.dispose();
  }

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

  // ============================================================
  // API
  // ============================================================

  Future<void> loadData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        hasError = false;
      });
    }

    try {
      final apiUrl =
      dotenv.env['API_URL'];

      if (apiUrl == null ||
          apiUrl.trim().isEmpty) {
        throw Exception(
          'API_URL is missing',
        );
      }

      final response =
      await http.get(
        Uri.parse(apiUrl),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'API returned ${response.statusCode}',
        );
      }

      final decoded =
      jsonDecode(response.body);

      final List<
          Map<String, dynamic>> result =
      [];

      if (decoded is Map &&
          decoded['categories'] is Map) {
        final categories =
        decoded['categories']
        as Map;

        categories.forEach(
              (category, value) {
            if (value is Map &&
                value['wallpapers']
                is List) {
              final images =
              value['wallpapers']
              as List;

              for (final image
              in images) {
                if (image is String &&
                    image
                        .trim()
                        .isNotEmpty) {
                  result.add({
                    'image': image,
                    'category':
                    category.toString(),
                  });
                }
              }
            }
          },
        );
      }

      if (!mounted) return;

      setState(() {
        wallpapers = result;
        filtered = result;
        isLoading = false;
      });
    } catch (error) {
      debugPrint(
        'Search API error: $error',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearchChanged() {
    final query =
    _controller.text
        .trim()
        .toLowerCase();

    if (query.isEmpty) {
      if (!mounted) return;

      setState(() {
        filtered = wallpapers;
      });

      return;
    }

    final results =
    wallpapers.where(
          (item) {
        final category =
        item['category']
            .toString()
            .toLowerCase();

        final image =
        item['image']
            .toString()
            .toLowerCase();

        final name =
        getWallpaperName(
          item['image'].toString(),
        ).toLowerCase();

        return category
            .contains(query) ||
            image.contains(query) ||
            name.contains(query);
      },
    ).toList();

    if (!mounted) return;

    setState(() {
      filtered = results;
    });
  }

  void _clearSearch() {
    _controller.clear();
    _searchFocus.unfocus();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,

      body: Stack(
        children: [
          _buildAmbientBackground(),

          SafeArea(
            child: CustomScrollView(
              physics:
              const BouncingScrollPhysics(),

              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),

                if (isLoading)
                  _buildLoadingGrid()
                else if (hasError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child:
                    _buildErrorState(),
                  )
                else if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child:
                      _buildEmptyState(),
                    )
                  else
                    _buildWallpaperGrid(),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100.h,
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
  // AMBIENT BACKGROUND
  // ============================================================

  Widget _buildAmbientBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation:
          _ambientController,
          builder:
              (context, child) {
            final value =
                _ambientController.value;

            return Stack(
              children: [
                Positioned(
                  top:
                  -210.h +
                      (value * 30.h),
                  right:
                  -190.w,
                  child:
                  _ambientOrb(
                    410.w,
                    _isDark
                        ? .045
                        : .018,
                  ),
                ),
                Positioned(
                  top:
                  410.h -
                      (value * 25.h),
                  left:
                  -190.w,
                  child:
                  _ambientOrb(
                    340.w,
                    _isDark
                        ? .025
                        : .012,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _ambientOrb(
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
        AppColors.accent
            .withOpacity(
          opacity,
        ),
      ),
    )
        .animate(
      onPlay: (controller) {
        controller.repeat(
          reverse: true,
        );
      },
    )
        .blurXY(
      begin: 90,
      end: 125,
      duration:
      const Duration(
        seconds: 8,
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding:
      EdgeInsets.fromLTRB(
        20.w,
        18.h,
        20.w,
        24.h,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _buildTopBar(),

          SizedBox(
            height: 34.h,
          ),

          Text(
            'SEARCH',
            style:
            GoogleFonts.bebasNeue(
              color: _primary,
              fontSize: 76.sp,
              height: .80,
              letterSpacing: 2.4,
            ),
          )
              .animate()
              .fadeIn(
            duration:
            const Duration(
              milliseconds: 750,
            ),
          )
              .moveY(
            begin: 55,
            end: 0,
            curve:
            Curves.easeOutExpo,
          )
              .blurXY(
            begin: 2,
            end: 0,
            duration:
            const Duration(
              milliseconds: 600,
            ),
          ),

          SizedBox(
            height: 13.h,
          ),

          Text(
            'Find the perfect visual for your screen.',
            style:
            GoogleFonts.inter(
              color: _secondary,
              fontSize: 13.sp,
              height: 1.65,
              fontWeight:
              FontWeight.w500,
            ),
          )
              .animate()
              .fadeIn(
            delay:
            const Duration(
              milliseconds: 160,
            ),
          )
              .moveY(
            begin: 15,
            end: 0,
          ),

          SizedBox(
            height: 23.h,
          ),

          _buildSearchBar(),

          SizedBox(
            height: 17.h,
          ),

          _buildInfoPills(),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          behavior:
          HitTestBehavior.opaque,
          onTap: () {
            Navigator.pop(context);
          },
          child: _glassCircleButton(
            Icons
                .arrow_back_ios_new_rounded,
          ),
        ),

        SizedBox(
          width: 14.w,
        ),

        Expanded(
          child: Row(
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                decoration:
                const BoxDecoration(
                  shape:
                  BoxShape.circle,
                  color:
                  AppColors.accent,
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
              Text(
                'DISCOVER COLLECTIONS',
                style:
                GoogleFonts.inter(
                  color: _secondary,
                  fontSize: 8.sp,
                  fontWeight:
                  FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),

        _resultCounter(),
      ],
    )
        .animate()
        .fadeIn(
      duration:
      const Duration(
        milliseconds: 550,
      ),
    )
        .moveY(
      begin: -18,
      end: 0,
      curve:
      Curves.easeOutCubic,
    );
  }

  Widget _glassCircleButton(
      IconData icon,
      ) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(
        19.r,
      ),
      child: BackdropFilter(
        filter:
        ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          width: 52.w,
          height: 52.w,
          decoration:
          BoxDecoration(
            color:
            _surface.withOpacity(
              _isDark ? .72 : .88,
            ),
            borderRadius:
            BorderRadius.circular(
              19.r,
            ),
            border:
            Border.all(
              color: _divider,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: _primary,
            size: 18.sp,
          ),
        ),
      ),
    );
  }

  Widget _resultCounter() {
    return AnimatedContainer(
      duration:
      const Duration(
        milliseconds: 300,
      ),
      padding:
      EdgeInsets.symmetric(
        horizontal: 11.w,
        vertical: 8.h,
      ),
      decoration:
      BoxDecoration(
        color:
        _surfaceSoft,
        borderRadius:
        BorderRadius.circular(
          14.r,
        ),
      ),
      child: Text(
        '${filtered.length}',
        style:
        GoogleFonts.inter(
          color: _primary,
          fontSize: 9.sp,
          fontWeight:
          FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(
        24.r,
      ),
      child: BackdropFilter(
        filter:
        ImageFilter.blur(
          sigmaX: 16,
          sigmaY: 16,
        ),
        child: AnimatedContainer(
          duration:
          const Duration(
            milliseconds: 220,
          ),
          height: 60.h,
          padding:
          EdgeInsets.symmetric(
            horizontal: 17.w,
          ),
          decoration:
          BoxDecoration(
            color:
            _surface.withOpacity(
              _isDark ? .82 : .94,
            ),
            borderRadius:
            BorderRadius.circular(
              24.r,
            ),
            border:
            Border.all(
              color: _divider,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: _muted,
                size: 22.sp,
              ),

              SizedBox(
                width: 12.w,
              ),

              Expanded(
                child: TextField(
                  controller:
                  _controller,
                  focusNode:
                  _searchFocus,
                  textInputAction:
                  TextInputAction.search,
                  cursorColor:
                  AppColors.accent,
                  style:
                  GoogleFonts.inter(
                    color: _primary,
                    fontSize: 14.sp,
                    fontWeight:
                    FontWeight.w600,
                  ),
                  decoration:
                  InputDecoration(
                    border:
                    InputBorder.none,
                    enabledBorder:
                    InputBorder.none,
                    focusedBorder:
                    InputBorder.none,
                    disabledBorder:
                    InputBorder.none,
                    filled: false,
                    contentPadding:
                    EdgeInsets.zero,
                    hintText:
                    'Search wallpapers...',
                    hintStyle:
                    GoogleFonts.inter(
                      color: _muted,
                      fontSize: 13.sp,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ),
              ),

              AnimatedSwitcher(
                duration:
                const Duration(
                  milliseconds: 180,
                ),
                child:
                _controller
                    .text
                    .isNotEmpty
                    ? GestureDetector(
                  key:
                  const ValueKey(
                    'clear',
                  ),
                  onTap:
                  _clearSearch,
                  child: Icon(
                    Icons
                        .close_rounded,
                    color:
                    _muted,
                    size:
                    20.sp,
                  ),
                )
                    : const SizedBox(
                  key:
                  ValueKey(
                    'empty',
                  ),
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
      const Duration(
        milliseconds: 280,
      ),
      duration:
      const Duration(
        milliseconds: 600,
      ),
    )
        .moveY(
      begin: 18,
      end: 0,
      curve:
      Curves.easeOutExpo,
    );
  }

  // ============================================================
  // PILLS
  // ============================================================

  Widget _buildInfoPills() {
    return Row(
      children: [
        _pill(
          Icons.auto_awesome_rounded,
          'Premium',
        ),
        SizedBox(
          width: 8.w,
        ),
        _pill(
          Icons.high_quality_rounded,
          '4K',
        ),
        SizedBox(
          width: 8.w,
        ),
        _pill(
          Icons.wallpaper_rounded,
          '${filtered.length}',
        ),
      ],
    )
        .animate()
        .fadeIn(
      delay:
      const Duration(
        milliseconds: 380,
      ),
    )
        .moveY(
      begin: 12,
      end: 0,
    );
  }

  Widget _pill(
      IconData icon,
      String label,
      ) {
    return Container(
      padding:
      EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 9.h,
      ),
      decoration:
      BoxDecoration(
        color:
        _surface.withOpacity(
          _isDark ? .72 : .86,
        ),
        borderRadius:
        BorderRadius.circular(
          16.r,
        ),
        border:
        Border.all(
          color: _divider,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _secondary,
            size: 14.sp,
          ),
          SizedBox(
            width: 7.w,
          ),
          Text(
            label,
            style:
            GoogleFonts.inter(
              color: _secondary,
              fontSize: 9.sp,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GRID
  // ============================================================

  SliverPadding _buildWallpaperGrid() {
    return SliverPadding(
      padding:
      EdgeInsets.symmetric(
        horizontal: 20.w,
      ),
      sliver:
      SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        childCount:
        filtered.length,
        itemBuilder:
            (context, index) {
          return _buildWallpaperCard(
            context,
            index,
          );
        },
      ),
    );
  }

  // ============================================================
  // WALLPAPER CARD
  // ============================================================

  Widget _buildWallpaperCard(
      BuildContext context,
      int index,
      ) {
    final item =
    filtered[index];

    final image =
    item['image'].toString();

    final category =
    item['category'].toString();

    final height =
        _cardHeights[
        index %
            _cardHeights.length]
            .h;

    return GestureDetector(
      behavior:
      HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration:
            const Duration(
              milliseconds: 450,
            ),
            reverseTransitionDuration:
            const Duration(
              milliseconds: 350,
            ),
            pageBuilder:
                (
                context,
                animation,
                secondaryAnimation,
                ) {
              return PreviewScreen(
                imageUrl: image,
                category:
                category,
              );
            },
            transitionsBuilder:
                (
                context,
                animation,
                secondaryAnimation,
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
                    begin: .985,
                    end: 1,
                  ).animate(curve),
                  child: child,
                ),
              );
            },
          ),
        );
      },
      child: Hero(
        tag: image,
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(
            31.r,
          ),
          child: SizedBox(
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImage(
                  image,
                  height,
                ),

                _buildCinematicOverlay(),

                _buildCategoryLabel(
                  category,
                ),

                _buildWallpaperInfo(
                  image,
                ),
              ],
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
        70 * index,
      ),
      duration:
      const Duration(
        milliseconds: 700,
      ),
    )
        .moveY(
      begin: 55,
      end: 0,
      duration:
      const Duration(
        milliseconds: 700,
      ),
      curve:
      Curves.easeOutExpo,
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
        milliseconds: 700,
      ),
      curve:
      Curves.easeOutExpo,
    )
        .blurXY(
      begin: 1.5,
      end: 0,
      duration:
      const Duration(
        milliseconds: 500,
      ),
    );
  }

  Widget _buildImage(
      String image,
      double height,
      ) {
    return Image.network(
      image,
      width:
      double.infinity,
      height: height,
      fit: BoxFit.cover,
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
          child: Center(
            child: Icon(
              Icons
                  .image_not_supported_outlined,
              color: _muted,
              size: 30.sp,
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CINEMATIC OVERLAY
  // ============================================================

  Widget _buildCinematicOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration:
        BoxDecoration(
          gradient:
          LinearGradient(
            begin:
            Alignment.topCenter,
            end:
            Alignment.bottomCenter,
            stops: const [
              0.0,
              0.45,
              0.78,
              1.0,
            ],
            colors: [
              Colors.black
                  .withOpacity(.02),
              Colors.black
                  .withOpacity(.04),
              Colors.black
                  .withOpacity(.28),
              Colors.black
                  .withOpacity(.76),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  Widget _buildCategoryLabel(
      String category,
      ) {
    return Positioned(
      top: 15.h,
      left: 15.w,
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(
          14.r,
        ),
        child: BackdropFilter(
          filter:
          ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Container(
            padding:
            EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 7.h,
            ),
            decoration:
            BoxDecoration(
              color:
              Colors.black
                  .withOpacity(.28),
              borderRadius:
              BorderRadius.circular(
                14.r,
              ),
              // IMPORTANT:
              // No accent/green border.
              border:
              Border.all(
                color: Colors.white
                    .withOpacity(.10),
                width: .7,
              ),
            ),
            child: Text(
              category
                  .toUpperCase(),
              style:
              GoogleFonts.inter(
                color: Colors.white
                    .withOpacity(.88),
                fontSize: 7.5.sp,
                fontWeight:
                FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // WALLPAPER INFO
  // ============================================================

  Widget _buildWallpaperInfo(
      String image,
      ) {
    return Positioned(
      left: 16.w,
      right: 16.w,
      bottom: 16.h,
      child: Row(
        children: [
          Expanded(
            child: Text(
              getWallpaperName(
                image,
              ),
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style:
              GoogleFonts.inter(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),

          SizedBox(
            width: 10.w,
          ),

          Container(
            width: 27.w,
            height: 27.w,
            decoration:
            BoxDecoration(
              color:
              Colors.black
                  .withOpacity(.28),
              shape:
              BoxShape.circle,
              border:
              Border.all(
                color: Colors.white
                    .withOpacity(.12),
                width: .7,
              ),
            ),
            child: Icon(
              Icons
                  .arrow_outward_rounded,
              color:
              Colors.white
                  .withOpacity(.88),
              size: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING GRID
  // ============================================================

  SliverPadding _buildLoadingGrid() {
    return SliverPadding(
      padding:
      EdgeInsets.symmetric(
        horizontal: 20.w,
      ),
      sliver:
      SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        childCount: 6,
        itemBuilder:
            (context, index) {
          return _buildSkeleton(
            index,
          );
        },
      ),
    );
  }

  Widget _buildSkeleton(
      int index,
      ) {
    final height =
        _cardHeights[
        index %
            _cardHeights.length]
            .h;

    return Container(
      height: height,
      decoration:
      BoxDecoration(
        color:
        _surfaceSoft,
        borderRadius:
        BorderRadius.circular(
          31.r,
        ),
      ),
    )
        .animate(
      onPlay: (controller) {
        controller.repeat();
      },
    )
        .shimmer(
      duration:
      const Duration(
        milliseconds: 1500,
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
        EdgeInsets.symmetric(
          horizontal: 40.w,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 78.w,
              height: 78.w,
              decoration:
              BoxDecoration(
                color:
                _surfaceSoft,
                borderRadius:
                BorderRadius.circular(
                  26.r,
                ),
              ),
              child: Icon(
                Icons
                    .search_off_rounded,
                color: _muted,
                size: 34.sp,
              ),
            ),

            SizedBox(
              height: 22.h,
            ),

            Text(
              'NOTHING FOUND',
              style:
              GoogleFonts.bebasNeue(
                color: _primary,
                fontSize: 32.sp,
                letterSpacing: 1.4,
              ),
            ),

            SizedBox(
              height: 8.h,
            ),

            Text(
              'Try another wallpaper name or collection.',
              textAlign:
              TextAlign.center,
              style:
              GoogleFonts.inter(
                color: _secondary,
                fontSize: 12.sp,
                height: 1.6,
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
        milliseconds: 600,
      ),
    )
        .moveY(
      begin: 20,
      end: 0,
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding:
        EdgeInsets.symmetric(
          horizontal: 40.w,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 78.w,
              height: 78.w,
              decoration:
              BoxDecoration(
                color:
                _surfaceSoft,
                borderRadius:
                BorderRadius.circular(
                  26.r,
                ),
              ),
              child: Icon(
                Icons
                    .cloud_off_rounded,
                color: _muted,
                size: 34.sp,
              ),
            ),

            SizedBox(
              height: 22.h,
            ),

            Text(
              'UNABLE TO LOAD',
              style:
              GoogleFonts.bebasNeue(
                color: _primary,
                fontSize: 31.sp,
                letterSpacing: 1.4,
              ),
            ),

            SizedBox(
              height: 8.h,
            ),

            Text(
              'Something went wrong while loading the collection.',
              textAlign:
              TextAlign.center,
              style:
              GoogleFonts.inter(
                color: _secondary,
                fontSize: 12.sp,
                height: 1.6,
              ),
            ),

            SizedBox(
              height: 22.h,
            ),

            GestureDetector(
              onTap: loadData,
              child: Container(
                padding:
                EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 12.h,
                ),
                decoration:
                BoxDecoration(
                  color:
                  AppColors.accent,
                  borderRadius:
                  BorderRadius.circular(
                    17.r,
                  ),
                ),
                child: Text(
                  'TRY AGAIN',
                  style:
                  GoogleFonts.inter(
                    color:
                    Colors.white,
                    fontSize:
                    9.sp,
                    fontWeight:
                    FontWeight.w800,
                    letterSpacing:
                    1.2,
                  ),
                ),
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
        milliseconds: 600,
      ),
    )
        .moveY(
      begin: 20,
      end: 0,
    );
  }

  // ============================================================
  // NAME
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
        .where(
          (word) => word.isNotEmpty,
    )
        .map(
          (word) =>
      word[0].toUpperCase() +
          word.substring(1),
    )
        .join(' ');
  }
}