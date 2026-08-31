
    import 'dart:math' as math;

    import 'package:flutter/material.dart';
    import 'package:flutter/services.dart';
    import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
    import 'package:google_fonts/google_fonts.dart';

    import '../../../../core/theme/app_theme.dart';

    class FoliageSplashScreen extends StatefulWidget {
    const FoliageSplashScreen({
    super.key,
    this.onFinished,
    });

    final VoidCallback? onFinished;

    @override
    State<FoliageSplashScreen> createState() =>
    _FoliageSplashScreenState();
    }

    class _FoliageSplashScreenState
    extends State<FoliageSplashScreen>
    with TickerProviderStateMixin {
    late final AnimationController _controller;
    late final AnimationController _ambientController;

    late final Animation<double> _scale;
    late final Animation<double> _opacity;
    late final Animation<double> _markRotation;
    late final Animation<double> _textOpacity;
    late final Animation<double> _textSlide;

    bool _finished = false;

    @override
    void initState() {
    super.initState();

    // -------------------------------------------------------------------------
    // MAIN ENTRANCE ANIMATION
    // -------------------------------------------------------------------------

    _controller = AnimationController(
    vsync: this,
    duration: const Duration(
    milliseconds: 1250,
    ),
    );

    _scale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(
    0,
    .68,
    curve: Curves.easeOutBack,
    ),
    );

    _opacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(
    0,
    .42,
    curve: Curves.easeOut,
    ),
    );

    _markRotation = Tween<double>(
    begin: -.10,
    end: 0,
    ).animate(
    CurvedAnimation(
    parent: _controller,
    curve: const Interval(
    0,
    .75,
    curve: Curves.easeOutCubic,
    ),
    ),
    );

    _textOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(
    .30,
    .82,
    curve: Curves.easeOut,
    ),
    );

    _textSlide = Tween<double>(
    begin: 16,
    end: 0,
    ).animate(
    CurvedAnimation(
    parent: _controller,
    curve: const Interval(
    .28,
    .85,
    curve: Curves.easeOutCubic,
    ),
    ),
    );

    // -------------------------------------------------------------------------
    // AMBIENT ANIMATION
    // -------------------------------------------------------------------------

    _ambientController = AnimationController(
    vsync: this,
    duration: const Duration(
    seconds: 12,
    ),
    )..repeat();

    _controller.forward();

    // -------------------------------------------------------------------------
    // FINISH
    // -------------------------------------------------------------------------

    Future<void>.delayed(
    const Duration(
    milliseconds: 1900,
    ),
    _finish,
    );
    }

    @override
    void dispose() {
    _controller.dispose();
    _ambientController.dispose();

    super.dispose();
    }

    void _finish() {
    if (!mounted || _finished) {
    return;
    }

    _finished = true;

    HapticFeedback.selectionClick();

    widget.onFinished?.call();
    }

    @override
    Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    final isDark = brightness == Brightness.dark;

    final colors = theme.colorScheme;

    final backgroundColor = isDark
    ? const Color(0xFF07100C)
        : const Color(0xFFF5F7F2);

    final primaryColor = isDark
    ? const Color(0xFF8FBA91)
        : FleckTheme.seedColor;

    final foregroundColor = isDark
    ? Colors.white
        : const Color(0xFF101812);

    final secondaryColor = isDark
    ? Colors.white.withValues(alpha: .62)
        : colors.onSurfaceVariant;

    return AnnotatedRegion<SystemUiOverlayStyle>(
    value: isDark
    ? SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: backgroundColor,
    systemNavigationBarIconBrightness:
    Brightness.light,
    )
        : SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: backgroundColor,
    systemNavigationBarIconBrightness:
    Brightness.dark,
    ),
    child: Scaffold(
    backgroundColor: backgroundColor,
    body: Stack(
    fit: StackFit.expand,
    children: [
    // =================================================================
    // AMBIENT BACKGROUND
    // =================================================================

    AnimatedBuilder(
    animation: _ambientController,
    builder: (context, child) {
    return _SplashBackground(
    progress: _ambientController.value,
    isDark: isDark,
    primaryColor: primaryColor,
    );
    },
    ),

    // =================================================================
    // CENTER CONTENT
    // =================================================================

    Center(
    child: AnimatedBuilder(
    animation: _controller,
    builder: (
    context,
    child,
    ) {
    return FadeTransition(
    opacity: _opacity,
    child: Transform.translate(
    offset: Offset(
    0,
    -_textSlide.value * .20,
    ),
    child: Transform.scale(
    scale: .78 +
    (_scale.value * .22),
    child: Transform.rotate(
    angle: _markRotation.value,
    child: child,
    ),
    ),
    ),
    );
    },
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    // ---------------------------------------------------------
    // LOGO MARK
    // ---------------------------------------------------------

    _AnimatedLogoMark(
    isDark: isDark,
    primaryColor: primaryColor,
    animation: _ambientController,
    ),

    SizedBox(height: 22.h),

    // ---------------------------------------------------------
    // FOLIAGE
    // ---------------------------------------------------------

    FadeTransition(
    opacity: _textOpacity,
    child: Text(
    'Foliage',
    style: GoogleFonts.inter(
    color: foregroundColor,
    fontSize: 34.sp,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.7,
    height: .95,
    ),
    ),
    ),

    SizedBox(height: 9.h),

    // ---------------------------------------------------------
    // TAGLINE
    // ---------------------------------------------------------

    AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
    return Opacity(
    opacity: _textOpacity.value,
    child: Transform.translate(
    offset: Offset(
    0,
    _textSlide.value,
    ),
    child: child,
    ),
    );
    },
    child: Text(
    'Wallpaper, your way.',
    textAlign: TextAlign.center,
    style: GoogleFonts.inter(
    color: secondaryColor,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: -.15,
    ),
    ),
    ),
    ],
    ),
    ),
    ),

    // =================================================================
    // TOP LEFT DECORATION
    // =================================================================

    Positioned(
    top: -70.h,
    left: -80.w,
    child: _GlowOrb(
    size: 220.w,
    color: primaryColor,
    opacity: isDark ? .09 : .055,
    animation: _ambientController,
    direction: 1,
    ),
    ),

    // =================================================================
    // BOTTOM RIGHT DECORATION
    // =================================================================

    Positioned(
    right: -100.w,
    bottom: -100.h,
    child: _GlowOrb(
    size: 280.w,
    color: primaryColor,
    opacity: isDark ? .075 : .045,
    animation: _ambientController,
    direction: -1,
    ),
    ),

    // =================================================================
    // BOTTOM BRANDING
    // =================================================================

    Positioned(
    left: 0,
    right: 0,
    bottom: 32.h,
    child: FadeTransition(
    opacity: _textOpacity,
    child: Column(
    children: [
    Text(
    'FOLIAGE',
    style: GoogleFonts.inter(
    color: secondaryColor.withValues(
    alpha: isDark ? .48 : .58,
    ),
    fontSize: 9.sp,
    fontWeight: FontWeight.w800,
    letterSpacing: 3.2,
    ),
    ),
    SizedBox(height: 8.h),
    Container(
    width: 4.w,
    height: 4.w,
    decoration: BoxDecoration(
    color: primaryColor.withValues(
    alpha: .75,
    ),
    shape: BoxShape.circle,
    ),
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
    }

// =============================================================================
// SPLASH BACKGROUND
// =============================================================================

    class _SplashBackground extends StatelessWidget {
    const _SplashBackground({
    required this.progress,
    required this.isDark,
    required this.primaryColor,
    });

    final double progress;
    final bool isDark;
    final Color primaryColor;

    @override
    Widget build(BuildContext context) {
    return CustomPaint(
    painter: _SplashBackgroundPainter(
    progress: progress,
    isDark: isDark,
    primaryColor: primaryColor,
    ),
    size: Size.infinite,
    );
    }
    }

    class _SplashBackgroundPainter
    extends CustomPainter {
    const _SplashBackgroundPainter({
    required this.progress,
    required this.isDark,
    required this.primaryColor,
    });

    final double progress;
    final bool isDark;
    final Color primaryColor;

    @override
    void paint(
    Canvas canvas,
    Size size,
    ) {
    final t = progress * math.pi * 2;

    // -------------------------------------------------------------------------
    // BASE
    // -------------------------------------------------------------------------

    final background = Paint()
    ..shader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
    ? const [
    Color(0xFF07100C),
    Color(0xFF102819),
    Color(0xFF07100C),
    ]
        : const [
    Color(0xFFF7F9F4),
    Color(0xFFEFF4EC),
    Color(0xFFF8F9F6),
    ],
    ).createShader(
    Offset.zero & size,
    );

    canvas.drawRect(
    Offset.zero & size,
    background,
    );

    // -------------------------------------------------------------------------
    // LARGE SOFT LIGHT
    // -------------------------------------------------------------------------

    final lightCenter = Offset(
    size.width * (.58 + math.sin(t) * .045),
    size.height * (.40 + math.cos(t) * .035),
    );

    final lightPaint = Paint()
    ..shader = RadialGradient(
    colors: [
    primaryColor.withValues(
    alpha: isDark ? .10 : .075,
    ),
    Colors.transparent,
    ],
    ).createShader(
    Rect.fromCircle(
    center: lightCenter,
    radius: size.width * .68,
    ),
    );

    canvas.drawCircle(
    lightCenter,
    size.width * .68,
    lightPaint,
    );

    // -------------------------------------------------------------------------
    // ORGANIC LEAF 1
    // -------------------------------------------------------------------------

    _drawLeaf(
    canvas,
    center: Offset(
    size.width * .82 + math.sin(t) * 14,
    size.height * .38,
    ),
    width: size.width * .65,
    height: size.height * .82,
    rotation: -.45,
    color: primaryColor.withValues(
    alpha: isDark ? .055 : .035,
    ),
    );

    // -------------------------------------------------------------------------
    // ORGANIC LEAF 2
    // -------------------------------------------------------------------------

    _drawLeaf(
    canvas,
    center: Offset(
    size.width * .10 + math.cos(t) * 12,
    size.height * .72,
    ),
    width: size.width * .55,
    height: size.height * .70,
    rotation: .58,
    color: primaryColor.withValues(
    alpha: isDark ? .045 : .028,
    ),
    );

    // -------------------------------------------------------------------------
    // SMALL LEAF
    // -------------------------------------------------------------------------

    _drawLeaf(
    canvas,
    center: Offset(
    size.width * .92,
    size.height * .82 + math.sin(t) * 8,
    ),
    width: size.width * .34,
    height: size.height * .46,
    rotation: -.25,
    color: primaryColor.withValues(
    alpha: isDark ? .035 : .022,
    ),
    );

    // -------------------------------------------------------------------------
    // VIGNETTE
    // -------------------------------------------------------------------------

    final vignette = Paint()
    ..shader = RadialGradient(
    colors: [
    Colors.transparent,
    Colors.black.withValues(
    alpha: isDark ? .30 : .025,
    ),
    ],
    stops: const [
    .40,
    1,
    ],
    ).createShader(
    Offset.zero & size,
    );

    canvas.drawRect(
    Offset.zero & size,
    vignette,
    );
    }

    void _drawLeaf(
    Canvas canvas, {
    required Offset center,
    required double width,
    required double height,
    required double rotation,
    required Color color,
    }) {
    canvas.save();

    canvas.translate(
    center.dx,
    center.dy,
    );

    canvas.rotate(rotation);

    final path = Path();

    path.moveTo(
    0,
    -height / 2,
    );

    path.cubicTo(
    width * .42,
    -height * .34,
    width * .48,
    height * .18,
    0,
    height / 2,
    );

    path.cubicTo(
    -width * .42,
    height * .18,
    -width * .42,
    -height * .34,
    0,
    -height / 2,
    );

    canvas.drawPath(
    path,
    Paint()..color = color,
    );

    // Central vein.
    final vein = Paint()
    ..color = color.withValues(
    alpha: color.a * .7,
    )
    ..strokeWidth = 1.1;

    canvas.drawLine(
    Offset(
    0,
    -height * .37,
    ),
    Offset(
    0,
    height * .37,
    ),
    vein,
    );

    canvas.restore();
    }

    @override
    bool shouldRepaint(
    covariant _SplashBackgroundPainter oldDelegate,
    ) {
    return oldDelegate.progress != progress ||
    oldDelegate.isDark != isDark ||
    oldDelegate.primaryColor != primaryColor;
    }
    }

// =============================================================================
// LOGO MARK
// =============================================================================

    class _AnimatedLogoMark extends StatelessWidget {
    const _AnimatedLogoMark({
    required this.isDark,
    required this.primaryColor,
    required this.animation,
    });

    final bool isDark;
    final Color primaryColor;
    final AnimationController animation;

    @override
    Widget build(BuildContext context) {
    return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
    final t = animation.value * math.pi * 2;

    final breathing =
    1 + (math.sin(t) * .025);

    return Transform.scale(
    scale: breathing,
    child: child,
    );
    },
    child: Container(
    width: 88.w,
    height: 88.w,
    decoration: BoxDecoration(
    color: isDark
    ? Colors.white.withValues(alpha: .09)
        : Colors.white.withValues(alpha: .82),
    borderRadius: BorderRadius.circular(
    30.r,
    ),
    border: Border.all(
    color: isDark
    ? Colors.white.withValues(alpha: .13)
        : primaryColor.withValues(alpha: .12),
    width: .9,
    ),
    boxShadow: [
    BoxShadow(
    color: isDark
    ? Colors.black.withValues(alpha: .25)
        : primaryColor.withValues(alpha: .08),
    blurRadius: 35,
    offset: const Offset(
    0,
    16,
    ),
    ),
    ],
    ),
    child: Stack(
    alignment: Alignment.center,
    children: [
    Container(
    width: 62.w,
    height: 62.w,
    decoration: BoxDecoration(
    color: primaryColor.withValues(
    alpha: isDark ? .17 : .10,
    ),
    borderRadius: BorderRadius.circular(
    22.r,
    ),
    ),
    ),

    Icon(
    Icons.eco_rounded,
    color: isDark
    ? const Color(0xFFA4C9A4)
        : primaryColor,
    size: 42.sp,
    ),
    ],
    ),
    ),
    );
    }
    }

// =============================================================================
// GLOW ORB
// =============================================================================

    class _GlowOrb extends StatelessWidget {
    const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
    required this.animation,
    required this.direction,
    });

    final double size;
    final Color color;
    final double opacity;
    final AnimationController animation;
    final int direction;

    @override
    Widget build(BuildContext context) {
    return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
    final t = animation.value * math.pi * 2;

    return Transform.translate(
    offset: Offset(
    math.sin(t) * 10 * direction,
    math.cos(t) * 8,
    ),
    child: child,
    );
    },
    child: Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: color.withValues(
    alpha: opacity,
    ),
    ),
    ),
    );
    }
    }