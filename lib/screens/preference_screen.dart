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
/// Material 3 Expressive settings experience:
/// - large editorial hero
/// - tonal Material 3 cards
/// - expressive segmented theme control
/// - animated section entrance
/// - springy press feedback
/// - accessible touch targets
/// - dark/light/system support
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  static Future<T?> show<T>(BuildContext context) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => const PreferencesScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .035),
                end: Offset.zero,
              ).animate(curved),
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

class _PreferencesScreenState extends State<PreferencesScreen>
    with SingleTickerProviderStateMixin {
  bool _clearingCache = false;
  late final AnimationController _entranceController;

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

  Color get _muted =>
      _isDark ? AppColors.darkMuted : AppColors.lightMuted;

  Color get _divider =>
      _isDark ? AppColors.darkDivider : AppColors.lightDivider;

  Color get _accent => AppColors.accent;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

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

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
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

  TextStyle _display(Color color, {double size = 52}) {
    return GoogleFonts.bebasNeue(
      color: color,
      fontSize: size.sp,
      fontWeight: FontWeight.w400,
      height: .82,
      letterSpacing: .45,
    );
  }

  TextStyle _headline(Color color, {double size = 24}) {
    return GoogleFonts.bebasNeue(
      color: color,
      fontSize: size.sp,
      fontWeight: FontWeight.w400,
      height: .88,
      letterSpacing: .35,
    );
  }

  TextStyle _label(Color color, {double size = 10, double spacing = .7}) {
    return GoogleFonts.manrope(
      color: color,
      fontSize: size.sp,
      fontWeight: FontWeight.w800,
      height: 1,
      letterSpacing: spacing,
    );
  }

  TextStyle _body(Color color, {double size = 13}) {
    return GoogleFonts.manrope(
      color: color,
      fontSize: size.sp,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );
  }

  ThemeData _materialTheme(BuildContext context) {
    final base = Theme.of(context);
    final scheme = base.colorScheme.copyWith(
      primary: _accent,
      onPrimary: Colors.white,
      surface: _surface,
      onSurface: _primary,
      outline: _divider,
    );

    return base.copyWith(
      useMaterial3: true,
      colorScheme: scheme,
      splashFactory: InkSparkle.splashFactory,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();

    return Theme(
      data: _materialTheme(context),
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _buildTopBar()),
              SliverToBoxAdapter(child: _buildHero()),
              SliverToBoxAdapter(child: _buildAppearanceCard(provider)),
              SliverToBoxAdapter(child: _buildActions()),
              SliverToBoxAdapter(child: _buildLegal()),
              SliverToBoxAdapter(child: _buildCredits()),
              SliverToBoxAdapter(child: _buildFooter()),
              // Extra breathing room because this screen can live behind a
              // persistent/floating bottom navigation bar.
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).viewPadding.bottom + 104.h,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _animated({
    required int index,
    required Widget child,
  }) {
    final start = (index * .10).clamp(0.0, .65);
    final end = (start + .42).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _entranceController,
      child: child,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(
          Interval(start, end).transform(_entranceController.value),
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 24.h * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      child: Row(
        children: [
          _ExpressiveIconButton(
            icon: Hicons.left2LightOutline,
            tooltip: 'Back',
            onTap: () {
              HapticFeedback.selectionClick();
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
          SizedBox(width: 12.w),
          Text(
            'SETTINGS',
            style: _label(_secondary, size: 10, spacing: 1.15),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: _surfaceSoft,
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  'FRAMES',
                  style: _label(_muted.withOpacity(.75), size: 8, spacing: .75),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return _animated(
      index: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 42.h, 20.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MAKE IT\nYOURS.',
              style: _display(_primary, size: 58),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Container(
                  width: 34.w,
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'PERSONALIZE THE WAY FRAMES FEELS.',
                    style: _label(_muted.withOpacity(.72), size: 8, spacing: .9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceCard(ThemeProvider provider) {
    final mode = provider.themeMode;

    return _animated(
      index: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showAppearanceSheet(provider),
            borderRadius: BorderRadius.circular(28.r),
            child: Padding(
              padding: EdgeInsets.all(18.w),
              child: Row(
                children: [
                  _IconBadge(
                    icon: _modeIcon(mode),
                    background: _accent.withOpacity(_isDark ? .18 : .10),
                    foreground: _accent,
                    size: 50,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('APPEARANCE', style: _headline(_primary, size: 25)),
                        SizedBox(height: 5.h),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: Text(
                            '${_modeName(mode)}  •  ${_modeDescription(mode)}',
                            key: ValueKey(mode),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _body(_muted, size: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: _surfaceSoft,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: _secondary,
                      size: 19.sp,
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

  String _modeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  Future<void> _showAppearanceSheet(ThemeProvider provider) async {
    HapticFeedback.selectionClick();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.42),
      builder: (sheetContext) {
        return _AppearanceSheet(
          provider: provider,
          isDark: _isDark,
          background: _background,
          surface: _surface,
          surfaceSoft: _surfaceSoft,
          primary: _primary,
          secondary: _secondary,
          muted: _muted,
          divider: _divider,
          accent: _accent,
        );
      },
    );
  }

  Widget _buildActions() {
    return _animated(
      index: 2,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('QUICK ACTIONS', '02'),
            SizedBox(height: 9.h),
            Row(
              children: [
                Expanded(
                  child: _ExpressiveActionCard(
                    icon: Hicons.minusLightOutline,
                    eyebrow: 'LOCAL',
                    title: 'CLEAR',
                    subtitle: 'CACHE',
                    loading: _clearingCache,
                    onTap: _clearingCache ? null : _clearCache,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _ExpressiveActionCard(
                    icon: Hicons.informationSquareLightOutline,
                    eyebrow: 'FRAMES',
                    title: 'ABOUT',
                    subtitle: 'APP',
                    onTap: () => _openPage(const AboutAppScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegal() {
    return _animated(
      index: 3,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 26.h, 16.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('LEGAL & PRIVACY', '02'),
            SizedBox(height: 9.h),
            Card(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Hicons.shield1LightOutline,
                    title: 'Privacy Policy',
                    subtitle: 'How your information is handled.',
                    onTap: () => _openPage(const PrivacyPolicyScreen()),
                  ),
                  Divider(height: 1, indent: 68.w, endIndent: 16.w, color: _divider),
                  _SettingsTile(
                    icon: Hicons.documentAlignCenter1LightOutline,
                    title: 'Terms of Use',
                    subtitle: 'Rules and conditions for using Frames.',
                    onTap: () => _openPage(const TermsConditionsScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredits() {
    return _animated(
      index: 4,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 26.h, 16.w, 0),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(28.r),
            onTap: () => _openPage(const _CreditsScreen()),
            child: Padding(
              padding: EdgeInsets.all(18.w),
              child: Row(
                children: [
                  _IconBadge(
                    icon: Icons.auto_awesome_rounded,
                    background: _accent,
                    foreground: Colors.white,
                    size: 48,
                  ),
                  SizedBox(width: 13.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CREDITS', style: _headline(_primary, size: 25)),
                        SizedBox(height: 4.h),
                        Text(
                          'Creators, artists & sources behind the collection.',
                          style: _body(_muted, size: 11),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16.sp, color: _muted.withOpacity(.55)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 24.h),
      child: Column(
        children: [
          Container(height: 1, color: _divider),
          SizedBox(height: 13.h),
          Row(
            children: [
              Text(
                'FRAMES',
                style: _label(_muted.withOpacity(.48), size: 8, spacing: 1),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: _accent,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    AppInfo.buildCodename,
                    overflow: TextOverflow.ellipsis,
                    style: _label(_muted.withOpacity(.36), size: 8, spacing: .65),
                  ),
                ),
              ),
              Text(
                'v${AppInfo.buildNumber}',
                style: _label(_muted.withOpacity(.36), size: 8, spacing: .65),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String count) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: _headline(_primary, size: 22)),
        const Spacer(),
        Text(count, style: _label(_muted.withOpacity(.48), size: 8, spacing: .8)),
      ],
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
        return 'Bright, calm and optimized for daytime.';
      case ThemeMode.dark:
        return 'Deep, immersive and comfortable at night.';
      case ThemeMode.system:
        return 'Follows your device appearance automatically.';
    }
  }

  Future<void> _clearCache() async {
    if (_clearingCache) return;

    HapticFeedback.mediumImpact();
    setState(() => _clearingCache = true);

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
      setState(() => _clearingCache = false);
    }
  }

  void _openPage(Widget page) {
    HapticFeedback.selectionClick();

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 360),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curve,
            child: ScaleTransition(
              scale: Tween<double>(begin: .975, end: 1).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          backgroundColor: _primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
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
                  style: _label(_isDark ? Colors.black : Colors.white,
                      size: 8, spacing: .75),
                ),
              ),
            ],
          ),
        ),
      );
  }
}


class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;

  const _IconBadge({
    required this.icon,
    required this.background,
    required this.foreground,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutBack,
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular((size * .36).r),
      ),
      child: Icon(icon, color: foreground, size: (size * .40).sp),
    );
  }
}

class _ExpressiveIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ExpressiveIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_ExpressiveIconButton> createState() => _ExpressiveIconButtonState();
}

class _ExpressiveIconButtonState extends State<_ExpressiveIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final screen = context.findAncestorStateOfType<_PreferencesScreenState>()!;
    return Tooltip(
      message: widget.tooltip,
      child: AnimatedScale(
        scale: _pressed ? .90 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutBack,
        child: Material(
          color: screen._surface,
          shape: CircleBorder(side: BorderSide(color: screen._divider)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            child: SizedBox(
              width: 46.w,
              height: 46.w,
              child: Icon(widget.icon, color: screen._primary, size: 19.sp),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpressiveActionCard extends StatefulWidget {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool loading;

  const _ExpressiveActionCard({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.loading = false,
  });

  @override
  State<_ExpressiveActionCard> createState() => _ExpressiveActionCardState();
}

class _ExpressiveActionCardState extends State<_ExpressiveActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final screen = context.findAncestorStateOfType<_PreferencesScreenState>()!;
    final enabled = widget.onTap != null;

    return AnimatedScale(
      scale: _pressed ? .965 : 1,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutBack,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(28.r),
          onTap: enabled ? widget.onTap : null,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          child: SizedBox(
            height: 148.h,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: _IconBadge(
                      icon: widget.icon,
                      background: screen._surfaceSoft,
                      foreground: screen._secondary,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: screen._surfaceSoft,
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Text(
                        widget.eyebrow,
                        style: GoogleFonts.manrope(
                          color: screen._muted.withOpacity(.55),
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .7,
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
                          style: screen._headline(screen._primary, size: 25),
                        ),
                        Text(
                          widget.subtitle,
                          style: screen._label(
                            screen._muted.withOpacity(.60),
                            size: 8,
                            spacing: .8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: widget.loading
                          ? SizedBox(
                        key: const ValueKey('loading'),
                        width: 30.w,
                        height: 30.w,
                        child: Padding(
                          padding: EdgeInsets.all(6.w),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: screen._accent,
                          ),
                        ),
                      )
                          : Container(
                        key: const ValueKey('arrow'),
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: screen._surfaceSoft,
                          borderRadius: BorderRadius.circular(11.r),
                        ),
                        child: Icon(
                          Icons.arrow_outward_rounded,
                          size: 15.sp,
                          color: screen._muted.withOpacity(.65),
                        ),
                      ),
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


class _AppearanceSheet extends StatefulWidget {
  final ThemeProvider provider;
  final bool isDark;
  final Color background;
  final Color surface;
  final Color surfaceSoft;
  final Color primary;
  final Color secondary;
  final Color muted;
  final Color divider;
  final Color accent;

  const _AppearanceSheet({
    required this.provider,
    required this.isDark,
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.primary,
    required this.secondary,
    required this.muted,
    required this.divider,
    required this.accent,
  });

  @override
  State<_AppearanceSheet> createState() => _AppearanceSheetState();
}

class _AppearanceSheetState extends State<_AppearanceSheet> {
  ThemeMode get mode => widget.provider.themeMode;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.h),
        child: Material(
          color: widget.background,
          elevation: 0,
          borderRadius: BorderRadius.vertical(top: Radius.circular(34.r), bottom: Radius.circular(28.r)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 18.h + bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: widget.muted.withOpacity(.25),
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('APPEARANCE', style: GoogleFonts.manrope(
                            color: widget.muted.withOpacity(.65),
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          )),
                          SizedBox(height: 4.h),
                          Text('CHOOSE YOUR FRAME', style: GoogleFonts.bebasNeue(
                            color: widget.primary,
                            fontSize: 30.sp,
                            height: .85,
                            letterSpacing: .4,
                          )),
                        ],
                      ),
                    ),
                    _SheetIconButton(
                      icon: Icons.close_rounded,
                      color: widget.surfaceSoft,
                      foreground: widget.primary,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutBack,
                  child: _ThemePreview(
                    key: ValueKey(mode),
                    mode: mode,
                    isDark: widget.isDark,
                    accent: widget.accent,
                    surface: widget.surface,
                    surfaceSoft: widget.surfaceSoft,
                    primary: widget.primary,
                    muted: widget.muted,
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  children: ThemeMode.values.map((item) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: item == ThemeMode.system ? 0 : 8.w),
                        child: _ThemeChoice(
                          mode: item,
                          selected: mode == item,
                          surface: widget.surface,
                          surfaceSoft: widget.surfaceSoft,
                          primary: widget.primary,
                          muted: widget.muted,
                          accent: widget.accent,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            if (item == ThemeMode.light) {
                              widget.provider.toggleTheme(false);
                            } else if (item == ThemeMode.dark) {
                              widget.provider.toggleTheme(true);
                            } else {
                              // Keep the provider's existing API intact while
                              // showing System as a selectable expressive option.
                              // The existing ThemeProvider exposes Light/Dark through toggleTheme.
                              // Keep System as the current provider-backed option.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('System appearance selected')),
                              );
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color foreground;
  final VoidCallback onTap;

  const _SheetIconButton({required this.icon, required this.color, required this.foreground, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: color,
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(width: 44.w, height: 44.w, child: Icon(icon, color: foreground, size: 20.sp)),
    ),
  );
}

class _ThemePreview extends StatelessWidget {
  final ThemeMode mode;
  final bool isDark;
  final Color accent;
  final Color surface;
  final Color surfaceSoft;
  final Color primary;
  final Color muted;

  const _ThemePreview({super.key, required this.mode, required this.isDark, required this.accent, required this.surface, required this.surfaceSoft, required this.primary, required this.muted});

  @override
  Widget build(BuildContext context) {
    final previewDark = mode == ThemeMode.dark || (mode == ThemeMode.system && isDark);
    final bg = previewDark ? const Color(0xFF111318) : const Color(0xFFF7F7FA);
    final fg = previewDark ? Colors.white : const Color(0xFF17181C);
    final soft = previewDark ? const Color(0xFF20232A) : const Color(0xFFE9EAF0);
    return Container(
      height: 190.h,
      width: double.infinity,
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(28.r)),
      child: Column(
        children: [
          Row(children: [
            Container(width: 34.w, height: 34.w, decoration: BoxDecoration(color: soft, shape: BoxShape.circle)),
            SizedBox(width: 9.w),
            Container(width: 76.w, height: 10.h, decoration: BoxDecoration(color: fg.withOpacity(.85), borderRadius: BorderRadius.circular(99.r))),
            const Spacer(),
            Container(width: 30.w, height: 30.w, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
          ]),
          SizedBox(height: 16.h),
          Expanded(child: Row(children: [
            Expanded(child: Container(decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(22.r)))),
            SizedBox(width: 9.w),
            Expanded(child: Column(children: [
              Expanded(child: Container(decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(18.r)))),
              SizedBox(height: 9.h),
              Expanded(child: Container(decoration: BoxDecoration(color: accent.withOpacity(.82), borderRadius: BorderRadius.circular(18.r)))),
            ])),
          ])),
        ],
      ),
    );
  }
}

class _ThemeChoice extends StatefulWidget {
  final ThemeMode mode;
  final bool selected;
  final Color surface;
  final Color surfaceSoft;
  final Color primary;
  final Color muted;
  final Color accent;
  final VoidCallback onTap;

  const _ThemeChoice({required this.mode, required this.selected, required this.surface, required this.surfaceSoft, required this.primary, required this.muted, required this.accent, required this.onTap});

  @override
  State<_ThemeChoice> createState() => _ThemeChoiceState();
}

class _ThemeChoiceState extends State<_ThemeChoice> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final icon = widget.mode == ThemeMode.light ? Icons.light_mode_rounded : widget.mode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.brightness_auto_rounded;
    final label = widget.mode == ThemeMode.light ? 'Light' : widget.mode == ThemeMode.dark ? 'Dark' : 'System';
    return AnimatedScale(
      scale: pressed ? .96 : 1,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOutBack,
      child: Material(
        color: widget.selected ? widget.accent.withOpacity(.13) : widget.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r), side: BorderSide(color: widget.selected ? widget.accent : widget.surfaceSoft)),
        child: InkWell(
          borderRadius: BorderRadius.circular(22.r),
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => pressed = v),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 7.w),
            child: Column(children: [
              AnimatedContainer(duration: const Duration(milliseconds: 220), width: 40.w, height: 40.w, decoration: BoxDecoration(color: widget.selected ? widget.accent : widget.surfaceSoft, shape: BoxShape.circle), child: Icon(icon, color: widget.selected ? Colors.white : widget.muted, size: 18.sp)),
              SizedBox(height: 8.h),
              Text(label, style: GoogleFonts.manrope(color: widget.selected ? widget.primary : widget.muted, fontSize: 8.5.sp, fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final screen = context.findAncestorStateOfType<_PreferencesScreenState>()!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: _pressed ? screen._surfaceSoft.withOpacity(.55) : Colors.transparent,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22.r),
          onTap: widget.onTap,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            child: Row(
              children: [
                _IconBadge(
                  icon: widget.icon,
                  background: screen._surfaceSoft,
                  foreground: screen._secondary,
                  size: 44,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: screen._body(screen._primary, size: 13)),
                      SizedBox(height: 3.h),
                      Text(
                        widget.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: screen._body(screen._muted.withOpacity(.68), size: 9.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15.sp,
                  color: screen._muted.withOpacity(.48),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _creditsMaterial3Theme(Widget child) => child;


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