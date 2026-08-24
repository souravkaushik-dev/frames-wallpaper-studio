import 'dart:convert';

import 'package:dotty/api_servie/wallpaper_Api.dart';
import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/bottom_nav.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
  });

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final PageController controller =
  PageController();

  int currentPage = 0;

  bool loading = true;

  List<Wallpaper> recentWallpapers = [];

  List<Map<String, dynamic>> pages = [];

  @override
  void initState() {
    super.initState();

    fetchWallpapers();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // ============================================================
  // COLORS
  // ============================================================

  bool get isDark =>
      Theme.of(context).brightness ==
          Brightness.dark;

  Color get background =>
      isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground;

  Color get surface =>
      isDark
          ? AppColors.darkSurface
          : AppColors.lightSurface;

  Color get surfaceSoft =>
      isDark
          ? AppColors.darkSurfaceSoft
          : AppColors.lightSurfaceSoft;

  Color get primary =>
      isDark
          ? AppColors.darkPrimary
          : AppColors.lightPrimary;

  Color get secondary =>
      isDark
          ? AppColors.darkSecondary
          : AppColors.lightSecondary;

  Color get muted =>
      isDark
          ? AppColors.darkMuted
          : AppColors.lightMuted;

  Color get divider =>
      isDark
          ? AppColors.darkDivider
          : AppColors.lightDivider;

  Color get accent =>
      AppColors.accent;

  // ============================================================
  // FETCH WALLPAPERS
  // ============================================================

  Future<void> fetchWallpapers() async {
    try {
      final apiUrl =
      dotenv.env['API_URL'];

      if (apiUrl == null ||
          apiUrl.isEmpty) {
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
          'Failed to load wallpapers',
        );
      }

      final data =
      jsonDecode(
        response.body,
      );

      final List<String> images = [];

      final List<Wallpaper>
      loadedWallpapers = [];

      final categories =
      data['categories'];

      if (categories is Map) {
        categories.forEach(
              (key, value) {
            final wallpapers =
            List<String>.from(
              value['wallpapers'] ?? [],
            );

            if (wallpapers.isNotEmpty) {
              images.add(
                wallpapers.first,
              );
            }

            for (
            final image
            in wallpapers
            ) {
              loadedWallpapers.add(
                Wallpaper(
                  id:
                  image.hashCode
                      .toString(),
                  image:
                  image,
                  title:
                  getWallpaperName(
                    image,
                  ),
                  subtitle:
                  'Premium wallpaper',
                  category:
                  key.toString(),
                  isViewed:
                  false,
                  addedAt:
                  DateTime.now(),
                ),
              );
            }
          },
        );
      }

      images.shuffle();

      if (images.length < 3) {
        throw Exception(
          'Not enough wallpapers',
        );
      }

      pages = [
        {
          'title':
          'Visuals,\nrefined.',
          'subtitle':
          'A carefully curated space for wallpapers that feel as good as they look.',
          'image':
          images[0],
        },
        {
          'title':
          'Find your\nframe.',
          'subtitle':
          'Explore cinematic, minimal and expressive collections made for your screen.',
          'image':
          images[1],
        },
        {
          'title':
          'Made to\nfeel.',
          'subtitle':
          'Smooth interactions, thoughtful details and wallpapers designed around your device.',
          'image':
          images[2],
        },
      ];

      recentWallpapers =
          loadedWallpapers;
    } catch (e) {
      debugPrint(
        'Onboarding error: $e',
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      loading = false;
    });
  }

  // ============================================================
  // WALLPAPER NAME
  // ============================================================

  String getWallpaperName(
      String imageUrl,
      ) {
    final fileName =
        imageUrl
            .split('/')
            .last;

    return fileName
        .split('.')
        .first
        .replaceAll(
      RegExp(
        r'\d+x\d+',
      ),
      '',
    )
        .replaceAll(
      RegExp(
        r'\d+',
      ),
      '',
    )
        .replaceAll(
      '-',
      ' ',
    )
        .replaceAll(
      '_',
      ' ',
    )
        .trim()
        .toUpperCase();
  }

  // ============================================================
  // FINISH
  // ============================================================

  Future<void> _finish() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    await prefs.setBool(
      'onboarding_done',
      true,
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context)
        .pushReplacement(
      PageRouteBuilder(
        transitionDuration:
        const Duration(
          milliseconds: 850,
        ),
        pageBuilder:
            (
            context,
            animation,
            secondaryAnimation,
            ) =>
            MainScreen(
              recentWallpapers:
              recentWallpapers,
            ),
        transitionsBuilder:
            (
            context,
            animation,
            secondaryAnimation,
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
  }

  // ============================================================
  // NEXT
  // ============================================================

  void _next() {
    if (currentPage ==
        pages.length - 1) {
      _finish();
      return;
    }

    controller.nextPage(
      duration:
      const Duration(
        milliseconds: 650,
      ),
      curve:
      Curves.easeOutCubic,
    );
  }

  // ============================================================
  // SKIP
  // ============================================================

  Future<void> _skip() async {
    await _finish();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    if (loading ||
        pages.length < 3) {
      return Scaffold(
        backgroundColor:
        background,
        body:
        Center(
          child:
          SizedBox(
            width:
            22.w,
            height:
            22.w,
            child:
            CircularProgressIndicator(
              strokeWidth:
              2,
              color:
              accent,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
      background,

      body:
      PageView.builder(
        controller:
        controller,

        itemCount:
        pages.length,

        physics:
        const BouncingScrollPhysics(),

        onPageChanged:
            (value) {
          setState(() {
            currentPage =
                value;
          });
        },

        itemBuilder:
            (
            context,
            index,
            ) {
          return _buildPage(
            pages[index],
            index,
          );
        },
      ),
    );
  }

  // ============================================================
  // PAGE
  // ============================================================

  Widget _buildPage(
      Map<String, dynamic> item,
      int index,
      ) {
    return Stack(
      fit:
      StackFit.expand,

      children: [
        // ======================================================
        // WALLPAPER
        // ======================================================

        Hero(
          tag:
          item['image'],

          child:
          Image.network(
            item['image'],
            fit:
            BoxFit.cover,

            errorBuilder:
                (
                context,
                error,
                stackTrace,
                ) {
              return Container(
                color:
                background,
              );
            },
          )
              .animate(
            onPlay:
                (controller) {
              controller.repeat(
                reverse:
                true,
              );
            },
          )
              .scale(
            begin:
            const Offset(
              1,
              1,
            ),
            end:
            const Offset(
              1.035,
              1.035,
            ),
            duration:
            12.seconds,
            curve:
            Curves.easeInOut,
          ),
        ),

        // ======================================================
        // CINEMATIC OVERLAY
        // ======================================================

        Container(
          decoration:
          BoxDecoration(
            gradient:
            LinearGradient(
              begin:
              Alignment.topCenter,
              end:
              Alignment.bottomCenter,
              colors:
              isDark
                  ? [
                Colors.black
                    .withOpacity(
                  .06,
                ),
                Colors.black
                    .withOpacity(
                  .18,
                ),
                background
                    .withOpacity(
                  .98,
                ),
              ]
                  : [
                Colors.black
                    .withOpacity(
                  .02,
                ),
                Colors.black
                    .withOpacity(
                  .07,
                ),
                background
                    .withOpacity(
                  .97,
                ),
              ],
              stops:
              const [
                0,
                .45,
                1,
              ],
            ),
          ),
        ),

        // ======================================================
        // CONTENT
        // ======================================================

        SafeArea(
          child:
          Padding(
            padding:
            EdgeInsets.fromLTRB(
              22.w,
              20.h,
              22.w,
              20.h,
            ),

            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                // =================================================
                // TOP LEFT FRAME BRAND
                // =================================================

                Row(
                  children: [
                    _FrameMark(
                      primary:
                      primary,
                      accent:
                      accent,
                      surface:
                      surface,
                    ),

                    SizedBox(
                      width:
                      10.w,
                    ),

                    Text(
                      'FRAMES',
                      style:
                      GoogleFonts.inter(
                        color:
                        primary,
                        fontSize:
                        10.sp,
                        fontWeight:
                        FontWeight.w800,
                        letterSpacing:
                        2.8,
                      ),
                    ),

                    const Spacer(),

                    // Small skip control
                    _SkipButton(
                      secondary:
                      secondary,
                      onTap:
                      _skip,
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(
                  duration:
                  550.ms,
                )
                    .moveY(
                  begin:
                  -8,
                  end:
                  0,
                  duration:
                  600.ms,
                  curve:
                  Curves.easeOutCubic,
                ),

                const Spacer(),

                // =================================================
                // PAGE NUMBER
                // =================================================

                Text(
                  '0${index + 1}',
                  style:
                  GoogleFonts.inter(
                    color:
                    accent,
                    fontSize:
                    9.sp,
                    fontWeight:
                    FontWeight.w800,
                    letterSpacing:
                    2,
                  ),
                )
                    .animate()
                    .fadeIn(
                  duration:
                  400.ms,
                ),

                SizedBox(
                  height:
                  11.h,
                ),

                // =================================================
                // TITLE
                // =================================================

                Text(
                  item['title'],
                  style:
                  GoogleFonts.inter(
                    color:
                    primary,
                    fontSize:
                    45.sp,
                    height:
                    .94,
                    fontWeight:
                    FontWeight.w800,
                    letterSpacing:
                    -.8,
                  ),
                )
                    .animate()
                    .fadeIn(
                  duration:
                  650.ms,
                )
                    .moveY(
                  begin:
                  22,
                  end:
                  0,
                  duration:
                  650.ms,
                  curve:
                  Curves.easeOutCubic,
                ),

                SizedBox(
                  height:
                  17.h,
                ),

                SizedBox(
                  width:
                  .82.sw,
                  child:
                  Text(
                    item['subtitle'],
                    style:
                    GoogleFonts.inter(
                      color:
                      secondary,
                      fontSize:
                      13.sp,
                      height:
                      1.75,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(
                  delay:
                  120.ms,
                  duration:
                  600.ms,
                )
                    .moveY(
                  begin:
                  10,
                  end:
                  0,
                  duration:
                  600.ms,
                ),

                SizedBox(
                  height:
                  30.h,
                ),

                // =================================================
                // BOTTOM CONTROLS
                // =================================================

                _BottomControls(
                  currentPage:
                  currentPage,
                  pageCount:
                  pages.length,
                  accent:
                  accent,
                  muted:
                  muted,
                  primary:
                  primary,
                  surface:
                  surface,
                  divider:
                  divider,
                  isDark:
                  isDark,
                  onNext:
                  _next,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// FRAME MARK
// ================================================================

class _FrameMark
    extends StatelessWidget {
  const _FrameMark({
    required this.primary,
    required this.accent,
    required this.surface,
  });

  final Color primary;
  final Color accent;
  final Color surface;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width:
      28.w,
      height:
      28.w,

      decoration:
      BoxDecoration(
        color:
        surface.withOpacity(
          .92,
        ),

        border:
        Border.all(
          color:
          primary.withOpacity(
            .16,
          ),
        ),

        borderRadius:
        BorderRadius.circular(
          8.r,
        ),
      ),

      child:
      Stack(
        children: [
          Positioned(
            left:
            5.w,
            top:
            5.w,
            right:
            5.w,
            bottom:
            5.w,
            child:
            Container(
              decoration:
              BoxDecoration(
                border:
                Border.all(
                  color:
                  accent.withOpacity(
                    .65,
                  ),
                  width:
                  1.2,
                ),
                borderRadius:
                BorderRadius.circular(
                  4.r,
                ),
              ),
            ),
          ),

          Positioned(
            right:
            5.w,
            bottom:
            5.w,
            child:
            Container(
              width:
              4.5.w,
              height:
              4.5.w,
              decoration:
              BoxDecoration(
                color:
                accent,
                borderRadius:
                BorderRadius.circular(
                  1.5.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SKIP BUTTON
// ================================================================

class _SkipButton
    extends StatelessWidget {
  const _SkipButton({
    required this.secondary,
    required this.onTap,
  });

  final Color secondary;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color:
      Colors.transparent,

      child:
      InkWell(
        onTap:
        onTap,

        borderRadius:
        BorderRadius.circular(
          14.r,
        ),

        child:
        Padding(
          padding:
          EdgeInsets.symmetric(
            horizontal:
            8.w,
            vertical:
            7.h,
          ),

          child:
          Row(
            mainAxisSize:
            MainAxisSize.min,

            children: [
              Text(
                'SKIP',
                style:
                GoogleFonts.inter(
                  color:
                  secondary,
                  fontSize:
                  9.sp,
                  fontWeight:
                  FontWeight.w700,
                  letterSpacing:
                  1.2,
                ),
              ),

              SizedBox(
                width:
                4.w,
              ),

              Icon(
                Icons
                    .arrow_forward_rounded,
                size:
                13.sp,
                color:
                secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// BOTTOM CONTROLS
// ================================================================

class _BottomControls
    extends StatelessWidget {
  const _BottomControls({
    required this.currentPage,
    required this.pageCount,
    required this.accent,
    required this.muted,
    required this.primary,
    required this.surface,
    required this.divider,
    required this.isDark,
    required this.onNext,
  });

  final int currentPage;
  final int pageCount;

  final Color accent;
  final Color muted;
  final Color primary;
  final Color surface;
  final Color divider;

  final bool isDark;

  final VoidCallback onNext;

  @override
  Widget build(
      BuildContext context,
      ) {
    final isLast =
        currentPage ==
            pageCount - 1;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,

      children: [
        // ------------------------------------------------------
        // INDICATORS
        // ------------------------------------------------------

        Expanded(
          child:
          Row(
            children:
            List.generate(
              pageCount,
                  (index) {
                final active =
                    currentPage ==
                        index;

                return AnimatedContainer(
                  duration:
                  const Duration(
                    milliseconds:
                    400,
                  ),

                  curve:
                  Curves.easeOutCubic,

                  margin:
                  EdgeInsets.only(
                    right:
                    7.w,
                  ),

                  width:
                  active
                      ? 28.w
                      : 6.w,

                  height:
                  3.h,

                  decoration:
                  BoxDecoration(
                    color:
                    active
                        ? accent
                        : muted.withOpacity(
                      .28,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      20.r,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        SizedBox(
          width:
          12.w,
        ),

        // ------------------------------------------------------
        // UNIQUE NEXT BUTTON
        // ------------------------------------------------------

        _NextButton(
          isLast:
          isLast,
          accent:
          accent,
          primary:
          primary,
          surface:
          surface,
          divider:
          divider,
          onTap:
          onNext,
        ),
      ],
    );
  }
}

// ================================================================
// NEXT BUTTON
// ================================================================

class _NextButton
    extends StatelessWidget {
  const _NextButton({
    required this.isLast,
    required this.accent,
    required this.primary,
    required this.surface,
    required this.divider,
    required this.onTap,
  });

  final bool isLast;

  final Color accent;
  final Color primary;
  final Color surface;
  final Color divider;

  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color:
      Colors.transparent,

      child:
      InkWell(
        onTap:
        onTap,

        borderRadius:
        BorderRadius.circular(
          18.r,
        ),

        child:
        AnimatedContainer(
          duration:
          const Duration(
            milliseconds:
            350,
          ),

          curve:
          Curves.easeOutCubic,

          height:
          48.h,

          constraints:
          BoxConstraints(
            minWidth:
            52.w,
            maxWidth:
            92.w,
          ),

          padding:
          EdgeInsets.symmetric(
            horizontal:
            isLast
                ? 14.w
                : 0,
          ),

          decoration:
          BoxDecoration(
            color:
            accent,

            borderRadius:
            BorderRadius.circular(
              18.r,
            ),

            border:
            Border.all(
              color:
              accent.withOpacity(
                .35,
              ),
              width:
              1,
            ),
          ),

          child:
          Center(
            child:
            isLast
                ? Row(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Text(
                  'ENTER',
                  style:
                  GoogleFonts.inter(
                    color:
                    primary,
                    fontSize:
                    9.sp,
                    fontWeight:
                    FontWeight.w800,
                    letterSpacing:
                    1.1,
                  ),
                ),
                SizedBox(
                  width:
                  5.w,
                ),
                Icon(
                  Icons
                      .arrow_forward_rounded,
                  color:
                  primary,
                  size:
                  17.sp,
                ),
              ],
            )
                : Icon(
              Icons
                  .arrow_forward_rounded,
              color:
              primary,
              size:
              19.sp,
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
      delay:
      200.ms,
      duration:
      500.ms,
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
      550.ms,
      curve:
      Curves.easeOutCubic,
    );
  }
}