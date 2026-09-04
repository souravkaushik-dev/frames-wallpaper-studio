import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeStyle {
  monochrome,
  pastel,
}

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'themeMode';
  static const String _themeStyleKey = 'themeStyle';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeStyle _themeStyle = ThemeStyle.monochrome;

  ThemeMode get themeMode => _themeMode;
  ThemeStyle get themeStyle => _themeStyle;

  /// The selected mode. When the mode is [ThemeMode.system], the actual
  /// brightness is controlled by Flutter's ThemeMode.system in MaterialApp.
  bool get isSystem => _themeMode == ThemeMode.system;
  bool get isPastel => _themeStyle == ThemeStyle.pastel;
  bool get isMonochrome => _themeStyle == ThemeStyle.monochrome;

  /// Use the current Flutter theme brightness so colors also follow the
  /// device when ThemeMode.system is selected.
  bool get isDark {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return brightness == Brightness.dark;
    }
  }

  ThemeProvider() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    switch (prefs.getString(_themeModeKey)) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        _themeMode = ThemeMode.system;
        break;
    }

    switch (prefs.getString(_themeStyleKey)) {
      case 'pastel':
        _themeStyle = ThemeStyle.pastel;
        break;
      case 'monochrome':
      default:
        _themeStyle = ThemeStyle.monochrome;
        break;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);

    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    await setThemeMode(
      value ? ThemeMode.dark : ThemeMode.light,
    );
  }

  Future<void> setThemeStyle(ThemeStyle style) async {
    _themeStyle = style;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeStyleKey, style.name);

    notifyListeners();
  }

  Future<void> togglePastel() async {
    await setThemeStyle(
      _themeStyle == ThemeStyle.pastel
          ? ThemeStyle.monochrome
          : ThemeStyle.pastel,
    );
  }

  Color get backgroundColor {
    if (_themeStyle == ThemeStyle.pastel) {
      return isDark
          ? const Color(0xFF17151A)
          : const Color(0xFFF8F5FA);
    }
    return isDark
        ? const Color(0xFF0A0A0A)
        : const Color(0xFFF7F7F7);
  }

  Color get surfaceColor {
    if (_themeStyle == ThemeStyle.pastel) {
      return isDark
          ? const Color(0xFF211E25)
          : const Color(0xFFFFFFFF);
    }
    return isDark
        ? const Color(0xFF141414)
        : const Color(0xFFFFFFFF);
  }

  Color get surfaceSoftColor {
    if (_themeStyle == ThemeStyle.pastel) {
      return isDark
          ? const Color(0xFF2A2630)
          : const Color(0xFFF0EBF3);
    }
    return isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF0F0F0);
  }

  Color get primaryColor {
    if (_themeStyle == ThemeStyle.pastel) {
      return isDark
          ? const Color(0xFFF7F1F8)
          : const Color(0xFF29232D);
    }
    return isDark
        ? const Color(0xFFF5F5F5)
        : const Color(0xFF111111);
  }

  Color get secondaryColor {
    if (_themeStyle == ThemeStyle.pastel) {
      return isDark
          ? const Color(0xFFBDB3C1)
          : const Color(0xFF6F6573);
    }
    return isDark
        ? const Color(0xFFA0A0A0)
        : const Color(0xFF666666);
  }

  Color get mutedColor {
    if (_themeStyle == ThemeStyle.pastel) {
      return isDark
          ? const Color(0xFF817685)
          : const Color(0xFFA79DAA);
    }
    return isDark
        ? const Color(0xFF666666)
        : const Color(0xFFA3A3A3);
  }

  Color get dividerColor {
    if (_themeStyle == ThemeStyle.pastel) {
      return isDark
          ? const Color(0xFF38323D)
          : const Color(0xFFE5DEE8);
    }
    return isDark
        ? const Color(0xFF292929)
        : const Color(0xFFE5E5E5);
  }

  Color get pastelPrimary =>
      isDark ? const Color(0xFFE5D9F2) : const Color(0xFFDCCFF2);

  Color get pastelBlue =>
      isDark ? const Color(0xFFD5E5F0) : const Color(0xFFCFE3F2);

  Color get pastelMint =>
      isDark ? const Color(0xFFD6E8DD) : const Color(0xFFD3EBDD);

  Color get pastelPeach =>
      isDark ? const Color(0xFFF0D7CA) : const Color(0xFFF3D8C8);

  Color get pastelButter =>
      isDark ? const Color(0xFFEDE2BA) : const Color(0xFFF1E4B8);

  Color get pastelRose =>
      isDark ? const Color(0xFFECCFD6) : const Color(0xFFF1D2D8);

  Color get pastelSage =>
      isDark ? const Color(0xFFD9E5CD) : const Color(0xFFDCE7D0);

  Color get pastelPeriwinkle =>
      isDark ? const Color(0xFFD7DDF1) : const Color(0xFFD5DCF3);

  ThemeData get lightTheme => _buildTheme(Brightness.light);
  ThemeData get darkTheme => _buildTheme(Brightness.dark);

  ThemeData _buildTheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;

    final background = dark
        ? (_themeStyle == ThemeStyle.pastel
        ? const Color(0xFF17151A)
        : const Color(0xFF0A0A0A))
        : (_themeStyle == ThemeStyle.pastel
        ? const Color(0xFFF8F5FA)
        : const Color(0xFFF7F7F7));

    final surface = dark
        ? (_themeStyle == ThemeStyle.pastel
        ? const Color(0xFF211E25)
        : const Color(0xFF141414))
        : const Color(0xFFFFFFFF);

    final primary = dark
        ? (_themeStyle == ThemeStyle.pastel
        ? const Color(0xFFF7F1F8)
        : const Color(0xFFF5F5F5))
        : (_themeStyle == ThemeStyle.pastel
        ? const Color(0xFF29232D)
        : const Color(0xFF111111));

    final secondary = dark
        ? (_themeStyle == ThemeStyle.pastel
        ? const Color(0xFFBDB3C1)
        : const Color(0xFFA0A0A0))
        : (_themeStyle == ThemeStyle.pastel
        ? const Color(0xFF6F6573)
        : const Color(0xFF666666));

    final primaryAccent = _themeStyle == ThemeStyle.pastel
        ? (dark
        ? const Color(0xFFE5D9F2)
        : const Color(0xFFDCCFF2))
        : const Color(0xFF111111);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: primaryAccent,
      onPrimary: dark ? const Color(0xFF29232D) : Colors.white,
      secondary: primaryAccent,
      onSecondary: dark ? const Color(0xFF29232D) : Colors.white,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      surface: surface,
      onSurface: primary,
      surfaceContainerHighest:
      dark ? const Color(0xFF2A2630) : const Color(0xFFF0EBF3),
      onSurfaceVariant: secondary,
      outline: dark ? const Color(0xFF38323D) : const Color(0xFFE5DEE8),
      outlineVariant: dark ? const Color(0xFF302B34) : const Color(0xFFEDE7EF),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: primary,
      onInverseSurface: background,
      inversePrimary: primaryAccent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: dark ? const Color(0xFF38323D) : const Color(0xFFE5DEE8),
        thickness: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: primary,
        elevation: 0,
        centerTitle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primary,
        contentTextStyle: TextStyle(color: background),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
