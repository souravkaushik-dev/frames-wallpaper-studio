import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routing/navigation_shell.dart';
import 'core/theme/app_theme.dart';
import 'features/favorites/presentation/widgets/ffav_store.dart';
import 'features/home/presentation/widgets/foliage_onboarding_screen.dart';
import 'features/home/presentation/widgets/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FleckFavoritesStore.init();

  runApp(
    const FleckApp(),
  );
}

class FleckApp extends StatefulWidget {
  const FleckApp({
    super.key,
  });

  @override
  State<FleckApp> createState() =>
      _FleckAppState();
}

class _FleckAppState
    extends State<FleckApp> {
  // ===========================================================================
  // THEME MODE
  // ===========================================================================

  ThemeMode _themeMode =
      ThemeMode.system;

  // ===========================================================================
  // ONBOARDING
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
  // STARTUP STATE
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
  // ONBOARDING COMPLETE
  // ===========================================================================

  Future<void> _finishOnboarding(
      String name,
      ) async {
    if (!mounted) {
      return;
    }

    // The onboarding screen already saves:
    //
    // foliage_user_name
    // foliage_onboarding_completed
    //
    // We only switch the app to the main shell.

    setState(() {
      _onboardingCompleted = true;
    });
  }

  // ===========================================================================
  // STARTUP CONTENT
  // ===========================================================================

  Widget _buildStartupContent() {
    // -------------------------------------------------------------------------
    // Startup / preference check
    // -------------------------------------------------------------------------

    if (_checkingOnboarding) {
      return const FoliageSplashScreen();
    }

    // -------------------------------------------------------------------------
    // FIRST INSTALL
    // -------------------------------------------------------------------------

    if (!_onboardingCompleted) {
      return FoliageOnboardingScreen(
        onCompleted:
        _finishOnboarding,
      );
    }

    // -------------------------------------------------------------------------
    // RETURNING USER
    // -------------------------------------------------------------------------

    return FleckShell(
      themeMode:
      _themeMode,
      onThemeModeChanged:
      _changeThemeMode,
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return ScreenUtilPlusInit(
      designSize:
      const Size(
        390,
        844,
      ),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (
          context,
          child,
          ) {
        return MaterialApp(
          // ===================================================================
          // APP
          // ===================================================================

          debugShowCheckedModeBanner:
          false,

          title: 'Foliage',

          // ===================================================================
          // FLECK THEME
          // ===================================================================

          theme:
          FleckTheme.light,

          darkTheme:
          FleckTheme.dark,

          themeMode:
          _themeMode,

          // ===================================================================
          // THEME TRANSITION
          // ===================================================================

          themeAnimationDuration:
          const Duration(
            milliseconds: 300,
          ),

          themeAnimationCurve:
          Curves.easeOutCubic,

          // ===================================================================
          // LOCALIZATION
          // ===================================================================

          localizationsDelegates:
          const [
            GlobalMaterialLocalizations
                .delegate,
            GlobalWidgetsLocalizations
                .delegate,
            GlobalCupertinoLocalizations
                .delegate,
          ],

          supportedLocales:
          const [
            Locale('en'),
          ],

          // ===================================================================
          // SYSTEM UI
          // ===================================================================

          builder: (
              context,
              child,
              ) {
            final theme =
            Theme.of(context);

            final brightness =
                theme.brightness;

            final colors =
                theme.colorScheme;

            final isDark =
                brightness ==
                    Brightness.dark;

            return AnnotatedRegion<
                SystemUiOverlayStyle>(
              value:
              SystemUiOverlayStyle(
                statusBarColor:
                Colors.transparent,

                systemNavigationBarColor:
                colors.surface,

                statusBarIconBrightness:
                isDark
                    ? Brightness.light
                    : Brightness.dark,

                systemNavigationBarIconBrightness:
                isDark
                    ? Brightness.light
                    : Brightness.dark,

                systemNavigationBarDividerColor:
                Colors.transparent,
              ),
              child:
              child ??
                  const SizedBox
                      .shrink(),
            );
          },

          // ===================================================================
          // STARTUP / APP SHELL
          // ===================================================================

          home:
          _buildStartupContent(),
        );
      },
    );
  }
}