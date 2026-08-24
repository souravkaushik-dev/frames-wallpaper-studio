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
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  // ============================================================
  // API
  // ============================================================

  Future<Map<String, dynamic>> fetchData() async {
    final apiUrl = dotenv.env['API_URL'];

    if (apiUrl == null || apiUrl.isEmpty) {
      throw Exception('API_URL is not configured');
    }

    final response = await http.get(
      Uri.parse(apiUrl),
    );

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

  // ============================================================
  // THEME
  // ============================================================

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
    final background = _background(context);
    final surface = _surface(context);
    final surfaceSoft = _surfaceSoft(context);
    final text = _primary(context);
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
              primary: text,
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
              primary: text,
              secondary: secondary,
            );
          }

          final data = snapshot.data!;

          final rawCategories = data['categories'];

          final Map<String, dynamic> categories =
          rawCategories is Map
              ? Map<String, dynamic>.from(rawCategories)
              : <String, dynamic>{};

          final categoryEntries = categories.entries.toList();

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
                // ==================================================
                // CINEMATIC HERO
                // ==================================================

                SliverToBoxAdapter(
                  child: _buildHero(
                    context: context,
                    text: text,
                    secondary: secondary,
                    categoryCount: categoryEntries.length,
                  ),
                ),

                // ==================================================
                // SECTION HEADER
                // ==================================================

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      22.w,
                      8.h,
                      22.w,
                      22.h,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'COLLECTIONS',
                                style: GoogleFonts.bebasNeue(
                                  color: text,
                                  fontSize: 43.sp,
                                  height: .82,
                                  letterSpacing: 2.8,
                                ),
                              ),
                              SizedBox(height: 9.h),
                              Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(
                                      milliseconds: 500,
                                    ),
                                    width: 25.w,
                                    height: 2,
                                    color: _accent,
                                  ),
                                  SizedBox(width: 9.w),
                                  Text(
                                    'CURATED VISUAL WORLDS',
                                    style: GoogleFonts.inter(
                                      color: secondary,
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.7,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(.07),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: divider,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              categoryEntries.length
                                  .toString()
                                  .padLeft(2, '0'),
                              style: GoogleFonts.inter(
                                color: text,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(
                    duration: const Duration(
                      milliseconds: 650,
                    ),
                  )
                      .moveY(
                    begin: 22,
                    end: 0,
                    curve: Curves.easeOutExpo,
                  ),
                ),

                // ==================================================
                // CATEGORY GRID
                // ==================================================

                if (categoryEntries.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmpty(
                      context,
                      text,
                      secondary,
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                    ),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14.h,
                      crossAxisSpacing: 14.w,
                      childCount: categoryEntries.length,
                      itemBuilder: (context, index) {
                        final entry = categoryEntries[index];
                        final categoryName = entry.key;

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
                            .where(
                              (item) => item.isNotEmpty,
                        )
                            .toList()
                            : <String>[];

                        const heights = [
                          360.0,
                          280.0,
                          410.0,
                          315.0,
                        ];

                        return _CinematicCategoryCard(
                          index: index,
                          title: categoryName,
                          thumbnail: thumbnail,
                          wallpaperCount: wallpapers.length,
                          height: heights[index % heights.length].h,
                          accent: _accent,
                          fallback: surfaceSoft,
                          muted: muted,
                          onTap: () {
                            _openCategory(
                              context,
                              title: categoryName,
                              wallpapers: wallpapers,
                            );
                          },
                        );
                      },
                    ),
                  ),

                // ==================================================
                // BOTTOM
                // ==================================================

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 80.h,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 34.w,
                          height: 1,
                          color: divider,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'END OF COLLECTIONS',
                          style: GoogleFonts.inter(
                            color: muted.withOpacity(.55),
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
    required BuildContext context,
    required Color text,
    required Color secondary,
    required int categoryCount,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22.w,
        78.h,
        22.w,
        28.h,
      ),
      child: AnimatedBuilder(
        animation: _heroController,
        builder: (context, child) {
          final progress = Curves.easeInOut.transform(
            _heroController.value,
          );

          final offsetX = (progress - .5) * 5;
          final offsetY = (progress - .5) * 3;

          return Transform.translate(
            offset: Offset(offsetX, offsetY),
            child: child,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // SMALL LABEL
            // ======================================================

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
                SizedBox(width: 9.w),
                Text(
                  'FRAME / COLLECTIONS',
                  style: GoogleFonts.inter(
                    color: secondary,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.2,
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(
              duration: const Duration(
                milliseconds: 500,
              ),
            )
                .moveX(
              begin: -20,
              end: 0,
              curve: Curves.easeOutExpo,
            ),

            SizedBox(height: 12.h),

            // ======================================================
            // BIG TITLE
            // ======================================================

            Text(
              'DISCOVER',
              style: GoogleFonts.bebasNeue(
                color: text,
                fontSize: 92.sp,
                height: .76,
                letterSpacing: 2.5,
              ),
            )
                .animate()
                .fadeIn(
              duration: const Duration(
                milliseconds: 900,
              ),
            )
                .moveY(
              begin: 80,
              end: 0,
              duration: const Duration(
                milliseconds: 950,
              ),
              curve: Curves.easeOutExpo,
            )
                .scale(
              begin: const Offset(.92, .92),
              end: const Offset(1, 1),
              duration: const Duration(
                milliseconds: 950,
              ),
              curve: Curves.easeOutExpo,
            ),

            SizedBox(height: 18.h),

            // ======================================================
            // DESCRIPTION
            // ======================================================

            SizedBox(
              width: 330.w,
              child: Text(
                'Curated visual worlds built around atmosphere, mood and modern screen aesthetics.',
                style: GoogleFonts.inter(
                  color: secondary,
                  fontSize: 13.sp,
                  height: 1.65,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
                .animate()
                .fadeIn(
              delay: const Duration(
                milliseconds: 250,
              ),
              duration: const Duration(
                milliseconds: 700,
              ),
            )
                .moveY(
              begin: 20,
              end: 0,
              curve: Curves.easeOutExpo,
            ),

            SizedBox(height: 22.h),

            // ======================================================
            // META
            // ======================================================

            Row(
              children: [
                _MetaItem(
                  number: categoryCount
                      .toString()
                      .padLeft(2, '0'),
                  label: 'WORLDS',
                  color: text,
                ),
                SizedBox(width: 22.w),
                _MetaDivider(
                  color: _divider(context),
                ),
                SizedBox(width: 22.w),
                _MetaItem(
                  number: '4K',
                  label: 'READY',
                  color: text,
                ),
                SizedBox(width: 22.w),
                _MetaDivider(
                  color: _divider(context),
                ),
                SizedBox(width: 22.w),
                _MetaItem(
                  number: '∞',
                  label: 'MOODS',
                  color: text,
                ),
              ],
            )
                .animate()
                .fadeIn(
              delay: const Duration(
                milliseconds: 450,
              ),
              duration: const Duration(
                milliseconds: 700,
              ),
            )
                .moveY(
              begin: 20,
              end: 0,
              curve: Curves.easeOutExpo,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // OPEN CATEGORY
  // ============================================================

  void _openCategory(
      BuildContext context, {
        required String title,
        required List<String> wallpapers,
      }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 850,
        ),
        reverseTransitionDuration: const Duration(
          milliseconds: 600,
        ),
        pageBuilder: (_, animation, __) {
          return CategoryScreen(
            title: title,
            wallpapers: wallpapers,
          );
        },
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutExpo,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .08),
                end: Offset.zero,
              ).animate(curved),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: .96,
                  end: 1,
                ).animate(curved),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading({
    required Color background,
    required Color primary,
    required Color secondary,
  }) {
    return Container(
      color: background,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              color: _accent.withOpacity(.035),
              shape: BoxShape.circle,
              border: Border.all(
                color: _accent.withOpacity(.16),
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 21.w,
                height: 21.w,
                child: CircularProgressIndicator(
                  strokeWidth: 1.6,
                  color: _accent,
                ),
              ),
            ),
          )
              .animate(
            onPlay: (controller) => controller.repeat(
              reverse: true,
            ),
          )
              .scale(
            begin: const Offset(.94, .94),
            end: const Offset(1.05, 1.05),
            duration: const Duration(
              milliseconds: 1500,
            ),
            curve: Curves.easeInOut,
          ),
          SizedBox(height: 18.h),
          Text(
            'CURATING',
            style: GoogleFonts.inter(
              color: secondary,
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

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
            width: 82.w,
            height: 82.w,
            decoration: BoxDecoration(
              color: surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: divider,
              ),
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              color: _accent.withOpacity(.70),
              size: 34.sp,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'COLLECTIONS UNAVAILABLE',
            textAlign: TextAlign.center,
            style: GoogleFonts.bebasNeue(
              color: text,
              fontSize: 28.sp,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: secondary,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 22.h),
          GestureDetector(
            onTap: () {
              setState(() {
                _future = fetchData();
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 11.h,
              ),
              decoration: BoxDecoration(
                color: _accent.withOpacity(.08),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: divider,
                ),
              ),
              child: Text(
                'TRY AGAIN',
                style: GoogleFonts.inter(
                  color: text,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
      duration: const Duration(
        milliseconds: 600,
      ),
    )
        .moveY(
      begin: 25,
      end: 0,
      curve: Curves.easeOutExpo,
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty(
      BuildContext context,
      Color text,
      Color secondary,
      ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 105.w,
            height: 105.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accent.withOpacity(.035),
              border: Border.all(
                color: _accent.withOpacity(.13),
              ),
            ),
            child: Icon(
              Icons.collections_rounded,
              color: _accent.withOpacity(.55),
              size: 40.sp,
            ),
          )
              .animate(
            onPlay: (controller) => controller.repeat(
              reverse: true,
            ),
          )
              .scale(
            begin: const Offset(.95, .95),
            end: const Offset(1.04, 1.04),
            duration: const Duration(
              milliseconds: 1800,
            ),
            curve: Curves.easeInOut,
          ),
          SizedBox(height: 25.h),
          Text(
            'NO COLLECTIONS',
            style: GoogleFonts.bebasNeue(
              color: text,
              fontSize: 32.sp,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'New visual worlds will appear here soon.',
            style: GoogleFonts.inter(
              color: secondary,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
      duration: const Duration(
        milliseconds: 700,
      ),
    )
        .moveY(
      begin: 25,
      end: 0,
      curve: Curves.easeOutExpo,
    );
  }
}

// ==================================================================
// META ITEM
// ==================================================================

class _MetaItem extends StatelessWidget {
  final String number;
  final String label;
  final Color color;

  const _MetaItem({
    required this.number,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: GoogleFonts.bebasNeue(
            color: color,
            fontSize: 25.sp,
            height: .8,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          style: GoogleFonts.inter(
            color: color.withOpacity(.45),
            fontSize: 7.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// META DIVIDER
// ==================================================================

class _MetaDivider extends StatelessWidget {
  final Color color;

  const _MetaDivider({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 26.h,
      color: color,
    );
  }
}

// ==================================================================
// CINEMATIC CATEGORY CARD
// ==================================================================

class _CinematicCategoryCard extends StatefulWidget {
  final int index;
  final String title;
  final String thumbnail;
  final int wallpaperCount;
  final double height;
  final Color accent;
  final Color fallback;
  final Color muted;
  final VoidCallback onTap;

  const _CinematicCategoryCard({
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
  State<_CinematicCategoryCard> createState() =>
      _CinematicCategoryCardState();
}

class _CinematicCategoryCardState
    extends State<_CinematicCategoryCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  late final AnimationController _motionController;

  @override
  void initState() {
    super.initState();

    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
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
        setState(() {
          _pressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });

        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? .95 : 1,
        duration: const Duration(
          milliseconds: 180,
        ),
        curve: Curves.easeOutCubic,
        child: Hero(
          tag: 'category-${widget.title}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34.r),
            child: SizedBox(
              height: widget.height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ==================================================
                  // SLOW IMAGE MOVEMENT
                  // ==================================================

                  AnimatedBuilder(
                    animation: _motionController,
                    builder: (context, child) {
                      final progress =
                      Curves.easeInOut.transform(
                        _motionController.value,
                      );

                      final scale =
                          1.045 + (progress * .045);

                      final dx =
                          (progress - .5) * 7;

                      final dy =
                          (progress - .5) * 5;

                      return Transform.translate(
                        offset: Offset(dx, dy),
                        child: Transform.scale(
                          scale: scale,
                          child: child,
                        ),
                      );
                    },
                    child: widget.thumbnail.isEmpty
                        ? Container(
                      color: widget.fallback,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image_outlined,
                        color: widget.muted,
                        size: 30.sp,
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
                            size: 28.sp,
                          ),
                        );
                      },
                    ),
                  ),

                  // ==================================================
                  // CINEMATIC VIGNETTE
                  // ==================================================

                  const Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [
                              0,
                              .30,
                              .62,
                              1,
                            ],
                            colors: [
                              Color(0x1A000000),
                              Colors.transparent,
                              Color(0x42000000),
                              Color(0xF0000000),
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
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0x30000000),
                              Colors.transparent,
                              Color(0x18000000),
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
                    top: 17.h,
                    left: 17.w,
                    child: Row(
                      children: [
                        Text(
                          (widget.index + 1)
                              .toString()
                              .padLeft(2, '0'),
                          style: GoogleFonts.inter(
                            color:
                            Colors.white.withOpacity(.72),
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.8,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 350,
                          ),
                          width: _pressed ? 28.w : 18.w,
                          height: 1,
                          color:
                          widget.accent.withOpacity(
                            _pressed ? .85 : .45,
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
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 350,
                      ),
                      width: _pressed ? 11.w : 7.w,
                      height: _pressed ? 11.w : 7.w,
                      decoration: BoxDecoration(
                        color: widget.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // ==================================================
                  // BOTTOM CONTENT
                  // ==================================================

                  Positioned(
                    left: 18.w,
                    right: 18.w,
                    bottom: 18.h,
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 5.w,
                              height: 5.w,
                              decoration: BoxDecoration(
                                color: widget.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 7.w),
                            Expanded(
                              child: Text(
                                '${widget.wallpaperCount} WALLPAPERS',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color:
                                  Colors.white.withOpacity(.70),
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8.h),

                        Text(
                          widget.title.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.bebasNeue(
                            color: Colors.white,
                            fontSize: 45.sp,
                            height: .80,
                            letterSpacing: 1.8,
                          ),
                        ),

                        SizedBox(height: 11.h),

                        Row(
                          children: [
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(
                                  milliseconds: 500,
                                ),
                                height: 1,
                                color:
                                widget.accent.withOpacity(
                                  _pressed ? .70 : .28,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            AnimatedRotation(
                              turns: _pressed ? .12 : 0,
                              duration: const Duration(
                                milliseconds: 300,
                              ),
                              child: Icon(
                                Icons.arrow_outward_rounded,
                                color:
                                Colors.white.withOpacity(.78),
                                size: 15.sp,
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
        milliseconds: widget.index * 120,
      ),
      duration: const Duration(
        milliseconds: 900,
      ),
    )
        .moveY(
      begin: 90,
      end: 0,
      delay: Duration(
        milliseconds: widget.index * 120,
      ),
      duration: const Duration(
        milliseconds: 950,
      ),
      curve: Curves.easeOutExpo,
    )
        .scale(
      begin: const Offset(.90, .90),
      end: const Offset(1, 1),
      duration: const Duration(
        milliseconds: 950,
      ),
      curve: Curves.easeOutExpo,
    )
        .blurXY(
      begin: 4,
      end: 0,
      duration: const Duration(
        milliseconds: 800,
      ),
    );
  }
}
