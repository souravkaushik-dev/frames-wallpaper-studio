import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/previewscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryScreen extends StatefulWidget {
  final String title;
  final List<String> wallpapers;

  const CategoryScreen({
    super.key,
    required this.title,
    required this.wallpapers,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _introController.forward();
      }
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  // ============================================================
  // THEME
  // ============================================================

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _background(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkBackground
        : AppColors.lightBackground;
  }

  Color _surface(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkSurface
        : AppColors.lightSurface;
  }

  Color _surfaceSoft(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkSurfaceSoft
        : AppColors.lightSurfaceSoft;
  }

  Color _primary(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;
  }

  Color _secondary(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;
  }

  Color _muted(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkMuted
        : AppColors.lightMuted;
  }

  Color _divider(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkDivider
        : AppColors.lightDivider;
  }

  Color get _accent => AppColors.accent;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bg = _background(context);
    final surface = _surface(context);
    final surfaceSoft = _surfaceSoft(context);
    final primary = _primary(context);
    final secondary = _secondary(context);
    final muted = _muted(context);
    final divider = _divider(context);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            cacheExtent: 800,
            slivers: [
              // ======================================================
              // HEADER
              // ======================================================

              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      12.h,
                      16.w,
                      0,
                    ),
                    child: _Header(
                      title: widget.title,
                      count: widget.wallpapers.length,
                      surface: surface,
                      surfaceSoft: surfaceSoft,
                      divider: divider,
                      primary: primary,
                      secondary: secondary,
                      accent: _accent,
                      onBack: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),

              // ======================================================
              // HERO
              // ======================================================

              SliverToBoxAdapter(
                child: _AnimatedIntro(
                  controller: _introController,
                  child: _Hero(
                    image: widget.wallpapers.isEmpty
                        ? null
                        : widget.wallpapers.first,
                    title: widget.title,
                    count: widget.wallpapers.length,
                    background: bg,
                    surface: surface,
                    primary: primary,
                    secondary: secondary,
                    muted: muted,
                    divider: divider,
                    accent: _accent,
                    onTap: widget.wallpapers.isEmpty
                        ? null
                        : () {
                      _openPreview(
                        context,
                        widget.wallpapers.first,
                      );
                    },
                  ),
                ),
              ),

              // ======================================================
              // SMALL SECTION TITLE
              // ======================================================

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    2.h,
                    20.w,
                    14.h,
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,
                    children: [
                      Text(
                        'COLLECTION',
                        style: GoogleFonts.bebasNeue(
                          color: primary,
                          fontSize: 28.sp,
                          height: .9,
                          letterSpacing: .2,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: _accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 7.w),
                      Text(
                        widget.wallpapers.length
                            .toString()
                            .padLeft(2, '0'),
                        style: GoogleFonts.manrope(
                          color: muted,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ======================================================
              // GRID
              // ======================================================

              if (widget.wallpapers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    primary: primary,
                    secondary: secondary,
                    accent: _accent,
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    14.w,
                    0,
                    14.w,
                    80.h,
                  ),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10.h,
                    crossAxisSpacing: 10.w,
                    childCount: widget.wallpapers.length,
                    itemBuilder: (
                        context,
                        index,
                        ) {
                      final image =
                      widget.wallpapers[index];

                      return RepaintBoundary(
                        key: ValueKey(image),
                        child: _WallpaperCard(
                          image: image,
                          index: index,
                          title: widget.title,
                          accent: _accent,
                          surface: surface,
                          primary: primary,
                          muted: muted,
                          divider: divider,
                          onTap: () {
                            _openPreview(
                              context,
                              image,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

              // ======================================================
              // END
              // ======================================================

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 100.h,
                  ),
                  child: _EndMark(
                    divider: divider,
                    muted: muted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PREVIEW
  // ============================================================

  void _openPreview(
      BuildContext context,
      String image,
      ) {
    HapticFeedback.selectionClick();

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 380,
        ),
        reverseTransitionDuration: const Duration(
          milliseconds: 260,
        ),
        pageBuilder: (
            _,
            animation,
            __,
            ) {
          return PreviewScreen(
            imageUrl: image,
            category: widget.title,
          );
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
            child: ScaleTransition(
              scale: Tween<double>(
                begin: .975,
                end: 1,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// ANIMATED INTRO
// ============================================================================

class _AnimatedIntro extends StatelessWidget {
  final AnimationController controller;
  final Widget child;

  const _AnimatedIntro({
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (
          context,
          child,
          ) {
        final value = Curves.easeOutCubic.transform(
          controller.value,
        );

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              20.h * (1 - value),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================

class _Header extends StatelessWidget {
  final String title;
  final int count;

  final Color surface;
  final Color surfaceSoft;
  final Color divider;
  final Color primary;
  final Color secondary;
  final Color accent;

  final VoidCallback onBack;

  const _Header({
    required this.title,
    required this.count,
    required this.surface,
    required this.surfaceSoft,
    required this.divider,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleButton(
          icon: Icons.arrow_back_ios_new_rounded,
          background: surfaceSoft,
          border: divider,
          foreground: primary,
          onTap: onBack,
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 5.w,
                    height: 5.w,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 7.w),
                  Text(
                    'ATMOSPHERE',
                    style: GoogleFonts.manrope(
                      color: secondary,
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.7,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                title.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  color: primary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.4,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 8.h,
          ),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(
              13.r,
            ),
            border: Border.all(
              color: divider,
            ),
          ),
          child: Text(
            count.toString().padLeft(2, '0'),
            style: GoogleFonts.manrope(
              color: primary,
              fontSize: 8.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// HERO
// ============================================================================

class _Hero extends StatelessWidget {
  final String? image;
  final String title;
  final int count;

  final Color background;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color muted;
  final Color divider;
  final Color accent;

  final VoidCallback? onTap;

  const _Hero({
    required this.image,
    required this.title,
    required this.count,
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.muted,
    required this.divider,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        14.w,
        18.h,
        14.w,
        24.h,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            30.r,
          ),
          child: SizedBox(
            height: 475.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ==================================================
                // IMAGE
                // ==================================================

                if (image != null)
                  Image.network(
                    image!,
                    fit: BoxFit.cover,
                    cacheWidth: 1000,
                    filterQuality:
                    FilterQuality.medium,
                    gaplessPlayback: true,
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return Container(
                        color: surface,
                        child: Center(
                          child: Icon(
                            Icons
                                .broken_image_outlined,
                            color: muted,
                            size: 28.sp,
                          ),
                        ),
                      );
                    },
                  )
                else
                  Container(
                    color: surface,
                  ),

                // ==================================================
                // OVERLAY
                // ==================================================

                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [
                            0,
                            .42,
                            .72,
                            1,
                          ],
                          colors: [
                            background.withOpacity(.12),
                            background.withOpacity(.02),
                            background.withOpacity(.20),
                            background.withOpacity(.96),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // TOP
                // ==================================================

                Positioned(
                  top: 16.h,
                  left: 16.w,
                  right: 16.w,
                  child: Row(
                    children: [
                      _Pill(
                        text: 'COLLECTION',
                        background:
                        surface.withOpacity(.72),
                        foreground: primary,
                        border: divider,
                      ),
                      const Spacer(),
                      _Pill(
                        text: '4K',
                        background:
                        surface.withOpacity(.72),
                        foreground: primary,
                        border: divider,
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // SIDE LABEL
                // ==================================================

                Positioned(
                  right: 17.w,
                  top: 78.h,
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      'FRAME 01',
                      style: GoogleFonts.manrope(
                        color:
                        primary.withOpacity(.42),
                        fontSize: 6.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // BOTTOM
                // ==================================================

                Positioned(
                  left: 18.w,
                  right: 18.w,
                  bottom: 18.h,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'SELECTED ATMOSPHERE',
                            style: GoogleFonts.manrope(
                              color: primary
                                  .withOpacity(.68),
                              fontSize: 7.sp,
                              fontWeight:
                              FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6.h),

                      Text(
                        title.toUpperCase(),
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: GoogleFonts.bebasNeue(
                          color: primary,
                          fontSize: 66.sp,
                          height: .84,
                          letterSpacing: .2,
                        ),
                      ),

                      SizedBox(height: 11.h),

                      Row(
                        children: [
                          Text(
                            '${count.toString().padLeft(2, '0')} FRAMES',
                            style: GoogleFonts.manrope(
                              color: primary
                                  .withOpacity(.58),
                              fontSize: 7.sp,
                              fontWeight:
                              FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            width: 1,
                            height: 12.h,
                            color: primary
                                .withOpacity(.22),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            '4K',
                            style: GoogleFonts.manrope(
                              color: primary
                                  .withOpacity(.58),
                              fontSize: 7.sp,
                              fontWeight:
                              FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 13.h),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: primary
                                  .withOpacity(.18),
                            ),
                          ),
                          SizedBox(width: 9.w),
                          Container(
                            width: 32.w,
                            height: 32.w,
                            decoration: BoxDecoration(
                              color: surface
                                  .withOpacity(.78),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: divider,
                              ),
                            ),
                            child: Icon(
                              Icons
                                  .arrow_outward_rounded,
                              color: primary,
                              size: 14.sp,
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
      ),
    );
  }
}

// ============================================================================
// PILL
// ============================================================================

class _Pill extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;
  final Color border;

  const _Pill({
    required this.text,
    required this.background,
    required this.foreground,
    required this.border,
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
        borderRadius: BorderRadius.circular(
          10.r,
        ),
        border: Border.all(
          color: border,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          color: foreground,
          fontSize: 6.5.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ============================================================================
// WALLPAPER CARD
// ============================================================================

class _WallpaperCard extends StatefulWidget {
  final String image;
  final int index;
  final String title;

  final Color accent;
  final Color surface;
  final Color primary;
  final Color muted;
  final Color divider;

  final VoidCallback onTap;

  const _WallpaperCard({
    required this.image,
    required this.index,
    required this.title,
    required this.accent,
    required this.surface,
    required this.primary,
    required this.muted,
    required this.divider,
    required this.onTap,
  });

  @override
  State<_WallpaperCard> createState() =>
      _WallpaperCardState();
}

class _WallpaperCardState
    extends State<_WallpaperCard> {
  bool _pressed = false;

  static const List<double> _heights = [
    285,
    340,
    250,
    320,
    300,
    350,
  ];

  @override
  Widget build(BuildContext context) {
    final height =
        _heights[
        widget.index % _heights.length
        ].h;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });

        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? .96 : 1,
        duration: const Duration(
          milliseconds: 110,
        ),
        curve: Curves.easeOutCubic,
        child: Hero(
          tag: widget.image,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              22.r,
            ),
            child: SizedBox(
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ==================================================
                  // IMAGE
                  // ==================================================

                  Image.network(
                    widget.image,
                    fit: BoxFit.cover,
                    cacheWidth: 650,
                    filterQuality: FilterQuality.low,
                    gaplessPlayback: true,
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return Container(
                        color: widget.surface,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons
                              .broken_image_outlined,
                          color: widget.muted,
                          size: 24.sp,
                        ),
                      );
                    },
                  ),

                  // ==================================================
                  // OVERLAY
                  // ==================================================

                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin:
                            Alignment.topCenter,
                            end:
                            Alignment.bottomCenter,
                            stops: const [
                              0,
                              .55,
                              1,
                            ],
                            colors: [
                              widget.surface
                                  .withOpacity(.06),
                              widget.surface
                                  .withOpacity(.01),
                              widget.surface
                                  .withOpacity(.90),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // NUMBER
                  // ==================================================

                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding:
                      EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: widget.surface
                            .withOpacity(.70),
                        borderRadius:
                        BorderRadius.circular(
                          10.r,
                        ),
                        border: Border.all(
                          color: widget.divider
                              .withOpacity(.7),
                        ),
                      ),
                      child: Text(
                        (widget.index + 1)
                            .toString()
                            .padLeft(2, '0'),
                        style:
                        GoogleFonts.manrope(
                          color: widget.primary,
                          fontSize: 7.sp,
                          fontWeight:
                          FontWeight.w800,
                          letterSpacing: .8,
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // DOT
                  // ==================================================

                  Positioned(
                    top: 17.h,
                    right: 17.w,
                    child: Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: BoxDecoration(
                        color: widget.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // ==================================================
                  // BOTTOM
                  // ==================================================

                  Positioned(
                    left: 14.w,
                    right: 14.w,
                    bottom: 14.h,
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          '4K • ${widget.title.toUpperCase()}',
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            color: widget.primary
                                .withOpacity(.55),
                            fontSize: 6.5.sp,
                            fontWeight:
                            FontWeight.w800,
                            letterSpacing: .8,
                          ),
                        ),

                        SizedBox(height: 5.h),

                        Text(
                          'FRAME ${(widget.index + 1).toString().padLeft(2, '0')}',
                          style:
                          GoogleFonts.bebasNeue(
                            color: widget.primary,
                            fontSize: 26.sp,
                            height: .9,
                            letterSpacing: .2,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: widget.primary
                                    .withOpacity(.18),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons
                                  .arrow_outward_rounded,
                              color: widget.primary
                                  .withOpacity(.65),
                              size: 13.sp,
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
        ),
      ),
    );
  }
}

// ============================================================================
// CIRCLE BUTTON
// ============================================================================

class _CircleButton extends StatelessWidget {
  final IconData icon;

  final Color background;
  final Color border;
  final Color foreground;

  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.background,
    required this.border,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          16.r,
        ),
        child: Ink(
          width: 46.w,
          height: 46.w,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(
              16.r,
            ),
            border: Border.all(
              color: border,
            ),
          ),
          child: Icon(
            icon,
            color: foreground,
            size: 15.sp,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class _EmptyState extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final Color accent;

  const _EmptyState({
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: accent.withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image_not_supported_outlined,
              color: accent,
              size: 25.sp,
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            'EMPTY COLLECTION',
            style: GoogleFonts.bebasNeue(
              color: primary,
              fontSize: 25.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Nothing here yet.',
            style: GoogleFonts.manrope(
              color: secondary,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// END
// ============================================================================

class _EndMark extends StatelessWidget {
  final Color divider;
  final Color muted;

  const _EndMark({
    required this.divider,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30.w,
          height: 1,
          color: divider,
        ),
        SizedBox(height: 10.h),
        Text(
          'END',
          style: GoogleFonts.manrope(
            color: muted.withOpacity(.35),
            fontSize: 6.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}