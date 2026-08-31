import 'dart:convert';

import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/category_spage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> _future;
  late final AnimationController _heroController;

  @override
  void initState() {
    super.initState();

    _future = fetchData();

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // API
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> fetchData() async {
    final apiUrl = dotenv.env['API_URL'];

    if (apiUrl == null || apiUrl.isEmpty) {
      throw Exception('API_URL is not configured');
    }

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load categories: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid API response');
    }

    return decoded;
  }

  // ------------------------------------------------------------
  // THEME
  // ------------------------------------------------------------

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
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

  Color _text(BuildContext context) {
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

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final background = _background(context);
    final surface = _surface(context);
    final surfaceSoft = _surfaceSoft(context);
    final text = _text(context);
    final secondary = _secondary(context);
    final muted = _muted(context);
    final divider = _divider(context);

    return Scaffold(
      backgroundColor: background,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading(
              background: background,
              secondary: secondary,
            );
          }

          if (snapshot.hasError) {
            return _buildError(
              background: background,
              surface: surface,
              text: text,
              secondary: secondary,
              divider: divider,
            );
          }

          if (!snapshot.hasData) {
            return _buildLoading(
              background: background,
              secondary: secondary,
            );
          }

          final data = snapshot.data!;
          final rawCategories = data['categories'];

          final Map<String, dynamic> categories =
          rawCategories is Map
              ? Map<String, dynamic>.from(rawCategories)
              : <String, dynamic>{};

          final entries = categories.entries.toList();

          return RefreshIndicator(
            color: _accent,
            backgroundColor: surface,
            onRefresh: () async {
              setState(() {
                _future = fetchData();
              });

              await _future;
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(
                    context,
                    count: entries.length,
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      10.h,
                      20.w,
                      18.h,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Explore',
                          style: GoogleFonts.manrope(
                            color: text,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 11.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color: surfaceSoft,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '${entries.length} collections',
                            style: GoogleFonts.manrope(
                              color: muted,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (entries.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmpty(
                      text: text,
                      secondary: secondary,
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];

                        final category =
                        entry.value is Map
                            ? Map<String, dynamic>.from(
                          entry.value as Map,
                        )
                            : <String, dynamic>{};

                        final thumbnail =
                            category['thumbnail']?.toString() ?? '';

                        final rawWallpapers =
                        category['wallpapers'];

                        final wallpapers =
                        rawWallpapers is List
                            ? rawWallpapers
                            .map((item) => item.toString())
                            .where((item) => item.isNotEmpty)
                            .toList()
                            : <String>[];

                        const heights = [
                          310.0,
                          250.0,
                          350.0,
                          285.0,
                        ];

                        return _MinimalCategoryCard(
                          index: index,
                          title: entry.key,
                          thumbnail: thumbnail,
                          wallpaperCount: wallpapers.length,
                          height: heights[index % heights.length].h,
                          accent: _accent,
                          fallback: surfaceSoft,
                          muted: muted,
                          onTap: () {
                            _openCategory(
                              context,
                              title: entry.key,
                              wallpapers: wallpapers,
                            );
                          },
                        );
                      },
                    ),
                  ),

                SliverToBoxAdapter(
                  child: SizedBox(height: 60.h),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader(
      BuildContext context, {
        required int count,
      }) {
    final text = _text(context);
    final secondary = _secondary(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        70.h,
        20.w,
        28.h,
      ),
      child: AnimatedBuilder(
        animation: _heroController,
        builder: (context, child) {
          final value = Curves.easeInOut.transform(
            _heroController.value,
          );

          return Transform.translate(
            offset: Offset(
              (value - .5) * 3,
              (value - .5) * 2,
            ),
            child: child,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: BoxDecoration(
                    color: _accent,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'WALLPAPER COLLECTIONS',
                  style: GoogleFonts.manrope(
                    color: secondary,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            Text(
              'Find your\nnext wallpaper.',
              style: GoogleFonts.manrope(
                color: text,
                fontSize: 45.sp,
                fontWeight: FontWeight.w700,
                height: .98,
                letterSpacing: -2.2,
              ),
            ),

            SizedBox(height: 15.h),

            SizedBox(
              width: 310.w,
              child: Text(
                'A carefully selected collection of wallpapers for every mood and screen.',
                style: GoogleFonts.manrope(
                  color: secondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                ),
              ),
            ),

            SizedBox(height: 22.h),

            Row(
              children: [
                _HeaderStat(
                  value: count.toString().padLeft(2, '0'),
                  label: 'COLLECTIONS',
                  color: text,
                ),
                SizedBox(width: 18.w),
                Container(
                  width: 1,
                  height: 25.h,
                  color: _divider(context),
                ),
                SizedBox(width: 18.w),
                _HeaderStat(
                  value: '4K',
                  label: 'QUALITY',
                  color: text,
                ),
              ],
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(
        duration: const Duration(milliseconds: 650),
      )
          .moveY(
        begin: 20,
        end: 0,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  // ------------------------------------------------------------
  // NAVIGATION
  // ------------------------------------------------------------

  void _openCategory(
      BuildContext context, {
        required String title,
        required List<String> wallpapers,
      }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 550),
        reverseTransitionDuration:
        const Duration(milliseconds: 400),
        pageBuilder: (_, animation, __) {
          return CategoryScreen(
            title: title,
            wallpapers: wallpapers,
          );
        },
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .035),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // LOADING
  // ------------------------------------------------------------

  Widget _buildLoading({
    required Color background,
    required Color secondary,
  }) {
    return Container(
      color: background,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 22.w,
            height: 22.w,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: _accent,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading collections',
            style: GoogleFonts.manrope(
              color: secondary,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 400));
  }

  // ------------------------------------------------------------
  // ERROR
  // ------------------------------------------------------------

  Widget _buildError({
    required Color background,
    required Color surface,
    required Color text,
    required Color secondary,
    required Color divider,
  }) {
    return Container(
      color: background,
      alignment: Alignment.center,
      padding: EdgeInsets.all(28.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: surface,
              shape: BoxShape.circle,
              border: Border.all(color: divider),
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              color: _accent,
              size: 27.sp,
            ),
          ),

          SizedBox(height: 18.h),

          Text(
            'Something went wrong',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: text,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),

          SizedBox(height: 7.h),

          Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: secondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 20.h),

          GestureDetector(
            onTap: () {
              setState(() {
                _future = fetchData();
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 18.w,
                vertical: 11.h,
              ),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Text(
                'Try again',
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // EMPTY
  // ------------------------------------------------------------

  Widget _buildEmpty({
    required Color text,
    required Color secondary,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            color: _accent.withOpacity(.55),
            size: 42.sp,
          ),
          SizedBox(height: 18.h),
          Text(
            'No collections yet',
            style: GoogleFonts.manrope(
              color: text,
              fontSize: 21.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            'New wallpapers will appear here soon.',
            style: GoogleFonts.manrope(
              color: secondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HEADER STAT
// ============================================================

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _HeaderStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.manrope(
            color: color,
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          style: GoogleFonts.manrope(
            color: color.withOpacity(.45),
            fontSize: 7.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MINIMAL CATEGORY CARD
// ============================================================

class _MinimalCategoryCard extends StatefulWidget {
  final int index;
  final String title;
  final String thumbnail;
  final int wallpaperCount;
  final double height;
  final Color accent;
  final Color fallback;
  final Color muted;
  final VoidCallback onTap;

  const _MinimalCategoryCard({
    required this.index,
    required this.title,
    required this.thumbnail,
    required this.wallpaperCount,
    required this.height,
    required this.accent,
    required this.fallback,
    required this.muted,
    required this.onTap,
  });

  @override
  State<_MinimalCategoryCard> createState() =>
      _MinimalCategoryCardState();
}

class _MinimalCategoryCardState
    extends State<_MinimalCategoryCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  late final AnimationController _motionController;

  @override
  void initState() {
    super.initState();

    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
      },
      onTapCancel: () {
        setState(() => _pressed = false);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? .975 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: Hero(
          tag: 'category-${widget.title}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22.r),
            child: SizedBox(
              height: widget.height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // IMAGE
                  AnimatedBuilder(
                    animation: _motionController,
                    builder: (context, child) {
                      final progress =
                      Curves.easeInOut.transform(
                        _motionController.value,
                      );

                      return Transform.translate(
                        offset: Offset(
                          (progress - .5) * 4,
                          (progress - .5) * 5,
                        ),
                        child: Transform.scale(
                          scale: 1.025 + progress * .025,
                          child: child,
                        ),
                      );
                    },
                    child: widget.thumbnail.isEmpty
                        ? Container(
                      color: widget.fallback,
                      child: Icon(
                        Icons.image_outlined,
                        color: widget.muted,
                        size: 28.sp,
                      ),
                    )
                        : Image.network(
                      widget.thumbnail,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return Container(
                          color: widget.fallback,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: widget.muted,
                            size: 27.sp,
                          ),
                        );
                      },
                    ),
                  ),

                  // SOFT GRADIENT
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x08000000),
                              Colors.transparent,
                              Color(0xD9000000),
                            ],
                            stops: [0, .52, 1],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // TOP LABEL
                  Positioned(
                    top: 13.h,
                    left: 13.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.20),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${(widget.index + 1).toString().padLeft(2, '0')}',
                        style: GoogleFonts.manrope(
                          color: Colors.white.withOpacity(.9),
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // ARROW
                  Positioned(
                    top: 13.h,
                    right: 13.w,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(
                          _pressed ? .45 : .22,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_outward_rounded,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                    ),
                  ),

                  // CONTENT
                  Positioned(
                    left: 14.w,
                    right: 14.w,
                    bottom: 14.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.wallpaperCount} wallpapers',
                          style: GoogleFonts.manrope(
                            color: Colors.white.withOpacity(.68),
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 5.h),

                        Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                            letterSpacing: -0.7,
                          ),
                        ),

                        SizedBox(height: 10.h),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.white.withOpacity(.25),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              width: 5.w,
                              height: 5.w,
                              decoration: BoxDecoration(
                                color: widget.accent,
                                shape: BoxShape.circle,
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
      delay: Duration(
        milliseconds: widget.index * 70,
      ),
      duration: const Duration(milliseconds: 550),
    )
        .moveY(
      begin: 30,
      end: 0,
      delay: Duration(
        milliseconds: widget.index * 70,
      ),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
    );
  }
}