import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/privacy_policy.dart';
import 'package:dotty/screens/terms_condition.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../Provider/theme_provider.dart';
import '../Provider/version_provider.dart';
import 'about_Screen.dart';

/// Plain Material 3 expressive settings.
///
/// Design rules:
/// - No grid
/// - No cards
/// - No pastel/decorative colors
/// - No shadows/elevation
/// - No colored tiles
/// - Large plain typography
/// - Generous vertical spacing
/// - Simple text rows
/// - Google Sans Flex for headings/titles
/// - Roboto for supporting text
class PreferencesScreen extends StatefulWidget {
const PreferencesScreen({super.key});

static Future<T?> show<T>(BuildContext context) {
return Navigator.push<T>(
context,
PageRouteBuilder(
transitionDuration: const Duration(milliseconds: 420),
reverseTransitionDuration: const Duration(milliseconds: 300),
pageBuilder: (_, __, ___) => const PreferencesScreen(),
transitionsBuilder: (_, animation, __, child) {
final curve = CurvedAnimation(
parent: animation,
curve: Curves.easeOutCubic,
reverseCurve: Curves.easeInCubic,
);

return FadeTransition(
opacity: curve,
child: SlideTransition(
position: Tween<Offset>(
begin: const Offset(0, .02),
end: Offset.zero,
).animate(curve),
child: child,
),
);
},
),
);
}

@override
State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen>
with SingleTickerProviderStateMixin {
bool _clearingCache = false;
late final AnimationController _entranceController;
ThemeMode _selectedTheme = ThemeMode.light;

bool get _isDark =>
Theme.of(context).brightness == Brightness.dark;

Color get _background =>
_isDark ? AppColors.darkBackground : AppColors.lightBackground;

Color get _primary =>
_isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

Color get _secondary =>
_isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

Color get _muted =>
_isDark ? AppColors.darkMuted : AppColors.lightMuted;

Color get _divider =>
_isDark ? AppColors.darkDivider : AppColors.lightDivider;

TextStyle _heading({
double size = 43,
Color? color,
FontWeight weight = FontWeight.w400,
}) {
return GoogleFonts.googleSansFlex(
color: color ?? _primary,
fontSize: size.sp,
fontWeight: weight,
height: 1.05,
letterSpacing: -.7,
);
}

TextStyle _title({
double size = 18,
Color? color,
FontWeight weight = FontWeight.w500,
}) {
return GoogleFonts.googleSansFlex(
color: color ?? _primary,
fontSize: size.sp,
fontWeight: weight,
height: 1.15,
letterSpacing: -.2,
);
}

TextStyle _subtitle({
double size = 13,
Color? color,
FontWeight weight = FontWeight.w400,
}) {
return GoogleFonts.roboto(
color: color ?? _muted,
fontSize: size.sp,
fontWeight: weight,
height: 1.45,
);
}

TextStyle _sectionLabel({
double size = 13,
Color? color,
}) {
return GoogleFonts.googleSansFlex(
color: color ?? _muted,
fontSize: size.sp,
fontWeight: FontWeight.w500,
height: 1.15,
letterSpacing: -.1,
);
}

@override
void initState() {
super.initState();

_entranceController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 650),
)..forward();

WidgetsBinding.instance.addPostFrameCallback((_) {
if (!mounted) return;

final provider = context.read<ThemeProvider>();

setState(() {
_selectedTheme = provider.themeMode;
});

_updateSystemUI();
});
}

@override
void didChangeDependencies() {
super.didChangeDependencies();

WidgetsBinding.instance.addPostFrameCallback((_) {
if (mounted) {
_updateSystemUI();
}
});
}

@override
void dispose() {
_entranceController.dispose();
super.dispose();
}

void _updateSystemUI() {
SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

SystemChrome.setSystemUIOverlayStyle(
SystemUiOverlayStyle(
statusBarColor: Colors.transparent,
systemNavigationBarColor: _background,
statusBarIconBrightness:
_isDark ? Brightness.light : Brightness.dark,
systemNavigationBarIconBrightness:
_isDark ? Brightness.light : Brightness.dark,
),
);
}

@override
Widget build(BuildContext context) {
final provider = context.watch<ThemeProvider>();

return Scaffold(
backgroundColor: _background,
body: SafeArea(
bottom: false,
child: CustomScrollView(
physics: const BouncingScrollPhysics(
parent: AlwaysScrollableScrollPhysics(),
),
slivers: [
SliverToBoxAdapter(
child: _animated(
index: 0,
child: _buildTopBar(),
),
),
SliverToBoxAdapter(
child: _animated(
index: 1,
child: _buildHeader(),
),
),
SliverToBoxAdapter(
child: _animated(
index: 2,
child: _buildAppearanceSection(provider),
),
),
SliverToBoxAdapter(
child: _animated(
index: 3,
child: _buildAppSection(),
),
),
SliverToBoxAdapter(
child: _animated(
index: 4,
child: _buildAboutSection(),
),
),
SliverToBoxAdapter(
child: _animated(
index: 5,
child: _buildFooter(),
),
),
SliverToBoxAdapter(
child: SizedBox(
height:
MediaQuery.of(context).viewPadding.bottom + 70.h,
),
),
],
),
),
);
}

Widget _animated({
required int index,
required Widget child,
}) {
final start = (index * .06).clamp(0.0, .55);
final end = (start + .38).clamp(0.0, 1.0);

return AnimatedBuilder(
animation: _entranceController,
child: child,
builder: (context, child) {
final value = Curves.easeOutCubic.transform(
Interval(
start,
end,
).transform(_entranceController.value),
);

return Opacity(
opacity: value,
child: Transform.translate(
offset: Offset(
0,
12.h * (1 - value),
),
child: child,
),
);
},
);
}

Widget _buildTopBar() {
return Padding(
padding: EdgeInsets.fromLTRB(
20.w,
18.h,
20.w,
0,
),
child: Align(
alignment: Alignment.centerLeft,
child: _PlainBackButton(
onTap: () {
HapticFeedback.selectionClick();

if (Navigator.canPop(context)) {
Navigator.pop(context);
}
},
),
),
);
}

Widget _buildHeader() {
return Padding(
padding: EdgeInsets.fromLTRB(
20.w,
67.h,
20.w,
42.h,
),
child: Text(
'Preferences',
style: _heading(
size: 43,
weight: FontWeight.w400,
),
),
);
}

Widget _buildAppearanceSection(ThemeProvider provider) {
return Padding(
padding: EdgeInsets.symmetric(horizontal: 20.w),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Appearance and Visuals',
style: _sectionLabel(
size: 15,
color: _muted.withOpacity(.72),
),
),
SizedBox(height: 31.h),

_PlainSettingItem(
title: 'Theme',
subtitle: _modeName(provider.themeMode),
onTap: () => _showAppearanceSheet(provider),
),

SizedBox(height: 32.h),

_PlainSettingItem(
title: 'Credits',
subtitle: 'Wallpaper and creative sources',
onTap: () => _openPage(const _CreditsScreen()),
),
],
),
);
}

Widget _buildAppSection() {
return Padding(
padding: EdgeInsets.fromLTRB(
20.w,
48.h,
20.w,
0,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'App',
style: _sectionLabel(
size: 15,
color: _muted.withOpacity(.72),
),
),
SizedBox(height: 31.h),

_PlainSettingItem(
title: 'Clear Cache',
subtitle: _clearingCache
? 'Clearing temporary files…'
    : 'Remove temporary downloaded files',
onTap: _clearingCache ? null : _clearCache,
trailing: _clearingCache
? SizedBox(
width: 17.w,
height: 17.w,
child: CircularProgressIndicator(
strokeWidth: 1.8,
color: _muted,
),
)
    : null,
),

SizedBox(height: 32.h),

_PlainSettingItem(
title: 'About',
subtitle: 'App information and version',
onTap: () => _openPage(const AboutAppScreen()),
),
],
),
);
}

Widget _buildAboutSection() {
return Padding(
padding: EdgeInsets.fromLTRB(
20.w,
48.h,
20.w,
0,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Legal',
style: _sectionLabel(
size: 15,
color: _muted.withOpacity(.72),
),
),
SizedBox(height: 31.h),

_PlainSettingItem(
title: 'Privacy Policy',
subtitle: 'How your information is handled',
onTap: () => _openPage(
const PrivacyPolicyScreen(),
),
),

SizedBox(height: 32.h),

_PlainSettingItem(
title: 'Terms and Conditions',
subtitle: 'Terms for using Dotty',
onTap: () => _openPage(
const TermsConditionsScreen(),
),
),

SizedBox(height: 48.h),

Text(
'App Info',
style: _heading(
size: 31,
weight: FontWeight.w400,
),
),

SizedBox(height: 30.h),

Text(
'frames',
style: _title(
size: 18,
weight: FontWeight.w500,
),
),

SizedBox(height: 7.h),

Text(
'${AppInfo.versionName}',
style: _subtitle(
size: 13,
color: _muted,
),
),
],
),
);
}

Widget _buildFooter() {
return Padding(
padding: EdgeInsets.fromLTRB(
20.w,
55.h,
20.w,
0,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: double.infinity,
height: 1,
color: _divider.withOpacity(.55),
),
SizedBox(height: 15.h),
Text(
'frames',
style: GoogleFonts.roboto(
color: _muted.withOpacity(.42),
fontSize: 9.sp,
fontWeight: FontWeight.w600,
letterSpacing: .8,
),
),
SizedBox(height: 5.h),
Text(
AppInfo.buildCodename,
style: GoogleFonts.roboto(
color: _muted.withOpacity(.32),
fontSize: 9.sp,
fontWeight: FontWeight.w400,
),
),
],
),
);
}

Future<void> _showAppearanceSheet(
ThemeProvider provider,
) async {
HapticFeedback.selectionClick();

await showModalBottomSheet<void>(
context: context,
backgroundColor: Colors.transparent,
isScrollControlled: true,
builder: (_) => _PlainAppearanceSheet(
provider: provider,
isDark: _isDark,
onChanged: () {
if (mounted) {
setState(() {
_selectedTheme = provider.themeMode;
});
}
},
),
);
}

Future<void> _clearCache() async {
if (_clearingCache) return;

HapticFeedback.mediumImpact();

setState(() {
_clearingCache = true;
});

try {
await DefaultCacheManager().emptyCache();

if (!mounted) return;

HapticFeedback.selectionClick();
_showSnackBar('Cache cleared');
} catch (error) {
debugPrint('Cache error: $error');

if (!mounted) return;

_showSnackBar('Could not clear cache');
} finally {
if (!mounted) return;

setState(() {
_clearingCache = false;
});
}
}

void _openPage(Widget page) {
HapticFeedback.selectionClick();

Navigator.push(
context,
PageRouteBuilder(
transitionDuration: const Duration(
milliseconds: 320,
),
reverseTransitionDuration: const Duration(
milliseconds: 240,
),
pageBuilder: (_, __, ___) => page,
transitionsBuilder: (_, animation, __, child) {
final curve = CurvedAnimation(
parent: animation,
curve: Curves.easeOutCubic,
);

return FadeTransition(
opacity: curve,
child: SlideTransition(
position: Tween<Offset>(
begin: const Offset(0, .015),
end: Offset.zero,
).animate(curve),
child: child,
),
);
},
),
);
}

void _showSnackBar(String message) {
ScaffoldMessenger.of(context)
..hideCurrentSnackBar()
..showSnackBar(
SnackBar(
behavior: SnackBarBehavior.floating,
margin: EdgeInsets.fromLTRB(
18.w,
0,
18.w,
18.h,
),
backgroundColor: _primary,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14.r),
),
content: Text(
message,
style: GoogleFonts.roboto(
color: _isDark ? Colors.black : Colors.white,
fontSize: 11.sp,
fontWeight: FontWeight.w600,
),
),
),
);
}

IconData _modeIcon(ThemeMode mode) {
switch (mode) {
case ThemeMode.light:
return Hicons.sun2LightOutline;
case ThemeMode.dark:
return Hicons.moonLightOutline;
case ThemeMode.system:
return Hicons.paletteLightOutline;
}
}

String _modeName(ThemeMode mode) {
switch (mode) {
case ThemeMode.light:
return 'Light';
case ThemeMode.dark:
return 'Dark';
case ThemeMode.system:
return 'System';
}
}
}

/// Plain text row.
/// No card, no background, no border, no shadow.
class _PlainSettingItem extends StatefulWidget {
final String title;
final String subtitle;
final VoidCallback? onTap;
final Widget? trailing;

const _PlainSettingItem({
required this.title,
required this.subtitle,
this.onTap,
this.trailing,
});

@override
State<_PlainSettingItem> createState() => _PlainSettingItemState();
}

class _PlainSettingItemState extends State<_PlainSettingItem> {
bool _pressed = false;

@override
Widget build(BuildContext context) {
final dark =
Theme.of(context).brightness == Brightness.dark;

final primary =
dark ? AppColors.darkPrimary : AppColors.lightPrimary;

final muted =
dark ? AppColors.darkMuted : AppColors.lightMuted;

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
child: AnimatedOpacity(
duration: const Duration(milliseconds: 100),
opacity: _pressed ? .55 : 1,
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
widget.title,
style: GoogleFonts.googleSansFlex(
color: primary,
fontSize: 18.sp,
fontWeight: FontWeight.w500,
height: 1.12,
letterSpacing: -.2,
),
),
SizedBox(height: 6.h),
Text(
widget.subtitle,
style: GoogleFonts.roboto(
color: muted.withOpacity(.72),
fontSize: 13.sp,
fontWeight: FontWeight.w400,
height: 1.4,
),
),
],
),
),
if (widget.trailing != null) ...[
SizedBox(width: 14.w),
Padding(
padding: EdgeInsets.only(top: 2.h),
child: widget.trailing,
),
],
],
),
),
);
}
}

class _PlainBackButton extends StatefulWidget {
final VoidCallback onTap;

const _PlainBackButton({
required this.onTap,
});

@override
State<_PlainBackButton> createState() =>
_PlainBackButtonState();
}

class _PlainBackButtonState extends State<_PlainBackButton> {
bool _pressed = false;

@override
Widget build(BuildContext context) {
final dark =
Theme.of(context).brightness == Brightness.dark;

final primary =
dark ? AppColors.darkPrimary : AppColors.lightPrimary;

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
duration: const Duration(milliseconds: 110),
scale: _pressed ? .88 : 1,
child: SizedBox(
width: 42.w,
height: 42.w,
child: Align(
alignment: Alignment.centerLeft,
child: Icon(
Hicons.left2LightOutline,
color: primary,
size: 22.sp,
),
),
),
),
);
}
}

class _PlainAppearanceSheet extends StatefulWidget {
final ThemeProvider provider;
final bool isDark;
final VoidCallback onChanged;

const _PlainAppearanceSheet({
required this.provider,
required this.isDark,
required this.onChanged,
});

@override
State<_PlainAppearanceSheet> createState() =>
_PlainAppearanceSheetState();
}

class _PlainAppearanceSheetState extends State<_PlainAppearanceSheet>
with SingleTickerProviderStateMixin {
late ThemeMode _selectedMode;
late final AnimationController _previewController;

bool get _isDark => widget.isDark;

Color get _background =>
_isDark ? AppColors.darkBackground : AppColors.lightBackground;

Color get _primary =>
_isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

Color get _muted =>
_isDark ? AppColors.darkMuted : AppColors.lightMuted;

Color get _surface =>
_isDark ? AppColors.darkSurface : AppColors.lightSurface;

Color get _soft =>
_isDark ? AppColors.darkSurfaceSoft : AppColors.lightSurfaceSoft;

Color get _divider =>
_isDark ? AppColors.darkDivider : AppColors.lightDivider;

@override
void initState() {
super.initState();

_selectedMode = widget.provider.themeMode;

_previewController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 550),
value: 1,
);
}

@override
void dispose() {
_previewController.dispose();
super.dispose();
}

Future<void> _selectTheme(ThemeMode mode) async {
if (_selectedMode == mode) return;

HapticFeedback.selectionClick();

setState(() {
_selectedMode = mode;
});

await _previewController.animateTo(
0,
curve: Curves.easeInOutCubic,
);

if (!mounted) return;

// ThemeProvider supports all three modes, including ThemeMode.system.
// Use setThemeMode so the provider persists the selected mode and
// MaterialApp can follow the device appearance when System is selected.
await widget.provider.setThemeMode(mode);

widget.onChanged();

if (mounted) {
await _previewController.animateTo(
1,
curve: Curves.easeOutCubic,
);
}
}

@override
Widget build(BuildContext context) {
final bottomInset = MediaQuery.of(context).viewInsets.bottom;

return AnimatedPadding(
duration: const Duration(milliseconds: 220),
curve: Curves.easeOutCubic,
padding: EdgeInsets.only(bottom: bottomInset),
child: DraggableScrollableSheet(
initialChildSize: .72,
minChildSize: .50,
maxChildSize: .88,
snap: true,
snapSizes: const [.72, .88],
expand: false,
builder: (context, scrollController) {
return Material(
color: _background,
clipBehavior: Clip.antiAlias,
borderRadius: BorderRadius.vertical(
top: Radius.circular(32.r),
),
child: CustomScrollView(
controller: scrollController,
physics: const BouncingScrollPhysics(),
slivers: [
SliverPadding(
padding: EdgeInsets.fromLTRB(
20.w,
10.h,
20.w,
30.h,
),
sliver: SliverList(
delegate: SliverChildListDelegate([
_buildHandle(),
SizedBox(height: 24.h),
_buildHeader(),
SizedBox(height: 26.h),
_buildPreview(),
SizedBox(height: 28.h),
_buildThemeOptions(),
SizedBox(height: 18.h),
_buildDescription(),
]),
),
),
],
),
);
},
),
);
}

Widget _buildHandle() {
return Center(
child: Container(
width: 38.w,
height: 4.h,
decoration: BoxDecoration(
color: _muted.withOpacity(.28),
borderRadius: BorderRadius.circular(99.r),
),
),
);
}

Widget _buildHeader() {
return Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Appearance',
style: GoogleFonts.googleSansFlex(
color: _primary,
fontSize: 27.sp,
fontWeight: FontWeight.w600,
height: 1.05,
letterSpacing: -.5,
),
),
SizedBox(height: 7.h),
Text(
'Choose how Dotty looks',
style: GoogleFonts.roboto(
color: _muted,
fontSize: 13.sp,
fontWeight: FontWeight.w400,
height: 1.4,
),
),
],
),
),
GestureDetector(
onTap: () => Navigator.pop(context),
child: Container(
width: 42.w,
height: 42.w,
alignment: Alignment.center,
decoration: BoxDecoration(
color: _soft,
borderRadius: BorderRadius.circular(14.r),
),
child: Icon(
Hicons.closeLightOutline,
color: _primary,
size: 19.sp,
),
),
),
],
);
}

Widget _buildPreview() {
return AnimatedBuilder(
animation: _previewController,
builder: (context, child) {
final value = Curves.easeOutCubic.transform(
_previewController.value,
);

return Opacity(
opacity: .35 + (.65 * value),
child: Transform.scale(
scale: .965 + (.035 * value),
child: child,
),
);
},
child: _ThemePreview(
mode: _selectedMode,
isDark: _isDark,
primary: _primary,
surface: _surface,
soft: _soft,
divider: _divider,
muted: _muted,
),
);
}

Widget _buildThemeOptions() {
return Column(
children: ThemeMode.values.map((mode) {
final selected = mode == _selectedMode;

return Padding(
padding: EdgeInsets.only(
bottom: mode == ThemeMode.dark ? 0 : 8.h,
),
child: _ExpressiveThemeOption(
mode: mode,
selected: selected,
isDark: _isDark,
primary: _primary,
muted: _muted,
soft: _soft,
onTap: () => _selectTheme(mode),
),
);
}).toList(),
);
}

Widget _buildDescription() {
String description;

switch (_selectedMode) {
case ThemeMode.light:
description = 'Light keeps the interface bright, soft and easy to read.';
break;
case ThemeMode.dark:
description = 'Dark uses deeper surfaces and lighter text for low-light use.';
break;
case ThemeMode.system:
description = 'System follows the appearance configured on your device.';
break;
}

return AnimatedSwitcher(
duration: const Duration(milliseconds: 220),
switchInCurve: Curves.easeOutCubic,
switchOutCurve: Curves.easeInCubic,
child: Padding(
key: ValueKey(_selectedMode),
padding: EdgeInsets.symmetric(horizontal: 2.w),
child: Text(
description,
style: GoogleFonts.roboto(
color: _muted.withOpacity(.72),
fontSize: 11.sp,
fontWeight: FontWeight.w400,
height: 1.45,
),
),
),
);
}
}

class _ExpressiveThemeOption extends StatefulWidget {
final ThemeMode mode;
final bool selected;
final bool isDark;
final Color primary;
final Color muted;
final Color soft;
final VoidCallback onTap;

const _ExpressiveThemeOption({
required this.mode,
required this.selected,
required this.isDark,
required this.primary,
required this.muted,
required this.soft,
required this.onTap,
});

@override
State<_ExpressiveThemeOption> createState() =>
_ExpressiveThemeOptionState();
}

class _ExpressiveThemeOptionState
extends State<_ExpressiveThemeOption> {
bool _pressed = false;

IconData get _icon {
switch (widget.mode) {
case ThemeMode.light:
return Hicons.sun2LightOutline;
case ThemeMode.dark:
return Hicons.moonLightOutline;
case ThemeMode.system:
return Hicons.paletteLightOutline;
}
}

String get _name {
switch (widget.mode) {
case ThemeMode.light:
return 'Light';
case ThemeMode.dark:
return 'Dark';
case ThemeMode.system:
return 'System';
}
}

@override
Widget build(BuildContext context) {
final selectedColor = widget.primary;

return GestureDetector(
behavior: HitTestBehavior.opaque,
onTapDown: (_) {
setState(() => _pressed = true);
},
onTapCancel: () {
setState(() => _pressed = false);
},
onTapUp: (_) {
setState(() => _pressed = false);
widget.onTap();
},
child: AnimatedScale(
scale: _pressed ? .985 : 1,
duration: const Duration(milliseconds: 120),
curve: Curves.easeOutCubic,
child: AnimatedContainer(
duration: const Duration(milliseconds: 220),
curve: Curves.easeOutCubic,
width: double.infinity,
padding: EdgeInsets.symmetric(
horizontal: 15.w,
vertical: 14.h,
),
decoration: BoxDecoration(
color: widget.selected
? selectedColor.withOpacity(.08)
    : Colors.transparent,
borderRadius: BorderRadius.circular(20.r),
border: Border.all(
color: widget.selected
? selectedColor.withOpacity(.35)
    : widget.soft.withOpacity(.7),
width: widget.selected ? 1.2 : 1,
),
),
child: Row(
children: [
AnimatedContainer(
duration: const Duration(milliseconds: 220),
width: 42.w,
height: 42.w,
decoration: BoxDecoration(
color: widget.selected
? selectedColor
    : widget.soft,
borderRadius: BorderRadius.circular(14.r),
),
child: Icon(
_icon,
color: widget.selected
? (widget.isDark ? Colors.black : Colors.white)
    : widget.primary,
size: 19.sp,
),
),
SizedBox(width: 13.w),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
_name,
style: GoogleFonts.googleSansFlex(
color: widget.primary,
fontSize: 16.sp,
fontWeight: widget.selected
? FontWeight.w600
    : FontWeight.w500,
height: 1.1,
),
),
SizedBox(height: 3.h),
Text(
_name == 'Light'
? 'Bright interface'
    : _name == 'Dark'
? 'Dim interface'
    : 'Follow device',
style: GoogleFonts.roboto(
color: widget.muted.withOpacity(.68),
fontSize: 10.5.sp,
fontWeight: FontWeight.w400,
),
),
],
),
),
AnimatedSwitcher(
duration: const Duration(milliseconds: 180),
transitionBuilder: (child, animation) {
return ScaleTransition(
scale: animation,
child: child,
);
},
child: widget.selected
? Container(
key: const ValueKey('selected'),
width: 27.w,
height: 27.w,
decoration: BoxDecoration(
color: widget.primary,
shape: BoxShape.circle,
),
child: Icon(
Hicons.ticket1LightOutline,
color: widget.isDark
? Colors.black
    : Colors.white,
size: 16.sp,
),
)
    : SizedBox(
key: const ValueKey('unselected'),
width: 27.w,
height: 27.w,
),
),
],
),
),
),
);
}
}

class _ThemePreview extends StatelessWidget {
final ThemeMode mode;
final bool isDark;
final Color primary;
final Color surface;
final Color soft;
final Color divider;
final Color muted;

const _ThemePreview({
required this.mode,
required this.isDark,
required this.primary,
required this.surface,
required this.soft,
required this.divider,
required this.muted,
});

@override
Widget build(BuildContext context) {
final previewDark = mode == ThemeMode.dark
? true
    : mode == ThemeMode.light
? false
    : isDark;

final previewBackground = previewDark
? const Color(0xFF101114)
    : const Color(0xFFF8F8F8);

final previewPrimary = previewDark
? Colors.white
    : const Color(0xFF171717);

final previewMuted = previewDark
? Colors.white54
    : Colors.black45;

final previewSoft = previewDark
? const Color(0xFF202126)
    : const Color(0xFFEFEFF1);

return AnimatedContainer(
duration: const Duration(milliseconds: 320),
curve: Curves.easeOutCubic,
width: double.infinity,
height: 170.h,
padding: EdgeInsets.fromLTRB(
17.w,
15.h,
17.w,
15.h,
),
decoration: BoxDecoration(
color: previewBackground,
borderRadius: BorderRadius.circular(26.r),
border: Border.all(
color: divider.withOpacity(.8),
),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 29.w,
height: 29.w,
decoration: BoxDecoration(
color: previewSoft,
borderRadius: BorderRadius.circular(10.r),
),
child: Icon(
Hicons.left2LightOutline,
color: previewPrimary,
size: 12.sp,
),
),
SizedBox(width: 9.w),
Text(
'Settings',
style: GoogleFonts.googleSansFlex(
color: previewPrimary,
fontSize: 16.sp,
fontWeight: FontWeight.w600,
),
),
],
),
SizedBox(height: 17.h),
Text(
'Appearance and Visuals',
style: GoogleFonts.googleSansFlex(
color: previewMuted,
fontSize: 8.sp,
fontWeight: FontWeight.w500,
),
),
SizedBox(height: 10.h),
Text(
'Theme',
style: GoogleFonts.googleSansFlex(
color: previewPrimary,
fontSize: 13.sp,
fontWeight: FontWeight.w500,
),
),
SizedBox(height: 3.h),
Text(
_themeName(),
style: GoogleFonts.roboto(
color: previewMuted,
fontSize: 8.sp,
fontWeight: FontWeight.w400,
),
),
const Spacer(),
Container(
width: double.infinity,
height: 1,
color: previewDark
? Colors.white12
    : Colors.black12,
),
],
),
);
}

String _themeName() {
switch (mode) {
case ThemeMode.light:
return 'Light';
case ThemeMode.dark:
return 'Dark';
case ThemeMode.system:
return 'System';
}
}
}

/// -----------------------------------------------------------------------------
/// CREDITS
/// -----------------------------------------------------------------------------

class _CreditsScreen extends StatelessWidget {
const _CreditsScreen();

static const List<_CreditSource> _wallpaperSources = [
_CreditSource(
name: 'Basic Apple Guy',
description: 'Apple-inspired wallpapers & artwork',
icon: Icons.apple_rounded,
),
_CreditSource(
name: 'Unsplash',
description: 'Photography & visual imagery',
icon: Icons.camera_alt_outlined,
),
_CreditSource(
name: 'Pinterest',
description: 'Visual references & discoveries',
icon: Icons.push_pin_outlined,
),
_CreditSource(
name: 'Pixabay',
description: 'Free images & visual resources',
icon: Icons.photo_library_outlined,
),
_CreditSource(
name: 'Wallcee',
description: 'Wallpaper resources',
icon: Icons.wallpaper_rounded,
),
_CreditSource(
name: 'WallpaperAccess',
description: 'Desktop wallpaper resources',
icon: Icons.desktop_windows_outlined,
),
_CreditSource(
name: 'Wallpaper Providers',
description: 'Independent wallpaper creators',
icon: Icons.collections_outlined,
),
];

static const List<_CreditSource> _graphicSources = [
_CreditSource(
name: 'Independent Artists',
description: 'Illustrations, artwork & visual creations',
icon: Icons.brush_outlined,
),
_CreditSource(
name: 'Photographers',
description: 'Photography used throughout the collection',
icon: Icons.camera_outlined,
),
_CreditSource(
name: 'Graphic Creators',
description: 'Graphic assets & creative resources',
icon: Icons.auto_awesome_outlined,
),
_CreditSource(
name: 'Visual Designers',
description: 'Design inspiration & visual resources',
icon: Icons.design_services_outlined,
),
];

bool _isDark(BuildContext context) =>
Theme.of(context).brightness == Brightness.dark;

Color _background(BuildContext context) =>
_isDark(context)
? AppColors.darkBackground
    : AppColors.lightBackground;

Color _primary(BuildContext context) =>
_isDark(context)
? AppColors.darkPrimary
    : AppColors.lightPrimary;

Color _muted(BuildContext context) =>
_isDark(context)
? AppColors.darkMuted
    : AppColors.lightMuted;

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: _background(context),
body: SafeArea(
bottom: false,
child: CustomScrollView(
physics: const BouncingScrollPhysics(),
slivers: [
SliverPadding(
padding: EdgeInsets.fromLTRB(
20.w,
18.h,
20.w,
50.h,
),
sliver: SliverList(
delegate: SliverChildListDelegate([
_PlainBackButton(
onTap: () {
HapticFeedback.selectionClick();
Navigator.pop(context);
},
),
SizedBox(height: 67.h),
Text(
'Credits',
style: GoogleFonts.googleSansFlex(
color: _primary(context),
fontSize: 43.sp,
fontWeight: FontWeight.w600,
height: 1.05,
letterSpacing: -.7,
),
),
SizedBox(height: 15.h),
Text(
'The creators and sources behind the visual collection.',
style: GoogleFonts.roboto(
color: _muted(context),
fontSize: 13.sp,
fontWeight: FontWeight.w400,
height: 1.45,
),
),
SizedBox(height: 48.h),
_CreditSectionPlain(
title: 'Wallpaper Sources',
sources: _wallpaperSources,
primary: _primary(context),
muted: _muted(context),
),
SizedBox(height: 48.h),
_CreditSectionPlain(
title: 'Graphic Sources',
sources: _graphicSources,
primary: _primary(context),
muted: _muted(context),
),
SizedBox(height: 48.h),
Text(
'Thank you to every creator whose work helps make '
'these screens more personal.',
style: GoogleFonts.roboto(
color: _muted(context),
fontSize: 13.sp,
fontWeight: FontWeight.w400,
height: 1.5,
),
),
SizedBox(height: 45.h),
Text(
'v${AppInfo.buildNumber}',
style: GoogleFonts.roboto(
color: _muted(context).withOpacity(.55),
fontSize: 10.sp,
fontWeight: FontWeight.w500,
),
),
]),
),
),
],
),
),
);
}
}

class _CreditSectionPlain extends StatelessWidget {
final String title;
final List<_CreditSource> sources;
final Color primary;
final Color muted;

const _CreditSectionPlain({
required this.title,
required this.sources,
required this.primary,
required this.muted,
});

@override
Widget build(BuildContext context) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: GoogleFonts.googleSansFlex(
color: muted.withOpacity(.72),
fontSize: 15.sp,
fontWeight: FontWeight.w500,
),
),
SizedBox(height: 26.h),
for (int i = 0; i < sources.length; i++) ...[
_PlainCreditItem(
source: sources[i],
primary: primary,
muted: muted,
),
if (i != sources.length - 1)
SizedBox(height: 27.h),
],
],
);
}
}

class _PlainCreditItem extends StatelessWidget {
final _CreditSource source;
final Color primary;
final Color muted;

const _PlainCreditItem({
required this.source,
required this.primary,
required this.muted,
});

@override
Widget build(BuildContext context) {
return Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
source.name,
style: GoogleFonts.googleSansFlex(
color: primary,
fontSize: 17.sp,
fontWeight: FontWeight.w500,
height: 1.15,
),
),
SizedBox(height: 5.h),
Text(
source.description,
style: GoogleFonts.roboto(
color: muted.withOpacity(.72),
fontSize: 12.sp,
fontWeight: FontWeight.w400,
height: 1.35,
),
),
],
),
),
],
);
}
}

class _CreditSource {
final String name;
final String description;
final IconData icon;

const _CreditSource({
required this.name,
required this.description,
required this.icon,
});
}
