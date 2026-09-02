import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/privacy_policy.dart';
import 'package:dotty/screens/terms_condition.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../Provider/theme_provider.dart';
import '../Provider/version_provider.dart';
import 'about_Screen.dart';

/// FRAMES — Preferences
///
/// Bento / boxy editorial UI inspired by the supplied reference:
/// - 2-column asymmetric grid
/// - large rounded rectangular cards
/// - soft translucent-looking surfaces
/// - compact category pills
/// - oversized typography
/// - minimal metadata
/// - subtle press animations
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  static Future<T?> show<T>(BuildContext context) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => const PreferencesScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .025),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _clearingCache = false;

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _background =>
      _isDark ? AppColors.darkBackground : AppColors.lightBackground;

  Color get _surface =>
      _isDark ? AppColors.darkSurface : AppColors.lightSurface;

  Color get _surfaceSoft =>
      _isDark
          ? AppColors.darkSurfaceSoft
          : AppColors.lightSurfaceSoft;

  Color get _primary =>
      _isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

  Color get _secondary =>
      _isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

  Color get _muted =>
      _isDark ? AppColors.darkMuted : AppColors.lightMuted;

  Color get _divider =>
      _isDark ? AppColors.darkDivider : AppColors.lightDivider;

  Color get _accent => AppColors.accent;

  TextStyle _heroText({
    required Color color,
    double size = 50,
  }) {
    return GoogleFonts.bebasNeue(
      color: color,
      fontSize: size.sp,
      fontWeight: FontWeight.w400,
      height: .80,
      letterSpacing: .55,
    );
  }

  TextStyle _titleText({
    required Color color,
    double size = 20,
  }) {
    return GoogleFonts.bebasNeue(
      color: color,
      fontSize: size.sp,
      fontWeight: FontWeight.w400,
      height: .88,
      letterSpacing: .45,
    );
  }

  TextStyle _label({
    required Color color,
    double size = 6.5,
    double spacing = 1,
  }) {
    return GoogleFonts.manrope(
      color: color,
      fontSize: size.sp,
      fontWeight: FontWeight.w800,
      height: 1,
      letterSpacing: spacing,
    );
  }

  TextStyle _body({
    required Color color,
    double size = 8,
    FontWeight weight = FontWeight.w500,
  }) {
    return GoogleFonts.manrope(
      color: color,
      fontSize: size.sp,
      fontWeight: weight,
      height: 1.35,
      letterSpacing: .02,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateSystemUI();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateSystemUI();
    });
  }

  void _updateSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _background,
        statusBarIconBrightness:
        _isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness:
        _isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        top: true,
        bottom: true,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildHero()),
            SliverToBoxAdapter(child: _buildFilters()),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: _buildBentoGrid(provider),
              ),
            ),
            SliverToBoxAdapter(child: _buildFooter()),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
      child: Row(
        children: [
          _RoundButton(
            icon: Hicons.left2LightOutline,
            onTap: () {
              HapticFeedback.selectionClick();

              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              'FRAMES',
              style: _label(
                color: _secondary,
                size: 6.2,
                spacing: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // HERO
  // ===========================================================================

  Widget _buildHero() {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 34.h, 18.w, 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BEHIND THE \nFRAME',
            style: _heroText(
              color: _primary,
              size: 48,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                width: 26.w,
                height: 2.h,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'MAKE FRAMES FEEL LIKE YOURS.',
                style: _label(
                  color: _muted.withOpacity(.72),
                  size: 5.7,
                  spacing: .85,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FILTER PILLS
  // ===========================================================================

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 14.h),
      child: Row(
        children: [
          _FilterPill(
            label: 'APPEARANCE',
            selected: true,
            accent: _accent,
            primary: _primary,
            surface: _surface,
            divider: _divider,
          ),
          SizedBox(width: 7.w),
          _FilterPill(
            label: 'LIBRARY',
            selected: false,
            accent: _accent,
            primary: _primary,
            surface: _surface,
            divider: _divider,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BENTO GRID
  // ===========================================================================

  Widget _buildBentoGrid(ThemeProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 8.w;
        final columnWidth = (constraints.maxWidth - gap) / 2;

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: columnWidth,
                  child: _buildThemeBentoCard(provider),
                ),
                SizedBox(width: gap),
                SizedBox(
                  width: columnWidth,
                  child: Column(
                    children: [
                      _BentoActionCard(
                        height: 118.h,
                        icon: Hicons.minusLightOutline,
                        eyebrow: 'LOCAL',
                        title: 'CLEAR',
                        subtitle: 'CACHE',
                        loading: _clearingCache,
                        onTap:
                        _clearingCache ? null : _clearCache,
                        isDark: _isDark,
                      ),
                      SizedBox(height: gap),
                      _BentoActionCard(
                        height: 118.h,
                        icon: Hicons.informationSquareLightOutline,
                        eyebrow: 'FRAMES',
                        title: 'ABOUT',
                        subtitle: 'APP',
                        onTap: () {
                          _openPage(const AboutAppScreen());
                        },
                        isDark: _isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),
            Row(
              children: [
                Expanded(
                  child: _BentoActionCard(
                    height: 112.h,
                    icon: Hicons.shield1LightOutline,
                    eyebrow: 'LEGAL',
                    title: 'PRIVACY',
                    subtitle: 'POLICY',
                    onTap: () {
                      _openPage(const PrivacyPolicyScreen());
                    },
                    isDark: _isDark,
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: _BentoActionCard(
                    height: 112.h,
                    icon: Hicons.documentAlignCenter1LightOutline,
                    eyebrow: 'LEGAL',
                    title: 'TERMS',
                    subtitle: 'USE',
                    onTap: () {
                      _openPage(const TermsConditionsScreen());
                    },
                    isDark: _isDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),
            _CreditsBentoCard(
              onTap: () {
                _openPage(const _CreditsScreen());
              },
              isDark: _isDark,
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeBentoCard(ThemeProvider provider) {
    final mode = provider.themeMode;

    return Container(
      height: 244.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: _surfaceSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _modeIcon(mode),
                  color: _primary,
                  size: 17.sp,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 7.w,
                  vertical: 5.h,
                ),
                decoration: BoxDecoration(
                  color: _surfaceSoft,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '01',
                  style: _label(
                    color: _muted.withOpacity(.6),
                    size: 5.2,
                    spacing: .7,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            'THEME',
            style: _titleText(
              color: _primary,
              size: 23,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            _modeDescription(mode),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _body(
              color: _muted,
              size: 7,
            ),
          ),
          SizedBox(height: 11.h),
          Row(
            children: [
              _MiniThemeButton(
                icon: Icons.light_mode_rounded,
                selected: mode == ThemeMode.light,
                isDark: _isDark,
                onTap: () {
                  HapticFeedback.selectionClick();
                  provider.toggleTheme(false);
                },
              ),
              SizedBox(width: 5.w),
              _MiniThemeButton(
                icon: Icons.dark_mode_rounded,
                selected: mode == ThemeMode.dark,
                isDark: _isDark,
                onTap: () {
                  HapticFeedback.selectionClick();
                  provider.toggleTheme(true);
                },
              ),
              SizedBox(width: 5.w),
              _MiniThemeButton(
                icon: Icons.brightness_auto_rounded,
                selected: mode == ThemeMode.system,
                isDark: _isDark,
                onTap: () {
                  HapticFeedback.selectionClick();
                  _showSystemMessage();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _modeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }

  String _modeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Bright and clean. A softer frame for daytime.';
      case ThemeMode.dark:
        return 'Deep and immersive. Designed for low light.';
      case ThemeMode.system:
        return 'Automatically follows your device appearance.';
    }
  }

  void _showSystemMessage() {
    _showSnackBar('AUTO FOLLOWS YOUR DEVICE');
  }

  // ===========================================================================
  // CACHE
  // ===========================================================================

  Future<void> _clearCache() async {
    if (_clearingCache) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _clearingCache = true;
    });

    try {
      await DefaultCacheManager().emptyCache();

      if (!mounted) return;

      HapticFeedback.selectionClick();
      _showSnackBar('CACHE CLEARED');
    } catch (error) {
      debugPrint('Cache error: $error');

      if (!mounted) return;

      _showSnackBar('COULD NOT CLEAR CACHE');
    } finally {
      if (!mounted) return;

      setState(() {
        _clearingCache = false;
      });
    }
  }

  // ===========================================================================
  // NAVIGATION
  // ===========================================================================

  void _openPage(Widget page) {
    HapticFeedback.selectionClick();

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 240),
        reverseTransitionDuration:
        const Duration(milliseconds: 190),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .018),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // SNACKBAR
  // ===========================================================================

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _surface,
          elevation: 0,
          margin: EdgeInsets.fromLTRB(
            14.w,
            0,
            14.w,
            14.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
            side: BorderSide(color: _divider),
          ),
          content: Row(
            children: [
              Container(
                width: 7.w,
                height: 7.w,
                decoration: BoxDecoration(
                  color: _accent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Text(
                  message,
                  style: _label(
                    color: _primary,
                    size: 6,
                    spacing: .8,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ===========================================================================
  // FOOTER
  // ===========================================================================

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 24.h, 18.w, 22.h),
      child: Column(
        children: [
          Container(
            height: 1,
            color: _divider,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                'FRAMES',
                style: _label(
                  color: _muted.withOpacity(.52),
                  size: 5.7,
                ),
              ),
              SizedBox(width: 7.w),
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: _accent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  AppInfo.buildCodename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _label(
                    color: _muted.withOpacity(.4),
                    size: 5.7,
                    spacing: .65,
                  ),
                ),
              ),
              Text(
                'v${AppInfo.buildNumber}',
                style: _label(
                  color: _muted.withOpacity(.4),
                  size: 5.7,
                  spacing: .65,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FILTER PILL
// =============================================================================

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final Color primary;
  final Color surface;
  final Color divider;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.accent,
    required this.primary,
    required this.surface,
    required this.divider,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        horizontal: 13.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: selected
            ? primary
            : surface,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(
          color: selected ? primary : divider,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: selected
              ? Theme.of(context).scaffoldBackgroundColor
              : primary,
          fontSize: 5.7.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: .75,
          height: 1,
        ),
      ),
    );
  }
}

// =============================================================================
// MINI THEME BUTTON
// =============================================================================

class _MiniThemeButton extends StatefulWidget {
  final IconData icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _MiniThemeButton({
    required this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_MiniThemeButton> createState() => _MiniThemeButtonState();
}

class _MiniThemeButtonState extends State<_MiniThemeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent;

    final surface = widget.isDark
        ? AppColors.darkSurfaceSoft
        : AppColors.lightSurfaceSoft;

    final primary = widget.isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final divider = widget.isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? .92 : 1,
          duration: const Duration(milliseconds: 110),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 43.w,
            decoration: BoxDecoration(
              color: widget.selected
                  ? accent.withOpacity(widget.isDark ? .16 : .10)
                  : surface,
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(
                color: widget.selected
                    ? accent.withOpacity(.4)
                    : divider,
              ),
            ),
            child: Icon(
              widget.icon,
              color:
              widget.selected ? accent : primary.withOpacity(.7),
              size: 16.sp,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// BENTO ACTION CARD
// =============================================================================

class _BentoActionCard extends StatefulWidget {
  final double height;
  final IconData icon;
  final String eyebrow;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool loading;
  final bool isDark;

  const _BentoActionCard({
    required this.height,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    this.loading = false,
  });

  @override
  State<_BentoActionCard> createState() =>
      _BentoActionCardState();
}

class _BentoActionCardState extends State<_BentoActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final surface = widget.isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final soft = widget.isDark
        ? AppColors.darkSurfaceSoft
        : AppColors.lightSurfaceSoft;

    final primary = widget.isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final secondary = widget.isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final muted = widget.isDark
        ? AppColors.darkMuted
        : AppColors.lightMuted;

    final divider = widget.isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

    final enabled = widget.onTap != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled
          ? (_) => setState(() => _pressed = true)
          : null,
      onTapCancel: enabled
          ? () => setState(() => _pressed = false)
          : null,
      onTapUp: enabled
          ? (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        widget.onTap!();
      }
          : null,
      child: AnimatedScale(
        scale: _pressed ? .965 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: widget.height,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(26.r),
            border: Border.all(color: divider),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 39.w,
                  height: 39.w,
                  decoration: BoxDecoration(
                    color: soft,
                    shape: BoxShape.circle,
                  ),
                  child: widget.loading
                      ? Padding(
                    padding: EdgeInsets.all(11.w),
                    child: CircularProgressIndicator(
                      strokeWidth: 1.4,
                      color: AppColors.accent,
                    ),
                  )
                      : Icon(
                    widget.icon,
                    color: secondary,
                    size: 17.sp,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 7.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: soft,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    widget.eyebrow,
                    style: GoogleFonts.manrope(
                      color: muted.withOpacity(.58),
                      fontSize: 4.8.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .65,
                      height: 1,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.bebasNeue(
                        color: primary,
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w400,
                        height: .84,
                        letterSpacing: .4,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: muted.withOpacity(.62),
                        fontSize: 5.1.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .75,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    color: soft,
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Icon(
                    Icons.arrow_outward_rounded,
                    color: muted.withOpacity(.6),
                    size: 12.sp,
                  ),
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
// CREDITS BENTO CARD
// =============================================================================

class _CreditsBentoCard extends StatefulWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _CreditsBentoCard({
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_CreditsBentoCard> createState() =>
      _CreditsBentoCardState();
}

class _CreditsBentoCardState extends State<_CreditsBentoCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  late final AnimationController _shineController;

  @override
  void initState() {
    super.initState();

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = widget.isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final soft = widget.isDark
        ? AppColors.darkSurfaceSoft
        : AppColors.lightSurfaceSoft;

    final primary = widget.isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final secondary = widget.isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final muted = widget.isDark
        ? AppColors.darkMuted
        : AppColors.lightMuted;

    final divider = widget.isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
      },
      onTapCancel: () {
        setState(() => _pressed = false);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);

        HapticFeedback.selectionClick();

        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? .975 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 154.h,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: divider,
            ),
          ),
          child: Stack(
            children: [
              // ---------------------------------------------------------
              // SUBTLE ANIMATED LIGHT
              // ---------------------------------------------------------

              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shineController,
                  builder: (context, child) {
                    final value =
                        _shineController.value;

                    return IgnorePointer(
                      child: Opacity(
                        opacity: .035,
                        child: Align(
                          alignment: Alignment(
                            -1.5 + (value * 3),
                            0,
                          ),
                          child: Container(
                            width: 70.w,
                            height: 220.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.accent,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ---------------------------------------------------------
              // CONTENT
              // ---------------------------------------------------------

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // DOTSTUDIOS MARK
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: soft,
                          borderRadius:
                          BorderRadius.circular(15.r),
                        ),
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 18.w,
                                height: 18.w,
                                decoration: BoxDecoration(
                                  color:
                                  AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 11.sp,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 10.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DOTSTUDIOS',
                              style:
                              GoogleFonts.bebasNeue(
                                color: primary,
                                fontSize: 22.sp,
                                height: .85,
                                letterSpacing: .8,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'WALLPAPER + GRAPHIC CREDITS',
                              style: GoogleFonts.manrope(
                                color:
                                muted.withOpacity(.62),
                                fontSize: 5.sp,
                                fontWeight:
                                FontWeight.w800,
                                letterSpacing: .7,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // OPEN BUTTON
                      Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          color: soft,
                          borderRadius:
                          BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.arrow_outward_rounded,
                          color:
                          muted.withOpacity(.65),
                          size: 13.sp,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // -------------------------------------------------------
                  // CREDIT TEXT
                  // -------------------------------------------------------

                  Text(
                    'THANK YOU TO THE CREATORS & SOURCES',
                    style: GoogleFonts.manrope(
                      color: secondary,
                      fontSize: 6.2.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .55,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // -------------------------------------------------------
                  // SOURCE PILLS
                  // -------------------------------------------------------

                  SizedBox(
                    height: 31.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics:
                      const BouncingScrollPhysics(),
                      children: [
                        _creditPill(
                          'Basic Apple Guy',
                          primary,
                          soft,
                        ),

                        _creditPill(
                          'Unsplash',
                          primary,
                          soft,
                        ),

                        _creditPill(
                          'Pinterest',
                          primary,
                          soft,
                        ),

                        _creditPill(
                          'Pixabay',
                          primary,
                          soft,
                        ),

                        _creditPill(
                          'Wallcee',
                          primary,
                          soft,
                        ),

                        _creditPill(
                          'WallpaperAccess',
                          primary,
                          soft,
                        ),

                        _creditPill(
                          'Graphic Creators',
                          primary,
                          soft,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _creditPill(
      String label,
      Color primary,
      Color soft,
      ) {
    return Container(
      margin: EdgeInsets.only(right: 6.w),
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 7.h,
      ),
      decoration: BoxDecoration(
        color: soft.withOpacity(.72),
        borderRadius:
        BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: GoogleFonts.manrope(
              color: primary.withOpacity(.75),
              fontSize: 5.4.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: .15,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ROUND BUTTON
// =============================================================================

class _RoundButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<_RoundButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final surface = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final primary = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final divider = isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

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
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 43.w,
          height: 43.w,
          decoration: BoxDecoration(
            color: surface,
            shape: BoxShape.circle,
            border: Border.all(color: divider),
          ),
          child: Icon(
            widget.icon,
            color: primary,
            size: 17.sp,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CREDITS SCREEN
// =============================================================================

class _CreditsScreen extends StatefulWidget {
  const _CreditsScreen();

  @override
  State<_CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<_CreditsScreen> {
  final List<_CreditSource> _wallpaperSources = [
    _CreditSource(
      name: 'Basic Apple Guy',
      description: 'Apple-inspired wallpapers & artwork',
      icon: Icons.apple_rounded,
    ),
    _CreditSource(
      name: 'Unsplash',
      description: 'Photography & visual imagery',
      icon: Icons.camera_alt_outlined,
    ),
    _CreditSource(
      name: 'Pinterest',
      description: 'Visual references & discoveries',
      icon: Icons.push_pin_outlined,
    ),
    _CreditSource(
      name: 'Pixabay',
      description: 'Free images & visual resources',
      icon: Icons.photo_library_outlined,
    ),
    _CreditSource(
      name: 'Wallcee',
      description: 'Wallpaper resources',
      icon: Icons.wallpaper_rounded,
    ),
    _CreditSource(
      name: 'WallpaperAccess',
      description: 'Desktop wallpaper resources',
      icon: Icons.desktop_windows_outlined,
    ),
    _CreditSource(
      name: 'Wallpaper Providers',
      description: 'Independent wallpaper creators',
      icon: Icons.collections_outlined,
    ),
  ];

  final List<_CreditSource> _graphicSources = [
    _CreditSource(
      name: 'Independent Artists',
      description: 'Illustrations, artwork & visual creations',
      icon: Icons.brush_outlined,
    ),
    _CreditSource(
      name: 'Photographers',
      description: 'Photography used throughout the collection',
      icon: Icons.camera_outlined,
    ),
    _CreditSource(
      name: 'Graphic Creators',
      description: 'Graphic assets & creative resources',
      icon: Icons.auto_awesome_outlined,
    ),
    _CreditSource(
      name: 'Visual Designers',
      description: 'Design inspiration & visual resources',
      icon: Icons.design_services_outlined,
    ),
  ];

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background(context),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                14.w,
                10.h,
                14.w,
                35.h,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildTopBar(context),

                    SizedBox(height: 34.h),

                    _buildHero(context),

                    SizedBox(height: 30.h),

                    _buildStudioCard(context),

                    SizedBox(height: 29.h),

                    _buildSectionHeader(
                      context,
                      'WALLPAPER SOURCES',
                      '${_wallpaperSources.length} SOURCES',
                    ),

                    SizedBox(height: 10.h),

                    ...List.generate(
                      _wallpaperSources.length,
                          (index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: 8.h,
                          ),
                          child: _CreditAnimatedEntry(
                            index: index,
                            child: _CreditSourceCard(
                              source:
                              _wallpaperSources[index],
                              isDark: _isDark(context),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 27.h),

                    _buildSectionHeader(
                      context,
                      'GRAPHIC SOURCES',
                      '${_graphicSources.length} SOURCES',
                    ),

                    SizedBox(height: 10.h),

                    ...List.generate(
                      _graphicSources.length,
                          (index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: 8.h,
                          ),
                          child: _CreditAnimatedEntry(
                            index: index +
                                _wallpaperSources.length,
                            child: _CreditSourceCard(
                              source:
                              _graphicSources[index],
                              isDark: _isDark(context),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 28.h),

                    _buildAcknowledgement(context),

                    SizedBox(height: 28.h),

                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TOP BAR
  // ===========================================================================

  Widget _buildTopBar(BuildContext context) {
    final secondary = _secondary(context);

    return Row(
      children: [
        _CreditsRoundButton(
          icon: Hicons.left2LightOutline,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.pop(context);
          },
        ),

        SizedBox(width: 10.w),

        Text(
          'CREDITS',
          style: GoogleFonts.manrope(
            color: secondary,
            fontSize: 6.5.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.15,
          ),
        ),

        const Spacer(),

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 7.h,
          ),
          decoration: BoxDecoration(
            color: _surfaceSoft(context),
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: Row(
            children: [
              Container(
                width: 5.w,
                height: 5.w,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                'DOTSTUDIOS',
                style: GoogleFonts.manrope(
                  color: _muted(context).withOpacity(.7),
                  fontSize: 5.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // HERO
  // ===========================================================================

  Widget _buildHero(BuildContext context) {
    final primary = _primary(context);
    final muted = _muted(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DOTSTUDIOS',
          style: GoogleFonts.manrope(
            color: AppColors.accent,
            fontSize: 7.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.25,
          ),
        ),

        SizedBox(height: 9.h),

        Text(
          'MADE\nWITH CARE.',
          style: GoogleFonts.bebasNeue(
            color: primary,
            fontSize: 58.sp,
            fontWeight: FontWeight.w400,
            height: .76,
            letterSpacing: .8,
          ),
        ),

        SizedBox(height: 17.h),

        Container(
          width: 31.w,
          height: 2.h,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),

        SizedBox(height: 16.h),

        Text(
          'A collection of wallpapers, photography, artwork, '
              'and visual resources brought together for a calmer '
              'and more personal screen.',
          style: GoogleFonts.manrope(
            color: muted.withOpacity(.72),
            fontSize: 9.sp,
            fontWeight: FontWeight.w500,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // STUDIO CARD
  // ===========================================================================

  Widget _buildStudioCard(BuildContext context) {
    final surface = _surface(context);
    final soft = _surfaceSoft(context);
    final primary = _primary(context);
    final secondary = _secondary(context);
    final divider = _divider(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: divider,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius:
                  BorderRadius.circular(18.r),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 21.w,
                        height: 21.w,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 12.sp,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 11.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DOTSTUDIOS',
                      style: GoogleFonts.bebasNeue(
                        color: primary,
                        fontSize: 25.sp,
                        height: .82,
                        letterSpacing: .7,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'CREATIVE WALLPAPER STUDIO',
                      style: GoogleFonts.manrope(
                        color: secondary.withOpacity(.58),
                        fontSize: 5.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 15.h),

          Container(
            height: 1,
            color: divider.withOpacity(.65),
          ),

          SizedBox(height: 14.h),

          Text(
            'This app is made possible by the creators, '
                'photographers, artists, designers, and wallpaper '
                'providers whose work helps build the visual '
                'collection.',
            style: GoogleFonts.manrope(
              color: secondary,
              fontSize: 8.sp,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION HEADER
  // ===========================================================================

  Widget _buildSectionHeader(
      BuildContext context,
      String title,
      String count,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: GoogleFonts.bebasNeue(
            color: _primary(context),
            fontSize: 24.sp,
            fontWeight: FontWeight.w400,
            height: .85,
            letterSpacing: .5,
          ),
        ),

        const Spacer(),

        Text(
          count,
          style: GoogleFonts.manrope(
            color: _muted(context).withOpacity(.5),
            fontSize: 5.2.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: .7,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // ACKNOWLEDGEMENT
  // ===========================================================================

  Widget _buildAcknowledgement(BuildContext context) {
    final surface = _surface(context);
    final soft = _surfaceSoft(context);
    final primary = _primary(context);
    final secondary = _secondary(context);
    final divider = _divider(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(27.r),
        border: Border.all(
          color: divider,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius:
                  BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.favorite_outline_rounded,
                  color: AppColors.accent,
                  size: 18.sp,
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Text(
                  'TO EVERY CREATOR',
                  style: GoogleFonts.bebasNeue(
                    color: primary,
                    fontSize: 21.sp,
                    height: .85,
                    letterSpacing: .45,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Text(
            'Thank you for making beautiful things and '
                'sharing them with the world. Your work gives '
                'these screens their personality.',
            style: GoogleFonts.manrope(
              color: secondary,
              fontSize: 8.sp,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FOOTER
  // ===========================================================================

  Widget _buildFooter(BuildContext context) {
    final muted = _muted(context);

    return Column(
      children: [
        Row(
          children: [
            Text(
              'DOTSTUDIOS',
              style: GoogleFonts.manrope(
                color: muted.withOpacity(.48),
                fontSize: 5.5.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),

            const Spacer(),

            Text(
              'v${AppInfo.buildNumber}',
              style: GoogleFonts.manrope(
                color: muted.withOpacity(.38),
                fontSize: 5.5.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: .7,
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        Text(
          'WALLPAPERS • GRAPHICS • CREATORS',
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            color: muted.withOpacity(.28),
            fontSize: 4.8.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: .9,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// CREDIT SOURCE MODEL
// =============================================================================

class _CreditSource {
  final String name;
  final String description;
  final IconData icon;

  const _CreditSource({
    required this.name,
    required this.description,
    required this.icon,
  });
}

// =============================================================================
// CREDIT SOURCE CARD
// =============================================================================

class _CreditSourceCard extends StatefulWidget {
  final _CreditSource source;
  final bool isDark;

  const _CreditSourceCard({
    required this.source,
    required this.isDark,
  });

  @override
  State<_CreditSourceCard> createState() =>
      _CreditSourceCardState();
}

class _CreditSourceCardState
    extends State<_CreditSourceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final surface = widget.isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final soft = widget.isDark
        ? AppColors.darkSurfaceSoft
        : AppColors.lightSurfaceSoft;

    final primary = widget.isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final secondary = widget.isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final divider = widget.isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
      },
      onTapCancel: () {
        setState(() => _pressed = false);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
      },
      child: AnimatedScale(
        scale: _pressed ? .985 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(11.w),
          decoration: BoxDecoration(
            color: surface,
            borderRadius:
            BorderRadius.circular(21.r),
            border: Border.all(
              color: _pressed
                  ? AppColors.accent.withOpacity(.32)
                  : divider,
            ),
          ),
          child: Row(
            children: [
              // SOURCE ICON
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 45.w,
                height: 45.w,
                decoration: BoxDecoration(
                  color: _pressed
                      ? AppColors.accent.withOpacity(.12)
                      : soft,
                  borderRadius:
                  BorderRadius.circular(15.r),
                ),
                child: Icon(
                  widget.source.icon,
                  color: _pressed
                      ? AppColors.accent
                      : secondary.withOpacity(.72),
                  size: 18.sp,
                ),
              ),

              SizedBox(width: 11.w),

              // SOURCE INFORMATION
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.source.name,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: primary,
                        fontSize: 8.2.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    Text(
                      widget.source.description,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color:
                        secondary.withOpacity(.55),
                        fontSize: 6.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // ARROW
              Container(
                width: 31.w,
                height: 31.w,
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius:
                  BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.arrow_outward_rounded,
                  color:
                  secondary.withOpacity(.48),
                  size: 13.sp,
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
// ENTRY ANIMATION
// =============================================================================

class _CreditAnimatedEntry extends StatefulWidget {
  final int index;
  final Widget child;

  const _CreditAnimatedEntry({
    required this.index,
    required this.child,
  });

  @override
  State<_CreditAnimatedEntry> createState() =>
      _CreditAnimatedEntryState();
}

class _CreditAnimatedEntryState
    extends State<_CreditAnimatedEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 480,
      ),
    );

    Future.delayed(
      Duration(
        milliseconds:
        (widget.index.clamp(0, 10)) * 45,
      ),
          () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    return AnimatedBuilder(
      animation: animation,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(
              0,
              14 * (1 - animation.value),
            ),
            child: Transform.scale(
              scale: .985 +
                  (.015 * animation.value),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// ROUND BACK BUTTON
// =============================================================================

class _CreditsRoundButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CreditsRoundButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_CreditsRoundButton> createState() =>
      _CreditsRoundButtonState();
}

class _CreditsRoundButtonState
    extends State<_CreditsRoundButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final surface = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final divider = isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

    final primary = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
      },
      onTapCancel: () {
        setState(() => _pressed = false);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? .9 : 1,
        duration: const Duration(
          milliseconds: 120,
        ),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 43.w,
          height: 43.w,
          decoration: BoxDecoration(
            color: surface,
            borderRadius:
            BorderRadius.circular(15.r),
            border: Border.all(
              color: divider,
            ),
          ),
          child: Icon(
            widget.icon,
            color: primary,
            size: 17.sp,
          ),
        ),
      ),
    );
  }
}