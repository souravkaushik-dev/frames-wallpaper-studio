import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/onboarding/onboard.dart';
import 'package:dotty/screens/bottom_nav.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openApp() async {
    final prefs =
    await SharedPreferences.getInstance();

    final onboardingDone =
        prefs.getBool(
          'onboarding_done',
        ) ??
            false;

    await Future.delayed(
      const Duration(
        milliseconds: 2400,
      ),
    );

    if (!mounted) return;

    final nextScreen = onboardingDone
        ? const MainScreen(
      recentWallpapers: [],
    )
        : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration:
        const Duration(
          milliseconds: 800,
        ),
        pageBuilder:
            (
            context,
            animation,
            secondaryAnimation,
            ) =>
        nextScreen,
        transitionsBuilder:
            (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve:
              Curves.easeOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final background = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final primary = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final secondary = isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final muted = isDark
        ? AppColors.darkMuted
        : AppColors.lightMuted;

    final surface = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final accent =
        AppColors.accent;

    return Scaffold(
      backgroundColor:
      background,

      body: Stack(
        children: [
          // Subtle cinematic background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder:
                  (context, child) {
                return DecoratedBox(
                  decoration:
                  BoxDecoration(
                    gradient:
                    RadialGradient(
                      center: Alignment(
                        0,
                        -.25 +
                            (_controller.value *
                                .08),
                      ),
                      radius: .9,
                      colors: [
                        accent.withOpacity(
                          isDark
                              ? .035
                              : .025,
                        ),
                        background,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding:
                EdgeInsets.symmetric(
                  horizontal: 32.w,
                ),

                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [
                    // Minimal frame mark
                    _FrameIcon(
                      primary:
                      primary,
                      accent:
                      accent,
                      surface:
                      surface,
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
                        .88,
                        .88,
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

                    // Small brand
                    Text(
                      'FRAMES',
                      style:
                      GoogleFonts.inter(
                        color:
                        primary,
                        fontSize:
                        22.sp,
                        fontWeight:
                        FontWeight.w700,
                        letterSpacing:
                        4.5,
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
                      begin:
                      10,
                      end:
                      0,
                      duration:
                      650.ms,
                      curve:
                      Curves
                          .easeOutCubic,
                    ),

                    SizedBox(
                      height: 9.h,
                    ),

                    Text(
                      'CURATED WALLPAPERS',
                      style:
                      GoogleFonts.inter(
                        color:
                        secondary,
                        fontSize:
                        8.sp,
                        fontWeight:
                        FontWeight.w600,
                        letterSpacing:
                        2,
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

                    // Minimal progress
                    SizedBox(
                      width:
                      110.w,
                      child:
                      AnimatedBuilder(
                        animation:
                        _controller,
                        builder:
                            (
                            context,
                            child,
                            ) {
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
                                  height:
                                  2.h,
                                  color:
                                  muted
                                      .withOpacity(
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
                                      Curves
                                          .easeInOut
                                          .transform(
                                        _controller
                                            .value,
                                      ),
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
                                height:
                                9.h,
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

          // Bottom version
          Positioned(
            left: 0,
            right: 0,
            bottom: 26.h,
            child: Text(
              'FRAMES',
              textAlign:
              TextAlign.center,
              style:
              GoogleFonts.inter(
                color:
                muted.withOpacity(
                  .65,
                ),
                fontSize:
                7.sp,
                fontWeight:
                FontWeight.w600,
                letterSpacing:
                2,
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

// ================================================================
// MINIMAL FRAME ICON
// ================================================================

class _FrameIcon
    extends StatelessWidget {
  final Color primary;
  final Color accent;
  final Color surface;

  const _FrameIcon({
    required this.primary,
    required this.accent,
    required this.surface,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return SizedBox(
      width: 62.w,
      height: 62.w,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration:
              BoxDecoration(
                color:
                surface,
                border:
                Border.all(
                  color:
                  primary.withOpacity(
                    .12,
                  ),
                ),
                borderRadius:
                BorderRadius.circular(
                  16.r,
                ),
              ),
            ),
          ),

          Positioned(
            left: 9.w,
            top: 9.w,
            right: 9.w,
            bottom: 9.w,
            child: Container(
              decoration:
              BoxDecoration(
                border:
                Border.all(
                  color:
                  accent.withOpacity(
                    .55,
                  ),
                  width: 1.4,
                ),
                borderRadius:
                BorderRadius.circular(
                  9.r,
                ),
              ),
            ),
          ),

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