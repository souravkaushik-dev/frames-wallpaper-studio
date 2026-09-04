import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dotty/constants/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'category_screen.dart';

Map<String, dynamic> _decodeCategoryJson(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Invalid API response');
  }
  return decoded;
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // PERFORMANCE
  // ============================================================

  static const int _visibleCards = 5;
  static const int _precacheCount = 5;

  // One notifier drives only the animated deck.
  // The whole screen no longer rebuilds on every animation tick.
  final ValueNotifier<Offset> _dragNotifier =
  ValueNotifier<Offset>(Offset.zero);

  late final AnimationController _controller;

  Animation<double>? _xAnimation;
  Animation<double>? _yAnimation;

  // ============================================================
  // DATA
  // ============================================================

  late Future<Map<String, dynamic>> _future;

  List<_CategoryData> _categories = <_CategoryData>[];
  bool _didPrecache = false;

  bool _dragging = false;
  bool _animating = false;
  bool _expanded = false;

  // ============================================================
  // ANIMATION STATE
  // ============================================================

  double _dragX = 0;
  double _dragY = 0;

  double _startX = 0;
  double _endX = 0;

  double _startY = 0;
  double _endY = 0;

  CurvedAnimation? _curvedAnimation;

  // ============================================================
  // DECK
  // ============================================================

  double get _stackSpacing => 48.h;
  double get _spreadSpacing => 105.h;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _future = _fetchCategories();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _controller.addListener(_syncAnimation);
    _controller.addStatusListener(_animationFinished);
  }

  @override
  void dispose() {
    _curvedAnimation?.dispose();
    _dragNotifier.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // API
  // ============================================================

  Future<Map<String, dynamic>> _fetchCategories() async {
    final apiUrl = dotenv.env['API_URL'];

    if (apiUrl == null || apiUrl.trim().isEmpty) {
      throw Exception('API_URL is not configured');
    }

    final response = await http
        .get(
      Uri.parse(apiUrl),
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load categories (${response.statusCode})');
    }

    // Keep JSON parsing off the UI isolate for larger API responses.
    return compute(_decodeCategoryJson, response.body);
  }

  void _prepareCategories(Map<String, dynamic> data) {
    if (_categories.isNotEmpty) return;

    final raw = data['categories'];
    if (raw is! Map) return;

    final prepared = <_CategoryData>[];

    for (final entry in raw.entries) {
      final title = entry.key.toString();
      final value = entry.value;

      if (value is Map) {
        final thumbnail = value['thumbnail']?.toString() ?? '';
        final rawWallpapers = value['wallpapers'];

        final wallpapers = rawWallpapers is List
            ? rawWallpapers
            .map((item) => item.toString())
            .where((url) => url.isNotEmpty)
            .toList(growable: false)
            : const <String>[];

        prepared.add(
          _CategoryData(
            title: title,
            thumbnail: thumbnail,
            wallpapers: wallpapers,
          ),
        );
      } else {
        prepared.add(
          _CategoryData(
            title: title,
            thumbnail: '',
            wallpapers: const <String>[],
          ),
        );
      }
    }

    _categories = List<_CategoryData>.unmodifiable(prepared);
  }

  // ============================================================
  // IMAGE PRELOADING
  // ============================================================

  int _imageCacheWidth(BuildContext context) {
    final physicalWidth =
        MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context);

    // Enough detail for a large card while preventing unnecessarily
    // expensive full-resolution decodes on high-density displays.
    return physicalWidth.clamp(720.0, 1200.0).round();
  }

  void _precacheVisibleImages(BuildContext context) {
    if (_categories.isEmpty || _didPrecache) return;
    _didPrecache = true;

    final cacheWidth = _imageCacheWidth(context);
    final count = math.min(_precacheCount, _categories.length);

    // Start after the current frame so first paint stays responsive.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      for (var i = 0; i < count; i++) {
        final url = _categories[i].thumbnail;
        if (url.isEmpty) continue;

        final future = precacheImage(
          ResizeImage(
            NetworkImage(url),
            width: cacheWidth,
          ),
          context,
        );
        unawaited(future);
      }
    });
  }

  // ============================================================
  // ANIMATION
  // ============================================================

  void _syncAnimation() {
    if (!mounted) return;

    final x = _xAnimation?.value ?? _dragX;
    final y = _yAnimation?.value ?? _dragY;

    _dragX = x;
    _dragY = y;

    // Only the deck listens to this notifier.
    _dragNotifier.value = Offset(x, y);
  }

  void _animationFinished(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;

    final movedHorizontally = _endX.abs() > 100;
    final movedUp = _endY < -100;

    if (movedHorizontally || movedUp) {
      _moveCurrentToBack();
    }

    if (movedUp) {
      _expanded = false;
    }

    _dragX = 0;
    _dragY = 0;

    _startX = 0;
    _endX = 0;
    _startY = 0;
    _endY = 0;

    _xAnimation = null;
    _yAnimation = null;

    _animating = false;
    _dragNotifier.value = Offset.zero;

    setState(() {});
  }

  void _moveCurrentToBack() {
    if (_categories.length <= 1) return;

    final list = List<_CategoryData>.of(_categories);
    final current = list.removeAt(0);
    list.add(current);

    _categories = List<_CategoryData>.unmodifiable(list);
  }

  // ============================================================
  // PAN START
  // ============================================================

  void _onPanStart(DragStartDetails details) {
    if (_animating) return;

    _dragging = true;
    _dragX = 0;
    _dragY = 0;
    _dragNotifier.value = Offset.zero;

    HapticFeedback.selectionClick();
  }

  // ============================================================
  // PAN UPDATE
  // ============================================================

  void _onPanUpdate(DragUpdateDetails details) {
    if (_animating || !_dragging) return;

    _dragX = (_dragX + details.delta.dx).clamp(-500.0, 500.0);
    _dragY = (_dragY + details.delta.dy).clamp(-500.0, 420.0);

    _dragNotifier.value = Offset(_dragX, _dragY);
  }

  // ============================================================
  // PAN END
  // ============================================================

  void _onPanEnd(DragEndDetails details) {
    if (_animating) return;

    _dragging = false;

    final velocity = details.velocity.pixelsPerSecond;
    final horizontal = _dragX.abs();
    final vertical = _dragY.abs();

    if (horizontal > vertical &&
        (horizontal > 90 || velocity.dx.abs() > 650)) {
      _swipeHorizontal(velocity.dx >= 0 ? 1 : -1);
      return;
    }

    if (_dragY < -80 || velocity.dy < -600) {
      _swipeUp();
      return;
    }

    if (_dragY > 80 || velocity.dy > 550) {
      if (_expanded) {
        _collapse();
      } else {
        _spread();
      }
      return;
    }

    _returnToCenter();
  }

  // ============================================================
  // SWIPES
  // ============================================================

  void _swipeHorizontal(int direction) {
    if (_categories.length <= 1) {
      _returnToCenter();
      return;
    }

    _animating = true;
    HapticFeedback.mediumImpact();

    _startX = _dragX;
    _endX = direction * MediaQuery.sizeOf(context).width * 1.25;

    _startY = _dragY;
    _endY = _dragY - 15;

    _runAnimation(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _swipeUp() {
    if (_categories.length <= 1) {
      _returnToCenter();
      return;
    }

    _animating = true;
    HapticFeedback.mediumImpact();

    _startX = _dragX;
    _endX = _dragX * .12;

    _startY = _dragY;
    _endY = -MediaQuery.sizeOf(context).height * .86;

    _runAnimation(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _spread() {
    HapticFeedback.selectionClick();

    _startX = _dragX;
    _endX = 0;

    _startY = _dragY;
    _endY = 110;

    _animating = true;

    _runAnimation(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _collapse() {
    HapticFeedback.selectionClick();

    _startX = _dragX;
    _endX = 0;

    _startY = _dragY;
    _endY = 0;

    _animating = true;

    setState(() {
      _expanded = false;
    });

    _runAnimation(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  void _returnToCenter() {
    _startX = _dragX;
    _endX = 0;

    _startY = _dragY;
    _endY = 0;

    _animating = true;

    _runAnimation(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _runAnimation({
    required Duration duration,
    required Curve curve,
  }) {
    _curvedAnimation?.dispose();

    _controller
      ..duration = duration
      ..reset();

    final curved = CurvedAnimation(
      parent: _controller,
      curve: curve,
    );

    _curvedAnimation = curved;

    _xAnimation = Tween<double>(
      begin: _startX,
      end: _endX,
    ).animate(curved);

    _yAnimation = Tween<double>(
      begin: _startY,
      end: _endY,
    ).animate(curved);

    _controller.forward();
  }

  // ============================================================
  // DECK MATH
  // ============================================================

  double _cardHeight(BuildContext context) {
    return math.min(MediaQuery.sizeOf(context).height * .62, 525.h);
  }

  double _spacing(int depth, double dragY) {
    final progress = (dragY / 110).clamp(0.0, 1.0);
    final eased = Curves.easeOutCubic.transform(progress);

    return _stackSpacing + ((_spreadSpacing - _stackSpacing) * eased);
  }

  double _top(int depth, double dragY) {
    if (depth == 0) return dragY;
    return depth * _spacing(depth, dragY) + (dragY * .06);
  }

  double _scale(int depth, double dragY) {
    if (depth == 0) {
      final lift = (-dragY / 200).clamp(0.0, 1.0);
      return 1 + lift * .025;
    }

    return (1 - depth * .028).clamp(.84, 1.0);
  }

  double _rotation(int depth, double dragX) {
    if (depth != 0) return 0;
    return (dragX / 1150).clamp(-.05, .05);
  }

  double _opacity(int depth) {
    if (depth == 0) return 1;
    return (1 - depth * .075).clamp(.56, 1.0);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final background = _background(context);

    return Scaffold(
      backgroundColor: background,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loading();
          }

          if (snapshot.hasError) {
            return _error();
          }

          final data = snapshot.data;
          if (data == null) {
            return _loading();
          }

          _prepareCategories(data);

          if (_categories.isEmpty) {
            return _empty();
          }

          _precacheVisibleImages(context);
          return _page();
        },
      ),
    );
  }

  // ============================================================
  // PAGE
  // ============================================================

  Widget _page() {
    final primary = _primary(context);
    final secondary = _secondary(context);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _circleButton(
                  Icons.arrow_back_ios_new_rounded,
                      () => Navigator.pop(context),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DISCOVER',
                        style: GoogleFonts.manrope(
                          color: secondary,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.3,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Atmospheres',
                        style: GoogleFonts.bebasNeue(
                          color: primary,
                          fontSize: 31.sp,
                          height: .8,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48.w,
                  height: 48.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(.08),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _categories.length.toString().padLeft(2, '0'),
                    style: GoogleFonts.manrope(
                      color: primary,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 13.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Container(
                  width: 24.w,
                  height: 2,
                  color: _accent,
                ),
                SizedBox(width: 9.w),
                Text(
                  _expanded
                      ? 'SELECTED ATMOSPHERE'
                      : 'CURATED COLLECTIONS',
                  style: GoogleFonts.manrope(
                    color: secondary,
                    fontSize: 7.5.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Only this subtree rebuilds during drag/animation.
          Expanded(
            child: RepaintBoundary(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: ValueListenableBuilder<Offset>(
                  valueListenable: _dragNotifier,
                  builder: (context, drag, child) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (
                        int depth =
                            math.min(_visibleCards, _categories.length) - 1;
                        depth >= 0;
                        depth--
                        )
                          _buildCategoryCard(
                            depth,
                            drag.dx,
                            drag.dy,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          _bottomStatus(),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _buildCategoryCard(
      int depth,
      double dragX,
      double dragY,
      ) {
    final item = _categories[depth];
    final front = depth == 0;
    final height = _cardHeight(context);

    return Positioned(
      top: _top(depth, dragY),
      left: 20.w,
      right: 20.w,
      height: height,
      child: RepaintBoundary(
        child: Transform.scale(
          scale: _scale(depth, dragY),
          alignment: Alignment.topCenter,
          child: Transform.rotate(
            angle: _rotation(depth, dragX),
            alignment: Alignment.bottomCenter,
            child: Opacity(
              opacity: _opacity(depth),
              child: _AtmosphereCard(
                key: ValueKey('${item.title}-$depth'),
                title: item.title,
                thumbnail: item.thumbnail,
                count: item.wallpapers.length,
                index: depth,
                isFront: front,
                expanded: _expanded && front,
                dragX: front ? dragX : 0,
                dragY: front ? dragY : 0,
                height: height,
                cacheWidth: _imageCacheWidth(context),
                onTap: () {
                  if (!front || _animating) return;

                  if (!_expanded) {
                    setState(() {
                      _expanded = true;
                    });
                    HapticFeedback.mediumImpact();
                    return;
                  }

                  _openCategory(
                    item.title,
                    item.wallpapers,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM STATUS
  // ============================================================

  Widget _bottomStatus() {
    final secondary = _secondary(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _expanded
            ? Row(
          key: const ValueKey('expanded'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: secondary.withOpacity(.45),
              size: 18.sp,
            ),
            Text(
              ' SWIPE DOWN TO COLLAPSE',
              style: GoogleFonts.manrope(
                color: secondary.withOpacity(.48),
                fontSize: 7.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        )
            : Row(
          key: const ValueKey('collapsed'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.keyboard_arrow_left_rounded,
              color: secondary.withOpacity(.38),
              size: 17.sp,
            ),
            Text(
              ' SWIPE ',
              style: GoogleFonts.manrope(
                color: secondary.withOpacity(.45),
                fontSize: 7.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_right_rounded,
              color: secondary.withOpacity(.38),
              size: 17.sp,
            ),
            SizedBox(width: 12.w),
            SizedBox(
              width: 1,
              height: 12.h,
            ),
            SizedBox(width: 12.w),
            Icon(
              Icons.keyboard_arrow_up_rounded,
              color: secondary.withOpacity(.38),
              size: 17.sp,
            ),
            Text(
              ' EXPLORE',
              style: GoogleFonts.manrope(
                color: secondary.withOpacity(.45),
                fontSize: 7.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // OPEN CATEGORY
  // ============================================================

  void _openCategory(String title, List<String> wallpapers) {
    HapticFeedback.selectionClick();

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (context, animation, secondaryAnimation) {
          return CategoryScreen(
            title: title,
            wallpapers: wallpapers,
          );
        },
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: .98,
                end: 1,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // BUTTON
  // ============================================================

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17.r),
        child: Ink(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(17.r),
          ),
          child: Icon(
            icon,
            color: _primary(context),
            size: 16.sp,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATES
  // ============================================================

  Widget _loading() {
    return Center(
      child: SizedBox(
        width: 20.w,
        height: 20.w,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: _accent,
        ),
      ),
    );
  }

  Widget _error() {
    final primary = _primary(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: _accent,
            size: 35.sp,
          ),
          SizedBox(height: 14.h),
          Text(
            'UNABLE TO LOAD',
            style: GoogleFonts.bebasNeue(
              color: primary,
              fontSize: 28.sp,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 15.h),
          GestureDetector(
            onTap: () {
              setState(() {
                _categories = <_CategoryData>[];
                _didPrecache = false;
                _future = _fetchCategories();
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 11.h,
              ),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Text(
                'TRY AGAIN',
                style: GoogleFonts.manrope(
                  color: primary,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    final primary = _primary(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.layers_clear_rounded,
            color: _accent,
            size: 40.sp,
          ),
          SizedBox(height: 14.h),
          Text(
            'NO ATMOSPHERES',
            style: GoogleFonts.bebasNeue(
              color: primary,
              fontSize: 30.sp,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COLORS
  // ============================================================

  bool _isDark() {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _background(BuildContext context) {
    return _isDark()
        ? AppColors.darkBackground
        : AppColors.lightBackground;
  }

  Color _surface(BuildContext context) {
    return _isDark() ? AppColors.darkSurface : AppColors.lightSurface;
  }

  Color _primary(BuildContext context) {
    return _isDark() ? AppColors.darkPrimary : AppColors.lightPrimary;
  }

  Color _secondary(BuildContext context) {
    return _isDark() ? AppColors.darkSecondary : AppColors.lightSecondary;
  }

  Color get _accent => AppColors.accent;
}

// ==================================================================
// IMMUTABLE CATEGORY MODEL
// ==================================================================

class _CategoryData {
  final String title;
  final String thumbnail;
  final List<String> wallpapers;

  const _CategoryData({
    required this.title,
    required this.thumbnail,
    required this.wallpapers,
  });
}

// ==================================================================
// ATMOSPHERE CARD
// ==================================================================

class _AtmosphereCard extends StatelessWidget {
  final String title;
  final String thumbnail;
  final int count;
  final int index;
  final bool isFront;
  final bool expanded;
  final double dragX;
  final double dragY;
  final double height;
  final int cacheWidth;
  final VoidCallback onTap;

  const _AtmosphereCard({
    super.key,
    required this.title,
    required this.thumbnail,
    required this.count,
    required this.index,
    required this.isFront,
    required this.expanded,
    required this.dragX,
    required this.dragY,
    required this.height,
    required this.cacheWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final primary =
    dark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final secondary =
    dark ? AppColors.darkSecondary : AppColors.lightSecondary;
    final surface =
    dark ? AppColors.darkSurface : AppColors.lightSurface;

    final imageParallax = isFront ? dragX * .035 : 0.0;
    final imageVertical = isFront ? dragY * .025 : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ======================================================
            // IMAGE
            // ======================================================

            thumbnail.isEmpty
                ? ColoredBox(color: surface)
                : Transform.translate(
              offset: Offset(imageParallax, imageVertical),
              child: Image.network(
                thumbnail,
                fit: BoxFit.cover,
                cacheWidth: cacheWidth,
                filterQuality: FilterQuality.low,
                isAntiAlias: false,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  return ColoredBox(color: surface);
                },
              ),
            ),

            // ======================================================
            // LIGHTWEIGHT OVERLAY
            // ======================================================

            // ======================================================
            // ACCENT EDGE
            // ======================================================

            Positioned(
              left: 0,
              top: height * .34,
              child: SizedBox(
                width: isFront ? 4.w : 2.w,
                height: isFront ? 55.h : 35.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10.r),
                      bottomRight: Radius.circular(10.r),
                    ),
                  ),
                ),
              ),
            ),

            // ======================================================
            // TOP META
            // ======================================================

            Positioned(
              top: 20.h,
              left: 20.w,
              right: 20.w,
              child: Row(
                children: [
                  _MetaPill(
                    background: surface.withOpacity(.30),
                    foreground: primary,
                    text: (index + 1).toString().padLeft(2, '0'),
                  ),
                  const Spacer(),
                  _MetaPill(
                    background: surface.withOpacity(.30),
                    foreground: primary,
                    text: '$count WALLPAPERS',
                  ),
                ],
              ),
            ),

            // ======================================================
            // CENTER LABEL
            // ======================================================

            Positioned(
              top: height * .38,
              left: 23.w,
              child: Row(
                children: [
                  Container(
                    width: 23.w,
                    height: 2,
                    color: AppColors.accent,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    expanded ? 'SELECTED' : 'ATMOSPHERE',
                    style: GoogleFonts.bebasNeue(
                      color: primary.withOpacity(.62),
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.8,
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // BOTTOM
            // ======================================================

            Positioned(
              left: 23.w,
              right: 23.w,
              bottom: 24.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.bebasNeue(
                      color: primary,
                      fontSize: expanded ? 47.sp : 42.sp,
                      height: .78,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 7.w),
                      Text(
                        '4K COLLECTION',
                        style: GoogleFonts.manrope(
                          color: secondary.withOpacity(.65),
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      SizedBox(
                        width: 1,
                        height: 10.h,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '$count FRAMES',
                        style: GoogleFonts.manrope(
                          color: secondary.withOpacity(.65),
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: expanded ? 64.w : 56.w,
                        height: expanded ? 64.w : 56.w,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          expanded
                              ? Icons.arrow_forward_rounded
                              : Icons.north_east_rounded,
                          color: primary,
                          size: expanded ? 25.sp : 22.sp,
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
    );
  }
}

// ==================================================================
// META PILL
// ==================================================================

class _MetaPill extends StatelessWidget {
  final Color background;
  final Color foreground;
  final String text;

  const _MetaPill({
    required this.background,
    required this.foreground,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 7.h,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          color: foreground,
          fontSize: 7.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: .8,
        ),
      ),
    );
  }
}
