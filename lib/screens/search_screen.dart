import 'dart:convert';

import 'package:dotty/screens/previewscreen.dart';
import 'package:flutter/material.dart';
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
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> wallpapers = [];
  List<Map<String, dynamic>> filtered = [];

  bool isLoading = true;
  bool hasError = false;
  bool _searchFocused = false;

  final List<double> _cardHeights = [
    345,
    265,
    390,
    305,
  ];

  @override
  void initState() {
    super.initState();

    _controller.addListener(_onSearchChanged);

    _searchFocus.addListener(() {
      if (!mounted) return;

      setState(() {
        _searchFocused = _searchFocus.hasFocus;
      });
    });

    loadData();
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // COLORS
  // ============================================================

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

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
      final apiUrl = dotenv.env['API_URL'];

      if (apiUrl == null || apiUrl.trim().isEmpty) {
        throw Exception('API_URL is missing');
      }

      final response = await http.get(
        Uri.parse(apiUrl),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'API returned ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      final List<Map<String, dynamic>> result = [];

      if (decoded is Map &&
          decoded['categories'] is Map) {
        final categories =
        decoded['categories'] as Map;

        categories.forEach(
              (category, value) {
            if (value is Map &&
                value['wallpapers'] is List) {
              final images =
              value['wallpapers'] as List;

              for (final image in images) {
                if (image is String &&
                    image.trim().isNotEmpty) {
                  result.add({
                    'image': image,
                    'category': category.toString(),
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
    final query = _controller.text
        .trim()
        .toLowerCase();

    if (query.isEmpty) {
      if (!mounted) return;

      setState(() {
        filtered = wallpapers;
      });

      return;
    }

    final results = wallpapers.where(
          (item) {
        final category = item['category']
            .toString()
            .toLowerCase();

        final image = item['image']
            .toString()
            .toLowerCase();

        final name = getWallpaperName(
          item['image'].toString(),
        ).toLowerCase();

        return category.contains(query) ||
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

  void _openSearch() {
    _searchFocus.requestFocus();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
          // ------------------------------------------------------
          // MAIN CONTENT
          // ------------------------------------------------------

          SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              cacheExtent: 700,

              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),

                if (isLoading)
                  _buildLoadingGrid()
                else if (hasError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildErrorState(),
                  )
                else if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else
                    _buildWallpaperGrid(),
              ],
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
        20.w,
        18.h,
        20.w,
        22.h,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _buildTopBar(),

          SizedBox(height: 12.h),

          _buildTopSearch(),

          SizedBox(height: 27.h),

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'DISCOVER',
                  style: GoogleFonts.bebasNeue(
                    color: _primary,
                    fontSize: 62.sp,
                    height: .78,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.only(
                  bottom: 5.h,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 7.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent
                      .withOpacity(.10),
                  borderRadius:
                  BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.accent
                        .withOpacity(.22),
                  ),
                ),
                child: Text(
                  '${filtered.length}',
                  style: GoogleFonts.manrope(
                    color: AppColors.accent,
                    fontSize: 10.sp,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          Text(
            'Find something that feels like you.',
            style: GoogleFonts.manrope(
              color: _secondary,
              fontSize: 13.sp,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 22.h),

          _buildQuickFilters(),
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
        _iconButton(
          Icons.arrow_back_ios_new_rounded,
          onTap: () {
            Navigator.pop(context);
          },
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Row(
            children: [
              Container(
                width: 7.w,
                height: 7.w,
                decoration:
                const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                ),
              ),

              SizedBox(width: 8.w),

              Text(
                'WALLPAPER LAB',
                style: GoogleFonts.manrope(
                  color: _secondary,
                  fontSize: 8.sp,
                  fontWeight:
                  FontWeight.w500,
                  letterSpacing: 1.7,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 7.h,
          ),
          decoration: BoxDecoration(
            color: _surfaceSoft,
            borderRadius:
            BorderRadius.circular(12.r),
          ),
          child: Text(
            '4K',
            style: GoogleFonts.manrope(
              color: _primary,
              fontSize: 8.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconButton(
      IconData icon, {
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(17.r),
        child: Ink(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius:
            BorderRadius.circular(17.r),
            border: Border.all(
              color: _divider,
            ),
          ),
          child: Icon(
            icon,
            color: _primary,
            size: 17.sp,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // QUICK FILTERS
  // ============================================================

  Widget _buildQuickFilters() {
    return SizedBox(
      height: 38.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics:
        const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          _quickChip(
            icon: Icons.auto_awesome_rounded,
            label: 'ALL',
            active:
            _controller.text.isEmpty,
            onTap: _clearSearch,
          ),

          SizedBox(width: 8.w),

          _quickChip(
            icon: Icons.trending_up_rounded,
            label: 'TRENDING',
            onTap: () {
              _controller.text = 'trending';
            },
          ),

          SizedBox(width: 8.w),

          _quickChip(
            icon: Icons.phone_android_rounded,
            label: 'MOBILE',
            onTap: () {
              _controller.text = 'mobile';
            },
          ),

          SizedBox(width: 8.w),

          _quickChip(
            icon: Icons.nightlight_round,
            label: 'DARK',
            onTap: () {
              _controller.text = 'dark';
            },
          ),
        ],
      ),
    );
  }

  Widget _quickChip({
    required IconData icon,
    required String label,
    bool active = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(15.r),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
          ),
          decoration: BoxDecoration(
            color: active
                ? AppColors.accent
                .withOpacity(.12)
                : _surface,
            borderRadius:
            BorderRadius.circular(15.r),
            border: Border.all(
              color: active
                  ? AppColors.accent
                  .withOpacity(.30)
                  : _divider,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13.sp,
                color: active
                    ? AppColors.accent
                    : _muted,
              ),

              SizedBox(width: 6.w),

              Text(
                label,
                style: GoogleFonts.manrope(
                  color: active
                      ? AppColors.accent
                      : _secondary,
                  fontSize: 8.sp,
                  fontWeight:
                  FontWeight.w500,
                  letterSpacing: .8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM SEARCH BAR
  // ============================================================

  Widget _buildTopSearch() {
    final hasText = _controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      height: _searchFocused ? 58.h : 54.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: _isDark
            ? const Color(0xFF171918)
            : Colors.white,
        borderRadius: BorderRadius.circular(19.r),
        border: Border.all(
          color: _searchFocused
              ? AppColors.accent.withOpacity(.34)
              : _divider.withOpacity(.72),
          width: _searchFocused ? 1.15 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              _isDark ? .16 : .055,
            ),
            blurRadius: _searchFocused ? 25 : 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(
                _searchFocused ? .14 : .085,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.search_rounded,
              color: _searchFocused
                  ? AppColors.accent
                  : _secondary,
              size: 19.sp,
            ),
          ),

          SizedBox(width: 9.w),

          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _searchFocus,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.accent,
              style: GoogleFonts.manrope(
                color: _primary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Search wallpapers',
                hintStyle: GoogleFonts.manrope(
                  color: _muted.withOpacity(.82),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: hasText
                ? Material(
              key: const ValueKey('clear'),
              color: Colors.transparent,
              child: InkWell(
                onTap: _clearSearch,
                borderRadius: BorderRadius.circular(14.r),
                child: SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: Icon(
                    Icons.close_rounded,
                    color: _muted,
                    size: 18.sp,
                  ),
                ),
              ),
            )
                : Material(
              key: const ValueKey('searchAction'),
              color: Colors.transparent,
              child: InkWell(
                onTap: _openSearch,
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: _surfaceSoft,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: _secondary,
                    size: 16.sp,
                  ),
                ),
              ),
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
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),

      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,

        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,

        childCount: filtered.length,

        itemBuilder: (context, index) {
          final item = filtered[index];

          final image =
          item['image'].toString();

          final category =
          item['category'].toString();

          return TweenAnimationBuilder<double>(
            key: ValueKey('entry-$image'),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(
              milliseconds: 420 + ((index % 6) * 45),
            ),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 14 * (1 - value)),
                  child: Transform.scale(
                    scale: .975 + (.025 * value),
                    child: child,
                  ),
                ),
              );
            },
            child: RepaintBoundary(
              key: ValueKey(image),
              child: _WallpaperCard(
                image: image,
                category: category,
                height:
                _cardHeights[
                index %
                    _cardHeights.length]
                    .h,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration:
                      const Duration(
                        milliseconds: 280,
                      ),
                      reverseTransitionDuration:
                      const Duration(
                        milliseconds: 220,
                      ),
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
                        final curved =
                        CurvedAnimation(
                          parent: animation,
                          curve:
                          Curves.easeOutCubic,
                        );

                        return FadeTransition(
                          opacity: curved,
                          child: ScaleTransition(
                            scale:
                            Tween<double>(
                              begin: .985,
                              end: 1,
                            ).animate(curved),
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // WALLPAPER CARD
  // ============================================================

  Widget _WallpaperCard({
    required String image,
    required String category,
    required double height,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(26.r),

        child: Ink(
          height: height,

          decoration: BoxDecoration(
            color: _surfaceSoft,
            borderRadius:
            BorderRadius.circular(26.r),
          ),

          child: ClipRRect(
            borderRadius:
            BorderRadius.circular(26.r),

            child: Stack(
              fit: StackFit.expand,
              children: [
                // ------------------------------------------------
                // IMAGE
                // ------------------------------------------------

                Image.network(
                  image,

                  width: double.infinity,
                  height: height,

                  fit: BoxFit.cover,

                  filterQuality:
                  FilterQuality.medium,

                  cacheWidth: 900,

                  gaplessPlayback: true,

                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return Container(
                      color: _surfaceSoft,
                      child: Center(
                        child: Icon(
                          Icons
                              .image_not_supported_outlined,
                          color: _muted,
                          size: 28.sp,
                        ),
                      ),
                    );
                  },
                ),

                // ------------------------------------------------
                // DARK OVERLAY
                // ------------------------------------------------

                const Positioned.fill(
                  child: DecoratedBox(
                    decoration:
                    BoxDecoration(
                      gradient:
                      LinearGradient(
                        begin:
                        Alignment.topCenter,
                        end:
                        Alignment.bottomCenter,
                        stops: [
                          0.0,
                          0.45,
                          1.0,
                        ],
                        colors: [
                          Color(0x05000000),
                          Color(0x15000000),
                          Color(0xB8000000),
                        ],
                      ),
                    ),
                  ),
                ),

                // ------------------------------------------------
                // CATEGORY
                // ------------------------------------------------

                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 6.h,
                    ),

                    decoration:
                    BoxDecoration(
                      color: Colors.black
                          .withOpacity(.30),

                      borderRadius:
                      BorderRadius.circular(
                        12.r,
                      ),

                      border: Border.all(
                        color: Colors.white
                            .withOpacity(.12),
                      ),
                    ),

                    child: Text(
                      category.toUpperCase(),
                      style: GoogleFonts.manrope(
                        color: Colors.white
                            .withOpacity(.90),
                        fontSize: 7.sp,
                        fontWeight:
                        FontWeight.w500,
                        letterSpacing: .9,
                      ),
                    ),
                  ),
                ),

                // ------------------------------------------------
                // BOTTOM INFORMATION
                // ------------------------------------------------

                Positioned(
                  left: 13.w,
                  right: 13.w,
                  bottom: 13.h,

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
                          GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      Container(
                        width: 30.w,
                        height: 30.w,

                        decoration:
                        BoxDecoration(
                          color: Colors.black
                              .withOpacity(.30),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white
                                .withOpacity(.12),
                          ),
                        ),

                        child: Icon(
                          Icons
                              .arrow_outward_rounded,
                          color: Colors.white
                              .withOpacity(.90),
                          size: 12.sp,
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

  // ============================================================
  // LOADING
  // ============================================================

  SliverPadding _buildLoadingGrid() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),

      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childCount: 6,

        itemBuilder: (
            context,
            index,
            ) {
          return _SkeletonCard(
            height:
            _cardHeights[
            index %
                _cardHeights.length]
                .h,
          );
        },
      ),
    );
  }

  // ============================================================
  // SKELETON
  // ============================================================

  Widget _SkeletonCard({
    required double height,
  }) {
    return Container(
      height: height,

      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius:
        BorderRadius.circular(26.r),
      ),

      child: Stack(
        children: [
          Positioned(
            left: 13.w,
            top: 13.h,
            child: Container(
              width: 62.w,
              height: 22.h,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius:
                BorderRadius.circular(
                  10.r,
                ),
              ),
            ),
          ),

          Positioned(
            left: 13.w,
            right: 13.w,
            bottom: 13.h,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius:
                      BorderRadius.circular(
                        8.r,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 8.w),

                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration:
                  BoxDecoration(
                    color: _surface,
                    shape: BoxShape.circle,
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
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 35.w,
        ),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Container(
              width: 76.w,
              height: 76.w,

              decoration: BoxDecoration(
                color: _surfaceSoft,
                borderRadius:
                BorderRadius.circular(25.r),
              ),

              child: Icon(
                Icons.search_off_rounded,
                color: _muted,
                size: 32.sp,
              ),
            ),

            SizedBox(height: 20.h),

            Text(
              'NOTHING FOUND',
              style: GoogleFonts.bebasNeue(
                color: _primary,
                fontSize: 32.sp,
                letterSpacing: 1.2,
              ),
            ),

            SizedBox(height: 7.h),

            Text(
              'Try another wallpaper name or collection.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: _secondary,
                fontSize: 12.sp,
                height: 1.6,
              ),
            ),

            SizedBox(height: 18.h),

            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _clearSearch,
                borderRadius:
                BorderRadius.circular(15.r),

                child: Ink(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 17.w,
                    vertical: 11.h,
                  ),

                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius:
                    BorderRadius.circular(
                      15.r,
                    ),
                  ),

                  child: Text(
                    'CLEAR SEARCH',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight:
                      FontWeight.w500,
                      letterSpacing: 1,
                    ),
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
  // ERROR
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 35.w,
        ),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Container(
              width: 76.w,
              height: 76.w,

              decoration: BoxDecoration(
                color: _surfaceSoft,
                borderRadius:
                BorderRadius.circular(25.r),
              ),

              child: Icon(
                Icons.cloud_off_rounded,
                color: _muted,
                size: 32.sp,
              ),
            ),

            SizedBox(height: 20.h),

            Text(
              'UNABLE TO LOAD',
              style: GoogleFonts.bebasNeue(
                color: _primary,
                fontSize: 31.sp,
                letterSpacing: 1.2,
              ),
            ),

            SizedBox(height: 7.h),

            Text(
              'Something went wrong while loading the collection.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: _secondary,
                fontSize: 12.sp,
                height: 1.6,
              ),
            ),

            SizedBox(height: 20.h),

            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: loadData,
                borderRadius:
                BorderRadius.circular(15.r),

                child: Ink(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),

                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius:
                    BorderRadius.circular(
                      15.r,
                    ),
                  ),

                  child: Text(
                    'TRY AGAIN',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 9.sp,
                      fontWeight:
                      FontWeight.w500,
                      letterSpacing: 1.1,
                    ),
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

    fileName = fileName.replaceAll(
      RegExp(
        r'\.(jpg|jpeg|png|webp)$',
        caseSensitive: false,
      ),
      '',
    );

    fileName = fileName.replaceAll(
      RegExp(
        r'-\d+x\d+-\d+$',
      ),
      '',
    );

    fileName = fileName.replaceAll(
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