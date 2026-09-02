
import 'dart:ui';

import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
  Recommended app-level theme setup:

  MaterialApp(
    theme: lightTheme,
    darkTheme: darkTheme,
    themeMode: ThemeMode.system,
    home: const FoliageOnboardingScreen(...),
  );

  With ThemeMode.system, this screen automatically follows the device.
  ThemeMode.light and ThemeMode.dark can still be used when the user chooses
  to override the device appearance.
*/

class FoliageOnboardingScreen extends StatefulWidget {
const FoliageOnboardingScreen({
super.key,
required this.onCompleted,
});

final Future<void> Function(String name) onCompleted;

@override
State<FoliageOnboardingScreen> createState() =>
_FoliageOnboardingScreenState();
}

class _FoliageOnboardingScreenState extends State<FoliageOnboardingScreen>
with TickerProviderStateMixin {
late final PageController _pageController;
late final AnimationController _introController;
late final AnimationController _floatController;

int _currentPage = 0;
bool _finishing = false;

static const int _pageCount = 3;

final List<_OnboardingData> _pages = const [
_OnboardingData(
eyebrow: 'WELCOME TO DOTSTUDIOS',
title: 'YOUR SCREEN.\nYOUR FRAME.',
description:
'A calmer place to discover wallpapers, collect your favourites and make every screen feel like yours.',
primary: 'DISCOVER',
secondary: 'CURATED WALLPAPERS',
),
_OnboardingData(
eyebrow: 'MADE FOR DISCOVERY',
title: 'FIND YOUR\nNEXT FRAME.',
description:
'Browse beautiful collections without the clutter. Keep what feels right and let the rest disappear.',
primary: 'EXPLORE',
secondary: 'QUIET • SIMPLE • VISUAL',
),
_OnboardingData(
eyebrow: 'YOUR COLLECTION STARTS HERE',
title: 'MAKE IT\nYOURS.',
description:
'Save the wallpapers you love and turn your screen into a small piece of your personality.',
primary: 'GET STARTED',
secondary: 'YOUR WALLPAPER SPACE',
),
];

@override
void initState() {
super.initState();

_pageController = PageController(
viewportFraction: 1,
);

_introController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 900),
)..forward();

_floatController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 4200),
)..repeat(reverse: true);
}

@override
void dispose() {
_pageController.dispose();
_introController.dispose();
_floatController.dispose();
super.dispose();
}

/// Uses the active Material theme, so ThemeMode.system automatically
/// follows the device's light/dark appearance.
bool get _isDark =>
Theme.of(context).brightness == Brightness.dark;

Color get _background =>
_isDark ? AppColors.darkBackground : AppColors.lightBackground;

Color get _surface =>
_isDark ? AppColors.darkSurface : AppColors.lightSurface;

Color get _softSurface =>
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

Color get _accentForeground =>
_accent.computeLuminance() > .45
? (_isDark ? AppColors.darkBackground : AppColors.lightBackground)
    : (_isDark ? AppColors.lightBackground : AppColors.darkBackground);

void _onPageChanged(int page) {
if (!mounted) return;

HapticFeedback.selectionClick();

setState(() {
_currentPage = page;
});
}

Future<void> _next() async {
if (_finishing) return;

if (_currentPage == _pageCount - 1) {
await _finish();
return;
}

HapticFeedback.selectionClick();

await _pageController.nextPage(
duration: const Duration(milliseconds: 760),
curve: Curves.easeOutCubic,
);
}

Future<void> _back() async {
if (_finishing || _currentPage == 0) return;

HapticFeedback.selectionClick();

await _pageController.previousPage(
duration: const Duration(milliseconds: 760),
curve: Curves.easeOutCubic,
);
}

Future<void> _skip() async {
if (_finishing) return;

HapticFeedback.selectionClick();
await _finish();
}

Future<void> _finish() async {
if (_finishing) return;

setState(() {
_finishing = true;
});

HapticFeedback.mediumImpact();

// Persist completion HERE, inside onboarding itself. This makes the
// one-time onboarding behavior independent of the splash callback.
try {
final prefs = await SharedPreferences.getInstance();

await prefs.setBool('frames_onboarding_completed', true);
await prefs.setBool('foliage_onboarding_completed', true);
} catch (error) {
debugPrint('Onboarding completion save error: $error');
}

if (!mounted) return;

Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
PageRouteBuilder(
transitionDuration: const Duration(milliseconds: 650),
reverseTransitionDuration: const Duration(milliseconds: 350),
pageBuilder: (_, __, ___) =>
const MainScreen(recentWallpapers: []),
transitionsBuilder: (_, animation, __, child) {
final curved = CurvedAnimation(
parent: animation,
curve: Curves.easeOutCubic,
);

return FadeTransition(
opacity: curved,
child: SlideTransition(
position: Tween<Offset>(
begin: const Offset(.025, 0),
end: Offset.zero,
).animate(curved),
child: child,
),
);
},
),
(_) => false,
);
}
@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: _background,
body: AnimatedTheme(
data: Theme.of(context),
duration: const Duration(milliseconds: 300),
curve: Curves.easeOutCubic,
child: Stack(
children: [
_buildAmbientBackground(),

SafeArea(
bottom: false,
child: Column(
children: [
_buildTopBar(),

Expanded(
child: PageView.builder(
controller: _pageController,
physics: const BouncingScrollPhysics(
parent: AlwaysScrollableScrollPhysics(),
),
onPageChanged: _onPageChanged,
itemCount: _pageCount,
itemBuilder: (_, index) {
return _buildPage(index);
},
),
),

_buildBottomArea(),
],
),
),
],
),
),
);
}

// ===========================================================================
// AMBIENT BACKGROUND
// ===========================================================================

Widget _buildAmbientBackground() {
return Positioned.fill(
child: AnimatedBuilder(
animation: Listenable.merge([
_pageController,
_floatController,
]),
builder: (context, child) {
double page = _currentPage.toDouble();

if (_pageController.hasClients &&
_pageController.page != null) {
page = _pageController.page!;
}

final drift = _floatController.value * 14;

return Stack(
children: [
Positioned(
top: -130.h,
left: -100.w + (page * 18.w),
child: _GlowOrb(
size: 300.w,
color: _accent.withOpacity(
_isDark ? .08 : .055,
),
),
),
Positioned(
top: 210.h + drift.h,
right: -150.w - (page * 12.w),
child: _GlowOrb(
size: 340.w,
color: _accent.withOpacity(
_isDark ? .045 : .035,
),
),
),
Positioned(
bottom: -180.h,
left: 40.w,
child: _GlowOrb(
size: 300.w,
color: _primary.withOpacity(
_isDark ? .025 : .018,
),
),
),
],
);
},
),
);
}

// ===========================================================================
// TOP BAR
// ===========================================================================

Widget _buildTopBar() {
return Padding(
padding: EdgeInsets.fromLTRB(
18.w,
12.h,
18.w,
0,
),
child: SizedBox(
height: 45.h,
child: Row(
children: [
AnimatedSwitcher(
duration: const Duration(milliseconds: 300),
switchInCurve: Curves.easeOutCubic,
switchOutCurve: Curves.easeInCubic,
child: _currentPage == 0
? Row(
key: const ValueKey('logo'),
children: [
Container(
width: 28.w,
height: 28.w,
decoration: BoxDecoration(
color: _primary,
borderRadius: BorderRadius.circular(9.r),
),
child: Icon(
Icons.auto_awesome_rounded,
color: _background,
size: 13.sp,
),
),
SizedBox(width: 8.w),
Text(
'DOTSTUDIOS',
style: GoogleFonts.manrope(
color: _primary,
fontSize: 7.sp,
fontWeight: FontWeight.w800,
letterSpacing: 1.1,
),
),
],
)
    : _MiniBackButton(
key: const ValueKey('back'),
background: _surface,
border: _divider,
iconColor: _primary,
onTap: _back,
),
),

const Spacer(),

AnimatedOpacity(
duration: const Duration(milliseconds: 260),
opacity: _currentPage < _pageCount - 1 ? 1 : 0,
child: IgnorePointer(
ignoring: _currentPage == _pageCount - 1,
child: GestureDetector(
onTap: _skip,
behavior: HitTestBehavior.opaque,
child: Padding(
padding: EdgeInsets.symmetric(
horizontal: 9.w,
vertical: 8.h,
),
child: Text(
'SKIP',
style: GoogleFonts.manrope(
color: _muted.withOpacity(.72),
fontSize: 7.sp,
fontWeight: FontWeight.w800,
letterSpacing: 1.6,
),
),
),
),
),
),
],
),
),
);
}

// ===========================================================================
// PAGE
// ===========================================================================

Widget _buildPage(int index) {
return AnimatedBuilder(
animation: _pageController,
builder: (context, child) {
double page = _currentPage.toDouble();

if (_pageController.hasClients &&
_pageController.page != null) {
page = _pageController.page!;
}

final distance = (page - index).abs().clamp(0.0, 1.0);
final scale = 1.0 - (distance * .035);
final opacity = 1.0 - (distance * .16);

return Opacity(
opacity: opacity,
child: Transform.scale(
scale: scale,
child: child,
),
);
},
child: _buildPageContent(index),
);
}

Widget _buildPageContent(int index) {
final data = _pages[index];

return Padding(
padding: EdgeInsets.symmetric(horizontal: 16.w),
child: Column(
children: [
SizedBox(height: 8.h),

// Main visual area.
Expanded(
flex: 7,
child: _buildPhoneComposition(index),
),

SizedBox(height: 8.h),

// Copy.
Expanded(
flex: 4,
child: _buildCopy(data),
),
],
),
);
}

// ===========================================================================
// THREE-PHONE COMPOSITION
// ===========================================================================

Widget _buildPhoneComposition(int page) {
return LayoutBuilder(
builder: (context, constraints) {
final maxHeight = constraints.maxHeight;
final phoneHeight = maxHeight.clamp(
270.h,
445.h,
);

return AnimatedBuilder(
animation: _floatController,
builder: (context, child) {
final t = _floatController.value * 2 * 3.14159;

return Stack(
alignment: Alignment.center,
children: [
// LEFT PHONE
Positioned(
left: -4.w,
top: 43.h + (4 * _sin(t + .8)).h,
child: Transform.rotate(
angle: -.055,
child: Transform.scale(
scale: .79,
child: _PhoneMockup(
height: phoneHeight,
variant: (page + 2) % 3,
isDark: _isDark,
muted: true,
),
),
),
),

// RIGHT PHONE
Positioned(
right: -4.w,
top: 43.h + (4 * _sin(t + 2.4)).h,
child: Transform.rotate(
angle: .055,
child: Transform.scale(
scale: .79,
child: _PhoneMockup(
height: phoneHeight,
variant: (page + 1) % 3,
isDark: _isDark,
muted: true,
),
),
),
),

// CENTER PHONE
Transform.translate(
offset: Offset(
0,
(4 * _sin(t)).h,
),
child: _PhoneMockup(
height: phoneHeight,
variant: page,
isDark: _isDark,
),
),
],
);
},
);
},
);
}

double _sin(double value) {
// Lightweight sine approximation is unnecessary here; use
// a bounded triangle-like motion for a subtle floating effect.
final normalized = (value % 6.28318) / 6.28318;
return normalized < .5
? (normalized * 4) - 1
    : 3 - (normalized * 4);
}

// ===========================================================================
// COPY
// ===========================================================================

Widget _buildCopy(_OnboardingData data) {
return AnimatedSwitcher(
duration: const Duration(milliseconds: 360),
switchInCurve: Curves.easeOutCubic,
switchOutCurve: Curves.easeInCubic,
transitionBuilder: (child, animation) {
return FadeTransition(
opacity: animation,
child: SlideTransition(
position: Tween<Offset>(
begin: const Offset(0, .08),
end: Offset.zero,
).animate(animation),
child: child,
),
);
},
child: Padding(
key: ValueKey(data.title),
padding: EdgeInsets.fromLTRB(
8.w,
0,
8.w,
0,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 20.w,
height: 1.h,
decoration: BoxDecoration(
color: _accent,
borderRadius: BorderRadius.circular(10.r),
),
),
SizedBox(width: 8.w),
Text(
data.eyebrow,
style: GoogleFonts.manrope(
color: _accent,
fontSize: 6.4.sp,
fontWeight: FontWeight.w800,
letterSpacing: 1.15,
),
),
],
),

SizedBox(height: 10.h),

Text(
data.title,
style: GoogleFonts.bebasNeue(
color: _primary,
fontSize: 43.sp,
height: .78,
letterSpacing: .6,
),
),

SizedBox(height: 11.h),

Text(
data.description,
style: GoogleFonts.manrope(
color: _muted,
fontSize: 9.sp,
fontWeight: FontWeight.w500,
height: 1.45,
),
),

SizedBox(height: 9.h),

Text(
data.secondary,
style: GoogleFonts.manrope(
color: _muted.withOpacity(.42),
fontSize: 5.2.sp,
fontWeight: FontWeight.w800,
letterSpacing: .8,
),
),
],
),
),
);
}

// ===========================================================================
// BOTTOM AREA
// ===========================================================================

Widget _buildBottomArea() {
final isLast = _currentPage == _pageCount - 1;

return Padding(
padding: EdgeInsets.fromLTRB(
20.w,
5.h,
20.w,
17.h,
),
child: Row(
children: [
// PAGE INDICATOR
Expanded(
child: Row(
children: List.generate(
_pageCount,
(index) {
final active = index == _currentPage;

return Expanded(
child: Padding(
padding: EdgeInsets.only(
right: index == _pageCount - 1
? 0
    : 4.w,
),
child: AnimatedContainer(
duration: const Duration(milliseconds: 380),
curve: Curves.easeOutCubic,
height: active ? 4.h : 2.h,
decoration: BoxDecoration(
color: active
? _accent
    : _divider,
borderRadius:
BorderRadius.circular(20.r),
),
),
),
);
},
),
),
),

SizedBox(width: 13.w),

// NEXT / START
GestureDetector(
onTap: _finishing
? null
    : (isLast ? _finish : _next),
child: AnimatedContainer(
duration: const Duration(milliseconds: 360),
curve: Curves.easeOutCubic,
width: isLast ? 116.w : 54.w,
height: 54.w,
decoration: BoxDecoration(
color: _surface,
borderRadius: BorderRadius.circular(18.r),
border: Border.all(
color: _divider,
width: 1,
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(
_isDark ? .18 : .07,
),
blurRadius: 20,
offset: const Offset(0, 8),
),
],
),
child: AnimatedSwitcher(
duration: const Duration(milliseconds: 240),
child: _finishing
? SizedBox(
key: const ValueKey('loading'),
width: 18.w,
height: 18.w,
child: CircularProgressIndicator(
strokeWidth: 1.8,
valueColor:
AlwaysStoppedAnimation<Color>(
_accentForeground,
),
),
)
    : isLast
? Row(
key: const ValueKey('start'),
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Text(
'START',
style: GoogleFonts.manrope(
color: _accentForeground,
fontSize: 7.sp,
fontWeight:
FontWeight.w800,
letterSpacing: 1.15,
),
),
SizedBox(width: 5.w),
Icon(
Icons.arrow_forward_rounded,
color: _primary,
size: 16.sp,
),
],
)
    : Icon(
Icons.arrow_forward_rounded,
key: const ValueKey('next'),
color: _primary,
size: 20.sp,
),
),
),
),
],
),
);
}
}

// =============================================================================
// PHONE MOCKUP
// =============================================================================

class _PhoneMockup extends StatelessWidget {
final double height;
final int variant;
final bool isDark;
final bool muted;

const _PhoneMockup({
required this.height,
required this.variant,
required this.isDark,
this.muted = false,
});

@override
Widget build(BuildContext context) {
final width = height * .485;

return SizedBox(
width: width,
height: height,
child: Container(
padding: EdgeInsets.all(5.w),
decoration: BoxDecoration(
color: Colors.black,
borderRadius: BorderRadius.circular(38.r),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(
muted ? .12 : .24,
),
blurRadius: muted ? 20 : 32,
offset: const Offset(0, 14),
),
],
),
child: Container(
clipBehavior: Clip.antiAlias,
decoration: BoxDecoration(
color: isDark
? const Color(0xFF111312)
    : const Color(0xFFF4F4F0),
borderRadius: BorderRadius.circular(33.r),
),
child: Stack(
children: [
_PhoneScreen(
variant: variant,
isDark: isDark,
),

// Dynamic Island.
Positioned(
top: 8.h,
left: width * .5 - 29.w,
child: Container(
width: 58.w,
height: 18.h,
decoration: BoxDecoration(
color: Colors.black,
borderRadius:
BorderRadius.circular(20.r),
),
),
),

// Home indicator.
Positioned(
bottom: 7.h,
left: width * .5 - 25.w,
child: Container(
width: 50.w,
height: 3.h,
decoration: BoxDecoration(
color: isDark
? Colors.white.withOpacity(.7)
    : Colors.black.withOpacity(.55),
borderRadius:
BorderRadius.circular(20.r),
),
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
// PHONE SCREEN
// =============================================================================

class _PhoneScreen extends StatelessWidget {
final int variant;
final bool isDark;

const _PhoneScreen({
required this.variant,
required this.isDark,
});

// Palette for the miniature app shown inside the onboarding phones.
// The mockup deliberately follows the real app's appearance.
Color get background => isDark
? const Color(0xFF111312)
    : const Color(0xFFF6F6F2);

Color get surface => isDark
? const Color(0xFF1D201E)
    : const Color(0xFFFFFFFF);

Color get surfaceSoft => isDark
? const Color(0xFF272B28)
    : const Color(0xFFF0F0EC);

Color get primary => isDark
? const Color(0xFFF7F7F4)
    : const Color(0xFF171817);

Color get secondary => isDark
? Colors.white.withOpacity(.70)
    : Colors.black.withOpacity(.62);

Color get muted => isDark
? Colors.white.withOpacity(.50)
    : Colors.black.withOpacity(.43);

Color get border => isDark
? Colors.white.withOpacity(.09)
    : Colors.black.withOpacity(.08);

@override
Widget build(BuildContext context) {
return Container(
color: background,
child: Padding(
padding: EdgeInsets.fromLTRB(
11.w,
38.h,
11.w,
15.h,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_miniStatusBar(),

SizedBox(height: 14.h),

Row(
children: [
Text(
variant == 0
? 'Discover'
    : variant == 1
? 'Collections'
    : 'Your Frames',
style: GoogleFonts.manrope(
color: primary,
fontSize: 12.sp,
fontWeight: FontWeight.w800,
),
),
const Spacer(),
Container(
width: 23.w,
height: 23.w,
decoration: BoxDecoration(
color: surfaceSoft,
borderRadius:
BorderRadius.circular(8.r),
border: Border.all(
color: border,
),
),
child: Icon(
variant == 2
? Icons.favorite_rounded
    : Icons.search_rounded,
color: muted,
size: 11.sp,
),
),
],
),

SizedBox(height: 12.h),

_miniSearch(),

SizedBox(height: 12.h),

Expanded(
child: _buildVariantContent(),
),
],
),
),
);
}

Widget _miniStatusBar() {
return Row(
children: [
Text(
'9:41',
style: GoogleFonts.manrope(
color: primary,
fontSize: 5.5.sp,
fontWeight: FontWeight.w700,
),
),
const Spacer(),
Icon(
Icons.signal_cellular_alt_rounded,
color: primary,
size: 7.sp,
),
SizedBox(width: 3.w),
Icon(
Icons.wifi_rounded,
color: primary,
size: 7.sp,
),
SizedBox(width: 3.w),
Icon(
Icons.battery_full_rounded,
color: primary,
size: 8.sp,
),
],
);
}

Widget _miniSearch() {
return Container(
height: 26.h,
padding: EdgeInsets.symmetric(
horizontal: 7.w,
),
decoration: BoxDecoration(
color: surface,
borderRadius:
BorderRadius.circular(9.r),
border: Border.all(
color: border,
),
),
child: Row(
children: [
Icon(
Icons.search_rounded,
color: muted,
size: 10.sp,
),
SizedBox(width: 5.w),
Text(
'Search wallpapers',
style: GoogleFonts.manrope(
color: muted,
fontSize: 5.5.sp,
fontWeight: FontWeight.w500,
),
),
],
),
);
}

Widget _buildVariantContent() {
if (variant == 1) {
return Column(
children: [
_miniCollection(
'Minimal',
Icons.crop_square_rounded,
0,
),
SizedBox(height: 7.h),
_miniCollection(
'Nature',
Icons.landscape_rounded,
1,
),
SizedBox(height: 7.h),
_miniCollection(
'Dark',
Icons.dark_mode_rounded,
2,
),
SizedBox(height: 7.h),
_miniCollection(
'Abstract',
Icons.blur_on_rounded,
3,
),
],
);
}

if (variant == 2) {
return Column(
children: [
_miniSavedCard(0),
SizedBox(height: 7.h),
_miniSavedCard(1),
SizedBox(height: 7.h),
_miniSavedCard(2),
],
);
}

return Column(
children: [
Expanded(
flex: 5,
child: _miniWallpaper(
variant: 0,
large: true,
),
),
SizedBox(height: 7.h),
Expanded(
flex: 4,
child: Row(
children: [
Expanded(
child: _miniWallpaper(variant: 1),
),
SizedBox(width: 7.w),
Expanded(
child: _miniWallpaper(variant: 2),
),
],
),
),
],
);
}

Widget _miniWallpaper({
required int variant,
bool large = false,
}) {
final gradients = [
const LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
Color(0xFFB9C7D0),
Color(0xFF657B87),
Color(0xFF26343B),
],
),
const LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomRight,
colors: [
Color(0xFFE8D6BE),
Color(0xFFB68C6C),
Color(0xFF604331),
],
),
const LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
Color(0xFFD9D2E7),
Color(0xFF9689B5),
Color(0xFF514766),
],
),
];

return Container(
decoration: BoxDecoration(
gradient: gradients[variant % gradients.length],
borderRadius:
BorderRadius.circular(13.r),
),
child: Stack(
children: [
Positioned(
right: large ? 13.w : 7.w,
top: large ? 14.h : 7.h,
child: Container(
width: large ? 30.w : 17.w,
height: large ? 30.w : 17.w,
decoration: BoxDecoration(
color: Colors.white.withOpacity(.18),
shape: BoxShape.circle,
),
),
),
if (large)
Positioned(
left: 11.w,
bottom: 10.h,
child: Text(
'FRAME',
style: GoogleFonts.bebasNeue(
color: Colors.white.withOpacity(.9),
fontSize: 18.sp,
letterSpacing: 1,
),
),
),
],
),
);
}

Widget _miniCollection(
String title,
IconData icon,
int index,
) {
return Expanded(
child: Container(
padding: EdgeInsets.all(8.w),
decoration: BoxDecoration(
color: surface,
borderRadius:
BorderRadius.circular(12.r),
border: Border.all(
color: border,
),
),
child: Row(
children: [
Container(
width: 30.w,
height: double.infinity,
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
Color.lerp(
Colors.white,
const Color(0xFF6E6E6E),
.12 + index * .12,
) ??
Colors.white,
Color.lerp(
const Color(0xFF888888),
Colors.black,
index * .15,
) ??
Colors.black,
],
),
borderRadius:
BorderRadius.circular(9.r),
),
child: Icon(
icon,
color: Colors.white.withOpacity(.85),
size: 13.sp,
),
),
SizedBox(width: 7.w),
Expanded(
child: Text(
title,
style: GoogleFonts.manrope(
color: primary,
fontSize: 6.sp,
fontWeight: FontWeight.w700,
),
),
),
Icon(
Icons.arrow_forward_ios_rounded,
color: muted,
size: 7.sp,
),
],
),
),
);
}

Widget _miniSavedCard(int index) {
return Expanded(
child: Container(
decoration: BoxDecoration(
color: surface,
borderRadius:
BorderRadius.circular(12.r),
),
child: Row(
children: [
Expanded(
flex: 3,
child: _miniWallpaper(
variant: index,
),
),
Expanded(
flex: 4,
child: Padding(
padding: EdgeInsets.all(7.w),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'SAVED FRAME',
style: GoogleFonts.manrope(
color: primary,
fontSize: 5.5.sp,
fontWeight: FontWeight.w800,
letterSpacing: .4,
),
),
SizedBox(height: 3.h),
Text(
'Ready for your screen',
style: GoogleFonts.manrope(
color: muted,
fontSize: 4.6.sp,
fontWeight: FontWeight.w500,
),
),
],
),
),
),
],
),
),
);
}
}

// =============================================================================
// SMALL UI HELPERS
// =============================================================================

class _MiniBackButton extends StatelessWidget {
final Color background;
final Color border;
final Color iconColor;
final IconData icon;
final VoidCallback onTap;

const _MiniBackButton({
super.key,
required this.background,
required this.border,
required this.iconColor,
required this.onTap,
this.icon = Icons.arrow_back_rounded,
});

@override
Widget build(BuildContext context) {
return GestureDetector(
onTap: onTap,
behavior: HitTestBehavior.opaque,
child: Container(
width: 40.w,
height: 40.w,
decoration: BoxDecoration(
color: background,
borderRadius:
BorderRadius.circular(13.r),
border: Border.all(
color: border,
),
),
child: Icon(
icon,
color: iconColor,
size: 17.sp,
),
),
);
}
}

class _GlowOrb extends StatelessWidget {
final double size;
final Color color;

const _GlowOrb({
required this.size,
required this.color,
});

@override
Widget build(BuildContext context) {
return ImageFiltered(
imageFilter: ImageFilter.blur(
sigmaX: 65,
sigmaY: 65,
),
child: Container(
width: size,
height: size,
decoration: BoxDecoration(
color: color,
shape: BoxShape.circle,
),
),
);
}
}

class _OnboardingData {
final String eyebrow;
final String title;
final String description;
final String primary;
final String secondary;

const _OnboardingData({
required this.eyebrow,
required this.title,
required this.description,
required this.primary,
required this.secondary,
});
}
