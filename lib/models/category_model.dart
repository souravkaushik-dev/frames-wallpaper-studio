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

import '../screens/category_screen.dart';

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

  List<MapEntry<String, dynamic>> _cards = [];

  // ============================================================
  // GESTURE
  // ============================================================

  double _dragX = 0;
  double _dragY = 0;

  bool _dragging = false;
  bool _animating = false;

  // ============================================================
  // EXPANSION
  // ============================================================

  bool _expanded = false;

  // ============================================================
  // ANIMATION
  // ============================================================

  late final AnimationController _animationController;

  Animation<double>? _xAnimation;
  Animation<double>? _yAnimation;

  double _animationStartX = 0;
  double _animationEndX = 0;

  double _animationStartY = 0;
  double _animationEndY = 0;

  // ============================================================
  // DECK SETTINGS
  // ============================================================

  double get _normalSpacing => 43.h;

  double get _expandedSpacing => 96.h;

  int get _maxVisibleCards => 6;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _future = fetchData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 520,
      ),
    );

    _animationController.addListener(
      _onAnimationTick,
    );

    _animationController.addStatusListener(
      _onAnimationStatus,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // API
  // ============================================================

  Future<Map<String, dynamic>> fetchData() async {
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
        'Failed to load categories: '
            '${response.statusCode}',
      );
    }

    final decoded = jsonDecode(
      response.body,
    );

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Invalid API response',
      );
    }

    return decoded;
  }

  // ============================================================
  // PREPARE CARDS
  // ============================================================

  void _prepareCards(
      Map<String, dynamic> data,
      ) {
    if (_cards.isNotEmpty) {
      return;
    }

    final raw = data['categories'];

    if (raw is! Map) {
      return;
    }

    _cards = raw.entries
        .map(
          (entry) => MapEntry<String, dynamic>(
        entry.key.toString(),
        entry.value,
      ),
    )
        .toList();
  }

  // ============================================================
  // ANIMATION TICK
  // ============================================================

  void _onAnimationTick() {
    if (!mounted) {
      return;
    }

    if (_xAnimation != null) {
      _dragX = _xAnimation!.value;
    }

    if (_yAnimation != null) {
      _dragY = _yAnimation!.value;
    }

    setState(() {});
  }

  // ============================================================
  // ANIMATION COMPLETE
  // ============================================================

  void _onAnimationStatus(
      AnimationStatus status,
      ) {
    if (status != AnimationStatus.completed) {
      return;
    }

    if (!mounted) {
      return;
    }

    // ----------------------------------------------------------
    // HORIZONTAL SWIPE
    // ----------------------------------------------------------

    if (_animationEndX.abs() > 100) {
      if (_cards.length > 1) {
        final first = _cards.removeAt(0);
        _cards.add(first);
      }
    }

    // ----------------------------------------------------------
    // SWIPE UP
    // ----------------------------------------------------------

    if (_animationEndY < -100) {
      if (_cards.length > 1) {
        final first = _cards.removeAt(0);
        _cards.add(first);
      }

      _expanded = false;
    }

    // ----------------------------------------------------------
    // RESET
    // ----------------------------------------------------------

    _dragX = 0;
    _dragY = 0;

    _animationStartX = 0;
    _animationEndX = 0;

    _animationStartY = 0;
    _animationEndY = 0;

    _xAnimation = null;
    _yAnimation = null;

    _animating = false;

    setState(() {});
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
    if (_animating || !_dragging) {
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
        -400.0,
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

    final absX = _dragX.abs();
    final absY = _dragY.abs();

    // ==========================================================
    // HORIZONTAL
    // ==========================================================

    if (absX > absY &&
        (absX > 85 ||
            velocity.dx.abs() > 650)) {
      _swipeHorizontal(
        velocity.dx >= 0 ? 1 : -1,
      );

      return;
    }

    // ==========================================================
    // UP
    // ==========================================================

    if (_dragY < -75 ||
        velocity.dy < -600) {
      _swipeUp();

      return;
    }

    // ==========================================================
    // DOWN
    // ==========================================================

    if (_dragY > 75 ||
        velocity.dy > 500) {
      if (_expanded) {
        _collapse();
      } else {
        _spreadDown();
      }

      return;
    }

    // ==========================================================
    // RETURN
    // ==========================================================

    _returnToCenter();
  }

  // ============================================================
  // HORIZONTAL SWIPE
  // ============================================================

  void _swipeHorizontal(
      int direction,
      ) {
    if (_cards.length <= 1) {
      _returnToCenter();
      return;
    }

    _animating = true;

    HapticFeedback.mediumImpact();

    _animationStartX = _dragX;

    _animationEndX =
        direction *
            MediaQuery.of(context).size.width *
            1.25;

    _animationStartY = _dragY;

    _animationEndY =
        _dragY - 12;

    _createAnimation(
      curve: Curves.easeOutCubic,
      duration: const Duration(
        milliseconds: 520,
      ),
    );
  }

  // ============================================================
  // SWIPE UP
  // ============================================================

  void _swipeUp() {
    if (_cards.length <= 1) {
      _returnToCenter();
      return;
    }

    _animating = true;

    HapticFeedback.mediumImpact();

    _animationStartX = _dragX;

    _animationEndX = _dragX * .22;

    _animationStartY = _dragY;

    _animationEndY =
        -MediaQuery.of(context).size.height *
            .82;

    _createAnimation(
      curve: Curves.easeOutCubic,
      duration: const Duration(
        milliseconds: 560,
      ),
    );
  }

  // ============================================================
  // DOWN
  // ============================================================

  void _spreadDown() {
    HapticFeedback.selectionClick();

    _animationStartX = _dragX;
    _animationEndX = 0;

    _animationStartY = _dragY;
    _animationEndY = 105;

    _animating = true;

    _createAnimation(
      curve: Curves.easeOutCubic,
      duration: const Duration(
        milliseconds: 500,
      ),
    );
  }

  // ============================================================
  // COLLAPSE
  // ============================================================

  void _collapse() {
    HapticFeedback.selectionClick();

    _animationStartX = _dragX;
    _animationEndX = 0;

    _animationStartY = _dragY;
    _animationEndY = 0;

    _animating = true;

    _createAnimation(
      curve: Curves.easeOutCubic,
      duration: const Duration(
        milliseconds: 460,
      ),
    );

    setState(() {
      _expanded = false;
    });
  }

  // ============================================================
  // RETURN CENTER
  // ============================================================

  void _returnToCenter() {
    _animationStartX = _dragX;
    _animationEndX = 0;

    _animationStartY = _dragY;
    _animationEndY = 0;

    _animating = true;

    _createAnimation(
      curve: Curves.easeOutCubic,
      duration: const Duration(
        milliseconds: 340,
      ),
    );
  }

  // ============================================================
  // CREATE ANIMATION
  // ============================================================

  void _createAnimation({
    required Curve curve,
    required Duration duration,
  }) {
    _animationController
      ..duration = duration
      ..reset();

    final curved = CurvedAnimation(
      parent: _animationController,
      curve: curve,
    );

    _xAnimation = Tween<double>(
      begin: _animationStartX,
      end: _animationEndX,
    ).animate(curved);

    _yAnimation = Tween<double>(
      begin: _animationStartY,
      end: _animationEndY,
    ).animate(curved);

    _animationController.forward();
  }

  // ============================================================
  // CARD HEIGHT
  // ============================================================

  double _cardHeight(
      BuildContext context,
      ) {
    final screenHeight =
        MediaQuery.of(context).size.height;

    return math.min(
      screenHeight * .64,
      535.h,
    );
  }

  // ============================================================
  // SPACING
  // ============================================================

  double _spacingForDepth(
      int depth,
      ) {
    final pull =
    (_dragY / 105).clamp(
      0.0,
      1.0,
    );

    final smoothPull =
    Curves.easeOutCubic.transform(
      pull,
    );

    return _normalSpacing +
        ((_expandedSpacing -
            _normalSpacing) *
            smoothPull);
  }

  // ============================================================
  // CARD TOP
  // ============================================================

  double _cardTop(
      int depth,
      ) {
    if (depth == 0) {
      return _dragY;
    }

    return depth *
        _spacingForDepth(depth) +
        (_dragY * .08);
  }

  // ============================================================
  // CARD SCALE
  // ============================================================

  double _cardScale(
      int depth,
      ) {
    if (depth == 0) {
      final lift =
      (-_dragY / 180).clamp(
        0.0,
        1.0,
      );

      return 1.0 + lift * .018;
    }

    return (1.0 - depth * .025).clamp(
      .84,
      1.0,
    );
  }

  // ============================================================
  // ROTATION
  // ============================================================

  double _cardRotation(
      int depth,
      ) {
    if (depth != 0) {
      return 0;
    }

    final horizontal =
    (_dragX / 1100).clamp(
      -.055,
      .055,
    );

    return horizontal;
  }

  // ============================================================
  // OPACITY
  // ============================================================

  double _cardOpacity(
      int depth,
      ) {
    if (depth == 0) {
      return 1;
    }

    return (1 - depth * .065).clamp(
      .52,
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
    final background =
    _background(context);

    return Scaffold(
      backgroundColor: background,
      body: FutureBuilder<
          Map<String, dynamic>>(
        future: _future,
        builder: (
            context,
            snapshot,
            ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return _buildLoading(context);
          }

          if (snapshot.hasError) {
            return _buildError(context);
          }

          if (!snapshot.hasData) {
            return _buildLoading(context);
          }

          _prepareCards(
            snapshot.data!,
          );

          if (_cards.isEmpty) {
            return _buildEmpty(context);
          }

          return _buildPage(context);
        },
      ),
    );
  }

  // ============================================================
  // MAIN PAGE
  // ============================================================

  Widget _buildPage(
      BuildContext context,
      ) {
    final primary =
    _primary(context);

    final secondary =
    _secondary(context);

    final divider =
    _divider(context);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // ======================================================
          // HEADER
          // ======================================================

          Padding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              15.h,
              20.w,
              0,
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.center,
              children: [
                _iconButton(
                  context,
                  Icons
                      .arrow_back_ios_new_rounded,
                      () {
                    Navigator.pop(context);
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
                        'EXPLORE',
                        style:
                        GoogleFonts.manrope(
                          color: secondary,
                          fontSize: 8.sp,
                          fontWeight:
                          FontWeight.w800,
                          letterSpacing: 2.1,
                        ),
                      ),

                      SizedBox(
                        height: 3.h,
                      ),

                      Text(
                        'Your Atmosphere',
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        GoogleFonts.manrope(
                          color: primary,
                          fontSize: 22.sp,
                          fontWeight:
                          FontWeight.w800,
                          letterSpacing: -.9,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: 10.w,
                ),

                Container(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    _surfaceSoft(context),
                    borderRadius:
                    BorderRadius.circular(
                      100.r,
                    ),
                    border: Border.all(
                      color: divider,
                    ),
                  ),
                  child: Text(
                    '${_cards.length}',
                    style:
                    GoogleFonts.manrope(
                      color: primary,
                      fontSize: 10.sp,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 15.h,
          ),

          // ======================================================
          // SMALL INSTRUCTION
          // ======================================================

          Padding(
            padding:
            EdgeInsets.symmetric(
              horizontal: 20.w,
            ),
            child: AnimatedSwitcher(
              duration:
              const Duration(
                milliseconds: 250,
              ),
              child: Row(
                key: ValueKey(
                  _expanded,
                ),
                children: [
                  Icon(
                    _expanded
                        ? Icons
                        .keyboard_arrow_down_rounded
                        : Icons.swipe_rounded,
                    color:
                    secondary.withOpacity(.5),
                    size: 16.sp,
                  ),

                  SizedBox(
                    width: 7.w,
                  ),

                  Text(
                    _expanded
                        ? 'SWIPE DOWN TO COLLAPSE'
                        : 'SWIPE TO DISCOVER',
                    style:
                    GoogleFonts.manrope(
                      color:
                      secondary.withOpacity(
                        .55,
                      ),
                      fontSize: 8.sp,
                      fontWeight:
                      FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 13.h,
          ),

          // ======================================================
          // CARD AREA
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
                        _maxVisibleCards,
                        _cards.length,
                      ) -
                          1;
                  depth >= 0;
                  depth--
                  )
                    _buildCard(
                      context,
                      depth: depth,
                    ),
                ],
              ),
            ),
          ),

          // ======================================================
          // BOTTOM HINT
          // ======================================================

          Padding(
            padding:
            EdgeInsets.only(
              bottom: 22.h,
            ),
            child:
            _buildGestureHint(
              context,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _buildCard(
      BuildContext context, {
        required int depth,
      }) {
    final card =
    _cards[depth];

    final category =
    card.value is Map
        ? Map<String, dynamic>.from(
      card.value as Map,
    )
        : <String, dynamic>{};

    final thumbnail =
        category['thumbnail']
            ?.toString() ??
            '';

    final rawWallpapers =
    category['wallpapers'];

    final wallpapers =
    rawWallpapers is List
        ? rawWallpapers
        .map(
          (item) =>
          item.toString(),
    )
        .where(
          (item) =>
      item.isNotEmpty,
    )
        .toList()
        : <String>[];

    final cardHeight =
    _cardHeight(context);

    final top =
    _cardTop(depth);

    final scale =
    _cardScale(depth);

    final opacity =
    _cardOpacity(depth);

    final rotation =
    _cardRotation(depth);

    final isFront =
        depth == 0;

    return Positioned(
      top: top,
      left: 20.w,
      right: 20.w,
      height: cardHeight,
      child: Transform.scale(
        scale: scale,
        alignment:
        Alignment.topCenter,
        child: Transform.rotate(
          angle: rotation,
          alignment:
          Alignment.bottomCenter,
          child: Opacity(
            opacity: opacity,
            child: _CategoryDeckCard(
              index: depth,
              title: card.key,
              thumbnail: thumbnail,
              count:
              wallpapers.length,
              height: cardHeight,
              isFront: isFront,
              expanded: _expanded,
              onTap: () {
                if (!isFront ||
                    _animating) {
                  return;
                }

                if (!_expanded) {
                  _expandCard();
                  return;
                }

                _openCategory(
                  context,
                  title: card.key,
                  wallpapers:
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
  // EXPAND CARD
  // ============================================================

  void _expandCard() {
    HapticFeedback.mediumImpact();

    setState(() {
      _expanded = true;
      _dragX = 0;
      _dragY = 0;
    });
  }

  // ============================================================
  // GESTURE HINT
  // ============================================================

  Widget _buildGestureHint(
      BuildContext context,
      ) {
    final secondary =
    _secondary(context);

    return AnimatedOpacity(
      duration:
      const Duration(
        milliseconds: 220,
      ),
      opacity: _dragging ? 0 : 1,
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons
                .keyboard_arrow_left_rounded,
            color:
            secondary.withOpacity(.4),
            size: 18.sp,
          ),

          Text(
            ' SWIPE ',
            style:
            GoogleFonts.manrope(
              color:
              secondary.withOpacity(.45),
              fontSize: 7.sp,
              fontWeight:
              FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),

          Icon(
            Icons
                .keyboard_arrow_right_rounded,
            color:
            secondary.withOpacity(.4),
            size: 18.sp,
          ),

          SizedBox(
            width: 12.w,
          ),

          Container(
            width: 1,
            height: 12.h,
            color:
            secondary.withOpacity(.16),
          ),

          SizedBox(
            width: 12.w,
          ),

          Icon(
            Icons
                .keyboard_arrow_up_rounded,
            color:
            secondary.withOpacity(.4),
            size: 18.sp,
          ),

          Text(
            ' NEXT',
            style:
            GoogleFonts.manrope(
              color:
              secondary.withOpacity(.45),
              fontSize: 7.sp,
              fontWeight:
              FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OPEN CATEGORY
  // ============================================================

  void _openCategory(
      BuildContext context, {
        required String title,
        required List<String> wallpapers,
      }) {
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
              scale: Tween<double>(
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
  // ICON BUTTON
  // ============================================================

  Widget _iconButton(
      BuildContext context,
      IconData icon,
      VoidCallback onTap,
      ) {
    final surface =
    _surface(context);

    final divider =
    _divider(context);

    final primary =
    _primary(context);

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
            color: surface,
            borderRadius:
            BorderRadius.circular(
              17.r,
            ),
            border: Border.all(
              color: divider,
            ),
          ),
          child: Icon(
            icon,
            color: primary,
            size: 16.sp,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading(
      BuildContext context,
      ) {
    return ColoredBox(
      color:
      _background(context),
      child: Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            SizedBox(
              width: 40.w,
              height: 40.w,
              child:
              CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.accent,
              ),
            ),

            SizedBox(
              height: 15.h,
            ),

            Text(
              'Loading collections',
              style:
              GoogleFonts.manrope(
                color:
                _secondary(context),
                fontSize: 10.sp,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
      BuildContext context,
      ) {
    return ColoredBox(
      color:
      _background(context),
      child: Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 70.w,
              height: 70.w,
              decoration:
              BoxDecoration(
                color:
                _surface(context),
                shape:
                BoxShape.circle,
              ),
              child: Icon(
                Icons
                    .cloud_off_rounded,
                color:
                AppColors.accent,
                size: 28.sp,
              ),
            ),

            SizedBox(
              height: 18.h,
            ),

            Text(
              'COLLECTIONS\nUNAVAILABLE',
              textAlign:
              TextAlign.center,
              style:
              GoogleFonts.manrope(
                color:
                _primary(context),
                fontSize: 23.sp,
                fontWeight:
                FontWeight.w800,
                height: .95,
              ),
            ),

            SizedBox(
              height: 10.h,
            ),

            Text(
              'Check your connection and try again.',
              style:
              GoogleFonts.manrope(
                color:
                _secondary(context),
                fontSize: 10.sp,
                fontWeight:
                FontWeight.w500,
              ),
            ),

            SizedBox(
              height: 20.h,
            ),

            GestureDetector(
              onTap: () {
                setState(() {
                  _future =
                      fetchData();
                  _cards.clear();
                  _expanded = false;
                });
              },
              child: Container(
                padding:
                EdgeInsets.symmetric(
                  horizontal: 22.w,
                  vertical: 12.h,
                ),
                decoration:
                BoxDecoration(
                  color:
                  AppColors.accent,
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
                    fontSize: 9.sp,
                    fontWeight:
                    FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty(
      BuildContext context,
      ) {
    return ColoredBox(
      color:
      _background(context),
      child: Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .layers_clear_rounded,
              color:
              AppColors.accent,
              size: 44.sp,
            ),

            SizedBox(
              height: 15.h,
            ),

            Text(
              'NO COLLECTIONS',
              style:
              GoogleFonts.manrope(
                color:
                _primary(context),
                fontSize: 21.sp,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            SizedBox(
              height: 7.h,
            ),

            Text(
              'New collections will appear here.',
              style:
              GoogleFonts.manrope(
                color:
                _secondary(context),
                fontSize: 10.sp,
                fontWeight:
                FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // THEME
  // ============================================================

  bool _isDark(
      BuildContext context,
      ) {
    return Theme.of(context).brightness ==
        Brightness.dark;
  }

  Color _background(
      BuildContext context,
      ) {
    return _isDark(context)
        ? AppColors.darkBackground
        : AppColors.lightBackground;
  }

  Color _surface(
      BuildContext context,
      ) {
    return _isDark(context)
        ? AppColors.darkSurface
        : AppColors.lightSurface;
  }

  Color _surfaceSoft(
      BuildContext context,
      ) {
    return _isDark(context)
        ? AppColors.darkSurfaceSoft
        : AppColors.lightSurfaceSoft;
  }

  Color _primary(
      BuildContext context,
      ) {
    return _isDark(context)
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;
  }

  Color _secondary(
      BuildContext context,
      ) {
    return _isDark(context)
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;
  }

  Color _divider(
      BuildContext context,
      ) {
    return _isDark(context)
        ? AppColors.darkDivider
        : AppColors.lightDivider;
  }
}

// ==================================================================
// CATEGORY CARD
// ==================================================================

class _CategoryDeckCard
    extends StatelessWidget {
  final int index;
  final String title;
  final String thumbnail;
  final int count;
  final double height;
  final bool isFront;
  final bool expanded;
  final VoidCallback onTap;

  const _CategoryDeckCard({
    required this.index,
    required this.title,
    required this.thumbnail,
    required this.count,
    required this.height,
    required this.isFront,
    required this.expanded,
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

    final surface =
    dark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final secondary =
    dark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final fallback =
    dark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration:
        BoxDecoration(
          borderRadius:
          BorderRadius.circular(
            35.r,
          ),
          boxShadow: [
            BoxShadow(
              color:
              primary.withOpacity(
                dark
                    ? .14
                    : .10,
              ),
              blurRadius:
              isFront ? 35 : 22,
              spreadRadius: -7,
              offset:
              const Offset(
                0,
                17,
              ),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(
            35.r,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ====================================================
              // IMAGE
              // ====================================================

              thumbnail.isEmpty
                  ? ColoredBox(
                color: fallback,
              )
                  : Image.network(
                thumbnail,
                fit: BoxFit.cover,
                cacheWidth: 1200,
                filterQuality:
                FilterQuality.medium,
                gaplessPlayback: true,
                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return ColoredBox(
                    color: fallback,
                  );
                },
              ),

              // ====================================================
              // APP-COLOR GRADIENT
              // ====================================================

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
                        .32,
                        .65,
                        1,
                      ],
                      colors: [
                        primary
                            .withOpacity(.20),
                        primary
                            .withOpacity(.02),
                        surface
                            .withOpacity(.18),
                        surface
                            .withOpacity(.92),
                      ],
                    ),
                  ),
                ),
              ),

              // ====================================================
              // SIDE SHADE
              // ====================================================

              Positioned.fill(
                child:
                DecoratedBox(
                  decoration:
                  BoxDecoration(
                    gradient:
                    LinearGradient(
                      begin:
                      Alignment.centerLeft,
                      end:
                      Alignment.centerRight,
                      colors: [
                        surface
                            .withOpacity(.32),
                        surface
                            .withOpacity(.02),
                      ],
                    ),
                  ),
                ),
              ),

              // ====================================================
              // BORDER
              // ====================================================

              Positioned.fill(
                child:
                IgnorePointer(
                  child: Container(
                    decoration:
                    BoxDecoration(
                      borderRadius:
                      BorderRadius
                          .circular(
                        35.r,
                      ),
                      border:
                      Border.all(
                        color: primary
                            .withOpacity(
                          isFront
                              ? .18
                              : .10,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ====================================================
              // NUMBER
              // ====================================================

              Positioned(
                top: 20.h,
                left: 20.w,
                child:
                _GlassLabel(
                  background:
                  surface,
                  foreground:
                  primary,
                  child: Text(
                    (index + 1)
                        .toString()
                        .padLeft(
                      2,
                      '0',
                    ),
                    style:
                    GoogleFonts.manrope(
                      color: primary,
                      fontSize: 8.sp,
                      fontWeight:
                      FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              // ====================================================
              // COUNT
              // ====================================================

              Positioned(
                top: 20.h,
                right: 20.w,
                child:
                _GlassLabel(
                  background:
                  surface,
                  foreground:
                  primary,
                  child: Text(
                    '$count WALLPAPERS',
                    style:
                    GoogleFonts.manrope(
                      color:
                      primary,
                      fontSize: 7.sp,
                      fontWeight:
                      FontWeight.w800,
                      letterSpacing:
                      .8,
                    ),
                  ),
                ),
              ),

              // ====================================================
              // CENTER LABEL
              // ====================================================

              Positioned(
                top:
                height * .40,
                left: 23.w,
                child: Text(
                  expanded
                      ? 'EXPLORE COLLECTION'
                      : 'COLLECTION',
                  style:
                  GoogleFonts.manrope(
                    color:
                    primary.withOpacity(
                      .58,
                    ),
                    fontSize: 8.sp,
                    fontWeight:
                    FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),

              // ====================================================
              // BOTTOM CONTENT
              // ====================================================

              Positioned(
                left: 23.w,
                right: 23.w,
                bottom: 25.h,
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Expanded(
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
                              milliseconds: 280,
                            ),
                            curve:
                            Curves.easeOutCubic,
                            style:
                            GoogleFonts.manrope(
                              color: primary,
                              fontSize:
                              expanded
                                  ? 39.sp
                                  : 35.sp,
                              fontWeight:
                              FontWeight.w800,
                              height: .88,
                              letterSpacing:
                              -1.8,
                            ),
                            child: Text(
                              title
                                  .toUpperCase(),
                              maxLines: 2,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                            ),
                          ),

                          SizedBox(
                            height: 12.h,
                          ),

                          // ------------------------------------------------
                          // SMALL LABEL
                          // ------------------------------------------------

                          Row(
                            children: [
                              Container(
                                width: 5.w,
                                height: 5.w,
                                decoration:
                                BoxDecoration(
                                  color:
                                  AppColors
                                      .accent,
                                  shape:
                                  BoxShape
                                      .circle,
                                ),
                              ),

                              SizedBox(
                                width: 7.w,
                              ),

                              Text(
                                expanded
                                    ? 'TAP TO OPEN'
                                    : 'SWIPE TO REVEAL',
                                style:
                                GoogleFonts
                                    .manrope(
                                  color:
                                  primary
                                      .withOpacity(
                                    .58,
                                  ),
                                  fontSize: 7.sp,
                                  fontWeight:
                                  FontWeight
                                      .w800,
                                  letterSpacing:
                                  1.1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: 12.w,
                    ),

                    // ==================================================
                    // ARROW
                    // ==================================================

                    AnimatedContainer(
                      duration:
                      const Duration(
                        milliseconds: 300,
                      ),
                      curve:
                      Curves.easeOutCubic,
                      width:
                      expanded
                          ? 62.w
                          : 58.w,
                      height:
                      expanded
                          ? 62.w
                          : 58.w,
                      decoration:
                      BoxDecoration(
                        color:
                        primary.withOpacity(
                          dark
                              ? .12
                              : .10,
                        ),
                        shape:
                        BoxShape.circle,
                        border:
                        Border.all(
                          color:
                          primary.withOpacity(
                            .16,
                          ),
                        ),
                      ),
                      child: AnimatedRotation(
                        duration:
                        const Duration(
                          milliseconds: 280,
                        ),
                        turns:
                        expanded
                            ? .0
                            : 0,
                        child: Icon(
                          Icons
                              .arrow_forward_rounded,
                          color: primary,
                          size:
                          expanded
                              ? 25.sp
                              : 23.sp,
                        ),
                      ),
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
// GLASS LABEL
// ==================================================================

class _GlassLabel
    extends StatelessWidget {
  final Widget child;
  final Color background;
  final Color foreground;

  const _GlassLabel({
    required this.child,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration:
      BoxDecoration(
        color:
        background.withOpacity(.34),
        borderRadius:
        BorderRadius.circular(
          100.r,
        ),
        border: Border.all(
          color:
          foreground.withOpacity(.12),
        ),
      ),
      child: child,
    );
  }
}