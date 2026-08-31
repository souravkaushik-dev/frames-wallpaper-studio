import 'dart:ui';

import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/privacy_policy.dart';
import 'package:dotty/screens/terms_condition.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../Provider/theme_provider.dart';
import '../Provider/version_provider.dart';
import 'about_Screen.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() =>
      _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambientController;

  bool _clearingCache = false;

  // ============================================================
  // THEME
  // ============================================================

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _background => _isDark
      ? AppColors.darkBackground
      : AppColors.lightBackground;

  Color get _surface => _isDark
      ? AppColors.darkSurface
      : AppColors.lightSurface;

  Color get _surfaceSoft => _isDark
      ? AppColors.darkSurfaceSoft
      : AppColors.lightSurfaceSoft;

  Color get _primary => _isDark
      ? AppColors.darkPrimary
      : AppColors.lightPrimary;

  Color get _secondary => _isDark
      ? AppColors.darkSecondary
      : AppColors.lightSecondary;

  Color get _muted => _isDark
      ? AppColors.darkMuted
      : AppColors.lightMuted;

  Color get _divider => _isDark
      ? AppColors.darkDivider
      : AppColors.lightDivider;

  Color get _accent => AppColors.accent;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateSystemUI();
    });
  }

  // ============================================================
  // SYSTEM UI
  // ============================================================

  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness:
        _isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness:
        _isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  // ============================================================
  // TYPOGRAPHY
  // ============================================================

  TextStyle _display({
    required Color color,
    double size = 48,
    FontWeight weight = FontWeight.w800,
    double letterSpacing = -2,
    double height = .95,
  }) {
    return GoogleFonts.outfit(
      color: color,
      fontSize: size.sp,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  TextStyle _body({
    required Color color,
    double size = 12,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.nunitoSans(
      color: color,
      fontSize: size.sp,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );
  }

  TextStyle _label({
    required Color color,
    double size = 8,
    FontWeight weight = FontWeight.w800,
    double letterSpacing = 1.1,
  }) {
    return GoogleFonts.nunitoSans(
      color: color,
      fontSize: size.sp,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateSystemUI();
      }
    });

    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          _buildBackground(),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // ==================================================
                // HEADER
                // ==================================================

                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),

                // ==================================================
                // CONTENT
                // ==================================================

                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        // ==================================================
                        // APPEARANCE
                        // ==================================================

                        _section('APPEARANCE'),

                        SizedBox(height: 12.h),

                        _appearanceCard(themeProvider),

                        SizedBox(height: 30.h),

                        // ==================================================
                        // WHAT'S NEW
                        // ==================================================

                        _section('WHAT\'S NEW'),

                        SizedBox(height: 12.h),

                        _WhatsNewCard(
                          version:
                          AppInfo.buildNumber.toString(),
                          codename: AppInfo.buildCodename,
                          primary: _primary,
                          secondary: _secondary,
                          surface: _surface,
                          surfaceSoft: _surfaceSoft,
                          divider: _divider,
                          accent: _accent,
                        ),

                        SizedBox(height: 30.h),

                        // ==================================================
                        // STORAGE
                        // ==================================================

                        _section('STORAGE'),

                        SizedBox(height: 12.h),

                        _settingCard(
                          index: 1,
                          icon: Hicons.minusLightOutline,
                          title: 'Clear Cache',
                          subtitle:
                          'Remove temporary wallpaper files',
                          trailing: _arrow(),
                          loading: _clearingCache,
                          onTap: _clearCache,
                        ),

                        SizedBox(height: 30.h),

                        // ==================================================
                        // INFORMATION
                        // ==================================================

                        _section('INFORMATION'),

                        SizedBox(height: 12.h),

                        _settingCard(
                          index: 2,
                          icon: Hicons
                              .informationSquareLightOutline,
                          title: 'About Frames',
                          subtitle:
                          'Discover more about the app',
                          trailing: _arrow(),
                          onTap: () {
                            _openPage(
                              const AboutAppScreen(),
                            );
                          },
                        ),

                        SizedBox(height: 12.h),

                        _settingCard(
                          index: 3,
                          icon:
                          Hicons.shield1LightOutline,
                          title: 'Privacy Policy',
                          subtitle:
                          'Understand how your data is handled',
                          trailing: _arrow(),
                          onTap: () {
                            _openPage(
                              const PrivacyPolicyScreen(),
                            );
                          },
                        ),

                        SizedBox(height: 12.h),

                        _settingCard(
                          index: 4,
                          icon: Hicons
                              .documentAlignCenter1LightOutline,
                          title: 'Terms & Conditions',
                          subtitle:
                          'Review usage guidelines and policies',
                          trailing: _arrow(),
                          onTap: () {
                            _openPage(
                              const TermsConditionsScreen(),
                            );
                          },
                        ),

                        SizedBox(height: 50.h),

                        _footer(),

                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BACKGROUND
  // ============================================================

  Widget _buildBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ambientController,
          builder: (context, child) {
            final value = Curves.easeInOut.transform(
              _ambientController.value,
            );

            return Stack(
              children: [
                Positioned(
                  top: -190.h + value * 20.h,
                  right: -190.w + value * 18.w,
                  child: _ambientBlob(
                    390.w,
                    _isDark ? .018 : .007,
                  ),
                ),

                Positioned(
                  bottom: -210.h + value * 15.h,
                  left: -190.w,
                  child: _ambientBlob(
                    360.w,
                    _isDark ? .012 : .005,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _ambientBlob(
      double size,
      double opacity,
      ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _accent.withOpacity(opacity),
      ),
    ).animate(
      onPlay: (controller) {
        controller.repeat(reverse: true);
      },
    ).blurXY(
      begin: 60,
      end: 90,
      duration: const Duration(seconds: 10),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.w,
        16.h,
        16.w,
        28.h,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _backButton(),

              SizedBox(width: 12.w),

              const _FramesMark(),

              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FRAMES',
                      style: _label(
                        color: _accent,
                        size: 7,
                        letterSpacing: 1.8,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'YOUR SPACE',
                      style: _display(
                        color: _primary,
                        size: 16,
                        weight: FontWeight.w700,
                        letterSpacing: -.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(
            duration:
            const Duration(milliseconds: 550),
          )
              .moveY(
            begin: -12,
            end: 0,
            duration:
            const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          ),

          SizedBox(height: 27.h),

          Text(
            'SETTINGS',
            style: _display(
              color: _primary,
              size: 49,
              weight: FontWeight.w800,
              letterSpacing: -2.7,
            ),
          )
              .animate()
              .fadeIn(
            delay:
            const Duration(milliseconds: 100),
            duration:
            const Duration(milliseconds: 650),
          )
              .moveY(
            begin: 25,
            end: 0,
            duration:
            const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
          ),

          SizedBox(height: 12.h),

          Text(
            'Make Frames feel like yours.',
            style: _body(
              color: _secondary,
              size: 12,
              weight: FontWeight.w600,
            ).copyWith(
              height: 1.5,
            ),
          )
              .animate()
              .fadeIn(
            delay:
            const Duration(milliseconds: 220),
            duration:
            const Duration(milliseconds: 600),
          )
              .moveY(
            begin: 12,
            end: 0,
            duration:
            const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          ),

          SizedBox(height: 18.h),

          Row(
            children: [
              _GlassChip(
                icon: Hicons.colorPickerLightOutline,
                text: 'Theme',
              ),
              SizedBox(width: 7.w),
              _GlassChip(
                icon: Icons.auto_awesome_rounded,
                text: 'Premium',
              ),
              SizedBox(width: 7.w),
            _GlassChip(
                  icon: Hicons.settingLightOutline,
                  text: AppInfo.buildCodename,
                ),
            ],
          )
              .animate()
              .fadeIn(
            delay:
            const Duration(milliseconds: 330),
            duration:
            const Duration(milliseconds: 550),
          )
              .moveY(
            begin: 10,
            end: 0,
            duration:
            const Duration(milliseconds: 550),
            curve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BACK BUTTON
  // ============================================================

  Widget _backButton() {
    return _PressableScale(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pop(context);
      },
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: _surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: _divider,
          ),
        ),
        child: Icon(
          Hicons.left2LightOutline,
          color: _primary,
          size: 18.sp,
        ),
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _section(String title) {
    return Row(
      children: [
        Container(
          width: 7.w,
          height: 7.w,
          decoration: BoxDecoration(
            color: _accent,
            shape: BoxShape.circle,
          ),
        ),

        SizedBox(width: 8.w),

        Text(
          title,
          style: _label(
            color: _secondary,
            size: 7,
            letterSpacing: 1.7,
          ),
        ),

        SizedBox(width: 10.w),

        Expanded(
          child: Container(
            height: 1,
            color: _divider,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // APPEARANCE CARD
  // ============================================================

  Widget _appearanceCard(
      ThemeProvider provider,
      ) {
    final isDark =
        provider.themeMode == ThemeMode.dark;

    final modeLabel = isDark
        ? 'Dark'
        : provider.themeMode == ThemeMode.light
        ? 'Light'
        : 'System';

    return _SettingCard(
      icon: isDark
          ? Icons.dark_mode_rounded
          : Icons.light_mode_rounded,
      title: 'Appearance',
      subtitle: 'Choose how Frames looks on your device',
      text: _primary,
      secondary: _secondary,
      isDark: _isDark,
      index: 0,
      trailing: _ThemeModePill(
        label: modeLabel,
        accent: _accent,
      ),
      onTap: () {
        HapticFeedback.selectionClick();
        _showThemeBottomSheet(provider);
      },
    );
  }

  // ============================================================
  // THEME BOTTOM SHEET
  // ============================================================

  void _showThemeBottomSheet(
      ThemeProvider provider,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.42),
      isScrollControlled: false,
      useSafeArea: true,
      builder: (sheetContext) {
        return _ThemeBottomSheet(
          provider: provider,
          isDark: _isDark,
          background: _background,
          surface: _surface,
          surfaceSoft: _surfaceSoft,
          primary: _primary,
          secondary: _secondary,
          divider: _divider,
          accent: _accent,
        );
      },
    );
  }

  // ============================================================
  // SETTING CARD
  // ============================================================

  Widget _settingCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    bool loading = false,
  }) {
    return _SettingCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      text: _primary,
      secondary: _secondary,
      isDark: _isDark,
      index: index,
      trailing: trailing,
      onTap: onTap,
      loading: loading,
    );
  }

  // ============================================================
  // ARROW
  // ============================================================

  Widget _arrow() {
    return Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(
        color: _surfaceSoft,
        shape: BoxShape.circle,
        border: Border.all(
          color: _divider,
        ),
      ),
      child: Icon(
        Hicons.right2LightOutline,
        color: _secondary,
        size: 14.sp,
      ),
    );
  }

  // ============================================================
  // CACHE
  // ============================================================

  Future<void> _clearCache() async {
    if (_clearingCache) return;

    setState(() {
      _clearingCache = true;
    });

    HapticFeedback.mediumImpact();

    try {
      await DefaultCacheManager().emptyCache();

      if (!mounted) return;

      HapticFeedback.heavyImpact();

      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _surface,
          elevation: 0,
          margin: EdgeInsets.fromLTRB(
            16.w,
            0,
            16.w,
            18.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(22.r),
            side: BorderSide(
              color: _divider,
            ),
          ),
          content: Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: _accent,
                  size: 17.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Wallpaper cache cleared',
                  style: _body(
                    color: _primary,
                    size: 11,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint('Cache error: $e');
    } finally {
      if (!mounted) return;

      setState(() {
        _clearingCache = false;
      });
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _openPage(Widget page) {
    HapticFeedback.selectionClick();

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration:
        const Duration(milliseconds: 520),
        reverseTransitionDuration:
        const Duration(milliseconds: 380),
        pageBuilder:
            (
            context,
            animation,
            secondaryAnimation,
            ) =>
        page,
        transitionsBuilder:
            (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
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
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: .985,
                  end: 1,
                ).animate(curve),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _footer() {
    return Center(
      child: Column(
        children: [
          const _FramesMark(),

          SizedBox(height: 12.h),

          Text(
            'FRAMES',
            style: _display(
              color: _primary,
              size: 18,
              weight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            'CRAFTED FOR YOUR SCREEN',
            style: _label(
              color: _secondary.withOpacity(.5),
              size: 6.5,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
      duration:
      const Duration(milliseconds: 650),
    )
        .moveY(
      begin: 10,
      end: 0,
      duration:
      const Duration(milliseconds: 650),
    );
  }
}

// ==================================================================
// THEME MODE PILL
// ==================================================================

class _ThemeModePill extends StatelessWidget {
  final String label;
  final Color accent;

  const _ThemeModePill({
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: accent.withOpacity(.09),
        borderRadius:
        BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            label == 'Dark'
                ? Icons.dark_mode_rounded
                : label == 'Light'
                ? Icons.light_mode_rounded
                : Icons.settings_suggest_rounded,
            color: accent,
            size: 13.sp,
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              color: accent,
              fontSize: 8.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// PREMIUM THEME BOTTOM SHEET
// ==================================================================

class _ThemeBottomSheet extends StatefulWidget {
  final ThemeProvider provider;
  final bool isDark;

  final Color background;
  final Color surface;
  final Color surfaceSoft;
  final Color primary;
  final Color secondary;
  final Color divider;
  final Color accent;

  const _ThemeBottomSheet({
    required this.provider,
    required this.isDark,
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.primary,
    required this.secondary,
    required this.divider,
    required this.accent,
  });

  @override
  State<_ThemeBottomSheet> createState() =>
      _ThemeBottomSheetState();
}

class _ThemeBottomSheetState
    extends State<_ThemeBottomSheet> {
  late ThemeMode _selected;

  @override
  void initState() {
    super.initState();

    _selected = widget.provider.themeMode;
  }

  void _selectTheme(ThemeMode mode) {
    HapticFeedback.selectionClick();

    setState(() {
      _selected = mode;
    });

    if (mode == ThemeMode.dark) {
      widget.provider.toggleTheme(true);
    } else if (mode == ThemeMode.light) {
      widget.provider.toggleTheme(false);
    }

    Future.delayed(
      const Duration(milliseconds: 260),
          () {
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ============================================================
        // SOFT GLOW
        // ============================================================

        Positioned(
          top: -100.h,
          right: -80.w,
          child: IgnorePointer(
            child: Container(
              width: 230.w,
              height: 230.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.accent.withOpacity(.07),
              ),
            )
                .animate(
              onPlay: (controller) {
                controller.repeat(reverse: true);
              },
            )
                .blurXY(
              begin: 50,
              end: 75,
              duration:
              const Duration(seconds: 5),
            ),
          ),
        ),

        // ============================================================
        // SHEET
        // ============================================================

        Container(
          decoration: BoxDecoration(
            color: widget.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(38.r),
            ),
            border: Border(
              top: BorderSide(
                color: widget.primary.withOpacity(.07),
              ),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            18.w,
            10.h,
            18.w,
            18.h,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ======================================================
                // HANDLE
                // ======================================================

                Container(
                  width: 44.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: widget.primary
                        .withOpacity(.12),
                    borderRadius:
                    BorderRadius.circular(50.r),
                  ),
                ),

                SizedBox(height: 22.h),

                // ======================================================
                // HEADER
                // ======================================================

                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52.w,
                      height: 52.w,
                      decoration: BoxDecoration(
                        color: widget.accent
                            .withOpacity(.10),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.accent
                              .withOpacity(.12),
                        ),
                      ),
                      child: Icon(
                        Icons.palette_rounded,
                        color: widget.accent,
                        size: 22.sp,
                      ),
                    ),

                    SizedBox(width: 13.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appearance',
                            style: GoogleFonts.outfit(
                              color: widget.primary,
                              fontSize: 21.sp,
                              fontWeight:
                              FontWeight.w700,
                              letterSpacing: -.7,
                            ),
                          ),

                          SizedBox(height: 3.h),

                          Text(
                            'Shape the mood of your space',
                            style:
                            GoogleFonts.nunitoSans(
                              color:
                              widget.secondary,
                              fontSize: 10.sp,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // CLOSE

                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: widget.surfaceSoft,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.divider,
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: widget.secondary,
                          size: 17.sp,
                        ),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(
                  duration:
                  const Duration(
                    milliseconds: 350,
                  ),
                )
                    .moveY(
                  begin: 10,
                  end: 0,
                  duration:
                  const Duration(
                    milliseconds: 400,
                  ),
                  curve:
                  Curves.easeOutCubic,
                ),

                SizedBox(height: 20.h),

                // ======================================================
                // CURRENT MODE PREVIEW
                // ======================================================

                _ThemePreview(
                  mode: _selected,
                  accent: widget.accent,
                  primary: widget.primary,
                  secondary: widget.secondary,
                  surfaceSoft:
                  widget.surfaceSoft,
                )
                    .animate()
                    .fadeIn(
                  delay:
                  const Duration(
                    milliseconds: 100,
                  ),
                  duration:
                  const Duration(
                    milliseconds: 450,
                  ),
                )
                    .scale(
                  begin:
                  const Offset(.97, .97),
                  end:
                  const Offset(1, 1),
                  duration:
                  const Duration(
                    milliseconds: 500,
                  ),
                  curve:
                  Curves.easeOutCubic,
                ),

                SizedBox(height: 18.h),

                // ======================================================
                // OPTIONS
                // ======================================================

                Row(
                  children: [
                    Expanded(
                      child: _ThemeOption(
                        icon:
                        Icons.light_mode_rounded,
                        title: 'Light',
                        selected:
                        _selected ==
                            ThemeMode.light,
                        accent: widget.accent,
                        primary:
                        widget.primary,
                        secondary:
                        widget.secondary,
                        surfaceSoft:
                        widget.surfaceSoft,
                        divider:
                        widget.divider,
                        onTap: () {
                          _selectTheme(
                            ThemeMode.light,
                          );
                        },
                      ),
                    ),

                    SizedBox(width: 8.w),

                    Expanded(
                      child: _ThemeOption(
                        icon:
                        Icons.dark_mode_rounded,
                        title: 'Dark',
                        selected:
                        _selected ==
                            ThemeMode.dark,
                        accent: widget.accent,
                        primary:
                        widget.primary,
                        secondary:
                        widget.secondary,
                        surfaceSoft:
                        widget.surfaceSoft,
                        divider:
                        widget.divider,
                        onTap: () {
                          _selectTheme(
                            ThemeMode.dark,
                          );
                        },
                      ),
                    ),

                    SizedBox(width: 8.w),

                    Expanded(
                      child: _ThemeOption(
                        icon: Icons
                            .settings_suggest_rounded,
                        title: 'System',
                        selected:
                        _selected ==
                            ThemeMode.system,
                        accent: widget.accent,
                        primary:
                        widget.primary,
                        secondary:
                        widget.secondary,
                        surfaceSoft:
                        widget.surfaceSoft,
                        divider:
                        widget.divider,
                        onTap: () {
                          _selectTheme(
                            ThemeMode.system,
                          );
                        },
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(
                  delay:
                  const Duration(
                    milliseconds: 180,
                  ),
                  duration:
                  const Duration(
                    milliseconds: 450,
                  ),
                )
                    .moveY(
                  begin: 12,
                  end: 0,
                  duration:
                  const Duration(
                    milliseconds: 500,
                  ),
                  curve:
                  Curves.easeOutCubic,
                ),

                SizedBox(height: 14.h),

                // ======================================================
                // FOOTER HINT
                // ======================================================

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 11.h,
                  ),
                  decoration: BoxDecoration(
                    color: widget.primary
                        .withOpacity(.025),
                    borderRadius:
                    BorderRadius.circular(18.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .touch_app_rounded,
                        color: widget.secondary
                            .withOpacity(.55),
                        size: 14.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Your choice changes the entire Frames atmosphere.',
                          style:
                          GoogleFonts.nunitoSans(
                            color: widget.secondary
                                .withOpacity(.65),
                            fontSize: 8.sp,
                            fontWeight:
                            FontWeight.w600,
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
      ],
    )
        .animate()
        .fadeIn(
      duration:
      const Duration(milliseconds: 250),
    )
        .moveY(
      begin: 40,
      end: 0,
      duration:
      const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }
}

// ==================================================================
// THEME PREVIEW
// ==================================================================

class _ThemePreview extends StatelessWidget {
  final ThemeMode mode;
  final Color accent;
  final Color primary;
  final Color secondary;
  final Color surfaceSoft;

  const _ThemePreview({
    required this.mode,
    required this.accent,
    required this.primary,
    required this.secondary,
    required this.surfaceSoft,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = mode == ThemeMode.dark;

    final previewBackground = isDark
        ? const Color(0xFF151515)
        : const Color(0xFFF4F4F2);

    final previewCard = isDark
        ? const Color(0xFF202020)
        : Colors.white;

    final previewText = isDark
        ? Colors.white
        : const Color(0xFF171717);

    return AnimatedContainer(
      duration:
      const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      height: 116.h,
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: previewBackground,
        borderRadius:
        BorderRadius.circular(27.r),
        border: Border.all(
          color: primary.withOpacity(.07),
        ),
      ),
      child: Stack(
        children: [
          // MINI TOP BAR

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                Container(
                  width: 27.w,
                  height: 27.w,
                  decoration: BoxDecoration(
                    color: previewCard,
                    shape: BoxShape.circle,
                  ),
                ),

                SizedBox(width: 7.w),

                Container(
                  width: 55.w,
                  height: 7.h,
                  decoration: BoxDecoration(
                    color: previewText
                        .withOpacity(.12),
                    borderRadius:
                    BorderRadius.circular(10.r),
                  ),
                ),

                const Spacer(),

                Container(
                  width: 27.w,
                  height: 27.w,
                  decoration: BoxDecoration(
                    color: previewCard,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          // MINI CONTENT

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Row(
              children: [
                Expanded(
                  child: _PreviewTile(
                    color: previewCard,
                    accent: accent,
                  ),
                ),
                SizedBox(width: 7.w),
                Expanded(
                  child: _PreviewTile(
                    color: previewCard,
                    accent: accent,
                  ),
                ),
                SizedBox(width: 7.w),
                Expanded(
                  child: _PreviewTile(
                    color: previewCard,
                    accent: accent,
                  ),
                ),
              ],
            ),
          ),

          // FLOATING MODE LABEL

          Positioned(
            right: 8.w,
            top: 36.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 5.h,
              ),
              decoration: BoxDecoration(
                color: accent,
                borderRadius:
                BorderRadius.circular(30.r),
              ),
              child: Text(
                mode == ThemeMode.dark
                    ? 'DARK'
                    : mode == ThemeMode.light
                    ? 'LIGHT'
                    : 'AUTO',
                style: GoogleFonts.nunitoSans(
                  color: Colors.white,
                  fontSize: 6.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// PREVIEW TILE
// ==================================================================

class _PreviewTile extends StatelessWidget {
  final Color color;
  final Color accent;

  const _PreviewTile({
    required this.color,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius:
        BorderRadius.circular(14.r),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 7.w,
            right: 7.w,
            bottom: 7.h,
            child: Container(
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.black
                    .withOpacity(.07),
                borderRadius:
                BorderRadius.circular(10.r),
              ),
            ),
          ),

          Positioned(
            right: 7.w,
            top: 7.h,
            child: Container(
              width: 7.w,
              height: 7.w,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// THEME OPTION
// ==================================================================

class _ThemeOption extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool selected;

  final Color primary;
  final Color secondary;
  final Color surfaceSoft;
  final Color divider;
  final Color accent;

  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.selected,
    required this.primary,
    required this.secondary,
    required this.surfaceSoft,
    required this.divider,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_ThemeOption> createState() =>
      _ThemeOptionState();
}

class _ThemeOptionState
    extends State<_ThemeOption> {
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

      child: AnimatedScale(
        scale: _pressed ? .94 : 1,
        duration:
        const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          height: 92.h,
          padding: EdgeInsets.symmetric(
            horizontal: 8.w,
            vertical: 10.h,
          ),
          decoration: BoxDecoration(
            color: widget.selected
                ? widget.accent.withOpacity(.09)
                : widget.surfaceSoft,
            borderRadius:
            BorderRadius.circular(22.r),
            border: Border.all(
              color: widget.selected
                  ? widget.accent.withOpacity(.30)
                  : widget.divider,
              width: widget.selected ? 1.2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration:
                const Duration(milliseconds: 280),
                width: 37.w,
                height: 37.w,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? widget.accent
                      : widget.primary
                      .withOpacity(.055),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.selected
                      ? Colors.white
                      : widget.secondary,
                  size: 17.sp,
                ),
              ),

              SizedBox(height: 7.h),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      GoogleFonts.nunitoSans(
                        color: widget.selected
                            ? widget.accent
                            : widget.primary,
                        fontSize: 8.sp,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ),

                  if (widget.selected) ...[
                    SizedBox(width: 3.w),
                    Icon(
                      Icons.check_rounded,
                      color: widget.accent,
                      size: 11.sp,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// SETTING CARD
// ==================================================================

class _SettingCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color text;
  final Color secondary;
  final bool isDark;
  final int index;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool loading;

  const _SettingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.text,
    required this.secondary,
    required this.isDark,
    required this.index,
    required this.trailing,
    this.onTap,
    this.loading = false,
  });

  @override
  State<_SettingCard> createState() =>
      _SettingCardState();
}

class _SettingCardState
    extends State<_SettingCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent;

    final surface = widget.isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final surfaceSoft = widget.isDark
        ? AppColors.darkSurfaceSoft
        : AppColors.lightSurfaceSoft;

    final divider = widget.isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTapDown: widget.onTap == null
          ? null
          : (_) {
        setState(() {
          _pressed = true;
        });
      },

      onTapCancel: widget.onTap == null
          ? null
          : () {
        setState(() {
          _pressed = false;
        });
      },

      onTapUp: widget.onTap == null
          ? null
          : (_) {
        setState(() {
          _pressed = false;
        });

        widget.onTap!();
      },

      child: AnimatedScale(
        scale: _pressed ? .978 : 1,
        duration:
        const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: _pressed
                ? surfaceSoft
                : surface,
            borderRadius:
            BorderRadius.circular(28.r),
            border: Border.all(
              color: _pressed
                  ? accent.withOpacity(.14)
                  : divider,
            ),
          ),
          child: Row(
            children: [
              // ICON

              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: surfaceSoft,
                  borderRadius:
                  BorderRadius.circular(18.r),
                ),
                child: Icon(
                  widget.icon,
                  color: accent,
                  size: 21.sp,
                ),
              ),

              SizedBox(width: 13.w),

              // TEXT

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: widget.text,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.3,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      widget.subtitle,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: GoogleFonts.nunitoSans(
                        color: widget.secondary,
                        fontSize: 9.5.sp,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // TRAILING

              AnimatedSwitcher(
                duration:
                const Duration(milliseconds: 220),
                child: widget.loading
                    ? SizedBox(
                  key: const ValueKey('loader'),
                  width: 23.w,
                  height: 23.w,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accent,
                  ),
                )
                    : widget.trailing,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
      delay: Duration(
        milliseconds: widget.index * 70,
      ),
      duration:
      const Duration(milliseconds: 500),
    )
        .moveY(
      begin: 15,
      end: 0,
      duration:
      const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
    );
  }
}

// ==================================================================
// WHAT'S NEW
// ==================================================================

class _WhatsNewCard extends StatelessWidget {
  const _WhatsNewCard({
    required this.version,
    required this.codename,
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.surfaceSoft,
    required this.divider,
    required this.accent,
  });

  final String version;
  final String codename;

  final Color primary;
  final Color secondary;
  final Color surface;
  final Color surfaceSoft;
  final Color divider;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(19.w),
      decoration: BoxDecoration(
        color: surface,
        borderRadius:
        BorderRadius.circular(28.r),
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
              const _FramesMark(),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WHAT\'S NEW',
                      style: GoogleFonts.outfit(
                        color: primary,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.4,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Build $version • $codename',
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: GoogleFonts.nunitoSans(
                        color: secondary,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 9.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: accent.withOpacity(.09),
                  borderRadius:
                  BorderRadius.circular(30.r),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: accent,
                  size: 13.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          _updateItem(
            'Refined visual system',
            'A cleaner FRAMES identity with a softer interface.',
          ),

          _updateItem(
            'Smoother motion',
            'More natural transitions and interaction feedback.',
          ),

          _updateItem(
            'Theme consistency',
            'Light and dark interfaces now share one visual language.',
          ),

          _updateItem(
            'Wallpaper experience',
            'Improved browsing, presentation and discovery.',
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
      duration:
      const Duration(milliseconds: 600),
    )
        .moveY(
      begin: 15,
      end: 0,
      duration:
      const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _updateItem(
      String title,
      String description,
      ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 15.h,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 6.h,
            ),
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunitoSans(
                    color: primary,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 3.h),

                Text(
                  description,
                  style: GoogleFonts.nunitoSans(
                    color: secondary,
                    fontSize: 9.sp,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// GLASS CHIP
// ==================================================================

class _GlassChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GlassChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final surface = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final secondary = isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final divider = isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius:
        BorderRadius.circular(17.r),
        border: Border.all(
          color: divider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.accent,
            size: 13.sp,
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: GoogleFonts.nunitoSans(
                color: secondary,
                fontSize: 7.5.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// FRAMES MARK
// ==================================================================

class _FramesMark extends StatelessWidget {
  const _FramesMark();

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final surface = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final primary = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final accent = AppColors.accent;

    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        color: surface,
        borderRadius:
        BorderRadius.circular(9.r),
        border: Border.all(
          color: primary.withOpacity(.10),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 6.w,
            top: 6.w,
            right: 6.w,
            bottom: 6.w,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: accent.withOpacity(.7),
                  width: 1.2,
                ),
                borderRadius:
                BorderRadius.circular(5.r),
              ),
            ),
          ),

          Positioned(
            right: 5.w,
            bottom: 5.w,
            child: Container(
              width: 5.w,
              height: 5.w,
              decoration: BoxDecoration(
                color: accent,
                borderRadius:
                BorderRadius.circular(2.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// PRESSABLE
// ==================================================================

class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableScale({
    required this.child,
    required this.onTap,
  });

  @override
  State<_PressableScale> createState() =>
      _PressableScaleState();
}

class _PressableScaleState
    extends State<_PressableScale> {
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
        duration:
        const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}