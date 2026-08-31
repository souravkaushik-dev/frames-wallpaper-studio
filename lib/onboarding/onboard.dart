import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoliageOnboardingScreen extends StatefulWidget {
  const FoliageOnboardingScreen({
    super.key,
    required this.onCompleted,
  });

  final Future<void> Function(String name) onCompleted;

  @override
  State<FoliageOnboardingScreen> createState() =>
      _FoliageOnboardingScreenState();
}

class _FoliageOnboardingScreenState
    extends State<FoliageOnboardingScreen>
    with TickerProviderStateMixin {
  // ===========================================================================
  // PAGE CONTROLLER
  // ===========================================================================

  late final PageController _pageController;

  int _currentPage = 0;

  bool _finishing = false;

  // ===========================================================================
  // AMBIENT ANIMATION
  // ===========================================================================

  late final AnimationController _ambientController;

  // ===========================================================================
  // ONBOARDING CONTENT
  // ===========================================================================

  final List<_FoliagePage> _pages = const [
    _FoliagePage(
      number: '01',
      eyebrow: 'DISCOVER',
      title: 'Nature,\nreframed.',
      description:
      'Curated wallpapers inspired by the quiet beauty of nature.',
      imageUrl:
      'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=1600&q=90',
    ),
    _FoliagePage(
      number: '02',
      eyebrow: 'EXPLORE',
      title: 'Find your\natmosphere.',
      description:
      'Explore cinematic landscapes, organic textures and expressive artwork.',
      imageUrl:
      'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=1600&q=90',
    ),
    _FoliagePage(
      number: '03',
      eyebrow: 'PERSONALIZE',
      title: 'Make it\nyours.',
      description:
      'Save the wallpapers that feel right and make your screen feel like home.',
      imageUrl:
      'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=1600&q=90',
    ),
  ];

  // ===========================================================================
  // THEME
  // ===========================================================================

  bool get _isDark =>
      Theme.of(context).brightness ==
          Brightness.dark;

  Color get _background => _isDark
      ? const Color(0xFF07100C)
      : const Color(0xFFF4F6F1);

  Color get _foreground => _isDark
      ? const Color(0xFFF4F7F2)
      : const Color(0xFF101712);

  Color get _secondary => _isDark
      ? Colors.white.withValues(alpha: .68)
      : const Color(0xFF536057);

  Color get _muted => _isDark
      ? Colors.white.withValues(alpha: .42)
      : const Color(0xFF687269);

  Color get _accent => _isDark
      ? const Color(0xFFA5C99F)
      : const Color(0xFF5E8962);

  Color get _surface => _isDark
      ? Colors.white.withValues(alpha: .10)
      : Colors.white.withValues(alpha: .86);

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 16,
      ),
    )..repeat();
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _pageController.dispose();
    _ambientController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // NEXT PAGE
  // ===========================================================================

  Future<void> _nextPage() async {
    if (_finishing) {
      return;
    }

    if (_currentPage ==
        _pages.length - 1) {
      await _finishOnboarding();
      return;
    }

    HapticFeedback.selectionClick();

    await _pageController.nextPage(
      duration: const Duration(
        milliseconds: 700,
      ),
      curve: Curves.easeOutCubic,
    );
  }

  // ===========================================================================
  // SKIP
  // ===========================================================================

  Future<void> _skip() async {
    if (_finishing) {
      return;
    }

    HapticFeedback.selectionClick();

    await _finishOnboarding();
  }

  // ===========================================================================
  // FINISH
  // ===========================================================================

  Future<void> _finishOnboarding() async {
    if (_finishing) {
      return;
    }

    setState(() {
      _finishing = true;
    });

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      'foliage_onboarding_completed',
      true,
    );

    await prefs.setString(
      'foliage_user_name',
      '',
    );

    if (!mounted) {
      return;
    }

    await widget.onCompleted('');
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        physics:
        const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (
            context,
            index,
            ) {
          return _buildPage(
            _pages[index],
            index,
          );
        },
      ),
    );
  }

  // ===========================================================================
  // PAGE
  // ===========================================================================

  Widget _buildPage(
      _FoliagePage page,
      int index,
      ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // =====================================================================
        // WALLPAPER
        // =====================================================================

        _Wallpaper(
          imageUrl: page.imageUrl,
          animation:
          _ambientController,
        ),

        // =====================================================================
        // CINEMATIC OVERLAY
        // =====================================================================

        _GradientOverlay(
          isDark: _isDark,
          background: _background,
        ),

        // =====================================================================
        // CONTENT
        // =====================================================================

        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              22.w,
              18.h,
              22.w,
              18.h,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // =============================================================
                // HEADER
                // =============================================================

                _buildHeader(),

                // =============================================================
                // MAIN CONTENT
                //
                // Spacer keeps this content toward the bottom while still
                // allowing it to breathe on different screen sizes.
                // =============================================================

                const Spacer(),

                _buildEditorialContent(
                  page,
                  index,
                ),

                SizedBox(height: 27.h),

                // =============================================================
                // BOTTOM NAVIGATION
                // =============================================================

                _buildBottomControls(
                  index,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader() {
    return Row(
      children: [
        // ---------------------------------------------------------------------
        // FOLIAGE MARK
        // ---------------------------------------------------------------------

        _FoliageMark(
          accent: _accent,
          surface: _surface,
        ),

        SizedBox(width: 10.w),

        // ---------------------------------------------------------------------
        // BRAND
        // ---------------------------------------------------------------------

        Text(
          'FOLIAGE',
          style: GoogleFonts.inter(
            color: _foreground,
            fontSize: 10.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),

        const Spacer(),

        // ---------------------------------------------------------------------
        // SKIP
        // ---------------------------------------------------------------------

        GestureDetector(
          onTap: _skip,
          behavior:
          HitTestBehavior.opaque,
          child: Padding(
            padding:
            EdgeInsets.symmetric(
              horizontal: 7.w,
              vertical: 8.h,
            ),
            child: Row(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Text(
                  'SKIP',
                  style:
                  GoogleFonts.inter(
                    color: _foreground
                        .withValues(
                      alpha: .78,
                    ),
                    fontSize: 9.sp,
                    fontWeight:
                    FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons
                      .arrow_forward_rounded,
                  size: 13.sp,
                  color:
                  _foreground
                      .withValues(
                    alpha: .78,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(
      duration: 600.ms,
    )
        .moveY(
      begin: -10,
      end: 0,
      duration: 650.ms,
      curve:
      Curves.easeOutCubic,
    );
  }

  // ===========================================================================
  // EDITORIAL CONTENT
  // ===========================================================================

  Widget _buildEditorialContent(
      _FoliagePage page,
      int index,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        // ---------------------------------------------------------------------
        // NUMBER + EYEBROW
        // ---------------------------------------------------------------------

        Row(
          children: [
            Text(
              page.number,
              style: GoogleFonts.inter(
                color: _accent,
                fontSize: 9.sp,
                fontWeight:
                FontWeight.w800,
                letterSpacing: 2.4,
              ),
            ),
            SizedBox(width: 13.w),
            Container(
              width: 24.w,
              height: 1.h,
              color: _accent.withValues(
                alpha: .55,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              page.eyebrow,
              style: GoogleFonts.inter(
                color: _foreground
                    .withValues(
                  alpha: .58,
                ),
                fontSize: 8.sp,
                fontWeight:
                FontWeight.w700,
                letterSpacing: 1.8,
              ),
            ),
          ],
        )
            .animate(
          key: ValueKey(
            'meta_$index',
          ),
        )
            .fadeIn(
          duration: 450.ms,
        )
            .moveX(
          begin: -12,
          end: 0,
          duration: 500.ms,
          curve:
          Curves.easeOutCubic,
        ),

        SizedBox(height: 12.h),

        // ---------------------------------------------------------------------
        // TITLE
        // ---------------------------------------------------------------------

        Text(
          page.title,
          style: GoogleFonts.inter(
            color: _foreground,
            fontSize: 45.sp,
            height: .94,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.8,
          ),
        )
            .animate(
          key: ValueKey(
            'title_$index',
          ),
        )
            .fadeIn(
          delay: 80.ms,
          duration: 650.ms,
        )
            .moveY(
          begin: 24,
          end: 0,
          duration: 700.ms,
          curve:
          Curves.easeOutCubic,
        ),

        SizedBox(height: 17.h),

        // ---------------------------------------------------------------------
        // DESCRIPTION
        // ---------------------------------------------------------------------

        SizedBox(
          width: .82.sw,
          child: Text(
            page.description,
            style: GoogleFonts.inter(
              color: _secondary,
              fontSize: 13.sp,
              height: 1.65,
              fontWeight:
              FontWeight.w500,
            ),
          ),
        )
            .animate(
          key: ValueKey(
            'description_$index',
          ),
        )
            .fadeIn(
          delay: 180.ms,
          duration: 600.ms,
        )
            .moveY(
          begin: 12,
          end: 0,
          duration: 600.ms,
          curve:
          Curves.easeOutCubic,
        ),
      ],
    );
  }

  // ===========================================================================
  // BOTTOM CONTROLS
  // ===========================================================================

  Widget _buildBottomControls(
      int index,
      ) {
    final isLast =
        index == _pages.length - 1;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        // =====================================================================
        // PROGRESS
        // =====================================================================

        Expanded(
          child: Row(
            children: List.generate(
              _pages.length,
                  (i) {
                final active =
                    i == index;

                return AnimatedContainer(
                  duration:
                  const Duration(
                    milliseconds: 450,
                  ),
                  curve:
                  Curves.easeOutCubic,
                  width:
                  active ? 31.w : 7.w,
                  height: 3.h,
                  margin:
                  EdgeInsets.only(
                    right: 7.w,
                  ),
                  decoration:
                  BoxDecoration(
                    color: active
                        ? _accent
                        : _foreground
                        .withValues(
                      alpha: .26,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(
                      10.r,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // =====================================================================
        // NEXT / ENTER
        // =====================================================================

        GestureDetector(
          onTap: _nextPage,
          behavior:
          HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration:
            const Duration(
              milliseconds: 350,
            ),
            curve:
            Curves.easeOutCubic,
            height: 48.h,
            padding:
            EdgeInsets.symmetric(
              horizontal:
              isLast ? 15.w : 0,
            ),
            constraints:
            BoxConstraints(
              minWidth: 52.w,
            ),
            decoration:
            BoxDecoration(
              color: _accent,
              borderRadius:
              BorderRadius.circular(
                17.r,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                  _accent.withValues(
                    alpha:
                    _isDark ? .12 : .18,
                  ),
                  blurRadius: 20,
                  offset:
                  const Offset(
                    0,
                    7,
                  ),
                ),
              ],
            ),
            child: Center(
              child: isLast
                  ? Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Text(
                    'ENTER',
                    style:
                    GoogleFonts
                        .inter(
                      color:
                      _isDark
                          ? const Color(
                        0xFF07100C,
                      )
                          : Colors
                          .white,
                      fontSize: 9.sp,
                      fontWeight:
                      FontWeight.w800,
                      letterSpacing:
                      1.2,
                    ),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Icon(
                    Icons
                        .arrow_forward_rounded,
                    size: 17.sp,
                    color:
                    _isDark
                        ? const Color(
                      0xFF07100C,
                    )
                        : Colors
                        .white,
                  ),
                ],
              )
                  : Icon(
                Icons
                    .arrow_forward_rounded,
                size: 19.sp,
                color:
                _isDark
                    ? const Color(
                  0xFF07100C,
                )
                    : Colors.white,
              ),
            ),
          ),
        ),
      ],
    )
        .animate(
      key: ValueKey(
        'controls_$index',
      ),
    )
        .fadeIn(
      duration: 500.ms,
    )
        .scale(
      begin: const Offset(
        .95,
        .95,
      ),
      end: const Offset(
        1,
        1,
      ),
      duration: 500.ms,
      curve:
      Curves.easeOutCubic,
    );
  }
}

// =============================================================================
// WALLPAPER
// =============================================================================

class _Wallpaper extends StatelessWidget {
  const _Wallpaper({
    required this.imageUrl,
    required this.animation,
  });

  final String imageUrl;
  final Animation<double> animation;

  @override
  Widget build(
      BuildContext context,
      ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (
          context,
          child,
          ) {
        final value =
            animation.value *
                math.pi *
                2;

        final scale =
            1.045 +
                math.sin(value) *
                    .007;

        final x =
            math.sin(value) * 4;

        final y =
            math.cos(value) * 3;

        return Transform.translate(
          offset: Offset(x, y),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        filterQuality:
        FilterQuality.high,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return Container(
            color: Theme.of(
              context,
            ).scaffoldBackgroundColor,
          );
        },
      ),
    );
  }
}

// =============================================================================
// GRADIENT OVERLAY
// =============================================================================

class _GradientOverlay
    extends StatelessWidget {
  const _GradientOverlay({
    required this.isDark,
    required this.background,
  });

  final bool isDark;
  final Color background;

  @override
  Widget build(
      BuildContext context,
      ) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient:
          LinearGradient(
            begin:
            Alignment.topCenter,
            end:
            Alignment.bottomCenter,
            colors: isDark
                ? [
              Colors.black
                  .withValues(
                alpha: .08,
              ),
              Colors.black
                  .withValues(
                alpha: .10,
              ),
              Colors.black
                  .withValues(
                alpha: .30,
              ),
              const Color(
                0xFF07100C,
              ).withValues(
                alpha: .98,
              ),
            ]
                : [
              Colors.black
                  .withValues(
                alpha: .025,
              ),
              Colors.black
                  .withValues(
                alpha: .02,
              ),
              Colors.black
                  .withValues(
                alpha: .12,
              ),
              background.withValues(
                alpha: .98,
              ),
            ],
            stops: const [
              0,
              .35,
              .60,
              1,
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// FOLIAGE MARK
// =============================================================================

class _FoliageMark
    extends StatelessWidget {
  const _FoliageMark({
    required this.accent,
    required this.surface,
  });

  final Color accent;
  final Color surface;

  @override
  Widget build(
      BuildContext context,
      ) {
    return SizedBox(
      width: 30.w,
      height: 30.w,
      child: Stack(
        children: [
          // -------------------------------------------------------------------
          // OUTER
          // -------------------------------------------------------------------

          Positioned.fill(
            child: Container(
              decoration:
              BoxDecoration(
                color: surface,
                borderRadius:
                BorderRadius
                    .circular(
                  9.r,
                ),
                border: Border.all(
                  color:
                  accent.withValues(
                    alpha: .22,
                  ),
                  width: .8,
                ),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // INNER ORGANIC MARK
          // -------------------------------------------------------------------

          Center(
            child: Icon(
              Icons.eco_rounded,
              size: 17.sp,
              color: accent,
            ),
          ),

          // -------------------------------------------------------------------
          // DETAIL
          // -------------------------------------------------------------------

          Positioned(
            right: 5.w,
            bottom: 5.w,
            child: Container(
              width: 4.w,
              height: 4.w,
              decoration:
              BoxDecoration(
                color: accent,
                borderRadius:
                BorderRadius.circular(
                  2.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAGE MODEL
// =============================================================================

class _FoliagePage {
  const _FoliagePage({
    required this.number,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  final String number;
  final String eyebrow;
  final String title;
  final String description;
  final String imageUrl;
}