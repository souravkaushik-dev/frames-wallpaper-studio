import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
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
  late final Animation<double> _frames;
  late final Animation<double> _brand;
  late final Animation<double> _copy;
  bool _opening = false;

  @override
  void initState() {
    super.initState();

    // Keep the Android/iOS status and navigation areas available.
    // We do not hide system bars, so pulling down the notification panel
    // remains natural and the splash never fights the OS gesture area.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );

    _intro = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, .42, curve: Curves.easeOutCubic),
    );
    _frames = CurvedAnimation(
      parent: _controller,
      curve: const Interval(.08, .78, curve: Curves.easeOutBack),
    );
    _brand = CurvedAnimation(
      parent: _controller,
      curve: const Interval(.30, .76, curve: Curves.easeOutCubic),
    );
    _copy = CurvedAnimation(
      parent: _controller,
      curve: const Interval(.55, 1, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _openApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _background =>
      _isDark ? AppColors.darkBackground : AppColors.lightBackground;

  Color get _primary =>
      _isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

  Color get _muted =>
      _isDark ? AppColors.darkMuted : AppColors.lightMuted;

  Color get _surface =>
      _isDark ? AppColors.darkSurface : AppColors.lightSurface;

  @override
  Widget build(BuildContext context) {
    final overlayStyle = _isDark
        ? SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    )
        : SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: _background,
        body: SafeArea(
          top: true,
          bottom: true,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  _buildBackground(),
                  _buildMain(),
                  _buildBottom(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final onboardingDone =
          prefs.getBool('frames_onboarding_completed') ??
              prefs.getBool('foliage_onboarding_completed') ??
              false;

      await Future.delayed(const Duration(milliseconds: 2300));

      if (!mounted || _opening) return;

      _opening = true;
      HapticFeedback.selectionClick();

      final Widget nextScreen = onboardingDone
          ? const MainScreen(recentWallpapers: [])
          : FoliageOnboardingScreen(onCompleted: _finishOnboarding);

      _replaceWith(nextScreen);
    } catch (error) {
      debugPrint('Frames splash startup error: $error');

      if (!mounted || _opening) return;
      _opening = true;

      _replaceWith(
        FoliageOnboardingScreen(onCompleted: _finishOnboarding),
      );
    }
  }

  Future<void> _finishOnboarding(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('frames_onboarding_completed', true);
      await prefs.setString('frames_user_name', name);

      // Keep legacy keys synchronized for existing installs.
      await prefs.setBool('foliage_onboarding_completed', true);
      await prefs.setString('foliage_user_name', name);
    } catch (error) {
      debugPrint('Frames onboarding save error: $error');
    }

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        reverseTransitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => const MainScreen(
          recentWallpapers: [],
        ),
        transitionsBuilder: (_, animation, __, child) {
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

  void _replaceWith(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        reverseTransitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .018),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    final accent = AppColors.accent;

    return IgnorePointer(
      child: CustomPaint(
        painter: _SplashGridPainter(
          dark: _isDark,
          accent: accent,
          progress: _controller.value.clamp(0.0, 1.0).toDouble(),
        ),
      ),
    );
  }

  Widget _buildMain() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 26.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFrameOrbit(),
            SizedBox(height: 30.h),
            _buildBrand(),
            SizedBox(height: 13.h),
            FadeTransition(
              opacity: _copy,
              child: Text(
                'YOUR SPACE, CURATED',
                style: GoogleFonts.manrope(
                  color: _muted,
                  fontSize: 7.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.5,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            _buildProgress(),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameOrbit() {
    final t = _frames.value.clamp(0.0, 1.0).toDouble();
    final pulse = 1 + (0.018 * Curves.easeInOut.transform(
      ((t * 1.4) % 1).clamp(0.0, 1.0),
    ));

    return SizedBox(
      width: 270.w,
      height: 285.h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Transform.rotate(
            angle: -.075 * t,
            child: Transform.translate(
              offset: Offset(-51.w * t, 17.h * (1 - t)),
              child: Transform.scale(
                scale: .76 + (.10 * t),
                child: _ArtFrame(
                  kind: 1,
                  dark: _isDark,
                  muted: true,
                ),
              ),
            ),
          ),
          Transform.rotate(
            angle: .075 * t,
            child: Transform.translate(
              offset: Offset(51.w * t, 17.h * (1 - t)),
              child: Transform.scale(
                scale: .76 + (.10 * t),
                child: _ArtFrame(
                  kind: 2,
                  dark: _isDark,
                  muted: true,
                ),
              ),
            ),
          ),
          Transform.scale(
            scale: (.74 + (.26 * t)) * pulse,
            child: _ArtFrame(
              kind: 0,
              dark: _isDark,
            ),
          ),
          Positioned(
            bottom: 8.h,
            child: Opacity(
              opacity: .32 + (.68 * t),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Dot(active: true),
                  SizedBox(width: 5.w),
                  _Dot(),
                  SizedBox(width: 5.w),
                  _Dot(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return FadeTransition(
      opacity: _brand,
      child: Transform.translate(
        offset: Offset(0, 9.h * (1 - _brand.value)),
        child: Column(
          children: [
            Text(
              'FRAMES',
              style: GoogleFonts.bebasNeue(
                color: _primary,
                fontSize: 48.sp,
                height: .82,
                letterSpacing: 3.2,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: 34.w,
              height: 1.h,
              color: AppColors.accent.withOpacity(.8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return FadeTransition(
      opacity: _copy,
      child: SizedBox(
        width: 142.w,
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'LOADING',
                  style: GoogleFonts.manrope(
                    color: _muted.withOpacity(.58),
                    fontSize: 5.5.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(_controller.value.clamp(0.0, 1.0) * 100).round()}%',
                  style: GoogleFonts.manrope(
                    color: _muted.withOpacity(.58),
                    fontSize: 5.5.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 7.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: SizedBox(
                height: 2.h,
                child: Stack(
                  children: [
                    Container(color: _muted.withOpacity(.12)),
                    FractionallySizedBox(
                      widthFactor: _controller.value.clamp(0.0, 1.0),
                      child: Container(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return Positioned(
      left: 22.w,
      right: 22.w,
      bottom: 10.h,
      child: FadeTransition(
        opacity: _copy,
        child: Row(
          children: [
            Text(
              'DOTSTUDIOS',
              style: GoogleFonts.manrope(
                color: _muted.withOpacity(.45),
                fontSize: 6.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
              ),
            ),
            const Spacer(),
            Text(
              'WALLPAPER STUDIO',
              style: GoogleFonts.manrope(
                color: _muted.withOpacity(.35),
                fontSize: 5.5.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtFrame extends StatelessWidget {
  const _ArtFrame({
    required this.kind,
    required this.dark,
    this.muted = false,
  });

  final int kind;
  final bool dark;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final width = 142.w;
    final height = 250.h;

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(29.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(muted ? .10 : .18),
              blurRadius: muted ? 17 : 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(29.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _WallpaperArt(kind: kind),
              Positioned(
                top: 9.h,
                left: 9.w,
                right: 9.w,
                child: Row(
                  children: [
                    Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.9),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 30.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.16),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 11.w,
                right: 11.w,
                bottom: 12.h,
                child: Row(
                  children: [
                    Text(
                      kind == 0 ? '01' : kind == 1 ? '02' : '03',
                      style: GoogleFonts.bebasNeue(
                        color: Colors.white.withOpacity(.92),
                        fontSize: 15.sp,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'FRAME',
                      style: GoogleFonts.manrope(
                        color: Colors.white.withOpacity(.75),
                        fontSize: 5.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (muted)
                Container(color: dark
                    ? Colors.black.withOpacity(.18)
                    : Colors.white.withOpacity(.10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WallpaperArt extends StatelessWidget {
  const _WallpaperArt({required this.kind});

  final int kind;

  @override
  Widget build(BuildContext context) {
    if (kind == 1) {
      return CustomPaint(painter: _NaturePainter());
    }
    if (kind == 2) {
      return CustomPaint(painter: _MonochromePainter());
    }
    return CustomPaint(painter: _AbstractPainter());
  }
}

class _AbstractPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFD8D5C8),
        Color(0xFF9A9B90),
        Color(0xFF2B302D),
      ],
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    final shape = Paint()..color = Colors.white.withOpacity(.14);
    canvas.drawCircle(
      Offset(size.width * .72, size.height * .27),
      size.width * .34,
      shape,
    );

    final line = Paint()
      ..color = Colors.white.withOpacity(.22)
      ..strokeWidth = 1.3;
    canvas.drawLine(
      Offset(size.width * .08, size.height * .62),
      Offset(size.width * .92, size.height * .38),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFC9D0B7),
        Color(0xFF6D795F),
        Color(0xFF253027),
      ],
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    final leaf = Paint()..color = const Color(0xFF18231C).withOpacity(.72);
    final path = Path()
      ..moveTo(size.width * .12, size.height * .95)
      ..quadraticBezierTo(
        size.width * .52,
        size.height * .54,
        size.width * .78,
        size.height * .08,
      )
      ..quadraticBezierTo(
        size.width * .50,
        size.height * .30,
        size.width * .12,
        size.height * .95,
      )
      ..close();
    canvas.drawPath(path, leaf);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MonochromePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFE3E1DC),
        Color(0xFF898883),
        Color(0xFF181A19),
      ],
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .06
      ..color = Colors.white.withOpacity(.20);
    canvas.drawCircle(
      Offset(size.width * .52, size.height * .44),
      size.width * .34,
      ring,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Dot extends StatelessWidget {
  const _Dot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 14.w : 4.w,
      height: 4.w,
      decoration: BoxDecoration(
        color: active
            ? AppColors.accent
            : Theme.of(context).colorScheme.onSurface.withOpacity(.18),
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }
}

class _SplashGridPainter extends CustomPainter {
  const _SplashGridPainter({
    required this.dark,
    required this.accent,
    required this.progress,
  });

  final bool dark;
  final Color accent;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Deliberately keeps the corners completely clean.
    // The visual identity lives in the central composition instead.
    final linePaint = Paint()
      ..color = accent.withOpacity(dark ? .025 : .018)
      ..strokeWidth = .7;

    final center = Offset(size.width / 2, size.height * .42);
    final maxRadius = size.width * .72;

    for (int i = 0; i < 5; i++) {
      final radius = maxRadius * ((i + 1) / 5);
      final animatedRadius =
          radius + (progress * 10 * (i.isEven ? 1 : -1));

      canvas.drawCircle(center, animatedRadius, linePaint);
    }

    final crossPaint = Paint()
      ..color = accent.withOpacity(dark ? .04 : .025)
      ..strokeWidth = .7;

    canvas.drawLine(
      Offset(center.dx - size.width * .32, center.dy),
      Offset(center.dx + size.width * .32, center.dy),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SplashGridPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.dark != dark;
  }
}
