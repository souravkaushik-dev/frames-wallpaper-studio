import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/bottom_nav.dart';
import 'onboard.dart';

class FoliageSplashScreen extends StatefulWidget {
  const FoliageSplashScreen({
    super.key,
  });

  @override
  State<FoliageSplashScreen> createState() =>
      _FoliageSplashScreenState();
}

class _FoliageSplashScreenState
    extends State<FoliageSplashScreen>
    with SingleTickerProviderStateMixin {
  // ===========================================================================
  // ANIMATION
  // ===========================================================================

  late final AnimationController _controller;

  // ===========================================================================
  // STARTUP
  // ===========================================================================

  bool _opening = false;

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 2200,
      ),
    )..forward();

    _openApp();
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  // ===========================================================================
  // OPEN APP
  // ===========================================================================

  Future<void> _openApp() async {
    try {
      final prefs =
      await SharedPreferences.getInstance();

      final onboardingDone =
          prefs.getBool(
            'foliage_onboarding_completed',
          ) ??
              false;

      // -----------------------------------------------------------------------
      // Keep the Foliage splash on screen long enough to feel intentional.
      // -----------------------------------------------------------------------

      await Future.delayed(
        const Duration(
          milliseconds: 2400,
        ),
      );

      if (!mounted || _opening) {
        return;
      }

      _opening = true;

      HapticFeedback.selectionClick();

      // -----------------------------------------------------------------------
      // DECIDE WHERE TO GO
      // -----------------------------------------------------------------------

      final Widget nextScreen;

      if (onboardingDone) {
        nextScreen = const MainScreen(
          recentWallpapers: [],
        );
      } else {
        nextScreen = FoliageOnboardingScreen(
          onCompleted: _finishOnboarding,
        );
      }

      // -----------------------------------------------------------------------
      // REPLACE SPLASH
      // -----------------------------------------------------------------------

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration:
          const Duration(
            milliseconds: 800,
          ),
          reverseTransitionDuration:
          const Duration(
            milliseconds: 500,
          ),
          pageBuilder: (
              context,
              animation,
              secondaryAnimation,
              ) {
            return nextScreen;
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
    } catch (error) {
      debugPrint(
        'Foliage splash startup error: $error',
      );

      if (!mounted || _opening) {
        return;
      }

      _opening = true;

      // -----------------------------------------------------------------------
      // If preferences fail, show onboarding rather than leaving the user
      // stuck on the splash screen.
      // -----------------------------------------------------------------------

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration:
          const Duration(
            milliseconds: 800,
          ),
          pageBuilder: (
              context,
              animation,
              secondaryAnimation,
              ) {
            return FoliageOnboardingScreen(
              onCompleted: _finishOnboarding,
            );
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
  }

  // ===========================================================================
  // ONBOARDING COMPLETE
  // ===========================================================================

  Future<void> _finishOnboarding(
      String name,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      'foliage_onboarding_completed',
      true,
    );

    await prefs.setString(
      'foliage_user_name',
      name,
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration:
        const Duration(
          milliseconds: 700,
        ),
        pageBuilder: (
            context,
            animation,
            secondaryAnimation,
            ) {
          return const MainScreen(
            recentWallpapers: [],
          );
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
          (route) => false,
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final isDark =
        theme.brightness ==
            Brightness.dark;

    // -------------------------------------------------------------------------
    // FOLIAGE COLORS
    // -------------------------------------------------------------------------

    final background = isDark
        ? const Color(0xFF07100C)
        : const Color(0xFFF5F7F2);

    final primary = isDark
        ? const Color(0xFFF2F5F0)
        : const Color(0xFF101712);

    final secondary = isDark
        ? Colors.white.withValues(
      alpha: .65,
    )
        : const Color(0xFF536057);

    final muted = isDark
        ? Colors.white.withValues(
      alpha: .38,
    )
        : const Color(0xFF69736B);

    final surface = isDark
        ? Colors.white.withValues(
      alpha: .08,
    )
        : Colors.white.withValues(
      alpha: .82,
    );

    final accent = isDark
        ? const Color(0xFFA5C99F)
        : const Color(0xFF5E8962);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ===================================================================
          // CINEMATIC BACKGROUND
          // ===================================================================

          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (
                  context,
                  child,
                  ) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient:
                    RadialGradient(
                      center: Alignment(
                        0,
                        -.25 +
                            (_controller
                                .value *
                                .08),
                      ),
                      radius: .95,
                      colors: [
                        accent.withValues(
                          alpha: isDark
                              ? .075
                              : .045,
                        ),
                        background,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ===================================================================
          // ORGANIC GLOW - TOP RIGHT
          // ===================================================================

          Positioned(
            top: -100.h,
            right: -90.w,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (
                  context,
                  child,
                  ) {
                return Transform.translate(
                  offset: Offset(
                    10 *
                        _controller
                            .value,
                    5 *
                        math.sin(
                          _controller
                              .value *
                              3.14,
                        ),
                  ),
                  child: child,
                );
              },
              child: Container(
                width: 260.w,
                height: 260.w,
                decoration:
                BoxDecoration(
                  shape:
                  BoxShape.circle,
                  color:
                  accent.withValues(
                    alpha: isDark
                        ? .035
                        : .025,
                  ),
                ),
              ),
            ),
          ),

          // ===================================================================
          // ORGANIC GLOW - BOTTOM LEFT
          // ===================================================================

          Positioned(
            bottom: -120.h,
            left: -110.w,
            child: Container(
              width: 300.w,
              height: 300.w,
              decoration:
              BoxDecoration(
                shape:
                BoxShape.circle,
                color:
                accent.withValues(
                  alpha: isDark
                      ? .025
                      : .018,
                ),
              ),
            ),
          ),

          // ===================================================================
          // CENTER BRAND
          // ===================================================================

          SafeArea(
            child: Center(
              child: Padding(
                padding:
                EdgeInsets.symmetric(
                  horizontal: 32.w,
                ),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  children: [
                    // =========================================================
                    // FOLIAGE MARK
                    // =========================================================

                    _FoliageSplashMark(
                      primary: primary,
                      accent: accent,
                      surface: surface,
                    )
                        .animate(
                      controller:
                      _controller,
                    )
                        .fadeIn(
                      duration:
                      600.ms,
                    )
                        .scale(
                      begin:
                      const Offset(
                        .86,
                        .86,
                      ),
                      end:
                      const Offset(
                        1,
                        1,
                      ),
                      duration:
                      900.ms,
                      curve:
                      Curves
                          .easeOutCubic,
                    ),

                    SizedBox(
                      height: 22.h,
                    ),

                    // =========================================================
                    // BRAND
                    // =========================================================

                    Text(
                      'FOLIAGE',
                      style:
                      GoogleFonts.inter(
                        color: primary,
                        fontSize: 22.sp,
                        fontWeight:
                        FontWeight.w700,
                        letterSpacing: 4.5,
                      ),
                    )
                        .animate(
                      controller:
                      _controller,
                    )
                        .fadeIn(
                      delay:
                      250.ms,
                      duration:
                      650.ms,
                    )
                        .moveY(
                      begin: 10,
                      end: 0,
                      duration:
                      650.ms,
                      curve:
                      Curves
                          .easeOutCubic,
                    ),

                    SizedBox(
                      height: 9.h,
                    ),

                    // =========================================================
                    // SUBTITLE
                    // =========================================================

                    Text(
                      'CURATED WALLPAPERS',
                      style:
                      GoogleFonts.inter(
                        color: secondary,
                        fontSize: 8.sp,
                        fontWeight:
                        FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    )
                        .animate(
                      controller:
                      _controller,
                    )
                        .fadeIn(
                      delay:
                      450.ms,
                      duration:
                      600.ms,
                    ),

                    SizedBox(
                      height: 48.h,
                    ),

                    // =========================================================
                    // PROGRESS
                    // =========================================================

                    SizedBox(
                      width: 110.w,
                      child:
                      AnimatedBuilder(
                        animation:
                        _controller,
                        builder: (
                            context,
                            child,
                            ) {
                          final progress =
                          Curves
                              .easeInOut
                              .transform(
                            _controller
                                .value,
                          );

                          return Column(
                            children: [
                              ClipRRect(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  10.r,
                                ),
                                child:
                                Container(
                                  height: 2.h,
                                  color:
                                  muted
                                      .withValues(
                                    alpha:
                                    .15,
                                  ),
                                  child:
                                  Align(
                                    alignment:
                                    Alignment
                                        .centerLeft,
                                    child:
                                    FractionallySizedBox(
                                      widthFactor:
                                      progress,
                                      child:
                                      Container(
                                        decoration:
                                        BoxDecoration(
                                          color:
                                          accent,
                                          borderRadius:
                                          BorderRadius
                                              .circular(
                                            10.r,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 9.h,
                              ),
                              Text(
                                'LOADING',
                                style:
                                GoogleFonts
                                    .inter(
                                  color:
                                  muted,
                                  fontSize:
                                  7.sp,
                                  fontWeight:
                                  FontWeight
                                      .w600,
                                  letterSpacing:
                                  1.8,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                        .animate(
                      controller:
                      _controller,
                    )
                        .fadeIn(
                      delay:
                      700.ms,
                      duration:
                      500.ms,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ===================================================================
          // BOTTOM BRAND
          // ===================================================================

          Positioned(
            left: 0,
            right: 0,
            bottom: 26.h,
            child: Text(
              'FOLIAGE',
              textAlign:
              TextAlign.center,
              style: GoogleFonts.inter(
                color: muted.withValues(
                  alpha: .65,
                ),
                fontSize: 7.sp,
                fontWeight:
                FontWeight.w600,
                letterSpacing: 2,
              ),
            )
                .animate(
              controller:
              _controller,
            )
                .fadeIn(
              delay:
              1100.ms,
              duration:
              500.ms,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FOLIAGE SPLASH MARK
// =============================================================================

class _FoliageSplashMark
    extends StatelessWidget {
  const _FoliageSplashMark({
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
    return SizedBox(
      width: 62.w,
      height: 62.w,
      child: Stack(
        children: [
          // -------------------------------------------------------------------
          // OUTER CONTAINER
          // -------------------------------------------------------------------

          Positioned.fill(
            child: Container(
              decoration:
              BoxDecoration(
                color: surface,
                border: Border.all(
                  color:
                  primary.withValues(
                    alpha: .12,
                  ),
                ),
                borderRadius:
                BorderRadius.circular(
                  16.r,
                ),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // INNER FRAME
          // -------------------------------------------------------------------

          Positioned(
            left: 9.w,
            top: 9.w,
            right: 9.w,
            bottom: 9.w,
            child: Container(
              decoration:
              BoxDecoration(
                border: Border.all(
                  color:
                  accent.withValues(
                    alpha: .55,
                  ),
                  width: 1.4,
                ),
                borderRadius:
                BorderRadius.circular(
                  10.r,
                ),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // LEAF
          // -------------------------------------------------------------------

          Center(
            child: Icon(
              Icons.eco_rounded,
              color: accent,
              size: 24.sp,
            ),
          ),

          // -------------------------------------------------------------------
          // DETAIL DOT
          // -------------------------------------------------------------------

          Positioned(
            right: 6.w,
            bottom: 6.w,
            child: Container(
              width: 7.w,
              height: 7.w,
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