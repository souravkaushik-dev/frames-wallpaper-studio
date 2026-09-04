import 'dart:convert';

import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/previewscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class WidePage extends StatefulWidget {
  const WidePage({super.key});

  @override
  State<WidePage> createState() => _WidePageState();
}

class _WidePageState extends State<WidePage> {
  late Future<List<String>> _wideFuture;

  // Index of the wallpaper currently expanded in the collection.
  int? _expandedIndex;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _background =>
      _isDark ? AppColors.darkBackground : AppColors.lightBackground;

  Color get _surface =>
      _isDark ? AppColors.darkSurface : AppColors.lightSurface;

  Color get _surfaceSoft =>
      _isDark ? AppColors.darkSurfaceSoft : AppColors.lightSurfaceSoft;

  Color get _primary =>
      _isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

  Color get _secondary =>
      _isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

  Color get _muted => _isDark ? AppColors.darkMuted : AppColors.lightMuted;

  Color get _divider =>
      _isDark ? AppColors.darkDivider : AppColors.lightDivider;

  Color get _accent => AppColors.accent;

  @override
  void initState() {
    super.initState();
    _wideFuture = _fetchWideWallpapers();
  }

  // ===========================================================================
  // API
  // ===========================================================================

  Future<List<String>> _fetchWideWallpapers() async {
    final apiUrl = dotenv.env['API_URL'];

    if (apiUrl == null || apiUrl.trim().isEmpty) {
      throw Exception('API_URL is not configured');
    }

    final response = await http
        .get(Uri.parse(apiUrl))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Server returned ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid API response');
    }

    final categories = decoded['categories'];

    if (categories is! Map<String, dynamic>) {
      throw Exception('Categories not found');
    }

    final desktopCategory = categories['Desktop 4K'];

    if (desktopCategory is! Map<String, dynamic>) {
      return [];
    }

    final wallpapers = desktopCategory['wallpapers'];

    if (wallpapers is! List) {
      return [];
    }

    return wallpapers
        .map((item) => item.toString().trim())
        .where((url) => url.isNotEmpty)
        .toList();
  }

  Future<void> _refresh() async {
    HapticFeedback.selectionClick();

    final future = _fetchWideWallpapers();

    setState(() {
      _wideFuture = future;
    });

    await future;
  }

  void _retry() {
    HapticFeedback.selectionClick();

    setState(() {
      _wideFuture = _fetchWideWallpapers();
    });
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<String>>(
          future: _wideFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return _buildLoading();
            }

            if (snapshot.hasError && !snapshot.hasData) {
              return _buildError();
            }

            final wallpapers = snapshot.data ?? [];

            if (wallpapers.isEmpty) {
              return _buildEmpty();
            }

            return RefreshIndicator(
              color: _accent,
              backgroundColor: _surface,
              displacement: 70.h,
              strokeWidth: 1.4,
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                cacheExtent: 1000,
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(wallpapers.length)),

                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(14.w, 2.h, 14.w, 70.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final imageUrl = wallpapers[index];

                        return RepaintBoundary(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _AnimatedWideCard(
                              key: ValueKey('${imageUrl}_$index'),
                              index: index,
                              child: _WideCard(
                                imageUrl: imageUrl,
                                index: index,
                                primary: _primary,
                                muted: _muted,
                                divider: _divider,
                                surface: _surface,
                                surfaceSoft: _surfaceSoft,
                                accent: _accent,
                                isDark: _isDark,
                                isExpanded: _expandedIndex == index,
                                onToggleExtend: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _expandedIndex = _expandedIndex == index
                                        ? null
                                        : index;
                                  });
                                },
                                onTap: () {
                                  _openPreview(imageUrl);
                                },
                              ),
                            ),
                          ),
                        );
                      }, childCount: wallpapers.length),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================
  Widget _buildHeader(int count) {
    return SizedBox(
      height: 105.h,
      width: double.infinity,
      child: ClipRect(child: _MovingWideHeader()),
    );
  }

  // ===========================================================================
  // PREVIEW
  // ===========================================================================

  void _openPreview(String imageUrl) {
    if (imageUrl.trim().isEmpty) {
      return;
    }

    HapticFeedback.selectionClick();

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (context, animation, secondaryAnimation) {
          return PreviewScreen(imageUrl: imageUrl, category: 'Wide 4K');
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: .975, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // INFO
  // ===========================================================================

  void _showCollectionInfo(int count) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final sheetSurface = isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface;

        final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

        final secondary = isDark
            ? AppColors.darkSecondary
            : AppColors.lightSecondary;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
            child: Container(
              padding: EdgeInsets.all(17.w),
              decoration: BoxDecoration(
                color: sheetSurface,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkDivider
                      : AppColors.lightDivider,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.desktop_windows_rounded,
                      color: AppColors.accent,
                      size: 19.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WIDE 4K',
                          style: GoogleFonts.bebasNeue(
                            color: primary,
                            fontSize: 22.sp,
                            height: .88,
                            letterSpacing: .5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '$count wallpapers in this collection.',
                          style: GoogleFonts.googleSansFlex(
                            color: secondary,
                            fontSize: 7.5.sp,
                            fontWeight: FontWeight.w500,
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
      },
    );
  }

  // ===========================================================================
  // LOADING
  // ===========================================================================

  Widget _buildLoading() {
    return Center(
      child: _LoadingCard(
        surface: _surface,
        divider: _divider,
        accent: _accent,
      ),
    );
  }

  // ===========================================================================
  // ERROR
  // ===========================================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78.w,
              height: 78.w,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(29.r),
                border: Border.all(color: _divider),
              ),
              child: Icon(Icons.cloud_off_rounded, color: _accent, size: 29.sp),
            ),
            SizedBox(height: 19.h),
            Text(
              'COLLECTION\nUNAVAILABLE',
              textAlign: TextAlign.center,
              style: GoogleFonts.bebasNeue(
                fontSize: 29.sp,
                letterSpacing: .8,
                color: _primary,
                height: .9,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Unable to load wide wallpapers.',
              textAlign: TextAlign.center,
              style: GoogleFonts.googleSansFlex(
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
                color: _secondary,
              ),
            ),
            SizedBox(height: 20.h),
            _ActionButton(
              label: 'RETRY',
              surface: _surface,
              primary: _primary,
              divider: _divider,
              onTap: _retry,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // EMPTY
  // ===========================================================================

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78.w,
              height: 78.w,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(29.r),
                border: Border.all(color: _divider),
              ),
              child: Icon(
                Icons.desktop_windows_rounded,
                color: _muted,
                size: 29.sp,
              ),
            ),
            SizedBox(height: 19.h),
            Text(
              'NO WIDE WALLPAPERS',
              textAlign: TextAlign.center,
              style: GoogleFonts.bebasNeue(
                fontSize: 27.sp,
                letterSpacing: .7,
                color: _primary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'The wide collection is empty.',
              textAlign: TextAlign.center,
              style: GoogleFonts.googleSansFlex(
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
                color: _secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ANIMATED CARD ENTRY
// =============================================================================

class _AnimatedWideCard extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedWideCard({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  State<_AnimatedWideCard> createState() => _AnimatedWideCardState();
}

class _AnimatedWideCardState extends State<_AnimatedWideCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(curve);

    _slide = Tween<Offset>(
      begin: const Offset(0, .045),
      end: Offset.zero,
    ).animate(curve);

    final delay = Duration(milliseconds: (widget.index.clamp(0, 7)) * 45);

    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// =============================================================================
// DESKTOP CARD
// =============================================================================

class _WideCard extends StatefulWidget {
  final String imageUrl;
  final int index;

  final Color primary;
  final Color muted;
  final Color divider;
  final Color surface;
  final Color surfaceSoft;
  final Color accent;

  final bool isDark;
  final bool isExpanded;
  final VoidCallback onToggleExtend;
  final VoidCallback onTap;

  const _WideCard({
    required this.imageUrl,
    required this.index,
    required this.primary,
    required this.muted,
    required this.divider,
    required this.surface,
    required this.surfaceSoft,
    required this.accent,
    required this.isDark,
    required this.isExpanded,
    required this.onToggleExtend,
    required this.onTap,
  });

  @override
  State<_WideCard> createState() => _WideCardState();
}

class _WideCardState extends State<_WideCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _imageController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    // Very subtle continuous movement keeps the collection alive
    // without turning the wallpaper cards into distracting animations.
    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
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

        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? .975 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeInOutCubic,
          height: widget.isExpanded ? 490.h : 206.h,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: widget.surface,
            borderRadius: BorderRadius.circular(34.r),
            border: Border.all(
              color: widget.divider.withOpacity(.72),
              width: 1,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildAnimatedImage(),

              // Soft darkening at the bottom gives the same
              // photo-first editorial feeling as the reference.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, .48, .78, 1],
                      colors: [
                        Colors.black.withOpacity(.04),
                        Colors.transparent,
                        Colors.black.withOpacity(.16),
                        Colors.black.withOpacity(.72),
                      ],
                    ),
                  ),
                ),
              ),

              // Small top-left metadata pill.
              Positioned(
                left: 14.w,
                top: 13.h,
                child: _GlassPill(
                  text: '4K',
                  foreground: Colors.white,
                  background: Colors.white.withOpacity(.18),
                  border: Colors.white.withOpacity(.28),
                ),
              ),
              // Extend action — top-right of every wallpaper.
              Positioned(
                right: 14.w,
                top: 13.h,
                child: _ExtendButton(
                  expanded: widget.isExpanded,
                  onTap: widget.onToggleExtend,
                ),
              ),

              // Large wallpaper title.
              Positioned(
                left: 18.w,
                right: 18.w,
                bottom: 15.h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5.h),
                          Text(
                            'WIDE • 4K',
                            style: GoogleFonts.googleSansFlex(
                              color: Colors.white.withOpacity(.72),
                              fontSize: 5.6.sp,
                              fontWeight: FontWeight.w500,
                              letterSpacing: .85,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedImage() {
    return AnimatedBuilder(
      animation: _imageController,
      builder: (context, child) {
        final value = Curves.easeInOut.transform(_imageController.value);

        return Transform.scale(
          scale: 1.025 + (value * .018),
          child: Transform.translate(
            offset: Offset(0, -1.5 + (value * 3)),
            child: child,
          ),
        );
      },
      child: Image.network(
        widget.imageUrl,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        cacheWidth: 1200,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: widget.surfaceSoft,
            alignment: Alignment.center,
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 28.sp,
              color: widget.muted,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            color: widget.surfaceSoft,
            alignment: Alignment.center,
            child: SizedBox(
              width: 21.w,
              height: 21.w,
              child: CircularProgressIndicator(
                strokeWidth: 1.4,
                color: widget.accent,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  String _getName(String url) {
    try {
      final uri = Uri.tryParse(url);

      String value = uri?.pathSegments.isNotEmpty == true
          ? uri!.pathSegments.last
          : url.split('/').last;

      value = value.split('?').first;

      value = value.replaceFirst(
        RegExp(r'\.(jpg|jpeg|png|webp|avif)$', caseSensitive: false),
        '',
      );

      value = value.replaceFirst(
        RegExp(r'[_-]?\d{3,5}x\d{3,5}$', caseSensitive: false),
        '',
      );

      value = value.replaceAll(RegExp(r'[_-]+'), ' ').trim();

      if (value.isEmpty) {
        return 'WIDE';
      }

      return value
          .split(' ')
          .where((word) => word.trim().isNotEmpty)
          .map((word) {
            if (word.length == 1) {
              return word.toUpperCase();
            }

            return '${word[0].toUpperCase()}'
                '${word.substring(1).toLowerCase()}';
          })
          .join(' ');
    } catch (_) {
      return 'WIDE';
    }
  }
}



// =============================================================================
// TOP BUTTON
// =============================================================================

class _TopButton extends StatefulWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color border;
  final VoidCallback onTap;

  const _TopButton({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.border,
    required this.onTap,
  });

  @override
  State<_TopButton> createState() => _TopButtonState();
}

class _TopButtonState extends State<_TopButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
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
        scale: _pressed ? .92 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: widget.background,
            borderRadius: BorderRadius.circular(19.r),
            border: Border.all(color: widget.border),
          ),
          child: Icon(widget.icon, size: 18.sp, color: widget.foreground),
        ),
      ),
    );
  }
}

// =============================================================================
// GLASS PILL
// =============================================================================

class _GlassPill extends StatelessWidget {
  final String text;
  final Color foreground;
  final Color background;
  final Color border;

  const _GlassPill({
    required this.text,
    required this.foreground,
    required this.background,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: GoogleFonts.googleSansFlex(
          color: foreground,
          fontSize: 5.5.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: .45,
          height: 1,
        ),
      ),
    );
  }
}

// =============================================================================
// EXTEND BUTTON
// =============================================================================

class _ExtendButton extends StatefulWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _ExtendButton({required this.expanded, required this.onTap});

  @override
  State<_ExtendButton> createState() => _ExtendButtonState();
}

class _ExtendButtonState extends State<_ExtendButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? .92 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(widget.expanded ? .46 : .20),
            borderRadius: BorderRadius.circular(100.r),
            border: Border.all(color: Colors.white.withOpacity(.28)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedRotation(
                turns: widget.expanded ? .5 : 0,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: Icon(
                  Icons.unfold_more_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                widget.expanded ? 'COLLAPSE' : 'EXTEND',
                style: GoogleFonts.googleSansFlex(
                  color: Colors.white,
                  fontSize: 5.3.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: .65,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CIRCLE ICON BUTTON
// =============================================================================

class _CircleIconButton extends StatefulWidget {
  final IconData icon;
  final Color foreground;
  final Color background;
  final Color border;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.foreground,
    required this.background,
    required this.border,
    required this.onTap,
  });

  @override
  State<_CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<_CircleIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
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
        scale: _pressed ? .88 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 39.w,
          height: 39.w,
          decoration: BoxDecoration(
            color: widget.background,
            shape: BoxShape.circle,
            border: Border.all(color: widget.border),
          ),
          child: Icon(widget.icon, color: widget.foreground, size: 17.sp),
        ),
      ),
    );
  }
}

// =============================================================================
// ACTION BUTTON
// =============================================================================

class _ActionButton extends StatefulWidget {
  final String label;
  final Color surface;
  final Color primary;
  final Color divider;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.surface,
    required this.primary,
    required this.divider,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
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

        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? .96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: widget.surface,
            borderRadius: BorderRadius.circular(17.r),
            border: Border.all(color: widget.divider),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.googleSansFlex(
              fontSize: 8.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: .9,
              color: widget.primary,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// LOADING CARD
// =============================================================================

class _LoadingCard extends StatefulWidget {
  final Color surface;
  final Color divider;
  final Color accent;

  const _LoadingCard({
    required this.surface,
    required this.divider,
    required this.accent,
  });

  @override
  State<_LoadingCard> createState() => _LoadingCardState();
}

class _LoadingCardState extends State<_LoadingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = .45 + (_controller.value * .4);

        return AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 80),
          child: child,
        );
      },
      child: Container(
        width: 72.w,
        height: 72.w,
        decoration: BoxDecoration(
          color: widget.surface,
          borderRadius: BorderRadius.circular(27.r),
          border: Border.all(color: widget.divider),
        ),
        child: Center(
          child: SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: widget.accent,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// BOTTOM SHEET ACTION
// =============================================================================

class _BottomSheetAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BottomSheetAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_BottomSheetAction> createState() => _BottomSheetActionState();
}

class _BottomSheetActionState extends State<_BottomSheetAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(bottom: 5.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: _pressed ? widget.color.withOpacity(.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(17.r),
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: widget.color, size: 18.sp),
            SizedBox(width: 12.w),
            Text(
              widget.label,
              style: GoogleFonts.googleSansFlex(
                color: widget.color,
                fontSize: 7.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: .75,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovingWideHeader extends StatefulWidget {
  const _MovingWideHeader();

  @override
  State<_MovingWideHeader> createState() => _MovingWideHeaderState();
}

class _MovingWideHeaderState extends State<_MovingWideHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _text(Color primary) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        6,
        (index) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'WIDE',
              style: GoogleFonts.bebasNeue(
                color: primary,
                fontSize: 72.sp,
                fontWeight: FontWeight.w400,
                height: .85,
                letterSpacing: .5,
              ),
            ),
            SizedBox(width: 18.w),
            Text(
              '✱',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                color: const Color(0xFF79B85B),
                fontSize: 42.sp,
                height: .8,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(width: 18.w),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return SizedBox(
      height: 105.h,
      width: double.infinity,
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  child: _text(primary),
                  builder: (context, child) {
                    final screenWidth = constraints.maxWidth;

                    return Positioned(
                      left: -screenWidth * _controller.value,
                      top: 12.h,
                      child: child!,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
