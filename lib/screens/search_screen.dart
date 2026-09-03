import 'dart:convert';
import 'dart:math' as math;

import 'package:dotty/screens/previewscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _controller =
  TextEditingController();

  final FocusNode _searchFocus =
  FocusNode();

  final ScrollController _scrollController =
  ScrollController();

  late AnimationController _introController;

  // ============================================================
  // DATA
  // ============================================================

  List<Map<String, dynamic>> wallpapers = [];

  List<Map<String, dynamic>> filtered = [];

  /// These are populated directly from:
  ///
  /// decoded['categories']
  ///
  /// No hard-coded wallpaper categories.
  List<String> categories = [];

  String selectedCategory = 'ALL';

  // ============================================================
  // STATES
  // ============================================================

  bool isLoading = true;

  bool hasError = false;

  bool searchFocused = false;

  bool isRefreshing = false;

  // ============================================================
  // CARD HEIGHTS
  // ============================================================

  final List<double> _cardHeights = [
    330,
    245,
    300,
    225,
    275,
    255,
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 850,
      ),
    );

    _controller.addListener(
      _onSearchChanged,
    );

    _searchFocus.addListener(
      _onFocusChanged,
    );

    _introController.forward();

    loadData();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _controller.removeListener(
      _onSearchChanged,
    );

    _searchFocus.removeListener(
      _onFocusChanged,
    );

    _controller.dispose();

    _searchFocus.dispose();

    _scrollController.dispose();

    _introController.dispose();

    super.dispose();
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

  // ============================================================
  // FOCUS
  // ============================================================

  void _onFocusChanged() {
    if (!mounted) return;

    setState(() {
      searchFocused =
          _searchFocus.hasFocus;
    });
  }

  // ============================================================
  // API
  // ============================================================

  Future<void> loadData({
    bool refresh = false,
  }) async {
    if (refresh) {
      setState(() {
        isRefreshing = true;
        hasError = false;
      });
    } else {
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

      final response = await http.get(
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

      final List<String>
      apiCategories = [];

      // ========================================================
      // DIRECT API CATEGORY EXTRACTION
      // ========================================================

      if (decoded is Map &&
          decoded['categories'] is Map) {
        final Map categoryMap =
        decoded['categories'] as Map;

        categoryMap.forEach(
              (category, value) {
            final categoryName =
            category.toString().trim();

            if (categoryName.isEmpty) {
              return;
            }

            // Add category directly from API.
            apiCategories.add(
              categoryName,
            );

            // Get wallpapers for category.
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
                    'image':
                    image.trim(),
                    'category':
                    categoryName,
                  });
                }
              }
            }
          },
        );
      }

      // ========================================================
      // REMOVE DUPLICATE CATEGORIES
      // ========================================================

      final uniqueCategories =
      <String>[];

      final seen =
      <String>{};

      for (final category
      in apiCategories) {
        final normalized =
        category.toLowerCase();

        if (!seen.contains(
          normalized,
        )) {
          seen.add(normalized);

          uniqueCategories.add(
            category,
          );
        }
      }

      if (!mounted) return;

      setState(() {
        wallpapers = result;

        categories = [
          'ALL',
          ...uniqueCategories,
        ];

        isLoading = false;
        isRefreshing = false;
        hasError = false;
      });

      // Apply current search/category
      // after fresh API data arrives.
      _applyFilters();
    } catch (error) {
      debugPrint(
        'Search API error: $error',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
        isRefreshing = false;
        hasError = true;
      });
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearchChanged() {
    _applyFilters();
  }

  // ============================================================
  // FILTER
  // ============================================================

  void _applyFilters() {
    final query = _controller.text
        .trim()
        .toLowerCase();

    final results =
    wallpapers.where(
          (item) {
        final category =
            item['category']
                ?.toString() ??
                '';

        final image =
            item['image']
                ?.toString() ??
                '';

        final title =
        getWallpaperName(
          image,
        );

        // ------------------------------------------------------
        // CATEGORY
        // ------------------------------------------------------

        final categoryMatches =
            selectedCategory ==
                'ALL' ||
                category.toLowerCase() ==
                    selectedCategory
                        .toLowerCase();

        if (!categoryMatches) {
          return false;
        }

        // ------------------------------------------------------
        // EMPTY SEARCH
        // ------------------------------------------------------

        if (query.isEmpty) {
          return true;
        }

        // ------------------------------------------------------
        // SEARCH
        // ------------------------------------------------------

        return category
            .toLowerCase()
            .contains(query) ||
            title
                .toLowerCase()
                .contains(query) ||
            image
                .toLowerCase()
                .contains(query);
      },
    ).toList();

    if (!mounted) return;

    setState(() {
      filtered = results;
    });
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  void _selectCategory(
      String category,
      ) {
    if (selectedCategory ==
        category) {
      return;
    }

    setState(() {
      selectedCategory =
          category;
    });

    _applyFilters();
  }

  // ============================================================
  // CLEAR SEARCH
  // ============================================================

  void _clearSearch() {
    _controller.clear();

    _searchFocus.unfocus();

    _applyFilters();
  }

  // ============================================================
  // OPEN SEARCH
  // ============================================================

  void _openSearch() {
    _searchFocus.requestFocus();
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

      // IMPORTANT:
      // No AppBar.
      // No top navigation.
      // No extra header.
      body: SafeArea(
        child: RefreshIndicator(
          color:
          AppColors.accent,

          backgroundColor:
          _surface,

          onRefresh: () =>
              loadData(
                refresh: true,
              ),

          child:
          CustomScrollView(
            controller:
            _scrollController,

            physics:
            const BouncingScrollPhysics(
              parent:
              AlwaysScrollableScrollPhysics(),
            ),

            cacheExtent: 900,

            slivers: [
              // ------------------------------------------------
              // ONLY HEADER
              // ------------------------------------------------

              SliverToBoxAdapter(
                child:
                _buildHeader(),
              ),

              // ------------------------------------------------
              // CONTENT
              // ------------------------------------------------

              if (isLoading)
                _buildLoading()

              else if (hasError)
                SliverFillRemaining(
                  hasScrollBody:
                  false,
                  child:
                  _buildError(),
                )

              else if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody:
                    false,
                    child:
                    _buildEmpty(),
                  )

                else
                  _buildWallpaperFeed(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation:
      CurvedAnimation(
        parent:
        _introController,
        curve:
        Curves.easeOutCubic,
      ),

      builder:
          (context, child) {
        final value =
            _introController.value;

        return Opacity(
          opacity: value,

          child:
          Transform.translate(
            offset: Offset(
              0,
              24 * (1 - value),
            ),

            child: child,
          ),
        );
      },

      child: Padding(
        padding:
        EdgeInsets.fromLTRB(
          16.w,
          25.h,
          16.w,
          6.h,
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // ==================================================
            // ONLY MAIN HEADING
            // ==================================================

            Text(
              'FIND YOUR VIBE',

              style:
              GoogleFonts.bebasNeue(
                color:
                _primary,

                fontSize:
                48.sp,

                height:
                .84,

                letterSpacing:
                1.4,
              ),
            ),

            SizedBox(
              height: 18.h,
            ),

            // ==================================================
            // SEARCH
            // ==================================================

            _buildSearchBar(),

            SizedBox(
              height: 13.h,
            ),

            // ==================================================
            // API CATEGORIES
            // ==================================================

            _buildCategoryTags(),

            SizedBox(
              height: 8.h,
            ),

            // ==================================================
            // SMALL META ROW
            // ==================================================

            _buildMetaRow(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // META
  // ============================================================

  Widget _buildMetaRow() {
    return AnimatedSwitcher(
      duration:
      const Duration(
        milliseconds: 250,
      ),

      child: Row(
        key: ValueKey(
          '$selectedCategory-${filtered.length}',
        ),

        children: [
          Text(
            selectedCategory
                .toUpperCase(),

            style:
            GoogleFonts.manrope(
              color:
              _muted,

              fontSize:
              7.5.sp,

              fontWeight:
              FontWeight.w700,

              letterSpacing:
              1.2,
            ),
          ),

          const Spacer(),

          AnimatedSwitcher(
            duration:
            const Duration(
              milliseconds: 220,
            ),

            child: Text(
              '${filtered.length} WALLPAPERS',

              key: ValueKey(
                filtered.length,
              ),

              style:
              GoogleFonts.manrope(
                color:
                _secondary,

                fontSize:
                7.5.sp,

                fontWeight:
                FontWeight.w700,

                letterSpacing:
                .8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    final hasText =
        _controller.text
            .trim()
            .isNotEmpty;

    return AnimatedContainer(
      duration:
      const Duration(
        milliseconds: 330,
      ),

      curve:
      Curves.easeOutCubic,

      height:
      searchFocused
          ? 64.h
          : 55.h,

      padding:
      EdgeInsets.all(6.w),

      decoration:
      BoxDecoration(
        color:
        _surface,

        borderRadius:
        BorderRadius.circular(
          22.r,
        ),

        // ONLY BORDER.
        //
        // NO SHADOW.
        // NO GLOW.
        border:
        Border.all(
          color:
          searchFocused
              ? AppColors.accent
              .withOpacity(.55)
              : _divider
              .withOpacity(.65),

          width:
          searchFocused
              ? 1.2
              : 1,
        ),
      ),

      child: Row(
        children: [
          // ----------------------------------------------------
          // SEARCH ICON
          // ----------------------------------------------------

          AnimatedContainer(
            duration:
            const Duration(
              milliseconds: 280,
            ),

            curve:
            Curves.easeOutCubic,

            width:
            searchFocused
                ? 49.w
                : 42.w,

            height:
            searchFocused
                ? 49.w
                : 42.w,

            decoration:
            BoxDecoration(
              color:
              searchFocused
                  ? AppColors
                  .accent
                  .withOpacity(
                .12,
              )
                  : Colors
                  .transparent,

              borderRadius:
              BorderRadius.circular(
                16.r,
              ),
            ),

            child:
            AnimatedSwitcher(
              duration:
              const Duration(
                milliseconds: 200,
              ),

              transitionBuilder:
                  (
                  child,
                  animation,
                  ) {
                return ScaleTransition(
                  scale: animation,
                  child:
                  FadeTransition(
                    opacity:
                    animation,
                    child:
                    child,
                  ),
                );
              },

              child: Icon(
                Icons.search_rounded,

                key: ValueKey(
                  searchFocused,
                ),

                color:
                searchFocused
                    ? AppColors
                    .accent
                    : _muted,

                size:
                20.sp,
              ),
            ),
          ),

          SizedBox(
            width: 8.w,
          ),

          // ----------------------------------------------------
          // TEXT FIELD
          // ----------------------------------------------------

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
              GoogleFonts.manrope(
                color:
                _primary,

                fontSize:
                12.sp,

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

                hintText:
                'Search wallpapers',

                hintStyle:
                GoogleFonts.manrope(
                  color:
                  _muted.withOpacity(
                    .72,
                  ),

                  fontSize:
                  11.sp,

                  fontWeight:
                  FontWeight.w500,
                ),

                contentPadding:
                EdgeInsets.zero,
              ),
            ),
          ),

          // ----------------------------------------------------
          // ACTION BUTTON
          // ----------------------------------------------------

          AnimatedSwitcher(
            duration:
            const Duration(
              milliseconds: 220,
            ),

            transitionBuilder:
                (
                child,
                animation,
                ) {
              return ScaleTransition(
                scale: animation,
                child:
                FadeTransition(
                  opacity:
                  animation,
                  child:
                  child,
                ),
              );
            },

            child: hasText
                ? _searchAction(
              key:
              const ValueKey(
                'clear',
              ),

              icon:
              Icons.close_rounded,

              onTap:
              _clearSearch,
            )
                : _searchAction(
              key:
              const ValueKey(
                'arrow',
              ),

              icon:
              Icons
                  .arrow_forward_rounded,

              onTap:
              _openSearch,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH ACTION
  // ============================================================

  Widget _searchAction({
    required Key key,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      key: key,

      color:
      Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius:
        BorderRadius.circular(
          15.r,
        ),

        child: Container(
          width: 42.w,
          height: 42.w,

          decoration:
          BoxDecoration(
            color:
            _isDark
                ? Colors.white
                .withOpacity(
              .04,
            )
                : Colors.black
                .withOpacity(
              .035,
            ),

            borderRadius:
            BorderRadius.circular(
              15.r,
            ),
          ),

          child: Icon(
            icon,

            color:
            _secondary,

            size:
            17.sp,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // API CATEGORY TAGS
  // ============================================================

  Widget _buildCategoryTags() {
    if (categories.isEmpty) {
      return const SizedBox(
        height: 40,
      );
    }

    return SizedBox(
      height: 40.h,

      child: ListView.separated(
        scrollDirection:
        Axis.horizontal,

        physics:
        const BouncingScrollPhysics(),

        padding:
        EdgeInsets.zero,

        itemCount:
        categories.length,

        separatorBuilder:
            (_, __) {
          return SizedBox(
            width: 7.w,
          );
        },

        itemBuilder:
            (context, index) {
          final category =
          categories[index];

          final active =
              selectedCategory
                  .toLowerCase() ==
                  category
                      .toLowerCase();

          return _CategoryTag(
            category:
            category,

            active:
            active,

            primary:
            _primary,

            secondary:
            _secondary,

            surface:
            _surface,

            divider:
            _divider,

            onTap: () {
              _selectCategory(
                category,
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // WALLPAPER FEED
  // ============================================================

  SliverPadding
  _buildWallpaperFeed() {
    return SliverPadding(
      padding:
      EdgeInsets.fromLTRB(
        10.w,
        10.h,
        10.w,
        30.h,
      ),

      sliver: SliverList(
        delegate:
        SliverChildBuilderDelegate(
              (context, index) {
            final item =
            filtered[index];

            final image =
                item['image']
                    ?.toString() ??
                    '';

            final category =
                item['category']
                    ?.toString() ??
                    '';

            final title =
            getWallpaperName(
              image,
            );

            final height =
                _cardHeights[
                index %
                    _cardHeights
                        .length]
                    .h;

            return TweenAnimationBuilder<
                double>(
              key: ValueKey(
                '$image-$index',
              ),

              tween:
              Tween<double>(
                begin: 0,
                end: 1,
              ),

              duration: Duration(
                milliseconds:
                420 +
                    ((index % 6) * 70),
              ),

              curve:
              Curves.easeOutCubic,

              builder:
                  (
                  context,
                  value,
                  child,
                  ) {
                return Opacity(
                  opacity: value,

                  child:
                  Transform.translate(
                    offset: Offset(
                      0,
                      22 *
                          (1 - value),
                    ),

                    child:
                    Transform.scale(
                      scale:
                      .965 +
                          (.035 *
                              value),

                      child: child,
                    ),
                  ),
                );
              },

              child:
              _WallpaperCard(
                image:
                image,

                title:
                title,

                category:
                category,

                height:
                height,

                index:
                index,

                muted:
                _muted,

                onTap: () {
                  _openPreview(
                    image,
                    category,
                  );
                },
              ),
            );
          },

          childCount:
          filtered.length,
        ),
      ),
    );
  }

  // ============================================================
  // OPEN PREVIEW
  // ============================================================

  void _openPreview(
      String image,
      String category,
      ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration:
        const Duration(
          milliseconds: 400,
        ),

        reverseTransitionDuration:
        const Duration(
          milliseconds: 280,
        ),

        pageBuilder: (
            context,
            animation,
            secondaryAnimation,
            ) {
          return PreviewScreen(
            imageUrl:
            image,

            category:
            category,
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
            opacity:
            curved,

            child:
            ScaleTransition(
              scale:
              Tween<double>(
                begin: .965,
                end: 1,
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
  // LOADING
  // ============================================================

  SliverPadding _buildLoading() {
    return SliverPadding(
      padding:
      EdgeInsets.fromLTRB(
        10.w,
        10.h,
        10.w,
        30.h,
      ),

      sliver: SliverList(
        delegate:
        SliverChildBuilderDelegate(
              (context, index) {
            final height =
                _cardHeights[
                index %
                    _cardHeights
                        .length]
                    .h;

            return Padding(
              padding:
              EdgeInsets.only(
                bottom: 7.h,
              ),

              child:
              _LoadingCard(
                height:
                height,

                dark:
                _isDark,
              ),
            );
          },

          childCount: 5,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding:
        EdgeInsets.symmetric(
          horizontal: 30.w,
        ),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Icon(
              Icons
                  .search_off_rounded,

              color:
              _muted,

              size:
              34.sp,
            ),

            SizedBox(
              height: 15.h,
            ),

            Text(
              'NOTHING HERE',

              style:
              GoogleFonts
                  .bebasNeue(
                color:
                _primary,

                fontSize:
                32.sp,

                letterSpacing:
                1.2,
              ),
            ),

            SizedBox(
              height: 6.h,
            ),

            Text(
              'Try another search or choose a different category.',

              textAlign:
              TextAlign.center,

              style:
              GoogleFonts.manrope(
                color:
                _secondary,

                fontSize:
                11.sp,

                height:
                1.5,
              ),
            ),

            SizedBox(
              height: 16.h,
            ),

            GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory =
                  'ALL';
                });

                _clearSearch();
              },

              child:
              Container(
                padding:
                EdgeInsets.symmetric(
                  horizontal:
                  18.w,

                  vertical:
                  11.h,
                ),

                decoration:
                BoxDecoration(
                  color:
                  AppColors.accent,

                  borderRadius:
                  BorderRadius.circular(
                    15.r,
                  ),
                ),

                child: Text(
                  'RESET',

                  style:
                  GoogleFonts.manrope(
                    color:
                    Colors.white,

                    fontSize:
                    8.sp,

                    fontWeight:
                    FontWeight.w700,

                    letterSpacing:
                    1,
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

  Widget _buildError() {
    return Center(
      child: Padding(
        padding:
        EdgeInsets.symmetric(
          horizontal: 30.w,
        ),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Icon(
              Icons
                  .cloud_off_rounded,

              color:
              _muted,

              size:
              34.sp,
            ),

            SizedBox(
              height: 15.h,
            ),

            Text(
              'CAN\'T LOAD',

              style:
              GoogleFonts
                  .bebasNeue(
                color:
                _primary,

                fontSize:
                32.sp,

                letterSpacing:
                1.2,
              ),
            ),

            SizedBox(
              height: 6.h,
            ),

            Text(
              'Something went wrong while loading wallpapers.',

              textAlign:
              TextAlign.center,

              style:
              GoogleFonts.manrope(
                color:
                _secondary,

                fontSize:
                11.sp,

                height:
                1.5,
              ),
            ),

            SizedBox(
              height: 17.h,
            ),

            GestureDetector(
              onTap:
                  () => loadData(),

              child:
              Container(
                padding:
                EdgeInsets.symmetric(
                  horizontal:
                  18.w,

                  vertical:
                  11.h,
                ),

                decoration:
                BoxDecoration(
                  color:
                  AppColors.accent,

                  borderRadius:
                  BorderRadius.circular(
                    15.r,
                  ),
                ),

                child: Text(
                  'TRY AGAIN',

                  style:
                  GoogleFonts.manrope(
                    color:
                    Colors.white,

                    fontSize:
                    8.sp,

                    fontWeight:
                    FontWeight.w700,

                    letterSpacing:
                    1,
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
            caseSensitive:
            false,
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

    fileName =
        fileName.replaceAll(
          '_',
          ' ',
        );

    return fileName
        .split(' ')
        .where(
          (word) =>
      word.isNotEmpty,
    )
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

// =================================================================
// CATEGORY TAG
// =================================================================

class _CategoryTag
    extends StatelessWidget {
  final String category;

  final bool active;

  final Color primary;
  final Color secondary;
  final Color surface;
  final Color divider;

  final VoidCallback onTap;

  const _CategoryTag({
    required this.category,
    required this.active,
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.divider,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return AnimatedContainer(
      duration:
      const Duration(
        milliseconds: 260,
      ),

      curve:
      Curves.easeOutCubic,

      padding:
      EdgeInsets.symmetric(
        horizontal: 15.w,
      ),

      decoration:
      BoxDecoration(
        color: active
            ? AppColors.accent
            : surface,

        borderRadius:
        BorderRadius.circular(
          18.r,
        ),

        border:
        Border.all(
          color: active
              ? AppColors.accent
              : divider.withOpacity(
            .65,
          ),
        ),
      ),

      child: Material(
        color:
        Colors.transparent,

        child: InkWell(
          onTap: onTap,

          borderRadius:
          BorderRadius.circular(
            18.r,
          ),

          child: Row(
            mainAxisSize:
            MainAxisSize.min,

            children: [
              AnimatedSwitcher(
                duration:
                const Duration(
                  milliseconds: 180,
                ),

                child: active
                    ? Padding(
                  key:
                  const ValueKey(
                    'selected',
                  ),

                  padding:
                  EdgeInsets.only(
                    right:
                    5.w,
                  ),

                  child:
                  Icon(
                    Icons
                        .check_rounded,

                    color:
                    Colors.white,

                    size:
                    12.sp,
                  ),
                )
                    : const SizedBox(
                  key:
                  ValueKey(
                    'empty',
                  ),
                  width: 0,
                ),
              ),

              AnimatedDefaultTextStyle(
                duration:
                const Duration(
                  milliseconds: 220,
                ),

                style:
                GoogleFonts.manrope(
                  color: active
                      ? Colors.white
                      : secondary,

                  fontSize:
                  8.sp,

                  fontWeight:
                  FontWeight.w700,

                  letterSpacing:
                  .8,
                ),

                child: Text(
                  category
                      .toUpperCase(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// WALLPAPER CARD
// =================================================================

class _WallpaperCard
    extends StatefulWidget {
  final String image;
  final String title;
  final String category;
  final double height;
  final int index;
  final Color muted;
  final VoidCallback onTap;

  const _WallpaperCard({
    required this.image,
    required this.title,
    required this.category,
    required this.height,
    required this.index,
    required this.muted,
    required this.onTap,
  });

  @override
  State<_WallpaperCard> createState() =>
      _WallpaperCardState();
}

class _WallpaperCardState
    extends State<_WallpaperCard>
    with SingleTickerProviderStateMixin {
  late AnimationController
  _motionController;

  bool pressed = false;

  @override
  void initState() {
    super.initState();

    _motionController =
        AnimationController(
          vsync: this,

          duration: Duration(
            seconds:
            12 +
                (widget.index %
                    5),
          ),
        );

    _motionController.repeat(
      reverse: true,
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
    return Padding(
      padding:
      EdgeInsets.only(
        bottom: 7.h,
      ),

      child:
      GestureDetector(
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
          pressed
              ? .975
              : 1,

          duration:
          const Duration(
            milliseconds: 140,
          ),

          curve:
          Curves.easeOut,

          child:
          ClipRRect(
            borderRadius:
            BorderRadius.circular(
              28.r,
            ),

            child:
            SizedBox(
              width:
              double.infinity,

              height:
              widget.height,

              child:
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

                  final radians =
                      progress *
                          math.pi *
                          2;

                  final dx =
                      math.sin(
                        radians,
                      ) *
                          3.5;

                  final dy =
                      math.cos(
                        radians *
                            .7,
                      ) *
                          2.0;

                  final scale =
                      1.035 +
                          math.sin(
                            radians *
                                .8,
                          ) *
                              .007;

                  return Stack(
                    fit:
                    StackFit.expand,

                    children: [
                      // ------------------------------------------------
                      // MOVING IMAGE
                      // ------------------------------------------------

                      Transform.translate(
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
                      ),

                      // ------------------------------------------------
                      // IMAGE READABILITY GRADIENT
                      //
                      // This is NOT a glow.
                      // This is only for text readability.
                      // ------------------------------------------------

                      Positioned.fill(
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

                              stops: const [
                                0.38,
                                0.68,
                                1.0,
                              ],

                              colors: [
                                Colors
                                    .transparent,

                                Colors.black
                                    .withOpacity(
                                  .08,
                                ),

                                Colors.black
                                    .withOpacity(
                                  .72,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ------------------------------------------------
                      // API CATEGORY
                      // ------------------------------------------------

                      Positioned(
                        left:
                        18.w,

                        bottom:
                        52.h,

                        right:
                        70.w,

                        child:
                        Text(
                          widget.category
                              .toUpperCase(),

                          maxLines:
                          1,

                          overflow:
                          TextOverflow
                              .ellipsis,

                          style:
                          GoogleFonts
                              .manrope(
                            color: Colors
                                .white
                                .withOpacity(
                              .68,
                            ),

                            fontSize:
                            7.sp,

                            fontWeight:
                            FontWeight
                                .w700,

                            letterSpacing:
                            1.3,
                          ),
                        ),
                      ),

                      // ------------------------------------------------
                      // WALLPAPER NAME
                      // ------------------------------------------------

                      Positioned(
                        left:
                        18.w,

                        right:
                        62.w,

                        bottom:
                        17.h,

                        child:
                        Text(
                          widget.title,

                          maxLines:
                          2,

                          overflow:
                          TextOverflow
                              .ellipsis,

                          style:
                          GoogleFonts
                              .manrope(
                            color:
                            Colors
                                .white,

                            fontSize:
                            16.sp,

                            fontWeight:
                            FontWeight
                                .w700,

                            height:
                            1.04,
                          ),
                        ),
                      ),

                      // ------------------------------------------------
                      // NUMBER
                      // ------------------------------------------------

                      Positioned(
                        top:
                        14.h,

                        right:
                        17.w,

                        child:
                        Text(
                          '${widget.index + 1}'
                              .padLeft(
                            2,
                            '0',
                          ),

                          style:
                          GoogleFonts
                              .manrope(
                            color: Colors
                                .white
                                .withOpacity(
                              .60,
                            ),

                            fontSize:
                            8.sp,

                            fontWeight:
                            FontWeight
                                .w700,

                            letterSpacing:
                            1.1,
                          ),
                        ),
                      ),

                      // ------------------------------------------------
                      // OPEN BUTTON
                      // ------------------------------------------------

                      Positioned(
                        right:
                        17.w,

                        bottom:
                        16.h,

                        child:
                        AnimatedContainer(
                          duration:
                          const Duration(
                            milliseconds:
                            150,
                          ),

                          width:
                          pressed
                              ? 38.w
                              : 42.w,

                          height:
                          pressed
                              ? 38.w
                              : 42.w,

                          decoration:
                          BoxDecoration(
                            color: Colors
                                .white
                                .withOpacity(
                              .12,
                            ),

                            shape:
                            BoxShape
                                .circle,

                            border:
                            Border.all(
                              color: Colors
                                  .white
                                  .withOpacity(
                                .16,
                              ),

                              width:
                              1,
                            ),
                          ),

                          child:
                          Icon(
                            Icons
                                .arrow_outward_rounded,

                            color:
                            Colors.white,

                            size:
                            15.sp,
                          ),
                        ),
                      ),
                    ],
                  );
                },

                child:
                Image.network(
                  widget.image,

                  width:
                  double.infinity,

                  height:
                  widget.height,

                  fit:
                  BoxFit.cover,

                  filterQuality:
                  FilterQuality.high,

                  cacheWidth:
                  1100,

                  gaplessPlayback:
                  true,

                  errorBuilder:
                      (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return Container(
                      color:
                      Theme.of(
                        context,
                      ).brightness ==
                          Brightness.dark
                          ? const Color(
                        0xFF181919,
                      )
                          : const Color(
                        0xFFE8E8E8,
                      ),

                      alignment:
                      Alignment.center,

                      child:
                      Icon(
                        Icons
                            .image_not_supported_outlined,

                        color:
                        widget.muted,

                        size:
                        28.sp,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =================================================================
// LOADING CARD
// =================================================================

class _LoadingCard
    extends StatefulWidget {
  final double height;
  final bool dark;

  const _LoadingCard({
    required this.height,
    required this.dark,
  });

  @override
  State<_LoadingCard> createState() =>
      _LoadingCardState();
}

class _LoadingCardState
    extends State<_LoadingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController
  _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(
          vsync: this,

          duration:
          const Duration(
            milliseconds: 1250,
          ),
        );

    _controller.repeat();
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
    final base =
    widget.dark
        ? const Color(
      0xFF181919,
    )
        : const Color(
      0xFFE8E8E8,
    );

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(
        28.r,
      ),

      child:
      SizedBox(
        height:
        widget.height,

        child:
        AnimatedBuilder(
          animation:
          _controller,

          builder:
              (
              context,
              child,
              ) {
            return Stack(
              children: [
                Positioned.fill(
                  child:
                  ColoredBox(
                    color:
                    base,
                  ),
                ),

                Positioned(
                  left:
                  -180.w +
                      (_controller
                          .value *
                          500.w),

                  top:
                  0,

                  bottom:
                  0,

                  child:
                  Container(
                    width:
                    170.w,

                    decoration:
                    BoxDecoration(
                      gradient:
                      LinearGradient(
                        colors: [
                          base,

                          Colors.white
                              .withOpacity(
                            .065,
                          ),

                          base,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}