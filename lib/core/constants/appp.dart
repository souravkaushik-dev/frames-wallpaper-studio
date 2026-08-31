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
  State<FleckApp> createState() => _FleckAppState();
}

class _FleckAppState extends State<FleckApp> {
  // ===========================================================================
  // THEME
  // ===========================================================================

  ThemeMode _themeMode = ThemeMode.system;

  // ===========================================================================
  // STARTUP
  // ===========================================================================

  bool _checkingOnboarding = true;

  bool _onboardingCompleted = false;

  bool _splashFinished = false;

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
      await SharedPreferences.getInstance();

      final completed =
          prefs.getBool(
            'foliage_onboarding_completed',
          ) ??
              false;

      if (!mounted) {
        return;
      }

      setState(() {
        _onboardingCompleted = completed;
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
        _onboardingCompleted = false;
        _checkingOnboarding = false;
      });
    }
  }

  // ===========================================================================
  // SPLASH FINISHED
  // ===========================================================================

  void _onSplashFinished() {
    if (!mounted) {
      return;
    }

    setState(() {
      _splashFinished = true;
    });
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
    // IMPORTANT
    //
    // Splash remains visible until:
    //
    // 1. SharedPreferences has loaded
    // 2. Splash animation/timer has finished
    //
    // This prevents the splash from disappearing immediately.
    // -------------------------------------------------------------------------

    if (_checkingOnboarding || !_splashFinished) {
      return FoliageSplashScreen(
        onFinished: _onSplashFinished,
      );
    }

    // -------------------------------------------------------------------------
    // FIRST INSTALLATION
    // -------------------------------------------------------------------------

    if (!_onboardingCompleted) {
      return FoliageOnboardingScreen(
        onCompleted: _finishOnboarding,
      );
    }

    // -------------------------------------------------------------------------
    // NORMAL APPLICATION
    // -------------------------------------------------------------------------

    return FleckShell(
      themeMode: _themeMode,
      onThemeModeChanged: _changeThemeMode,
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
      debugShowCheckedModeBanner: false,

      title: 'Foliage',

      // -----------------------------------------------------------------------
      // LIGHT THEME
      // -----------------------------------------------------------------------

      theme: FleckTheme.light,

      // -----------------------------------------------------------------------
      // DARK THEME
      // -----------------------------------------------------------------------

      darkTheme: FleckTheme.dark,

      // -----------------------------------------------------------------------
      // AUTOMATIC SYSTEM THEME
      // -----------------------------------------------------------------------

      themeMode: _themeMode,

      // -----------------------------------------------------------------------
      // THEME ANIMATION
      // -----------------------------------------------------------------------

      themeAnimationDuration:
      const Duration(
        milliseconds: 300,
      ),

      themeAnimationCurve:
      Curves.easeOutCubic,

      // -----------------------------------------------------------------------
      // STARTUP
      // -----------------------------------------------------------------------

      home: _buildStartupScreen(),
    );
  }
}