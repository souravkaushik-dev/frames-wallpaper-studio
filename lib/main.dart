import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/onboarding/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'Provider/theme_provider.dart';
import 'onboarding/onboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider =
    context.watch<ThemeProvider>();

    return ScreenUtilInit(
      designSize:
      const Size(430, 932),

      minTextAdapt: true,
      splitScreenMode: true,

      builder:
          (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner:
          false,

          themeMode:
          themeProvider.themeMode,

          theme:
          _buildLightTheme(),

          darkTheme:
          _buildDarkTheme(),

          home:
          const FoliageSplashScreen(),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness:
      Brightness.light,

      scaffoldBackgroundColor:
      AppColors.lightBackground,

      colorScheme:
      const ColorScheme.light(
        surface:
        AppColors.lightSurface,
        primary:
        AppColors.lightPrimary,
        secondary:
        AppColors.accent,
        onSurface:
        AppColors.lightPrimary,
        onPrimary:
        AppColors.lightSurface,
        outline:
        AppColors.lightDivider,
      ),

      dividerColor:
      AppColors.lightDivider,

      textTheme:
      GoogleFonts.interTextTheme(
        ThemeData
            .light()
            .textTheme,
      ),

      appBarTheme:
      const AppBarTheme(
        backgroundColor:
        Colors.transparent,
        elevation: 0,
        surfaceTintColor:
        Colors.transparent,
        foregroundColor:
        AppColors.lightPrimary,
      ),

      bottomSheetTheme:
      const BottomSheetThemeData(
        backgroundColor:
        AppColors.lightSurface,
        surfaceTintColor:
        Colors.transparent,
        elevation: 0,
      ),

      cardTheme:
      CardThemeData(
        color:
        AppColors.lightSurface,
        elevation: 0,
        surfaceTintColor:
        Colors.transparent,
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(
            Radius.circular(28),
          ),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness:
      Brightness.dark,

      scaffoldBackgroundColor:
      AppColors.darkBackground,

      colorScheme:
      const ColorScheme.dark(
        surface:
        AppColors.darkSurface,
        primary:
        AppColors.darkPrimary,
        secondary:
        AppColors.accent,
        onSurface:
        AppColors.darkPrimary,
        onPrimary:
        AppColors.darkBackground,
        outline:
        AppColors.darkDivider,
      ),

      dividerColor:
      AppColors.darkDivider,

      textTheme:
      GoogleFonts.interTextTheme(
        ThemeData
            .dark()
            .textTheme,
      ),

      appBarTheme:
      const AppBarTheme(
        backgroundColor:
        Colors.transparent,
        elevation: 0,
        surfaceTintColor:
        Colors.transparent,
        foregroundColor:
        AppColors.darkPrimary,
      ),

      bottomSheetTheme:
      const BottomSheetThemeData(
        backgroundColor:
        AppColors.darkSurface,
        surfaceTintColor:
        Colors.transparent,
        elevation: 0,
      ),

      cardTheme:
      CardThemeData(
        color:
        AppColors.darkSurface,
        elevation: 0,
        surfaceTintColor:
        Colors.transparent,
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(
            Radius.circular(28),
          ),
        ),
      ),
    );
  }
}