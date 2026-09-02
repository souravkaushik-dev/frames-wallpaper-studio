import 'dart:convert';
import 'dart:math' as math;

import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/category_spage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'category_screen.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({
    super.key,
  });

  @override
  State<CategoriesPage> createState() =>
      _CategoriesPageState();
}

class _CategoriesPageState
    extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // DATA
  // ============================================================

  late Future<Map<String, dynamic>> _future;

  List<MapEntry<String, dynamic>> _categories = [];

  // ============================================================
  // GESTURE
  // ============================================================

  double _dragX = 0;
  double _dragY = 0;

  bool _dragging = false;
  bool _animating = false;
  bool _expanded = false;

  // ============================================================
  // ANIMATION
  // ============================================================

  late final AnimationController _controller;

  Animation<double>? _xAnimation;
  Animation<double>? _yAnimation;

  double _startX = 0;
  double _endX = 0;

  double _startY = 0;
  double _endY = 0;

  // ============================================================
  // DECK
  // ============================================================

  static const int _visibleCards = 5;

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
      duration: const Duration(
        milliseconds: 520,
      ),
    );

    _controller.addListener(_animate);

    _controller.addStatusListener(
      _animationFinished,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // API
  // ============================================================

  Future<Map<String, dynamic>>
  _fetchCategories() async {
    final apiUrl = dotenv.env['API_URL'];

    if (apiUrl == null ||
        apiUrl.trim().isEmpty) {
      throw Exception(
        'API_URL is not configured',
      );
    }

    final response = await http.get(
      Uri.parse(apiUrl),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load categories',
      );
    }

    final decoded =
    jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Invalid API response',
      );
    }

    return decoded;
  }

  // ============================================================
  // PREPARE
  // ============================================================

  void _prepareCategories(
      Map<String, dynamic> data,
      ) {
    if (_categories.isNotEmpty) {
      return;
    }

    final raw =
    data['categories'];

    if (raw is! Map) {
      return;
    }

    _categories = raw.entries
        .map(
          (entry) =>
          MapEntry<String, dynamic>(
            entry.key.toString(),
            entry.value,
          ),
    )
        .toList();
  }

  // ============================================================
  // ANIMATION
  // ============================================================

  void _animate() {
    if (!mounted) {
      return;
    }

    if (_xAnimation != null) {
      _dragX =
          _xAnimation!.value;
    }

    if (_yAnimation != null) {
      _dragY =
          _yAnimation!.value;
    }

    setState(() {});
  }

  // ============================================================
  // ANIMATION FINISHED
  // ============================================================

  void _animationFinished(
      AnimationStatus status,
      ) {
    if (status !=
        AnimationStatus.completed) {
      return;
    }

    if (!mounted) {
      return;
    }

    // ----------------------------------------------------------
    // LEFT / RIGHT
    // ----------------------------------------------------------

    if (_endX.abs() > 100) {
      _moveCurrentToBack();
    }

    // ----------------------------------------------------------
    // SWIPE UP
    // ----------------------------------------------------------

    if (_endY < -100) {
      _moveCurrentToBack();

      _expanded = false;
    }

    // ----------------------------------------------------------
    // RESET
    // ----------------------------------------------------------

    _dragX = 0;
    _dragY = 0;

    _startX = 0;
    _endX = 0;

    _startY = 0;
    _endY = 0;

    _xAnimation = null;
    _yAnimation = null;

    _animating = false;

    setState(() {});
  }

  // ============================================================
  // MOVE CARD
  // ============================================================

  void _moveCurrentToBack() {
    if (_categories.length <= 1) {
      return;
    }

    final current =
    _categories.removeAt(0);

    _categories.add(current);
  }

  // ============================================================
  // PAN START
  // ============================================================

  void _onPanStart(
      DragStartDetails details,
      ) {
    if (_animating) {
      return;
    }

    _dragging = true;

    _dragX = 0;
    _dragY = 0;

    HapticFeedback.selectionClick();
  }

  // ============================================================
  // PAN UPDATE
  // ============================================================

  void _onPanUpdate(
      DragUpdateDetails details,
      ) {
    if (_animating ||
        !_dragging) {
      return;
    }

    setState(() {
      _dragX += details.delta.dx;
      _dragY += details.delta.dy;

      _dragX = _dragX.clamp(
        -500.0,
        500.0,
      );

      _dragY = _dragY.clamp(
        -500.0,
        420.0,
      );
    });
  }

  // ============================================================
  // PAN END
  // ============================================================

  void _onPanEnd(
      DragEndDetails details,
      ) {
    if (_animating) {
      return;
    }

    _dragging = false;

    final velocity =
        details.velocity.pixelsPerSecond;

    final horizontal =
    _dragX.abs();

    final vertical =
    _dragY.abs();

    // ----------------------------------------------------------
    // HORIZONTAL
    // ----------------------------------------------------------

    if (horizontal > vertical &&
        (horizontal > 90 ||
            velocity.dx.abs() > 650)) {
      _swipeHorizontal(
        velocity.dx >= 0 ? 1 : -1,
      );

      return;
    }

    // ----------------------------------------------------------
    // UP
    // ----------------------------------------------------------

    if (_dragY < -80 ||
        velocity.dy < -600) {
      _swipeUp();

      return;
    }

    // ----------------------------------------------------------
    // DOWN
    // ----------------------------------------------------------

    if (_dragY > 80 ||
        velocity.dy > 550) {
      if (_expanded) {
        _collapse();
      } else {
        _spread();
      }

      return;
    }

    // ----------------------------------------------------------
    // RESET
    // ----------------------------------------------------------

    _returnToCenter();
  }

  // ============================================================
  // HORIZONTAL SWIPE
  // ============================================================

  void _swipeHorizontal(
      int direction,
      ) {
    if (_categories.length <= 1) {
      _returnToCenter();
      return;
    }

    _animating = true;

    HapticFeedback.mediumImpact();

    _startX = _dragX;

    _endX =
        direction *
            MediaQuery.of(context)
                .size
                .width *
            1.25;

    _startY = _dragY;

    _endY =
        _dragY - 15;

    _runAnimation(
      duration:
      const Duration(
        milliseconds: 560,
      ),
      curve:
      Curves.easeOutCubic,
    );
  }

  // ============================================================
  // SWIPE UP
  // ============================================================

  void _swipeUp() {
    if (_categories.length <= 1) {
      _returnToCenter();
      return;
    }

    _animating = true;

    HapticFeedback.mediumImpact();

    _startX = _dragX;

    _endX =
        _dragX * .12;

    _startY = _dragY;

    _endY =
        -MediaQuery.of(context)
            .size
            .height *
            .86;

    _runAnimation(
      duration:
      const Duration(
        milliseconds: 600,
      ),
      curve:
      Curves.easeOutCubic,
    );
  }

  // ============================================================
  // SPREAD
  // ============================================================

  void _spread() {
    HapticFeedback.selectionClick();

    _startX = _dragX;
    _endX = 0;

    _startY = _dragY;
    _endY = 110;

    _animating = true;

    _runAnimation(
      duration:
      const Duration(
        milliseconds: 520,
      ),
      curve:
      Curves.easeOutCubic,
    );
  }

  // ============================================================
  // COLLAPSE
  // ============================================================

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
      duration:
      const Duration(
        milliseconds: 480,
      ),
      curve:
      Curves.easeOutCubic,
    );
  }

  // ============================================================
  // RETURN
  // ============================================================

  void _returnToCenter() {
    _startX = _dragX;
    _endX = 0;

    _startY = _dragY;
    _endY = 0;

    _animating = true;

    _runAnimation(
      duration:
      const Duration(
        milliseconds: 350,
      ),
      curve:
      Curves.easeOutCubic,
    );
  }

  // ============================================================
  // RUN ANIMATION
  // ============================================================

  void _runAnimation({
    required Duration duration,
    required Curve curve,
  }) {
    _controller
      ..duration = duration
      ..reset();

    final curved =
    CurvedAnimation(
      parent: _controller,
      curve: curve,
    );

    _xAnimation =
        Tween<double>(
          begin: _startX,
          end: _endX,
        ).animate(curved);

    _yAnimation =
        Tween<double>(
          begin: _startY,
          end: _endY,
        ).animate(curved);

    _controller.forward();
  }

  // ============================================================
  // CARD HEIGHT
  // ============================================================

  double _cardHeight(
      BuildContext context,
      ) {
    final height =
        MediaQuery.of(context)
            .size
            .height;

    return math.min(
      height * .62,
      525.h,
    );
  }

  // ============================================================
  // SPACING
  // ============================================================

  double _spacing(
      int depth,
      ) {
    final progress =
    (_dragY / 110)
        .clamp(
      0.0,
      1.0,
    );

    final eased =
    Curves.easeOutCubic
        .transform(
      progress,
    );

    return _stackSpacing +
        ((_spreadSpacing -
            _stackSpacing) *
            eased);
  }

  // ============================================================
  // TOP
  // ============================================================

  double _top(
      int depth,
      ) {
    if (depth == 0) {
      return _dragY;
    }

    return depth *
        _spacing(depth) +
        (_dragY * .06);
  }

  // ============================================================
  // SCALE
  // ============================================================

  double _scale(
      int depth,
      ) {
    if (depth == 0) {
      final lift =
      (-_dragY / 200)
          .clamp(
        0.0,
        1.0,
      );

      return 1 +
          lift * .025;
    }

    return (1 -
        depth * .028)
        .clamp(
      .84,
      1.0,
    );
  }

  // ============================================================
  // ROTATION
  // ============================================================

  double _rotation(
      int depth,
      ) {
    if (depth != 0) {
      return 0;
    }

    return (_dragX / 1150)
        .clamp(
      -.05,
      .05,
    );
  }

  // ============================================================
  // OPACITY
  // ============================================================

  double _opacity(
      int depth,
      ) {
    if (depth == 0) {
      return 1;
    }

    return (1 -
        depth * .075)
        .clamp(
      .56,
      1,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      _background(context),
      body: FutureBuilder<
          Map<String, dynamic>>(
        future: _future,
        builder: (
            context,
            snapshot,
            ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return _loading();
          }

          if (snapshot.hasError) {
            return _error();
          }

          if (!snapshot.hasData) {
            return _loading();
          }

          _prepareCategories(
            snapshot.data!,
          );

          if (_categories.isEmpty) {
            return _empty();
          }

          return _page();
        },
      ),
    );
  }

  // ============================================================
  // PAGE
  // ============================================================

  Widget _page() {
    final primary =
    _primary(context);

    final secondary =
    _secondary(context);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // ======================================================
          // HEADER
          // ======================================================

          Padding(
            padding:
            EdgeInsets.fromLTRB(
              20.w,
              15.h,
              20.w,
              0,
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.center,
              children: [
                _circleButton(
                  Icons
                      .arrow_back_ios_new_rounded,
                      () {
                    Navigator.pop(
                      context,
                    );
                  },
                ),

                SizedBox(
                  width: 14.w,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DISCOVER',
                        style:
                        GoogleFonts.manrope(
                          color:
                          secondary,
                          fontSize:
                          8.sp,
                          fontWeight:
                          FontWeight.w800,
                          letterSpacing:
                          2.3,
                        ),
                      ),

                      SizedBox(
                        height: 3.h,
                      ),

                      Text(
                        'Atmospheres',
                        style:
                        GoogleFonts.bebasNeue(
                          color:
                          primary,
                          fontSize:
                          31.sp,
                          height: .8,
                          letterSpacing:
                          1.1,
                        ),
                      ),
                    ],
                  ),
                ),

                // ------------------------------------------------
                // CATEGORY COUNTER
                // ------------------------------------------------

                Container(
                  width: 48.w,
                  height: 48.w,
                  alignment:
                  Alignment.center,
                  decoration:
                  BoxDecoration(
                    color:
                    _accent.withOpacity(
                      .08,
                    ),
                    shape:
                    BoxShape.circle,
                    border:
                    Border.all(
                      color:
                      _divider(context),
                    ),
                  ),
                  child: Text(
                    _categories.length
                        .toString()
                        .padLeft(
                      2,
                      '0',
                    ),
                    style:
                    GoogleFonts.manrope(
                      color:
                      primary,
                      fontSize:
                      10.sp,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 13.h,
          ),

          // ======================================================
          // SUB HEADER
          // ======================================================

          Padding(
            padding:
            EdgeInsets.symmetric(
              horizontal: 20.w,
            ),
            child: Row(
              children: [
                Container(
                  width: 24.w,
                  height: 2,
                  color: _accent,
                ),

                SizedBox(
                  width: 9.w,
                ),

                Text(
                  _expanded
                      ? 'SELECTED ATMOSPHERE'
                      : 'CURATED COLLECTIONS',
                  style:
                  GoogleFonts.manrope(
                    color:
                    secondary,
                    fontSize:
                    7.5.sp,
                    fontWeight:
                    FontWeight.w800,
                    letterSpacing:
                    1.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 12.h,
          ),

          // ======================================================
          // DECK
          // ======================================================

          Expanded(
            child: GestureDetector(
              behavior:
              HitTestBehavior.opaque,
              onPanStart:
              _onPanStart,
              onPanUpdate:
              _onPanUpdate,
              onPanEnd:
              _onPanEnd,
              child: Stack(
                clipBehavior:
                Clip.none,
                children: [
                  for (
                  int depth =
                      math.min(
                        _visibleCards,
                        _categories.length,
                      ) -
                          1;
                  depth >= 0;
                  depth--
                  )
                    _buildCategoryCard(
                      depth,
                    ),
                ],
              ),
            ),
          ),

          // ======================================================
          // BOTTOM STATUS
          // ======================================================

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
      ) {
    final item =
    _categories[depth];

    final category =
    item.value is Map
        ? Map<String, dynamic>.from(
      item.value as Map,
    )
        : <String, dynamic>{};

    final thumbnail =
        category['thumbnail']
            ?.toString() ??
            '';

    final raw =
    category['wallpapers'];

    final wallpapers =
    raw is List
        ? raw
        .map(
          (e) =>
          e.toString(),
    )
        .where(
          (e) =>
      e.isNotEmpty,
    )
        .toList()
        : <String>[];

    final front =
        depth == 0;

    final height =
    _cardHeight(context);

    return Positioned(
      top: _top(depth),
      left: 20.w,
      right: 20.w,
      height: height,
      child: Transform.scale(
        scale: _scale(depth),
        alignment:
        Alignment.topCenter,
        child: Transform.rotate(
          angle: _rotation(depth),
          alignment:
          Alignment.bottomCenter,
          child: Opacity(
            opacity:
            _opacity(depth),
            child:
            _AtmosphereCard(
              title: item.key,
              thumbnail: thumbnail,
              count:
              wallpapers.length,
              index: depth,
              isFront: front,
              expanded:
              _expanded &&
                  front,
              dragX:
              front ? _dragX : 0,
              dragY:
              front ? _dragY : 0,
              height: height,
              onTap: () {
                if (!front ||
                    _animating) {
                  return;
                }

                if (!_expanded) {
                  setState(() {
                    _expanded = true;
                  });

                  HapticFeedback
                      .mediumImpact();

                  return;
                }

                _openCategory(
                  item.key,
                  wallpapers,
                );
              },
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
    final primary =
    _primary(context);

    final secondary =
    _secondary(context);

    return Padding(
      padding:
      EdgeInsets.fromLTRB(
        20.w,
        0,
        20.w,
        20.h,
      ),
      child: AnimatedSwitcher(
        duration:
        const Duration(
          milliseconds: 260,
        ),
        child: _expanded
            ? Row(
          key:
          const ValueKey(
            'expanded',
          ),
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons
                  .keyboard_arrow_down_rounded,
              color:
              secondary
                  .withOpacity(
                .45,
              ),
              size: 18.sp,
            ),
            Text(
              ' SWIPE DOWN TO COLLAPSE',
              style:
              GoogleFonts.manrope(
                color:
                secondary
                    .withOpacity(
                  .48,
                ),
                fontSize:
                7.sp,
                fontWeight:
                FontWeight.w800,
                letterSpacing:
                1.2,
              ),
            ),
          ],
        )
            : Row(
          key:
          const ValueKey(
            'collapsed',
          ),
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons
                  .keyboard_arrow_left_rounded,
              color:
              secondary
                  .withOpacity(
                .38,
              ),
              size: 17.sp,
            ),
            Text(
              ' SWIPE ',
              style:
              GoogleFonts.manrope(
                color:
                secondary
                    .withOpacity(
                  .45,
                ),
                fontSize:
                7.sp,
                fontWeight:
                FontWeight.w800,
                letterSpacing:
                1.4,
              ),
            ),
            Icon(
              Icons
                  .keyboard_arrow_right_rounded,
              color:
              secondary
                  .withOpacity(
                .38,
              ),
              size: 17.sp,
            ),
            SizedBox(
              width: 12.w,
            ),
            Container(
              width: 1,
              height: 12.h,
              color:
              secondary
                  .withOpacity(
                .15,
              ),
            ),
            SizedBox(
              width: 12.w,
            ),
            Icon(
              Icons
                  .keyboard_arrow_up_rounded,
              color:
              secondary
                  .withOpacity(
                .38,
              ),
              size: 17.sp,
            ),
            Text(
              ' EXPLORE',
              style:
              GoogleFonts.manrope(
                color:
                secondary
                    .withOpacity(
                  .45,
                ),
                fontSize:
                7.sp,
                fontWeight:
                FontWeight.w800,
                letterSpacing:
                1.4,
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

  void _openCategory(
      String title,
      List<String> wallpapers,
      ) {
    HapticFeedback.selectionClick();

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration:
        const Duration(
          milliseconds: 440,
        ),
        reverseTransitionDuration:
        const Duration(
          milliseconds: 300,
        ),
        pageBuilder: (
            context,
            animation,
            secondaryAnimation,
            ) {
          return CategoryScreen(
            title: title,
            wallpapers: wallpapers,
          );
        },
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          final curved =
          CurvedAnimation(
            parent: animation,
            curve:
            Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale:
              Tween<double>(
                begin: .965,
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
  // CIRCLE BUTTON
  // ============================================================

  Widget _circleButton(
      IconData icon,
      VoidCallback onTap,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(
          17.r,
        ),
        child: Ink(
          width: 48.w,
          height: 48.w,
          decoration:
          BoxDecoration(
            color:
            _surface(context),
            borderRadius:
            BorderRadius.circular(
              17.r,
            ),
            border:
            Border.all(
              color:
              _divider(context),
            ),
          ),
          child: Icon(
            icon,
            color:
            _primary(context),
            size: 16.sp,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _loading() {
    return Center(
      child:
      CircularProgressIndicator(
        strokeWidth: 1.5,
        color: _accent,
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _error() {
    return Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            Icons
                .cloud_off_rounded,
            color: _accent,
            size: 35.sp,
          ),
          SizedBox(
            height: 14.h,
          ),
          Text(
            'UNABLE TO LOAD',
            style:
            GoogleFonts.bebasNeue(
              color:
              _primary(context),
              fontSize:
              28.sp,
              letterSpacing:
              1.5,
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _categories.clear();
                _future =
                    _fetchCategories();
              });
            },
            child: Container(
              padding:
              EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 11.h,
              ),
              decoration:
              BoxDecoration(
                color:
                _accent,
                borderRadius:
                BorderRadius.circular(
                  100.r,
                ),
              ),
              child: Text(
                'TRY AGAIN',
                style:
                GoogleFonts.manrope(
                  color:
                  _primary(context),
                  fontSize:
                  8.sp,
                  fontWeight:
                  FontWeight.w800,
                  letterSpacing:
                  1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            Icons
                .layers_clear_rounded,
            color: _accent,
            size: 40.sp,
          ),
          SizedBox(
            height: 14.h,
          ),
          Text(
            'NO ATMOSPHERES',
            style:
            GoogleFonts.bebasNeue(
              color:
              _primary(context),
              fontSize:
              30.sp,
              letterSpacing:
              1.5,
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
    return Theme.of(context)
        .brightness ==
        Brightness.dark;
  }

  Color _background(
      BuildContext context,
      ) {
    return _isDark()
        ? AppColors.darkBackground
        : AppColors.lightBackground;
  }

  Color _surface(
      BuildContext context,
      ) {
    return _isDark()
        ? AppColors.darkSurface
        : AppColors.lightSurface;
  }

  Color _surfaceSoft(
      BuildContext context,
      ) {
    return _isDark()
        ? AppColors.darkSurfaceSoft
        : AppColors.lightSurfaceSoft;
  }

  Color _primary(
      BuildContext context,
      ) {
    return _isDark()
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;
  }

  Color _secondary(
      BuildContext context,
      ) {
    return _isDark()
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;
  }

  Color _divider(
      BuildContext context,
      ) {
    return _isDark()
        ? AppColors.darkDivider
        : AppColors.lightDivider;
  }

  Color get _accent =>
      AppColors.accent;
}

// ==================================================================
// ATMOSPHERE CARD
// ==================================================================

class _AtmosphereCard
    extends StatelessWidget {
  final String title;
  final String thumbnail;
  final int count;
  final int index;

  final bool isFront;
  final bool expanded;

  final double dragX;
  final double dragY;

  final double height;

  final VoidCallback onTap;

  const _AtmosphereCard({
    required this.title,
    required this.thumbnail,
    required this.count,
    required this.index,
    required this.isFront,
    required this.expanded,
    required this.dragX,
    required this.dragY,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final dark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final primary =
    dark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final secondary =
    dark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final surface =
    dark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final divider =
    dark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

    final fallback =
    dark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final imageParallax =
    isFront
        ? dragX * .035
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(
          34.r,
        ),
        child: Container(
          decoration:
          BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              34.r,
            ),
            border:
            Border.all(
              color:
              primary.withOpacity(
                isFront
                    ? .17
                    : .09,
              ),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ==================================================
              // IMAGE
              // ==================================================

              thumbnail.isEmpty
                  ? ColoredBox(
                color: fallback,
              )
                  : Transform.translate(
                offset:
                Offset(
                  imageParallax,
                  dragY * .025,
                ),
                child:
                Image.network(
                  thumbnail,
                  fit: BoxFit.cover,
                  cacheWidth: 1200,
                  filterQuality:
                  FilterQuality.medium,
                  gaplessPlayback:
                  true,
                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return ColoredBox(
                      color:
                      fallback,
                    );
                  },
                ),
              ),

              // ==================================================
              // APP COLOR OVERLAY
              // ==================================================

              Positioned.fill(
                child:
                DecoratedBox(
                  decoration:
                  BoxDecoration(
                    gradient:
                    LinearGradient(
                      begin:
                      Alignment.topCenter,
                      end:
                      Alignment.bottomCenter,
                      stops: const [
                        0,
                        .30,
                        .62,
                        1,
                      ],
                      colors: [
                        surface
                            .withOpacity(.24),
                        surface
                            .withOpacity(.02),
                        surface
                            .withOpacity(.20),
                        surface
                            .withOpacity(.94),
                      ],
                    ),
                  ),
                ),
              ),

              // ==================================================
              // ACCENT EDGE
              // ==================================================

              Positioned(
                left: 0,
                top: height * .34,
                child:
                AnimatedContainer(
                  duration:
                  const Duration(
                    milliseconds: 260,
                  ),
                  width:
                  isFront
                      ? 4.w
                      : 2.w,
                  height:
                  isFront
                      ? 55.h
                      : 35.h,
                  decoration:
                  BoxDecoration(
                    color:
                    AppColors.accent,
                    borderRadius:
                    BorderRadius.only(
                      topRight:
                      Radius.circular(
                        10.r,
                      ),
                      bottomRight:
                      Radius.circular(
                        10.r,
                      ),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // TOP META
              // ==================================================

              Positioned(
                top: 20.h,
                left: 20.w,
                right: 20.w,
                child: Row(
                  children: [
                    _MetaPill(
                      background:
                      surface
                          .withOpacity(
                        .30,
                      ),
                      foreground:
                      primary,
                      text:
                      (index + 1)
                          .toString()
                          .padLeft(
                        2,
                        '0',
                      ),
                    ),

                    const Spacer(),

                    _MetaPill(
                      background:
                      surface
                          .withOpacity(
                        .30,
                      ),
                      foreground:
                      primary,
                      text:
                      '$count WALLPAPERS',
                    ),
                  ],
                ),
              ),

              // ==================================================
              // CENTER EDITORIAL LABEL
              // ==================================================

              Positioned(
                top:
                height * .38,
                left: 23.w,
                child: Row(
                  children: [
                    Container(
                      width: 23.w,
                      height: 2,
                      color:
                      AppColors.accent,
                    ),

                    SizedBox(
                      width: 8.w,
                    ),

                    Text(
                      expanded
                          ? 'SELECTED'
                          : 'ATMOSPHERE',
                      style:
                      GoogleFonts.manrope(
                        color:
                        primary
                            .withOpacity(
                          .62,
                        ),
                        fontSize:
                        7.sp,
                        fontWeight:
                        FontWeight.w800,
                        letterSpacing:
                        1.8,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // BOTTOM
              // ==================================================

              Positioned(
                left: 23.w,
                right: 23.w,
                bottom: 24.h,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------------
                    // TITLE
                    // ------------------------------------------------

                    AnimatedDefaultTextStyle(
                      duration:
                      const Duration(
                        milliseconds:
                        300,
                      ),
                      curve:
                      Curves.easeOutCubic,
                      style:
                      GoogleFonts.bebasNeue(
                        color: primary,
                        fontSize:
                        expanded
                            ? 47.sp
                            : 42.sp,
                        height: .78,
                        letterSpacing:
                        2,
                      ),
                      child: Text(
                        title.toUpperCase(),
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(
                      height: 12.h,
                    ),

                    // ------------------------------------------------
                    // INFO
                    // ------------------------------------------------

                    Row(
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration:
                          const BoxDecoration(
                            color:
                            AppColors.accent,
                            shape:
                            BoxShape.circle,
                          ),
                        ),

                        SizedBox(
                          width: 7.w,
                        ),

                        Text(
                          '4K COLLECTION',
                          style:
                          GoogleFonts.manrope(
                            color:
                            secondary
                                .withOpacity(
                              .65,
                            ),
                            fontSize:
                            7.sp,
                            fontWeight:
                            FontWeight.w800,
                            letterSpacing:
                            1.1,
                          ),
                        ),

                        SizedBox(
                          width: 12.w,
                        ),

                        Container(
                          width: 1,
                          height: 10.h,
                          color:
                          divider,
                        ),

                        SizedBox(
                          width: 12.w,
                        ),

                        Text(
                          '$count FRAMES',
                          style:
                          GoogleFonts.manrope(
                            color:
                            secondary
                                .withOpacity(
                              .65,
                            ),
                            fontSize:
                            7.sp,
                            fontWeight:
                            FontWeight.w800,
                            letterSpacing:
                            1.1,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 16.h,
                    ),

                    // ------------------------------------------------
                    // ACTION ROW
                    // ------------------------------------------------

                    Row(
                      children: [
                        Expanded(
                          child:
                          Container(
                            height: 1,
                            color:
                            primary
                                .withOpacity(
                              .18,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 12.w,
                        ),

                        AnimatedContainer(
                          duration:
                          const Duration(
                            milliseconds:
                            260,
                          ),
                          width:
                          expanded
                              ? 64.w
                              : 56.w,
                          height:
                          expanded
                              ? 64.w
                              : 56.w,
                          decoration:
                          BoxDecoration(
                            color:
                            primary
                                .withOpacity(
                              .10,
                            ),
                            shape:
                            BoxShape.circle,
                            border:
                            Border.all(
                              color:
                              primary
                                  .withOpacity(
                                .16,
                              ),
                            ),
                          ),
                          child: Icon(
                            expanded
                                ? Icons
                                .arrow_forward_rounded
                                : Icons
                                .north_east_rounded,
                            color:
                            primary,
                            size:
                            expanded
                                ? 25.sp
                                : 22.sp,
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
    );
  }
}

// ==================================================================
// META PILL
// ==================================================================

class _MetaPill
    extends StatelessWidget {
  final Color background;
  final Color foreground;
  final String text;

  const _MetaPill({
    required this.background,
    required this.foreground,
    required this.text,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 7.h,
      ),
      decoration:
      BoxDecoration(
        color: background,
        borderRadius:
        BorderRadius.circular(
          100.r,
        ),
        border:
        Border.all(
          color:
          foreground.withOpacity(
            .13,
          ),
        ),
      ),
      child: Text(
        text,
        style:
        GoogleFonts.manrope(
          color:
          foreground,
          fontSize: 7.sp,
          fontWeight:
          FontWeight.w800,
          letterSpacing:
          .8,
        ),
      ),
    );
  }
}