import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
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

class _FoliageOnboardingScreenState extends State<FoliageOnboardingScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;

  late final AnimationController _backgroundController;
  late final AnimationController _contentController;
  late final AnimationController _finishController;

  int _currentPage = 0;
  int _selectedWallpaper = 0;

  bool _saving = false;
  bool _finishing = false;

  static const String _nameKey = 'foliage_user_name';
  static const String _onboardingKey = 'foliage_onboarding_completed';

  static const Duration _pageDuration = Duration(milliseconds: 650);

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _nameController = TextEditingController();
    _nameFocusNode = FocusNode();

    _nameController.addListener(_onNameChanged);

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _finishController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();

    _backgroundController.dispose();
    _contentController.dispose();
    _finishController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // GETTERS
  // ===========================================================================

  String get _name => _nameController.text.trim();

  bool get _hasName => _name.length >= 2;

  String get _initial {
    if (_name.isEmpty) {
      return 'F';
    }

    return _name.characters.first.toUpperCase();
  }

  List<_FoliagePage> get _pages => const [
    _FoliagePage(
      type: _FoliagePageType.hero,
    ),
    _FoliagePage(
      type: _FoliagePageType.discover,
    ),
    _FoliagePage(
      type: _FoliagePageType.choose,
    ),
    _FoliagePage(
      type: _FoliagePageType.personal,
    ),
  ];

  // ===========================================================================
  // NAME
  // ===========================================================================

  void _onNameChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // ===========================================================================
  // PAGE
  // ===========================================================================

  void _onPageChanged(int page) {
    if (!mounted) {
      return;
    }

    HapticFeedback.selectionClick();

    setState(() {
      _currentPage = page;
    });

    _contentController
      ..reset()
      ..forward();
  }

  Future<void> _next() async {
    if (_saving || _finishing) {
      return;
    }

    HapticFeedback.selectionClick();

    if (_currentPage < _pages.length - 1) {
      await _pageController.nextPage(
        duration: _pageDuration,
        curve: Curves.easeOutCubic,
      );

      return;
    }

    await _complete();
  }

  Future<void> _back() async {
    if (_currentPage <= 0 || _saving || _finishing) {
      return;
    }

    HapticFeedback.selectionClick();

    await _pageController.previousPage(
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
    );
  }

  // ===========================================================================
  // WALLPAPER
  // ===========================================================================

  void _selectWallpaper(int index) {
    if (_selectedWallpaper == index) {
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() {
      _selectedWallpaper = index;
    });
  }

  // ===========================================================================
  // COMPLETE
  // ===========================================================================

  Future<void> _complete() async {
    if (_saving || _finishing) {
      return;
    }

    if (!_hasName) {
      HapticFeedback.heavyImpact();

      _nameFocusNode.requestFocus();

      _showMessage(
        'Tell us what we should call you.',
      );

      return;
    }

    setState(() {
      _saving = true;
      _finishing = true;
    });

    HapticFeedback.mediumImpact();

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        _nameKey,
        _name,
      );

      await prefs.setBool(
        _onboardingKey,
        true,
      );

      await _finishController.forward();

      await widget.onCompleted(_name);
    } catch (error) {
      debugPrint(
        'Foliage onboarding error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
        _finishing = false;
      });

      _showMessage(
        'Could not finish setup. Try again.',
      );
    }
  }

  // ===========================================================================
  // SKIP
  // ===========================================================================

  Future<void> _skip() async {
    if (_saving || _finishing) {
      return;
    }

    HapticFeedback.selectionClick();

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
        _onboardingKey,
        true,
      );

      await widget.onCompleted('');
    } catch (error) {
      debugPrint(
        'Foliage skip error: $error',
      );
    }
  }

  // ===========================================================================
  // MESSAGE
  // ===========================================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: const Color(0xFF152019),
          margin: EdgeInsets.fromLTRB(
            18.w,
            0,
            18.w,
            20.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          content: Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 19.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07100C),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // -------------------------------------------------------------------
          // BACKGROUND
          // -------------------------------------------------------------------

          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return _ImmersiveBackground(
                progress: _backgroundController.value,
                selectedWallpaper: _selectedWallpaper,
              );
            },
          ),

          // -------------------------------------------------------------------
          // PAGE CONTENT
          // -------------------------------------------------------------------

          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _contentController,
                builder: (context, child) {
                  final animation = CurvedAnimation(
                    parent: _contentController,
                    curve: Curves.easeOutCubic,
                  );

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(
                          0,
                          .035,
                        ),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _buildPage(index),
              );
            },
          ),

          // -------------------------------------------------------------------
          // TOP NAV
          // -------------------------------------------------------------------

          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: _TopNavigation(
                currentPage: _currentPage,
                pageCount: _pages.length,
                onBack: _back,
                onSkip: _skip,
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // BOTTOM CONTROLS
          //
          // IMPORTANT:
          // This is directly inside Stack.
          // No SafeArea wrapping Positioned.
          // SafeArea is INSIDE _BottomNavigation.
          // -------------------------------------------------------------------

          if (!_finishing)
            _BottomNavigation(
              currentPage: _currentPage,
              pageCount: _pages.length,
              saving: _saving,
              onNext: _next,
            ),

          // -------------------------------------------------------------------
          // FINISH OVERLAY
          // -------------------------------------------------------------------

          if (_finishing)
            AnimatedBuilder(
              animation: _finishController,
              builder: (context, child) {
                final value = _finishController.value;

                return Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: const Color(0xFF07100C).withValues(
                        alpha: value,
                      ),
                      child: Center(
                        child: Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: .85 + (value * .15),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: _FinishMark(
                initial: _initial,
              ),
            ),

          // -------------------------------------------------------------------
          // TOP GRADIENT
          // -------------------------------------------------------------------

          if (!_finishing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 170.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: .30),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (_pages[index].type) {
      case _FoliagePageType.hero:
        return _HeroPage(
          animation: _backgroundController,
          onContinue: _next,
        );

      case _FoliagePageType.discover:
        return _DiscoverPage(
          animation: _backgroundController,
        );

      case _FoliagePageType.choose:
        return _ChoosePage(
          selected: _selectedWallpaper,
          animation: _backgroundController,
          onSelected: _selectWallpaper,
        );

      case _FoliagePageType.personal:
        return _PersonalPage(
          controller: _nameController,
          focusNode: _nameFocusNode,
          initial: _initial,
          animation: _backgroundController,
          onSubmitted: (_) => _complete(),
        );
    }
  }
}

// =============================================================================
// IMMERSIVE BACKGROUND
// =============================================================================

class _ImmersiveBackground extends StatelessWidget {
  const _ImmersiveBackground({
    required this.progress,
    required this.selectedWallpaper,
  });

  final double progress;
  final int selectedWallpaper;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ImmersiveBackgroundPainter(
        progress: progress,
        selectedWallpaper: selectedWallpaper,
      ),
      size: Size.infinite,
    );
  }
}

class _ImmersiveBackgroundPainter extends CustomPainter {
  const _ImmersiveBackgroundPainter({
    required this.progress,
    required this.selectedWallpaper,
  });

  final double progress;
  final int selectedWallpaper;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    const palettes = [
      [
        Color(0xFF07140C),
        Color(0xFF173D25),
        Color(0xFF08110B),
      ],
      [
        Color(0xFF0A1210),
        Color(0xFF294738),
        Color(0xFF0B1711),
      ],
      [
        Color(0xFF17100A),
        Color(0xFF58472D),
        Color(0xFF20160C),
      ],
    ];

    final palette = palettes[
    selectedWallpaper % palettes.length
    ];

    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: palette,
      ).createShader(
        Offset.zero & size,
      );

    canvas.drawRect(
      Offset.zero & size,
      background,
    );

    final lightCenter = Offset(
      size.width * (.65 + math.sin(t) * .06),
      size.height * (.32 + math.cos(t) * .04),
    );

    final light = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: .12),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: lightCenter,
          radius: size.width * .7,
        ),
      );

    canvas.drawCircle(
      lightCenter,
      size.width * .7,
      light,
    );

    _drawLeaf(
      canvas,
      center: Offset(
        size.width * .76 + math.sin(t) * 14,
        size.height * .40,
      ),
      width: size.width * .75,
      height: size.height * .85,
      rotation: -.42,
      color: Colors.white.withValues(alpha: .055),
    );

    _drawLeaf(
      canvas,
      center: Offset(
        size.width * .18 + math.cos(t) * 12,
        size.height * .67,
      ),
      width: size.width * .62,
      height: size.height * .72,
      rotation: .58,
      color: Colors.black.withValues(alpha: .12),
    );

    _drawLeaf(
      canvas,
      center: Offset(
        size.width * .93,
        size.height * .83 + math.sin(t) * 10,
      ),
      width: size.width * .40,
      height: size.height * .52,
      rotation: -.25,
      color: Colors.white.withValues(alpha: .045),
    );

    // Grain.
    final grain = Paint()
      ..color = Colors.white.withValues(alpha: .018);

    const spacing = 8.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final value = math.sin(
          x * .13 +
              y * .17 +
              progress * math.pi * 8,
        );

        if (value > .45) {
          canvas.drawCircle(
            Offset(x, y),
            .45,
            grain,
          );
        }
      }
    }

    // Vignette.
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: .52),
        ],
        stops: const [
          .35,
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
      width * .43,
      -height * .28,
      width * .45,
      height * .20,
      0,
      height / 2,
    );

    path.cubicTo(
      -width * .43,
      height * .20,
      -width * .43,
      -height * .28,
      0,
      -height / 2,
    );

    canvas.drawPath(
      path,
      Paint()..color = color,
    );

    final vein = Paint()
      ..color = Colors.white.withValues(alpha: .055)
      ..strokeWidth = 1.2;

    canvas.drawLine(
      Offset(
        0,
        -height * .38,
      ),
      Offset(
        0,
        height * .38,
      ),
      vein,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(
      covariant _ImmersiveBackgroundPainter oldDelegate,
      ) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedWallpaper != selectedWallpaper;
  }
}

// =============================================================================
// HERO PAGE
// =============================================================================

class _HeroPage extends StatelessWidget {
  const _HeroPage({
    required this.animation,
    required this.onContinue,
  });

  final AnimationController animation;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value * math.pi * 2;

        return Stack(
          fit: StackFit.expand,
          children: [
            _HeroLeafArtwork(
              progress: animation.value,
            ),

            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: 170.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: Offset(
                      math.sin(t) * 2,
                      0,
                    ),
                    child: Text(
                      'FOLIAGE',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(
                          alpha: .72,
                        ),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.4,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Let your\nscreen breathe.',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 46.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2.7,
                      height: .95,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Beautiful wallpapers for the\nlittle moments you see every day.',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(
                        alpha: .72,
                      ),
                      fontSize: 15.sp,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: 95.h,
              child: _SwipePill(
                onTap: onContinue,
              ),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// HERO ARTWORK
// =============================================================================

class _HeroLeafArtwork extends StatelessWidget {
  const _HeroLeafArtwork({
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LeafPainter(
        progress: progress,
      ),
      size: Size.infinite,
    );
  }
}

class _LeafPainter extends CustomPainter {
  const _LeafPainter({
    required this.progress,
  });

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF07140C),
          Color(0xFF183D27),
          Color(0xFF07100B),
        ],
      ).createShader(
        Offset.zero & size,
      );

    canvas.drawRect(
      Offset.zero & size,
      background,
    );

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF75A978).withValues(alpha: .30),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * .7,
            size.height * .32,
          ),
          radius: size.width * .75,
        ),
      );

    canvas.drawCircle(
      Offset(
        size.width * .7,
        size.height * .32,
      ),
      size.width * .75,
      glow,
    );

    _drawLeaf(
      canvas,
      center: Offset(
        size.width * .68 + math.sin(t) * 10,
        size.height * .40,
      ),
      width: size.width * .82,
      height: size.height * .68,
      rotation: -.48,
      color: const Color(0xFF244D31),
    );

    _drawLeaf(
      canvas,
      center: Offset(
        size.width * .30 + math.cos(t) * 8,
        size.height * .56,
      ),
      width: size.width * .70,
      height: size.height * .58,
      rotation: .65,
      color: const Color(0xFF102C1B),
    );

    _drawLeaf(
      canvas,
      center: Offset(
        size.width * .84,
        size.height * .78,
      ),
      width: size.width * .48,
      height: size.height * .45,
      rotation: -.2,
      color: const Color(0xFF386944),
    );

    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: .50),
        ],
        stops: const [
          .35,
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
      -height * .35,
      width * .48,
      height * .20,
      0,
      height / 2,
    );

    path.cubicTo(
      -width * .42,
      height * .20,
      -width * .42,
      -height * .35,
      0,
      -height / 2,
    );

    canvas.drawPath(
      path,
      Paint()..color = color,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(
      covariant _LeafPainter oldDelegate,
      ) {
    return oldDelegate.progress != progress;
  }
}

// =============================================================================
// DISCOVER PAGE
// =============================================================================

class _DiscoverPage extends StatelessWidget {
  const _DiscoverPage({
    required this.animation,
  });

  final AnimationController animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            _AtmosphereArtwork(
              progress: animation.value,
              variant: 1,
            ),

            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: 180.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _GlassLabel(
                    icon: Icons.explore_rounded,
                    text: 'DISCOVER',
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'Find a mood\nthat feels like you.',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 39.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2.1,
                      height: .97,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    'From quiet greens to bold textures,\nthere is a screen for every feeling.',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(
                        alpha: .72,
                      ),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              right: 24.w,
              bottom: 105.h,
              child: const _SwipeHint(
                text: 'SWIPE',
              ),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// CHOOSE PAGE
// =============================================================================

class _ChoosePage extends StatelessWidget {
  const _ChoosePage({
    required this.selected,
    required this.animation,
    required this.onSelected,
  });

  final int selected;
  final AnimationController animation;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            _AtmosphereArtwork(
              progress: animation.value,
              variant: selected + 2,
            ),

            Positioned(
              left: 24.w,
              right: 24.w,
              top: 125.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _GlassLabel(
                    icon: Icons.auto_awesome_rounded,
                    text: 'YOUR TASTE',
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'Which one\npulls you in?',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2.2,
                      height: .96,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 18.w,
              right: 18.w,
              bottom: 165.h,
              child: SizedBox(
                height: 210.h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(
                    3,
                        (index) {
                      final isSelected = selected == index;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onSelected(index),
                          child: AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 450,
                            ),
                            curve: Curves.easeOutCubic,
                            margin: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: isSelected ? 0 : 10.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(27.r),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(
                                  alpha: .18,
                                ),
                                width: isSelected ? 2 : .8,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color:
                                  Colors.black.withValues(
                                    alpha: .28,
                                  ),
                                  blurRadius: 30,
                                  offset: const Offset(
                                    0,
                                    15,
                                  ),
                                ),
                              ]
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius:
                              BorderRadius.circular(26.r),
                              child: _WallpaperPreview(
                                index: index,
                                selected: isSelected,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            Positioned(
              left: 24.w,
              bottom: 112.h,
              child: Row(
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    color: Colors.white.withValues(alpha: .65),
                    size: 16.sp,
                  ),
                  SizedBox(width: 7.w),
                  Text(
                    'Tap one to make it yours',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: .65),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// PERSONAL PAGE
// =============================================================================

class _PersonalPage extends StatelessWidget {
  const _PersonalPage({
    required this.controller,
    required this.focusNode,
    required this.initial,
    required this.animation,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String initial;
  final AnimationController animation;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            _PersonalArtwork(
              progress: animation.value,
              initial: initial,
            ),

            Positioned(
              left: 24.w,
              right: 24.w,
              top: 130.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _GlassLabel(
                    icon: Icons.person_outline_rounded,
                    text: 'ONE LAST THING',
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Make it\npersonal.',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 43.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2.4,
                      height: .94,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'What should we call the person\nbehind this beautiful screen?',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(
                        alpha: .72,
                      ),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: 150.h,
              child: _GlassNameField(
                controller: controller,
                focusNode: focusNode,
                onSubmitted: onSubmitted,
              ),
            ),

            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: 112.h,
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 14.sp,
                    color: Colors.white.withValues(alpha: .5),
                  ),
                  SizedBox(width: 7.w),
                  Text(
                    'Your name stays on your device.',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: .5),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// PERSONAL ARTWORK
// =============================================================================

class _PersonalArtwork extends StatelessWidget {
  const _PersonalArtwork({
    required this.progress,
    required this.initial,
  });

  final double progress;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final t = progress * math.pi * 2;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A1710),
                Color(0xFF1C4B2C),
                Color(0xFF07100B),
              ],
            ),
          ),
        ),

        Positioned(
          right: -70.w,
          top: 190.h,
          child: Transform.rotate(
            angle: -.35 + math.sin(t) * .04,
            child: Container(
              width: 300.w,
              height: 470.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(150.r),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: .10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        Positioned(
          left: -100.w,
          bottom: -80.h,
          child: Container(
            width: 330.w,
            height: 330.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF80A77D).withValues(alpha: .08),
            ),
          ),
        ),

        Center(
          child: Transform.translate(
            offset: Offset(
              math.sin(t) * 5,
              math.cos(t) * 5,
            ),
            child: Opacity(
              opacity: .08,
              child: Text(
                initial,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 280.sp,
                  fontWeight: FontWeight.w800,
                  height: .8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// ATMOSPHERE ARTWORK
// =============================================================================

class _AtmosphereArtwork extends StatelessWidget {
  const _AtmosphereArtwork({
    required this.progress,
    required this.variant,
  });

  final double progress;
  final int variant;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AtmospherePainter(
        progress: progress,
        variant: variant,
      ),
      size: Size.infinite,
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter({
    required this.progress,
    required this.variant,
  });

  final double progress;
  final int variant;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    const palettes = [
      [
        Color(0xFF07130C),
        Color(0xFF224C2C),
        Color(0xFF102519),
      ],
      [
        Color(0xFF0B1511),
        Color(0xFF34543C),
        Color(0xFF1B2920),
      ],
      [
        Color(0xFF17120C),
        Color(0xFF5C4B31),
        Color(0xFF20190F),
      ],
      [
        Color(0xFF080E17),
        Color(0xFF294052),
        Color(0xFF111A26),
      ],
      [
        Color(0xFF180C13),
        Color(0xFF56313C),
        Color(0xFF211116),
      ],
    ];

    final palette = palettes[variant % palettes.length];

    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: palette,
      ).createShader(
        Offset.zero & size,
      );

    canvas.drawRect(
      Offset.zero & size,
      background,
    );

    final circles = [
      (
      Offset(
        size.width * .18 + math.sin(t) * 25,
        size.height * .27,
      ),
      size.width * .58,
      .20,
      ),
      (
      Offset(
        size.width * .82,
        size.height * .58 + math.cos(t) * 22,
      ),
      size.width * .75,
      .13,
      ),
      (
      Offset(
        size.width * .42,
        size.height * .88,
      ),
      size.width * .52,
      .12,
      ),
    ];

    for (final circle in circles) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: circle.$3),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: circle.$1,
            radius: circle.$2,
          ),
        );

      canvas.drawCircle(
        circle.$1,
        circle.$2,
        paint,
      );
    }

    _drawOrganicShape(
      canvas,
      size,
      progress,
      color: Colors.white.withValues(alpha: .055),
      offset: .15,
      scale: 1.1,
    );

    _drawOrganicShape(
      canvas,
      size,
      progress,
      color: Colors.black.withValues(alpha: .15),
      offset: .75,
      scale: .8,
    );

    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: .48),
        ],
        stops: const [
          .35,
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

  void _drawOrganicShape(
      Canvas canvas,
      Size size,
      double progress, {
        required Color color,
        required double offset,
        required double scale,
      }) {
    final t = progress * math.pi * 2;

    canvas.save();

    canvas.translate(
      size.width * offset,
      size.height * .48,
    );

    canvas.rotate(
      math.sin(t + offset * 4) * .12,
    );

    final path = Path();

    path.moveTo(
      -size.width * .45 * scale,
      size.height * .40,
    );

    path.cubicTo(
      -size.width * .18 * scale,
      -size.height * .35,
      size.width * .24 * scale,
      -size.height * .42,
      size.width * .48 * scale,
      size.height * .30,
    );

    path.cubicTo(
      size.width * .12 * scale,
      size.height * .48,
      -size.width * .22 * scale,
      size.height * .52,
      -size.width * .45 * scale,
      size.height * .40,
    );

    canvas.drawPath(
      path,
      Paint()..color = color,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(
      covariant _AtmospherePainter oldDelegate,
      ) {
    return oldDelegate.progress != progress ||
        oldDelegate.variant != variant;
  }
}

// =============================================================================
// WALLPAPER PREVIEW
// =============================================================================

class _WallpaperPreview extends StatelessWidget {
  const _WallpaperPreview({
    required this.index,
    required this.selected,
  });

  final int index;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    const gradients = [
      [
        Color(0xFF173A24),
        Color(0xFF77A37A),
        Color(0xFF0B1D12),
      ],
      [
        Color(0xFF17202A),
        Color(0xFF657E72),
        Color(0xFF111915),
      ],
      [
        Color(0xFF412D1C),
        Color(0xFFA17A4E),
        Color(0xFF21150C),
      ],
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradients[index],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _MiniLeafPainter(
              index: index,
            ),
          ),

          if (selected)
            Positioned(
              top: 12.h,
              right: 12.w,
              child: Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: const Color(0xFF173A24),
                  size: 18.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniLeafPainter extends CustomPainter {
  const _MiniLeafPainter({
    required this.index,
  });

  final int index;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .14);

    for (int i = 0; i < 5; i++) {
      final x = size.width * (.15 + i * .18);
      final y = size.height * (.18 + (i % 2) * .25);

      canvas.save();

      canvas.translate(
        x,
        y,
      );

      canvas.rotate(
        -.7 + i * .35,
      );

      final path = Path();

      path.moveTo(
        0,
        -size.height * .20,
      );

      path.cubicTo(
        size.width * .24,
        -size.height * .12,
        size.width * .20,
        size.height * .14,
        0,
        size.height * .22,
      );

      path.cubicTo(
        -size.width * .20,
        size.height * .14,
        -size.width * .24,
        -size.height * .12,
        0,
        -size.height * .20,
      );

      canvas.drawPath(
        path,
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(
      covariant _MiniLeafPainter oldDelegate,
      ) {
    return oldDelegate.index != index;
  }
}

// =============================================================================
// GLASS LABEL
// =============================================================================

class _GlassLabel extends StatelessWidget {
  const _GlassLabel({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: .13),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: .82),
            size: 14.sp,
          ),
          SizedBox(width: 7.w),
          Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: .82),
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// GLASS ICON BUTTON
// =============================================================================

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: .13),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20.sp,
        ),
      ),
    );
  }
}

// =============================================================================
// GLASS TEXT BUTTON
// =============================================================================

class _GlassTextButton extends StatelessWidget {
  const _GlassTextButton({
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 15.w,
          vertical: 11.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: .12),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: .85),
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// TOP NAVIGATION
// =============================================================================

class _TopNavigation extends StatelessWidget {
  const _TopNavigation({
    required this.currentPage,
    required this.pageCount,
    required this.onBack,
    required this.onSkip,
  });

  final int currentPage;
  final int pageCount;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18.w,
        12.h,
        18.w,
        0,
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(
              milliseconds: 300,
            ),
            child: currentPage == 0
                ? SizedBox(
              key: const ValueKey('empty'),
              width: 44.w,
              height: 44.w,
            )
                : _GlassIconButton(
              key: const ValueKey('back'),
              icon: Icons.arrow_back_rounded,
              onTap: onBack,
            ),
          ),

          const Spacer(),

          const _FoliageLogo(),

          const Spacer(),

          if (currentPage < pageCount - 1)
            _GlassTextButton(
              text: 'Skip',
              onTap: onSkip,
            )
          else
            SizedBox(
              width: 55.w,
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// BOTTOM NAVIGATION
// =============================================================================

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.currentPage,
    required this.pageCount,
    required this.saving,
    required this.onNext,
  });

  final int currentPage;
  final int pageCount;
  final bool saving;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == pageCount - 1;

    return Positioned(
      left: 18.w,
      right: 18.w,
      bottom: 0,
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.only(
          bottom: 12.h,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ProgressLine(
              current: currentPage,
              count: pageCount,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: GestureDetector(
                onTap: saving ? null : onNext,
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 300,
                  ),
                  height: 58.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: .18,
                        ),
                        blurRadius: 25,
                        offset: const Offset(
                          0,
                          10,
                        ),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 250,
                    ),
                    child: saving
                        ? const Center(
                      key: ValueKey('loading'),
                      child: SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                        ),
                      ),
                    )
                        : Row(
                      key: ValueKey(
                        '$isLast-$currentPage',
                      ),
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Text(
                          isLast
                              ? 'Enter Foliage'
                              : currentPage == 2
                              ? 'That’s my style'
                              : 'Continue',
                          style: GoogleFonts.inter(
                            color:
                            const Color(0xFF102016),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color:
                          const Color(0xFF102016),
                          size: 18.sp,
                        ),
                      ],
                    ),
                  ),
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
// PROGRESS LINE
// =============================================================================

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.current,
    required this.count,
  });

  final int current;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(
              count,
                  (index) {
                final active = index <= current;

                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: 2.w,
                    ),
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(
                        alpha: .25,
                      ),
                      borderRadius:
                      BorderRadius.circular(10.r),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            '${current + 1}/$count',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: .55),
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SWIPE PILL
// =============================================================================

class _SwipePill extends StatelessWidget {
  const _SwipePill({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: Row(
          children: [
            SizedBox(width: 19.w),
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: const Color(0xFF173A24),
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Swipe to enter Foliage',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF102016),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SizedBox(width: 19.w),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SWIPE HINT
// =============================================================================

class _SwipeHint extends StatelessWidget {
  const _SwipeHint({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: .13),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.swipe_rounded,
            color: Colors.white.withValues(alpha: .7),
            size: 14.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: .7),
              fontSize: 9.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// NAME FIELD
// =============================================================================

class _GlassNameField extends StatelessWidget {
  const _GlassNameField({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: .18),
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLength: 40,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: onSubmitted,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          hintText: 'Your name',
          hintStyle: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: .42),
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.person_outline_rounded,
            color: Colors.white.withValues(alpha: .65),
            size: 21.sp,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18.w,
            vertical: 18.h,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// LOGO
// =============================================================================

class _FoliageLogo extends StatelessWidget {
  const _FoliageLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: .13),
        ),
      ),
      child: Icon(
        Icons.eco_rounded,
        color: Colors.white,
        size: 22.sp,
      ),
    );
  }
}

// =============================================================================
// FINISH
// =============================================================================

class _FinishMark extends StatelessWidget {
  const _FinishMark({
    required this.initial,
  });

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 90.w,
          height: 90.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .10),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: .18),
            ),
          ),
          child: Center(
            child: Text(
              initial,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 40.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          'Your space is ready.',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -.5,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// MODEL
// =============================================================================

class _FoliagePage {
  const _FoliagePage({
    required this.type,
  });

  final _FoliagePageType type;
}

enum _FoliagePageType {
  hero,
  discover,
  choose,
  personal,
}