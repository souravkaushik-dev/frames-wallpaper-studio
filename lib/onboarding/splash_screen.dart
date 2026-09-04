import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/bottom_nav.dart';
import 'onboard.dart';

class FoliageSplashScreen extends StatefulWidget {
  const FoliageSplashScreen({super.key});

  @override
  State<FoliageSplashScreen> createState() => _FoliageSplashScreenState();
}

class _FoliageSplashScreenState extends State<FoliageSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _intro;
  late final Animation<double> _studio;

  bool _opening = false;

  static const Color _framesGreen = Color(0xFF79B85B);

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _intro = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _studio = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        .55,
        1.0,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    _openApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _framesGreen,
        body: SafeArea(
          top: false,
          bottom: false,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  _buildFramesAnimation(),
                  _buildStudio(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FRAMES TYPOGRAPHY
  // ---------------------------------------------------------------------------

  Widget _buildFramesAnimation() {
    return Positioned.fill(
      child: ClipRect(
        child: FadeTransition(
          opacity: _intro,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              // Large enough to create the same cropped typography
              // feeling as your reference image.
              final fontSize = width * .72;

              // Each row is deliberately oversized.
              final rowHeight = height / 5.0;

              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // -----------------------------------------------------------
                  // ROW 1
                  // LEFT -> RIGHT
                  // -----------------------------------------------------------
                  _movingFrameRow(
                    top: 0,
                    rowHeight: rowHeight,
                    fontSize: fontSize,
                    startX: -width * .42,
                    endX: -width * .08,
                    direction: 1,
                  ),

                  // -----------------------------------------------------------
                  // ROW 2
                  // RIGHT -> LEFT
                  // -----------------------------------------------------------
                  _movingFrameRow(
                    top: rowHeight,
                    rowHeight: rowHeight,
                    fontSize: fontSize,
                    startX: -width * .08,
                    endX: -width * .42,
                    direction: -1,
                  ),

                  // -----------------------------------------------------------
                  // ROW 3
                  // LEFT -> RIGHT
                  // -----------------------------------------------------------
                  _movingFrameRow(
                    top: rowHeight * 2,
                    rowHeight: rowHeight,
                    fontSize: fontSize,
                    startX: -width * .42,
                    endX: -width * .08,
                    direction: 1,
                  ),

                  // -----------------------------------------------------------
                  // ROW 4
                  // RIGHT -> LEFT
                  // -----------------------------------------------------------
                  _movingFrameRow(
                    top: rowHeight * 3,
                    rowHeight: rowHeight,
                    fontSize: fontSize,
                    startX: -width * .08,
                    endX: -width * .42,
                    direction: -1,
                  ),

                  // -----------------------------------------------------------
                  // ROW 5
                  // LEFT -> RIGHT
                  // -----------------------------------------------------------
                  _movingFrameRow(
                    top: rowHeight * 4,
                    rowHeight: rowHeight,
                    fontSize: fontSize,
                    startX: -width * .42,
                    endX: -width * .08,
                    direction: 1,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOVING WORD
  // ---------------------------------------------------------------------------

  Widget _movingFrameRow({
    required double top,
    required double rowHeight,
    required double fontSize,
    required double startX,
    required double endX,
    required int direction,
  }) {
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      height: rowHeight,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            /*
             * Different rows move with different timing.
             *
             * direction:
             *  1  = left -> right
             * -1  = right -> left
             */

            final progress = Curves.easeInOut.transform(
              _controller.value,
            );

            final movement = startX +
                ((endX - startX) * progress);

            return Transform.translate(
              offset: Offset(
                movement,
                0,
              ),
              child: child,
            );
          },
          child: _buildFrameText(
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FRAME TEXT
  // ---------------------------------------------------------------------------

  Widget _buildFrameText({
    required double fontSize,
  }) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: FittedBox(
        fit: BoxFit.none,
        alignment: Alignment.centerLeft,
        child: Text(
          'FRAMES',
          maxLines: 1,
          softWrap: false,
          style: GoogleFonts.bebasNeue(
            color: Colors.black,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            height: .78,
            letterSpacing: -3,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DOTSTUDIOS
  // ---------------------------------------------------------------------------

  Widget _buildStudio() {
    return Positioned(
      right: 18.w,
      bottom: 18.h,
      child: FadeTransition(
        opacity: _studio,
        child: Text(
          'DOTSTUDIOS',
          style: GoogleFonts.manrope(
            color: Colors.black,
            fontSize: 8.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.4,
            height: 1,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // APP OPENING
  // ---------------------------------------------------------------------------

  Future<void> _openApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final onboardingDone =
          prefs.getBool('frames_onboarding_completed') ??
              prefs.getBool('foliage_onboarding_completed') ??
              false;

      await Future.delayed(
        const Duration(milliseconds: 1800),
      );

      if (!mounted || _opening) return;

      _opening = true;

      HapticFeedback.selectionClick();

      final Widget nextScreen = onboardingDone
          ? const MainScreen(
        recentWallpapers: [],
      )
          : FoliageOnboardingScreen(
        onCompleted: _finishOnboarding,
      );

      _replaceWith(nextScreen);
    } catch (error) {
      debugPrint(
        'Frames splash startup error: $error',
      );

      if (!mounted || _opening) return;

      _opening = true;

      _replaceWith(
        FoliageOnboardingScreen(
          onCompleted: _finishOnboarding,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // FINISH ONBOARDING
  // ---------------------------------------------------------------------------

  Future<void> _finishOnboarding(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
        'frames_onboarding_completed',
        true,
      );

      await prefs.setString(
        'frames_user_name',
        name,
      );

      // Keep legacy keys synchronized.
      await prefs.setBool(
        'foliage_onboarding_completed',
        true,
      );

      await prefs.setString(
        'foliage_user_name',
        name,
      );
    } catch (error) {
      debugPrint(
        'Frames onboarding save error: $error',
      );
    }

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 650,
        ),
        reverseTransitionDuration: const Duration(
          milliseconds: 400,
        ),
        pageBuilder: (_, __, ___) {
          return const MainScreen(
            recentWallpapers: [],
          );
        },
        transitionsBuilder: (
            _,
            animation,
            __,
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
          (_) => false,
    );
  }

  // ---------------------------------------------------------------------------
  // REPLACE SCREEN
  // ---------------------------------------------------------------------------

  void _replaceWith(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 650,
        ),
        reverseTransitionDuration: const Duration(
          milliseconds: 400,
        ),
        pageBuilder: (_, __, ___) {
          return screen;
        },
        transitionsBuilder: (
            _,
            animation,
            __,
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
                begin: const Offset(
                  0,
                  .015,
                ),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }
}