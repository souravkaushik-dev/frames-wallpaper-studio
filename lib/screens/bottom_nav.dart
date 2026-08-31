import 'package:dotty/api_servie/wallpaper_Api.dart';
import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/models/category_model.dart';
import 'package:dotty/screens/favorite_screen.dart';
import 'package:dotty/screens/home_screen.dart';
import 'package:dotty/screens/preference_screen.dart';
import 'package:dotty/screens/recent_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:m3e_floating_toolbar/m3e_floating_toolbar.dart';

class MainScreen extends StatefulWidget {
  final List<Wallpaper> recentWallpapers;

  const MainScreen({
    super.key,
    required this.recentWallpapers,
  });

  @override
  State<MainScreen> createState() =>
      _MainScreenState();
}

class _MainScreenState
    extends State<MainScreen> {
  int currentTab = 0;

  late List<Wallpaper> recentWallpapers;

  @override
  void initState() {
    super.initState();

    recentWallpapers =
    List<Wallpaper>.from(
      widget.recentWallpapers,
    );
  }

  // ============================================================
  // APP COLORS
  // ============================================================

  bool get isDark =>
      Theme.of(context).brightness ==
          Brightness.dark;

  Color get background =>
      isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground;

  Color get surface =>
      isDark
          ? AppColors.darkSurface
          : AppColors.lightSurface;

  Color get surfaceSoft =>
      isDark
          ? AppColors.darkSurfaceSoft
          : AppColors.lightSurfaceSoft;

  Color get primary =>
      isDark
          ? AppColors.darkPrimary
          : AppColors.lightPrimary;

  Color get secondary =>
      isDark
          ? AppColors.darkSecondary
          : AppColors.lightSecondary;

  Color get divider =>
      isDark
          ? AppColors.darkDivider
          : AppColors.lightDivider;

  Color get accent =>
      AppColors.accent;

  // ============================================================
  // PAGES
  // ============================================================

  Widget _buildPage(
      int index,
      ) {
    switch (index) {
      case 0:
        return const HomeScreen();

      case 1:
        return const CategoriesPage();

      case 2:
        return const SavedScreen();

      case 3:
        return RecentPage(
          key: ValueKey(
            recentWallpapers
                .map(
                  (wallpaper) =>
              wallpaper.id,
            )
                .join('|'),
          ),
          recentWallpapers:
          recentWallpapers,
        );

      case 4:
        return const PreferencesScreen();

      default:
        return const HomeScreen();
    }
  }

  // ============================================================
  // TAB CHANGE
  // ============================================================

  void _changeTab(
      int index,
      ) {
    if (currentTab ==
        index) {
      return;
    }

    HapticFeedback.selectionClick();

    setState(() {
      currentTab =
          index;
    });
  }

  // ============================================================
  // TOOLBAR COLORS
  // ============================================================

  M3EFloatingToolbarColors
  get _toolbarColors {
    return M3EFloatingToolbarColors(
      toolbarContainerColor:
      surface,

      toolbarContentColor:
      primary,

      fabContainerColor:
      accent,

      fabContentColor:
      primary,
    );
  }

  // ============================================================
  // DECORATION
  // ============================================================

  M3EFloatingToolbarDecoration
  get _toolbarDecoration {
    return M3EFloatingToolbarDecoration(
      colors:
      _toolbarColors,

      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(
          26.r,
        ),

        side:
        BorderSide(
          color:
          divider,

          width:
          1,
        ),
      ),

      contentPadding:
      EdgeInsets.symmetric(
        horizontal:
        7.w,

        vertical:
        6.h,
      ),

      // Cinematic but controlled.
      motion:
      M3EMotion.custom(
        stiffness:
        700,

        damping:
        0.82,
      ),

      // NO SHADOW.
      expandedShadowElevation:
      0,

      collapsedShadowElevation:
      0,
    );
  }

  // ============================================================
  // NAVIGATION ITEM
  // ============================================================

  Widget _navigationItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final selected =
        currentTab ==
            index;

    return GestureDetector(
      behavior:
      HitTestBehavior.opaque,

      onTap:
          () {
        _changeTab(
          index,
        );
      },

      child:
      AnimatedContainer(
        duration:
        const Duration(
          milliseconds:
          380,
        ),

        curve:
        Curves.easeOutCubic,

        padding:
        EdgeInsets.symmetric(
          horizontal:
          selected
              ? 13.w
              : 12.w,

          vertical:
          7.h,
        ),

        decoration:
        BoxDecoration(
          color:
          selected
              ? accent.withOpacity(
            isDark
                ? .14
                : .10,
          )
              : Colors.transparent,

          borderRadius:
          BorderRadius.circular(
            20.r,
          ),

          border:
          Border.all(
            color:
            selected
                ? accent.withOpacity(
              isDark
                  ? .22
                  : .18,
            )
                : Colors.transparent,
          ),
        ),

        child:
        AnimatedSize(
          duration:
          const Duration(
            milliseconds:
            320,
          ),

          curve:
          Curves.easeOutCubic,

          child:
          Row(
            mainAxisSize:
            MainAxisSize.min,

            children: [
              AnimatedSwitcher(
                duration:
                const Duration(
                  milliseconds:
                  240,
                ),

                transitionBuilder:
                    (
                    child,
                    animation,
                    ) {
                  return ScaleTransition(
                    scale:
                    animation,

                    child:
                    FadeTransition(
                      opacity:
                      animation,

                      child:
                      child,
                    ),
                  );
                },

                child:
                Icon(
                  selected
                      ? activeIcon
                      : icon,

                  key:
                  ValueKey(
                    selected,
                  ),

                  size:
                  selected
                      ? 20.sp
                      : 19.sp,

                  color:
                  selected
                      ? primary
                      : secondary,
                ),
              ),

              if (selected) ...[
                SizedBox(
                  width:
                  7.w,
                ),

                Text(
                  label,

                  style:
                  TextStyle(
                    color:
                    primary,

                    fontSize:
                    9.sp,

                    fontWeight:
                    FontWeight.w700,

                    letterSpacing:
                    .1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION CONTENT
  // ============================================================

  Widget _navigationContent() {
    return Row(
      mainAxisSize:
      MainAxisSize.min,

      children: [
        _navigationItem(
          index:
          0,

          icon:
          Hicons
              .home2LightOutline,

          activeIcon:
          Hicons
              .home2Bold,

          label:
          'Home',
        ),

        SizedBox(
          width:
          2.w,
        ),

        _navigationItem(
          index:
          1,

          icon:
          Hicons
              .categoryLightOutline,

          activeIcon:
          Hicons
              .categoryBold,

          label:
          'Explore',
        ),

        SizedBox(
          width:
          2.w,
        ),

        _navigationItem(
          index:
          2,

          icon:
          Hicons
              .heart2LightOutline,

          activeIcon:
          Hicons
              .heart2Bold,

          label:
          'Saved',
        ),

        SizedBox(
          width:
          2.w,
        ),

        _navigationItem(
          index:
          3,

          icon:
          Hicons
              .rotateLeftLightOutline,

          activeIcon:
          Hicons
              .rotateLeftBold,

          label:
          'Recent',
        ),

        SizedBox(
          width:
          2.w,
        ),

        _navigationItem(
          index: 4,

          icon:
          Hicons
              .settingLightOutline,

          activeIcon:
          Hicons
              .settingBold,

          label:
          'Settings',
        ),
      ],
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
      background,

      extendBody:
      true,

      body:
      Stack(
        children: [
          // ======================================================
          // APP CONTENT
          // ======================================================

          Positioned.fill(
            child:
            IndexedStack(
              index:
              currentTab,

              children:
              List.generate(
                5,
                _buildPage,
              ),
            ),
          ),

          // ======================================================
          // FLOATING EXPRESSIVE NAVIGATION
          // ======================================================

          Positioned(
            left:
            14.w,

            right:
            14.w,

            bottom:
            14.h,

            child:
            SafeArea(
              top:
              false,

              child:
              Align(
                alignment:
                Alignment.bottomCenter,

                child:
                M3EHorizontalFloatingToolbar(
                  expanded:
                  true,

                  decoration:
                  _toolbarDecoration,

                  content:
                  _navigationContent(),

                  tooltip:
                  'Navigation',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}