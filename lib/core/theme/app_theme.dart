import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class FleckTheme {
  // ===========================================================================
  // SINGLE SOURCE OF TRUTH
  // ===========================================================================

  static const Color seedColor =
  Color(0xFF4B5D8B);

  // ===========================================================================
  // BRAND COLORS
  // ===========================================================================

  static const Color primary =
      seedColor;

  static const Color primaryDark =
  Color(0xFF39496F);

  static const Color primaryLight =
  Color(0xFF6679A8);

  static const Color primarySoft =
  Color(0xFFDDE3F2);

  static const Color onPrimary =
  Color(0xFFFFFFFF);

  // ===========================================================================
  // LIGHT SURFACES
  // ===========================================================================

  static const Color lightBackground =
  Color(0xFFF9F9FB);

  static const Color lightSurface =
  Color(0xFFFFFFFF);

  static const Color lightSurfaceLow =
  Color(0xFFF5F5F8);

  static const Color lightSurfaceHigh =
  Color(0xFFEFEFF3);

  // ===========================================================================
  // DARK SURFACES
  // ===========================================================================

  static const Color darkBackground =
  Color(0xFF101116);

  static const Color darkSurface =
  Color(0xFF17181D);

  static const Color darkSurfaceLow =
  Color(0xFF1D1E24);

  static const Color darkSurfaceHigh =
  Color(0xFF25262D);

  // ===========================================================================
  // TEXT
  // ===========================================================================

  static const Color lightText =
  Color(0xFF17181C);

  static const Color lightTextSecondary =
  Color(0xFF65666D);

  static const Color darkText =
  Color(0xFFF3F3F7);

  static const Color darkTextSecondary =
  Color(0xFFB8B9C1);

  // ===========================================================================
  // OUTLINES
  // ===========================================================================

  static const Color lightOutline =
  Color(0xFFD9DAE0);

  static const Color darkOutline =
  Color(0xFF3B3C44);

  // ===========================================================================
  // TYPOGRAPHY
  // ===========================================================================

  static final String? fontFamily =
      GoogleFonts.josefinSans().fontFamily;

  // ===========================================================================
  // FLUTTER THEME
  // ===========================================================================

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.light,

      fontFamily: fontFamily,

      scaffoldBackgroundColor:
      lightBackground,

      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,

        primaryContainer:
        primarySoft,
        onPrimaryContainer:
        primaryDark,

        secondary: primary,
        onSecondary: onPrimary,

        secondaryContainer:
        primarySoft,
        onSecondaryContainer:
        primaryDark,

        surface: lightSurface,
        onSurface: lightText,

        surfaceContainerLowest:
        lightSurface,
        surfaceContainerLow:
        lightSurfaceLow,
        surfaceContainer:
        lightSurfaceLow,
        surfaceContainerHigh:
        lightSurfaceHigh,
        surfaceContainerHighest:
        lightSurfaceHigh,

        onSurfaceVariant:
        lightTextSecondary,

        outline:
        lightOutline,

        outlineVariant:
        lightOutline,

        error:
        Color(0xFFBA1A1A),
        onError:
        Color(0xFFFFFFFF),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.dark,

      fontFamily: fontFamily,

      scaffoldBackgroundColor:
      darkBackground,

      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        onPrimary: Color(0xFFFFFFFF),

        primaryContainer:
        primaryDark,
        onPrimaryContainer:
        primarySoft,

        secondary: primaryLight,
        onSecondary:
        Color(0xFFFFFFFF),

        secondaryContainer:
        primaryDark,
        onSecondaryContainer:
        primarySoft,

        surface: darkSurface,
        onSurface: darkText,

        surfaceContainerLowest:
        darkBackground,
        surfaceContainerLow:
        darkSurfaceLow,
        surfaceContainer:
        darkSurfaceLow,
        surfaceContainerHigh:
        darkSurfaceHigh,
        surfaceContainerHighest:
        darkSurfaceHigh,

        onSurfaceVariant:
        darkTextSecondary,

        outline:
        darkOutline,

        outlineVariant:
        darkOutline,

        error:
        Color(0xFFFFB4AB),
        onError:
        Color(0xFF690005),
      ),
    );
  }
}