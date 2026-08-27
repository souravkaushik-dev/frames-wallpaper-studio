import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/presentation/widgets/foliage_onboarding_screen.dart';
import '../../features/home/presentation/widgets/splash.dart';
import '../routing/navigation_shell.dart';
import '../theme/app_theme.dart';

class FleckApp extends StatefulWidget {
  const FleckApp({
    super.key,
  });

  @override
  State<FleckApp> createState() =>
      _FleckAppState();
}

class _FleckAppState extends State<FleckApp> {
  // ===========================================================================
  // THEME
  // ===========================================================================

  ThemeMode _themeMode =
      ThemeMode.system;

  // ===========================================================================
  // STARTUP
  // ===========================================================================

  bool _checkingOnboarding = true;

  bool _onboardingCompleted = false;

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _loadStartupState();
  }

  // ===========================================================================
  // LOAD STARTUP STATE
  // ===========================================================================

  Future<void> _loadStartupState() async {
    try {
      final prefs =
      await SharedPreferences
          .getInstance();

      final completed =
          prefs.getBool(
            'foliage_onboarding_completed',
          ) ??
              false;

      if (!mounted) {
        return;
      }

      setState(() {
        _onboardingCompleted =
            completed;

        _checkingOnboarding = false;
      });
    } catch (error) {
      debugPrint(
        'Foliage startup error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _onboardingCompleted =
        false;

        _checkingOnboarding = false;
      });
    }
  }

  // ===========================================================================
  // THEME MODE
  // ===========================================================================

  void _changeThemeMode(
      ThemeMode mode,
      ) {
    if (_themeMode == mode) {
      return;
    }

    setState(() {
      _themeMode = mode;
    });
  }

  // ===========================================================================
  // STARTUP SCREEN
  // ===========================================================================

  Widget _buildStartupScreen() {
    // -------------------------------------------------------------------------
    // Splash while checking first-launch state.
    // -------------------------------------------------------------------------

    if (_checkingOnboarding) {
      return const FoliageSplashScreen();
    }

    // -------------------------------------------------------------------------
    // First installation.
    // -------------------------------------------------------------------------

    if (!_onboardingCompleted) {
      return FoliageOnboardingScreen(
        onCompleted:
        _finishOnboarding,
      );
    }

    // -------------------------------------------------------------------------
    // Normal application.
    // -------------------------------------------------------------------------

    return FleckShell(
      themeMode:
      _themeMode,
      onThemeModeChanged:
      _changeThemeMode,
    );
  }

  // ===========================================================================
  // FINISH ONBOARDING
  // ===========================================================================

  Future<void> _finishOnboarding(
      String name,
      ) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _onboardingCompleted = true;
    });
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return MaterialApp(
      debugShowCheckedModeBanner:
      false,

      title: 'Foliage',

      // -----------------------------------------------------------------------
      // YOUR APP THEME
      // -----------------------------------------------------------------------

      theme:
      FleckTheme.light,

      darkTheme:
      FleckTheme.dark,

      themeMode:
      _themeMode,

      // -----------------------------------------------------------------------
      // APP
      // -----------------------------------------------------------------------

      home:
      _buildStartupScreen(),
    );
  }
}