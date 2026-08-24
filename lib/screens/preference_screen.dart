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
  const PreferencesScreen({
    super.key,
  });

  @override
  State<PreferencesScreen> createState() =>
      _PreferencesScreenState();
}

class _PreferencesScreenState
    extends State<PreferencesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambientController;

  bool _clearingCache = false;

  // ============================================================
  // THEME
  // ============================================================

  bool get _isDark =>
      Theme.of(context).brightness ==
          Brightness.dark;

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

    _ambientController =
    AnimationController(
      vsync: this,
      duration:
      const Duration(seconds: 14),
    )..repeat(reverse: true);

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) return;

      _updateSystemUI();
    });
  }

  // ============================================================
  // SYSTEM UI
  // ============================================================

  void _updateSystemUI() {
    SystemChrome
        .setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor:
        Colors.transparent,
        systemNavigationBarColor:
        Colors.transparent,
        statusBarIconBrightness:
        _isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarIconBrightness:
        _isDark
            ? Brightness.light
            : Brightness.dark,
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
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final themeProvider =
    Provider.of<ThemeProvider>(
      context,
    );

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (mounted) {
        _updateSystemUI();
      }
    });

    return Scaffold(
      backgroundColor:
      _background,

      body: Stack(
        children: [
          _buildBackground(),

          SafeArea(
            child:
            CustomScrollView(
              physics:
              const BouncingScrollPhysics(
                parent:
                AlwaysScrollableScrollPhysics(),
              ),

              slivers: [
                // =================================================
                // HEADER
                // =================================================

                SliverToBoxAdapter(
                  child:
                  _buildHeader(),
                ),

                // =================================================
                // CONTENT
                // =================================================

                SliverPadding(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal:
                    18.w,
                  ),

                  sliver:
                  SliverList(
                    delegate:
                    SliverChildListDelegate(
                      [
                        // ------------------------------------------------
                        // APPEARANCE
                        // ------------------------------------------------

                        _section(
                          'APPEARANCE',
                        ),

                        SizedBox(
                          height: 12.h,
                        ),

                        _themeCard(
                          themeProvider,
                        ),

                        SizedBox(
                          height: 32.h,
                        ),

                        // ------------------------------------------------
                        // WHAT'S NEW
                        // ------------------------------------------------

                        _section(
                          'WHAT\'S NEW',
                        ),

                        SizedBox(
                          height: 12.h,
                        ),

                        _WhatsNewCard(
                          version:
                          AppInfo
                              .buildNumber
                              .toString(),
                          codename:
                          AppInfo
                              .buildCodename,
                          primary:
                          _primary,
                          secondary:
                          _secondary,
                          surface:
                          _surface,
                          surfaceSoft:
                          _surfaceSoft,
                          divider:
                          _divider,
                          accent:
                          _accent,
                        ),

                        SizedBox(
                          height: 32.h,
                        ),

                        // ------------------------------------------------
                        // STORAGE
                        // ------------------------------------------------

                        _section(
                          'STORAGE',
                        ),

                        SizedBox(
                          height: 12.h,
                        ),

                        _settingCard(
                          index: 1,
                          icon: Hicons
                              .minusLightOutline,
                          title:
                          'Clear Cache',
                          subtitle:
                          'Remove temporary wallpaper files',
                          trailing:
                          _arrow(),
                          loading:
                          _clearingCache,
                          onTap:
                          _clearCache,
                        ),

                        SizedBox(
                          height: 32.h,
                        ),

                        // ------------------------------------------------
                        // INFORMATION
                        // ------------------------------------------------

                        _section(
                          'INFORMATION',
                        ),

                        SizedBox(
                          height: 12.h,
                        ),

                        _settingCard(
                          index: 2,
                          icon: Hicons
                              .informationSquareLightOutline,
                          title:
                          'About Frames',
                          subtitle:
                          'Discover more about the app',
                          trailing:
                          _arrow(),
                          onTap: () {
                            _openPage(
                              const AboutAppScreen(),
                            );
                          },
                        ),

                        SizedBox(
                          height: 14.h,
                        ),

                        _settingCard(
                          index: 3,
                          icon: Hicons
                              .shield1LightOutline,
                          title:
                          'Privacy Policy',
                          subtitle:
                          'Understand how your data is handled',
                          trailing:
                          _arrow(),
                          onTap: () {
                            _openPage(
                              const PrivacyPolicyScreen(),
                            );
                          },
                        ),

                        SizedBox(
                          height: 14.h,
                        ),

                        _settingCard(
                          index: 4,
                          icon: Hicons
                              .documentAlignCenter1LightOutline,
                          title:
                          'Terms & Conditions',
                          subtitle:
                          'Review usage guidelines and policies',
                          trailing:
                          _arrow(),
                          onTap: () {
                            _openPage(
                              const TermsConditionsScreen(),
                            );
                          },
                        ),

                        SizedBox(
                          height: 55.h,
                        ),

                        _footer(),

                        SizedBox(
                          height: 90.h,
                        ),
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
          animation:
          _ambientController,
          builder:
              (context, child) {
            final value =
                _ambientController.value;

            return Stack(
              children: [
                Positioned(
                  top:
                  -220.h +
                      value * 25.h,
                  right:
                  -210.w +
                      value * 20.w,
                  child:
                  _ambientBlob(
                    430.w,
                    _isDark
                        ? .018
                        : .008,
                  ),
                ),

                Positioned(
                  bottom:
                  -220.h +
                      value * 18.h,
                  left:
                  -220.w,
                  child:
                  _ambientBlob(
                    390.w,
                    _isDark
                        ? .012
                        : .006,
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
      decoration:
      BoxDecoration(
        shape:
        BoxShape.circle,
        color:
        _accent.withOpacity(
          opacity,
        ),
      ),
    ).animate(
      onPlay:
          (controller) {
        controller.repeat(
          reverse: true,
        );
      },
    ).blurXY(
      begin: 70,
      end: 100,
      duration:
      const Duration(
        seconds: 10,
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding:
      EdgeInsets.fromLTRB(
        20.w,
        18.h,
        20.w,
        30.h,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _backButton(),

              SizedBox(
                width: 14.w,
              ),

              const _FramesMark(),

              SizedBox(
                width: 10.w,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FRAMES',
                      style:
                      GoogleFonts.inter(
                        color:
                        _accent,
                        fontSize:
                        8.sp,
                        fontWeight:
                        FontWeight.w900,
                        letterSpacing:
                        2.2,
                      ),
                    ),

                    SizedBox(
                      height: 3.h,
                    ),

                    Text(
                      'YOUR SPACE',
                      style:
                      GoogleFonts.inter(
                        color:
                        _primary,
                        fontSize:
                        16.sp,
                        fontWeight:
                        FontWeight.w800,
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
            const Duration(
              milliseconds: 650,
            ),
          )
              .moveY(
            begin: -15,
            end: 0,
            duration:
            const Duration(
              milliseconds: 650,
            ),
            curve:
            Curves.easeOutCubic,
          ),

          SizedBox(
            height: 32.h,
          ),

          Text(
            'SETTINGS',
            style:
            GoogleFonts.inter(
              color: _primary,
              fontSize: 52.sp,
              height: .9,
              fontWeight:
              FontWeight.w800,
              letterSpacing:
              -1.5,
            ),
          )
              .animate()
              .fadeIn(
            delay:
            const Duration(
              milliseconds: 100,
            ),
            duration:
            const Duration(
              milliseconds: 700,
            ),
          )
              .moveY(
            begin: 30,
            end: 0,
            duration:
            const Duration(
              milliseconds: 700,
            ),
            curve:
            Curves.easeOutCubic,
          ),

          SizedBox(
            height: 14.h,
          ),

          Text(
            'Customize your wallpaper experience with a quiet, refined interface built around your screen.',
            style:
            GoogleFonts.inter(
              color:
              _secondary,
              fontSize:
              12.sp,
              height:
              1.7,
              fontWeight:
              FontWeight.w500,
            ),
          )
              .animate()
              .fadeIn(
            delay:
            const Duration(
              milliseconds: 220,
            ),
            duration:
            const Duration(
              milliseconds: 600,
            ),
          )
              .moveY(
            begin: 12,
            end: 0,
            duration:
            const Duration(
              milliseconds: 600,
            ),
          ),

          SizedBox(
            height: 22.h,
          ),

          Row(
            children: [
              _GlassChip(
                icon: Hicons
                    .colorPickerLightOutline,
                text: 'Theme',
              ),

              SizedBox(
                width: 8.w,
              ),

              _GlassChip(
                icon: Icons
                    .auto_awesome_rounded,
                text: 'Premium',
              ),

              SizedBox(
                width: 8.w,
              ),

              Expanded(
                child:
                _GlassChip(
                  icon: Hicons
                      .settingLightOutline,
                  text:
                  AppInfo
                      .buildCodename,
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(
            delay:
            const Duration(
              milliseconds: 350,
            ),
            duration:
            const Duration(
              milliseconds: 550,
            ),
          )
              .moveY(
            begin: 12,
            end: 0,
            duration:
            const Duration(
              milliseconds: 550,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FRAME MARK
  // ============================================================

  Widget _backButton() {
    return _PressableScale(
      onTap: () {
        HapticFeedback
            .selectionClick();

        Navigator.pop(
          context,
        );
      },
      child:
      Container(
        width: 48.w,
        height: 48.w,
        decoration:
        BoxDecoration(
          color:
          _surfaceSoft,
          shape:
          BoxShape.circle,
          border:
          Border.all(
            color:
            _divider,
          ),
        ),
        child:
        Icon(
          Hicons
              .left2LightOutline,
          color:
          _primary,
          size: 18.sp,
        ),
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _section(
      String title,
      ) {
    return Row(
      children: [
        Container(
          width: 5.w,
          height: 5.w,
          decoration:
          BoxDecoration(
            color: _accent,
            borderRadius:
            BorderRadius.circular(
              10,
            ),
          ),
        ),

        SizedBox(
          width: 8.w,
        ),

        Text(
          title,
          style:
          GoogleFonts.inter(
            color:
            _secondary,
            fontSize:
            8.sp,
            fontWeight:
            FontWeight.w900,
            letterSpacing:
            2,
          ),
        ),

        SizedBox(
          width: 10.w,
        ),

        Expanded(
          child:
          Container(
            height: 1,
            color:
            _divider,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // THEME CARD
  // ============================================================

  Widget _themeCard(
      ThemeProvider provider,
      ) {
    return _settingCard(
      index: 0,
      icon:
      Hicons.moonLightOutline,
      title:
      'Dark Mode',
      subtitle:
      'Switch between your light and dark visual space',
      trailing:
      _buildLiquidToggle(
        provider,
      ),
    );
  }

  // ============================================================
  // TOGGLE
  // ============================================================

  Widget _buildLiquidToggle(
      ThemeProvider provider,
      ) {
    final isDark =
        provider.themeMode ==
            ThemeMode.dark;

    return _SmoothLiquidToggle(
      value: isDark,
      onChanged: (value) {
        HapticFeedback
            .mediumImpact();

        provider.toggleTheme(
          value,
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
      secondary:
      _secondary,
      isDark:
      _isDark,
      index:
      index,
      trailing:
      trailing,
      onTap:
      onTap,
      loading:
      loading,
    );
  }

  // ============================================================
  // ARROW
  // ============================================================

  Widget _arrow() {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration:
      BoxDecoration(
        color:
        _surfaceSoft,
        shape:
        BoxShape.circle,
        border:
        Border.all(
          color:
          _divider,
        ),
      ),
      child:
      Icon(
        Hicons
            .right2LightOutline,
        color:
        _secondary,
        size: 14.sp,
      ),
    );
  }

  // ============================================================
  // CACHE
  // ============================================================

  Future<void>
  _clearCache() async {
    if (_clearingCache) {
      return;
    }

    setState(() {
      _clearingCache =
      true;
    });

    HapticFeedback
        .mediumImpact();

    try {
      await DefaultCacheManager()
          .emptyCache();

      if (!mounted) return;

      HapticFeedback
          .heavyImpact();

      ScaffoldMessenger
          .of(context)
          .hideCurrentSnackBar();

      ScaffoldMessenger
          .of(context)
          .showSnackBar(
        SnackBar(
          behavior:
          SnackBarBehavior
              .floating,
          backgroundColor:
          _surface,
          elevation: 0,
          margin:
          EdgeInsets.fromLTRB(
            16.w,
            0,
            16.w,
            18.h,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius
                .circular(
              20.r,
            ),
            side:
            BorderSide(
              color:
              _divider,
            ),
          ),
          content:
          Row(
            children: [
              Icon(
                Icons
                    .check_circle_rounded,
                color:
                _accent,
              ),
              SizedBox(
                width: 10.w,
              ),
              Expanded(
                child:
                Text(
                  'Wallpaper cache cleared',
                  style:
                  GoogleFonts.inter(
                    color:
                    _primary,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Cache error: $e',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _clearingCache =
        false;
      });
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _openPage(
      Widget page,
      ) {
    HapticFeedback
        .selectionClick();

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration:
        const Duration(
          milliseconds: 500,
        ),
        reverseTransitionDuration:
        const Duration(
          milliseconds: 350,
        ),
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
          final curve =
          CurvedAnimation(
            parent:
            animation,
            curve:
            Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity:
            curve,
            child:
            SlideTransition(
              position:
              Tween<Offset>(
                begin:
                const Offset(
                  .015,
                  .02,
                ),
                end:
                Offset.zero,
              ).animate(
                curve,
              ),
              child:
              child,
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
      child:
      Column(
        children: [
          const _FramesMark(),

          SizedBox(
            height: 13.h,
          ),

          Text(
            'FRAMES',
            style:
            GoogleFonts.inter(
              color:
              _primary,
              fontSize:
              19.sp,
              fontWeight:
              FontWeight.w800,
              letterSpacing:
              3,
            ),
          ),

          SizedBox(
            height: 5.h,
          ),

          Text(
            'CRAFTED FOR YOUR SCREEN',
            style:
            GoogleFonts.inter(
              color:
              _secondary
                  .withOpacity(
                .55,
              ),
              fontSize:
              7.sp,
              fontWeight:
              FontWeight.w800,
              letterSpacing:
              1.7,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
      duration:
      const Duration(
        milliseconds: 700,
      ),
    )
        .moveY(
      begin: 10,
      end: 0,
      duration:
      const Duration(
        milliseconds: 700,
      ),
    );
  }
}

// ==================================================================
// FRAMES MARK
// ==================================================================

class _FramesMark
    extends StatelessWidget {
  const _FramesMark();

  @override
  Widget build(
      BuildContext context,
      ) {
    final isDark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    final surface = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final primary = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final accent =
        AppColors.accent;

    return Container(
      width: 30.w,
      height: 30.w,
      decoration:
      BoxDecoration(
        color: surface,
        borderRadius:
        BorderRadius.circular(
          8.r,
        ),
        border:
        Border.all(
          color:
          primary.withOpacity(
            .12,
          ),
        ),
      ),
      child:
      Stack(
        children: [
          Positioned(
            left: 6.w,
            top: 6.w,
            right: 6.w,
            bottom: 6.w,
            child:
            Container(
              decoration:
              BoxDecoration(
                border:
                Border.all(
                  color:
                  accent.withOpacity(
                    .7,
                  ),
                  width: 1.2,
                ),
                borderRadius:
                BorderRadius.circular(
                  4.r,
                ),
              ),
            ),
          ),

          Positioned(
            right: 5.w,
            bottom: 5.w,
            child:
            Container(
              width: 4.w,
              height: 4.w,
              decoration:
              BoxDecoration(
                color:
                accent,
                borderRadius:
                BorderRadius.circular(
                  1.5.r,
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
// WHAT'S NEW
// ==================================================================

class _WhatsNewCard
    extends StatelessWidget {
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
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      EdgeInsets.all(
        20.w,
      ),
      decoration:
      BoxDecoration(
        color:
        surface,
        borderRadius:
        BorderRadius.circular(
          28.r,
        ),
        border:
        Border.all(
          color:
          divider,
        ),
      ),
      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _FramesMark(),

              SizedBox(
                width: 12.w,
              ),

              Expanded(
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      'WHAT\'S NEW',
                      style:
                      GoogleFonts.inter(
                        color:
                        primary,
                        fontSize:
                        15.sp,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    SizedBox(
                      height: 3.h,
                    ),

                    Text(
                      'Build $version • $codename',
                      maxLines:
                      1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      GoogleFonts.inter(
                        color:
                        secondary,
                        fontSize:
                        10.sp,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(
            height: 20.h,
          ),

          _updateItem(
            'Refined visual system',
            'A cleaner FRAMES identity with a more minimal interface.',
          ),

          _updateItem(
            'Smoother motion',
            'More natural transitions and softer interaction feedback.',
          ),

          _updateItem(
            'Theme consistency',
            'Light and dark interfaces now share the same visual language.',
          ),

          _updateItem(
            'Wallpaper experience',
            'Improved browsing, presentation and discovery throughout the app.',
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
      duration:
      const Duration(
        milliseconds: 650,
      ),
    )
        .moveY(
      begin: 18,
      end: 0,
      duration:
      const Duration(
        milliseconds: 650,
      ),
      curve:
      Curves.easeOutCubic,
    );
  }

  Widget _updateItem(
      String title,
      String description,
      ) {
    return Padding(
      padding:
      EdgeInsets.only(
        bottom: 16.h,
      ),
      child:
      Row(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          Container(
            margin:
            EdgeInsets.only(
              top: 6.h,
            ),
            width: 5.w,
            height: 5.w,
            decoration:
            BoxDecoration(
              color:
              accent,
              borderRadius:
              BorderRadius
                  .circular(
                10,
              ),
            ),
          ),

          SizedBox(
            width: 11.w,
          ),

          Expanded(
            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  title,
                  style:
                  GoogleFonts.inter(
                    color:
                    primary,
                    fontSize:
                    12.sp,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                SizedBox(
                  height: 4.h,
                ),

                Text(
                  description,
                  style:
                  GoogleFonts.inter(
                    color:
                    secondary,
                    fontSize:
                    10.sp,
                    height:
                    1.5,
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
// SMOOTH LIQUID TOGGLE
// ==================================================================

class _SmoothLiquidToggle
    extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>
  onChanged;

  const _SmoothLiquidToggle({
    required this.value,
    required this.onChanged,
  });

  @override
  State<_SmoothLiquidToggle>
  createState() =>
      _SmoothLiquidToggleState();
}

class _SmoothLiquidToggleState
    extends State<_SmoothLiquidToggle>
    with
        SingleTickerProviderStateMixin {
  late final AnimationController
  _controller;

  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(
          vsync: this,
          duration:
          const Duration(
            milliseconds: 600,
          ),
          value:
          widget.value
              ? 1
              : 0,
        );
  }

  @override
  void didUpdateWidget(
      covariant
      _SmoothLiquidToggle
      oldWidget,
      ) {
    super.didUpdateWidget(
      oldWidget,
    );

    if (oldWidget.value !=
        widget.value) {
      _controller.animateTo(
        widget.value
            ? 1
            : 0,
        duration:
        const Duration(
          milliseconds: 600,
        ),
        curve:
        Curves.easeOutExpo,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback
        .selectionClick();

    widget.onChanged(
      !widget.value,
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final isDark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    return GestureDetector(
      behavior:
      HitTestBehavior.opaque,

      onTapDown:
          (_) {
        setState(() {
          _pressed =
          true;
        });
      },

      onTapCancel:
          () {
        setState(() {
          _pressed =
          false;
        });
      },

      onTapUp:
          (_) {
        setState(() {
          _pressed =
          false;
        });

        _toggle();
      },

      child:
      AnimatedScale(
        scale:
        _pressed ? .94 : 1,
        duration:
        const Duration(
          milliseconds: 180,
        ),
        curve:
        Curves.easeOutCubic,
        child:
        AnimatedBuilder(
          animation:
          _controller,
          builder:
              (
              context,
              child,
              ) {
            final value =
            Curves.easeOutExpo
                .transform(
              _controller.value,
            );

            final left =
                4.w +
                    value *
                        30.w;

            return Container(
              width:
              70.w,
              height:
              40.h,
              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius.circular(
                  100,
                ),
                color:
                isDark
                    ? Colors.white
                    .withOpacity(
                  .045,
                )
                    : Colors.black
                    .withOpacity(
                  .035,
                ),
                border:
                Border.all(
                  color:
                  isDark
                      ? Colors.white
                      .withOpacity(
                    .08,
                  )
                      : Colors.black
                      .withOpacity(
                    .07,
                  ),
                ),
              ),
              child:
              Stack(
                children: [
                  AnimatedPositioned(
                    duration:
                    const Duration(
                      milliseconds:
                      600,
                    ),
                    curve:
                    Curves.easeOutExpo,
                    left:
                    left,
                    top:
                    4.h,
                    child:
                    Container(
                      width:
                      32.w,
                      height:
                      32.w,
                      decoration:
                      BoxDecoration(
                        shape:
                        BoxShape.circle,
                        color:
                        AppColors
                            .accent,
                      ),
                      child:
                      Center(
                        child:
                        AnimatedSwitcher(
                          duration:
                          const Duration(
                            milliseconds:
                            250,
                          ),
                          transitionBuilder:
                              (
                              child,
                              animation,
                              ) {
                            return ScaleTransition(
                              scale:
                              CurvedAnimation(
                                parent:
                                animation,
                                curve:
                                Curves.easeOutBack,
                              ),
                              child:
                              child,
                            );
                          },
                          child:
                          Icon(
                            widget.value
                                ? Icons
                                .dark_mode_rounded
                                : Icons
                                .light_mode_rounded,
                            key:
                            ValueKey(
                              widget.value,
                            ),
                            color:
                            Colors.white,
                            size:
                            15.sp,
                          ),
                        ),
                      ),
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
}

// ==================================================================
// SETTING CARD
// ==================================================================

class _SettingCard
    extends StatefulWidget {
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
  State<_SettingCard>
  createState() =>
      _SettingCardState();
}

class _SettingCardState
    extends State<_SettingCard> {
  bool _pressed = false;

  @override
  Widget build(
      BuildContext context,
      ) {
    final accent =
        AppColors.accent;

    final surface =
    widget.isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final surfaceSoft =
    widget.isDark
        ? AppColors
        .darkSurfaceSoft
        : AppColors
        .lightSurfaceSoft;

    final divider =
    widget.isDark
        ? AppColors
        .darkDivider
        : AppColors
        .lightDivider;

    return GestureDetector(
      behavior:
      HitTestBehavior.opaque,

      onTapDown:
      widget.onTap == null
          ? null
          : (_) {
        setState(() {
          _pressed =
          true;
        });
      },

      onTapCancel:
      widget.onTap == null
          ? null
          : () {
        setState(() {
          _pressed =
          false;
        });
      },

      onTapUp:
      widget.onTap == null
          ? null
          : (_) {
        setState(() {
          _pressed =
          false;
        });

        widget.onTap!();
      },

      child:
      AnimatedScale(
        scale:
        _pressed
            ? .978
            : 1,
        duration:
        const Duration(
          milliseconds:
          180,
        ),
        curve:
        Curves.easeOutCubic,
        child:
        Container(
          padding:
          EdgeInsets.all(
            15.w,
          ),
          decoration:
          BoxDecoration(
            color:
            _pressed
                ? surfaceSoft
                : surface,
            borderRadius:
            BorderRadius.circular(
              28.r,
            ),
            border:
            Border.all(
              color:
              _pressed
                  ? accent.withOpacity(
                .14,
              )
                  : divider,
            ),
          ),
          child:
          Row(
            children: [
              Container(
                width:
                52.w,
                height:
                52.w,
                decoration:
                BoxDecoration(
                  color:
                  surfaceSoft,
                  borderRadius:
                  BorderRadius.circular(
                    18.r,
                  ),
                ),
                child:
                Icon(
                  widget.icon,
                  color:
                  accent,
                  size:
                  22.sp,
                ),
              ),

              SizedBox(
                width:
                14.w,
              ),

              Expanded(
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      widget.title,
                      maxLines:
                      1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      GoogleFonts.inter(
                        color:
                        widget.text,
                        fontSize:
                        14.sp,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    SizedBox(
                      height:
                      5.h,
                    ),

                    Text(
                      widget.subtitle,
                      maxLines:
                      2,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      GoogleFonts.inter(
                        color:
                        widget
                            .secondary,
                        fontSize:
                        10.sp,
                        height:
                        1.45,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width:
                10.w,
              ),

              AnimatedSwitcher(
                duration:
                const Duration(
                  milliseconds:
                  250,
                ),
                child:
                widget.loading
                    ? SizedBox(
                  key:
                  const ValueKey(
                    'loader',
                  ),
                  width:
                  22.w,
                  height:
                  22.w,
                  child:
                  CircularProgressIndicator(
                    strokeWidth:
                    2,
                    color:
                    accent,
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
      delay:
      Duration(
        milliseconds:
        widget.index *
            70,
      ),
      duration:
      const Duration(
        milliseconds:
        550,
      ),
    )
        .moveY(
      begin:
      18,
      end:
      0,
      duration:
      const Duration(
        milliseconds:
        550,
      ),
      curve:
      Curves.easeOutCubic,
    );
  }
}

// ==================================================================
// GLASS CHIP
// ==================================================================

class _GlassChip
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GlassChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final isDark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    final surface =
    isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final secondary =
    isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final divider =
    isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

    return Container(
      padding:
      EdgeInsets.symmetric(
        horizontal:
        11.w,
        vertical:
        8.h,
      ),
      decoration:
      BoxDecoration(
        color:
        surface,
        borderRadius:
        BorderRadius.circular(
          16.r,
        ),
        border:
        Border.all(
          color:
          divider,
        ),
      ),
      child:
      Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            color:
            AppColors
                .accent,
            size:
            14.sp,
          ),

          SizedBox(
            width: 6.w,
          ),

          Flexible(
            child:
            Text(
              text,
              maxLines:
              1,
              overflow:
              TextOverflow
                  .ellipsis,
              style:
              GoogleFonts.inter(
                color:
                secondary,
                fontSize:
                8.sp,
                fontWeight:
                FontWeight.w700,
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

class _PressableScale
    extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableScale({
    required this.child,
    required this.onTap,
  });

  @override
  State<_PressableScale>
  createState() =>
      _PressableScaleState();
}

class _PressableScaleState
    extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(
      BuildContext context,
      ) {
    return GestureDetector(
      behavior:
      HitTestBehavior.opaque,

      onTapDown:
          (_) {
        setState(() {
          _pressed =
          true;
        });
      },

      onTapCancel:
          () {
        setState(() {
          _pressed =
          false;
        });
      },

      onTapUp:
          (_) {
        setState(() {
          _pressed =
          false;
        });

        widget.onTap();
      },

      child:
      AnimatedScale(
        scale:
        _pressed ? .92 : 1,
        duration:
        const Duration(
          milliseconds:
          170,
        ),
        curve:
        Curves.easeOutCubic,
        child:
        widget.child,
      ),
    );
  }
}