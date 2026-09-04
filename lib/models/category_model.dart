import 'dart:convert';
import 'dart:ui';

import 'package:dotty/screens/category_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class CategoriesPage extends StatefulWidget {
const CategoriesPage({
super.key,
});

@override
State<CategoriesPage> createState() =>
_CategoriesPageState();
}

class _CategoriesPageState
extends State<CategoriesPage>
with SingleTickerProviderStateMixin {
// ============================================================
// DATA
// ============================================================

late Future<Map<String, dynamic>> _future;

final List<MapEntry<String, dynamic>> _categories = [];

// ============================================================
// HEADER ANIMATION
// ============================================================

late final AnimationController _headerController;

// ============================================================
// GLASS TINTS
// ============================================================

static const List<Color> _glassTints = [
Color(0xFF9CCBE0),
Color(0xFFA8D1B5),
Color(0xFFD8C59D),
Color(0xFFC7B4D8),
Color(0xFFE0AAA1),
Color(0xFFBBD0A5),
];

// ============================================================
// INIT
// ============================================================

@override
void initState() {
super.initState();

_future = fetchData();

_headerController = AnimationController(
vsync: this,
duration: const Duration(
seconds: 18,
),
)..repeat();
}

// ============================================================
// DISPOSE
// ============================================================

@override
void dispose() {
_headerController.dispose();
super.dispose();
}

// ============================================================
// THEME
// ============================================================

bool _isDark(BuildContext context) {
return Theme.of(context).brightness ==
Brightness.dark;
}

Color _background(BuildContext context) {
return _isDark(context)
? const Color(0xFF0D0E0F)
    : const Color(0xFFFFFEFC);
}

Color _primary(BuildContext context) {
return _isDark(context)
? const Color(0xFFF5F5F2)
    : const Color(0xFF111111);
}

Color _muted(BuildContext context) {
return _isDark(context)
? const Color(0xFFB5B7B8)
    : const Color(0xFF111111);
}

Color _surface(BuildContext context) {
return _isDark(context)
? const Color(0xFF17191A)
    : const Color(0xFFF4F3EF);
}

Color _glassBase(BuildContext context) {
return _isDark(context)
? Colors.white.withOpacity(.075)
    : Colors.white.withOpacity(.58);
}

Color _glassBorder(BuildContext context) {
return _isDark(context)
? Colors.white.withOpacity(.14)
    : Colors.white.withOpacity(.50);
}

Color _glassText(BuildContext context) {
return _isDark(context)
? Colors.white
    : const Color(0xFF111111);
}

Color _glassMuted(BuildContext context) {
return _isDark(context)
? Colors.white.withOpacity(.55)
    : const Color(0xFF111111).withOpacity(.48);
}

List<BoxShadow> _glassShadow(
BuildContext context,
) {
if (_isDark(context)) {
return [
BoxShadow(
color: Colors.black.withOpacity(.25),
blurRadius: 20,
offset: const Offset(
0,
8,
),
),
];
}

return [
BoxShadow(
color: Colors.black.withOpacity(.055),
blurRadius: 18,
offset: const Offset(
0,
7,
),
),
];
}

Color _emptyImageColor(
BuildContext context,
) {
return _isDark(context)
? const Color(0xFF191B1C)
    : const Color(0xFFEFEFEF);
}

// ============================================================
// SYSTEM UI
// ============================================================

SystemUiOverlayStyle _systemUiStyle(
BuildContext context,
) {
final dark = _isDark(context);

return SystemUiOverlayStyle(
statusBarColor: Colors.transparent,
systemNavigationBarColor:
_background(context),
statusBarIconBrightness:
dark
? Brightness.light
    : Brightness.dark,
systemNavigationBarIconBrightness:
dark
? Brightness.light
    : Brightness.dark,
systemNavigationBarDividerColor:
Colors.transparent,
);
}

// ============================================================
// API
// ============================================================

Future<Map<String, dynamic>> fetchData() async {
final apiUrl = dotenv.env['API_URL'];

if (apiUrl == null ||
apiUrl.trim().isEmpty) {
throw Exception(
'API_URL is not configured',
);
}

final response = await http.get(
Uri.parse(apiUrl),
);

if (response.statusCode != 200) {
throw Exception(
'Failed to load categories: '
'${response.statusCode}',
);
}

final decoded = jsonDecode(
response.body,
);

if (decoded is! Map<String, dynamic>) {
throw Exception(
'Invalid API response',
);
}

return decoded;
}

// ============================================================
// PREPARE CATEGORIES
// ============================================================

void _prepareCategories(
Map<String, dynamic> data,
) {
if (_categories.isNotEmpty) {
return;
}

final rawCategories =
data['categories'];

if (rawCategories is! Map) {
return;
}

_categories.addAll(
rawCategories.entries.map(
(entry) {
return MapEntry<String, dynamic>(
entry.key.toString(),
entry.value,
);
},
),
);
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
final background =
_background(context);

return AnnotatedRegion<
SystemUiOverlayStyle>(
value: _systemUiStyle(context),
child: Scaffold(
backgroundColor: background,

body: FutureBuilder<
Map<String, dynamic>>(
future: _future,

builder: (
context,
snapshot,
) {
// ------------------------------------------------------
// LOADING
// ------------------------------------------------------

if (snapshot.connectionState ==
ConnectionState.waiting) {
return _buildLoading();
}

// ------------------------------------------------------
// ERROR
// ------------------------------------------------------

if (snapshot.hasError) {
return _buildError();
}

// ------------------------------------------------------
// NO DATA
// ------------------------------------------------------

if (!snapshot.hasData) {
return _buildLoading();
}

// ------------------------------------------------------
// PREPARE
// ------------------------------------------------------

_prepareCategories(
snapshot.data!,
);

// ------------------------------------------------------
// EMPTY
// ------------------------------------------------------

if (_categories.isEmpty) {
return _buildEmpty();
}

// ------------------------------------------------------
// CONTENT
// ------------------------------------------------------

return _buildContent();
},
),
),
);
}

// ============================================================
// CONTENT
// ============================================================

Widget _buildContent() {
return SafeArea(
bottom: false,
child: Column(
children: [
// ========================================================
// BIG MOVING HEADER
// ========================================================

_buildHeader(),

SizedBox(
height: 2.h,
),

// ========================================================
// COLLECTIONS
// ========================================================

Expanded(
child: ListView.builder(
physics:
const BouncingScrollPhysics(
parent:
AlwaysScrollableScrollPhysics(),
),

padding: EdgeInsets.only(
left: 14.w,
right: 14.w,
bottom: 25.h,
),

itemCount:
_categories.length,

itemBuilder: (
context,
index,
) {
return _buildCollectionCard(
index,
_categories[index],
);
},
),
),
],
),
);
}

// ============================================================
// BIG MOVING HEADER
// ============================================================

Widget _buildHeader() {
final primary =
_primary(context);

final accent =
const Color(0xFF76B85B);

return SizedBox(
height: 135.h,

child: ClipRect(
child: AnimatedBuilder(
animation: _headerController,

builder: (
context,
child,
) {
return LayoutBuilder(
builder: (
context,
constraints,
) {
final screenWidth =
constraints.maxWidth;

final itemWidth =
screenWidth * 1.55;

final offset =
-(_headerController.value *
itemWidth);

return Stack(
clipBehavior:
Clip.hardEdge,

children: [
Positioned(
left: offset,
top: 32.h,

child: Row(
mainAxisSize:
MainAxisSize.min,

children: [
_HeaderGroup(
primary: primary,
accent: accent,
),

_HeaderGroup(
primary: primary,
accent: accent,
),

_HeaderGroup(
primary: primary,
accent: accent,
),

_HeaderGroup(
primary: primary,
accent: accent,
),

_HeaderGroup(
primary: primary,
accent: accent,
),
],
),
),
],
);
},
);
},
),
),
);
}

// ============================================================
// COLLECTION CARD
// ============================================================

Widget _buildCollectionCard(
int index,
MapEntry<String, dynamic> entry,
) {
// ----------------------------------------------------------
// CATEGORY
// ----------------------------------------------------------

final category =
entry.value is Map
? Map<String, dynamic>.from(
entry.value as Map,
)
    : <String, dynamic>{};

// ----------------------------------------------------------
// THUMBNAIL
// ----------------------------------------------------------

final thumbnail =
category['thumbnail']
    ?.toString() ??
'';

// ----------------------------------------------------------
// WALLPAPERS
// ----------------------------------------------------------

final rawWallpapers =
category['wallpapers'];

final wallpapers =
rawWallpapers is List
? rawWallpapers
    .map(
(item) =>
item.toString(),
)
    .where(
(item) =>
item.isNotEmpty,
)
    .toList()
    : <String>[];

// ----------------------------------------------------------
// TINT
// ----------------------------------------------------------

final glassTint =
_glassTints[
index %
_glassTints.length
];

// ----------------------------------------------------------
// CARD
// ----------------------------------------------------------

return Padding(
padding: EdgeInsets.only(
bottom: 10.h,
),

child: LayoutBuilder(
builder: (
context,
constraints,
) {
final width =
constraints.maxWidth;

// ------------------------------------------------------
// CARD HEIGHT
// ------------------------------------------------------

final cardHeight =
width * .621;

// ------------------------------------------------------
// TALLER FOLDER BODY
// ------------------------------------------------------

final panelHeight =
cardHeight * .48;

return GestureDetector(
behavior:
HitTestBehavior.opaque,

onTap: () {
HapticFeedback
    .selectionClick();

_openCategory(
title: entry.key,
wallpapers: wallpapers,
);
},

child: SizedBox(
width: width,
height: cardHeight,

child: ClipRRect(
borderRadius:
BorderRadius.circular(
38.r,
),

child: Stack(
fit: StackFit.expand,

children: [
// ============================================
// WALLPAPER
// ============================================

_buildWallpaper(
thumbnail,
),

// ============================================
// FROSTED FOLDER
// ============================================

Positioned(
left: 0,
right: 0,
bottom: 0,
height: panelHeight,

child:
_FrostedFolderPanel(
title: entry.key,
count:
wallpapers.length,
tint: glassTint,
),
),
],
),
),
),
);
},
),
);
}

// ============================================================
// WALLPAPER
// ============================================================

Widget _buildWallpaper(
String thumbnail,
) {
if (thumbnail.isEmpty) {
return ColoredBox(
color: _emptyImageColor(
context,
),
);
}

return Image.network(
thumbnail,

width: double.infinity,
height: double.infinity,

fit: BoxFit.cover,

alignment: Alignment.center,

cacheWidth: 1400,

filterQuality:
FilterQuality.high,

gaplessPlayback: true,

errorBuilder: (
context,
error,
stackTrace,
) {
return ColoredBox(
color: _emptyImageColor(
context,
),
);
},
);
}

// ============================================================
// OPEN CATEGORY
// ============================================================

void _openCategory({
required String title,
required List<String> wallpapers,
}) {
Navigator.of(context).push(
PageRouteBuilder(
transitionDuration:
const Duration(
milliseconds: 380,
),

reverseTransitionDuration:
const Duration(
milliseconds: 260,
),

pageBuilder: (
context,
animation,
secondaryAnimation,
) {
return CategoryScreen(
title: title,
wallpapers: wallpapers,
);
},

transitionsBuilder: (
context,
animation,
secondaryAnimation,
child,
) {
final curve =
CurvedAnimation(
parent: animation,
curve:
Curves.easeOutCubic,
);

return FadeTransition(
opacity: curve,

child: ScaleTransition(
scale: Tween<double>(
begin: .985,
end: 1.0,
).animate(curve),

child: child,
),
);
},
),
);
}

// ============================================================
// LOADING
// ============================================================

Widget _buildLoading() {
final background =
_background(context);

final primary =
_primary(context);

return ColoredBox(
color: background,

child: Center(
child: SizedBox(
width: 26,
height: 26,

child:
CircularProgressIndicator(
strokeWidth: 1.4,
color: primary,
),
),
),
);
}

// ============================================================
// ERROR
// ============================================================

Widget _buildError() {
final background =
_background(context);

final primary =
_primary(context);

final muted =
_muted(context);

return ColoredBox(
color: background,

child: Center(
child: Column(
mainAxisSize:
MainAxisSize.min,

children: [
// ----------------------------------------------------
// TITLE
// ----------------------------------------------------

Text(
'COLLECTIONS',

  style: GoogleFonts.googleSansFlex(
    color: primary,
    fontSize: 30.sp,
    fontWeight: FontWeight.w500,
    height: .95,
    letterSpacing: -.3,
  ),
),

SizedBox(
height: 8.h,
),

// ----------------------------------------------------
// MESSAGE
// ----------------------------------------------------

Text(
'Unable to load collections.',

style:
GoogleFonts.googleSansFlex(
color:
muted.withOpacity(.55),
fontSize: 11.sp,
),
),

SizedBox(
height: 20.h,
),

// ----------------------------------------------------
// TRY AGAIN
// ----------------------------------------------------

_AdaptiveActionButton(
text: 'TRY AGAIN',
onTap: () {
setState(() {
_categories.clear();
_future = fetchData();
});
},
),
],
),
),
);
}

// ============================================================
// EMPTY
// ============================================================

Widget _buildEmpty() {
return ColoredBox(
color: _background(context),

child: Center(
child: Text(
'NO COLLECTIONS',

style:
GoogleFonts.bebasNeue(
color: _primary(context),
fontSize: 26.sp,
height: .9,
),
),
),
);
}
}

// ============================================================================
// HEADER GROUP
// ============================================================================

class _HeaderGroup
extends StatelessWidget {
final Color primary;
final Color accent;

const _HeaderGroup({
required this.primary,
required this.accent,
});

@override
Widget build(BuildContext context) {
return Row(
mainAxisSize:
MainAxisSize.min,

children: [
Text(
'COLLECTIONS',

maxLines: 1,

style:
GoogleFonts.bebasNeue(
color: primary,
fontSize: 76.sp,
fontWeight:
FontWeight.w400,
letterSpacing: -1.5,
height: .80,
),
),

SizedBox(
width: 26.w,
),

Text(
'✱',

style:
GoogleFonts.bebasNeue(
color: accent,
fontSize: 65.sp,
fontWeight:
FontWeight.w400,
height: .8,
),
),

SizedBox(
width: 26.w,
),
],
);
}
}

// ============================================================================
// FROSTED FOLDER PANEL
// ============================================================================

class _FrostedFolderPanel
extends StatelessWidget {
final String title;
final int count;
final Color tint;

const _FrostedFolderPanel({
required this.title,
required this.count,
required this.tint,
});

@override
Widget build(BuildContext context) {
final dark =
Theme.of(context).brightness ==
Brightness.dark;

return ClipPath(
clipper:
const _FolderPanelClipper(),

child: BackdropFilter(
filter: ImageFilter.blur(
sigmaX: 24,
sigmaY: 24,
),

child: Container(
decoration: BoxDecoration(
// ----------------------------------------------------
// ADAPTIVE TINTED GLASS
// ----------------------------------------------------

color: dark
? Color.alphaBlend(
tint.withOpacity(.15),
Colors.black
    .withOpacity(.58),
)
    : Color.alphaBlend(
tint.withOpacity(.22),
Colors.white
    .withOpacity(.62),
),

// ----------------------------------------------------
// BORDER
// ----------------------------------------------------

border: Border.all(
color: dark
? Colors.white
    .withOpacity(.14)
    : Colors.white
    .withOpacity(.34),
width: .8,
),

// ----------------------------------------------------
// SHADOW
// ----------------------------------------------------

boxShadow: [
BoxShadow(
color: Colors.black
    .withOpacity(
dark ? .22 : .035,
),
blurRadius: 18,
offset: const Offset(
0,
-2,
),
),
],
),

child:
_FolderInformation(
title: title,
count: count,
tint: tint,
),
),
),
);
}
}

// ============================================================================
// FOLDER INFORMATION
// ============================================================================

class _FolderInformation
extends StatelessWidget {
final String title;
final int count;
final Color tint;

const _FolderInformation({
required this.title,
required this.count,
required this.tint,
});

@override
Widget build(
BuildContext context,
) {
final dark =
Theme.of(context).brightness ==
Brightness.dark;

final primary =
dark
? Colors.white
    : const Color(0xFF111111);

final muted =
dark
? Colors.white.withOpacity(.58)
    : const Color(0xFF111111)
    .withOpacity(.40);

return LayoutBuilder(
builder: (
context,
constraints,
) {
final contentTop =
constraints.maxHeight *
.20;

return Stack(
children: [
Positioned(
left: 0,
right: 0,
top: contentTop,
bottom: 0,

child: Padding(
padding:
EdgeInsets.only(
left: 49.w,
right: 22.w,
),

child: Row(
crossAxisAlignment:
CrossAxisAlignment
    .center,

children: [
// ==================================================
// TITLE
// ==================================================

Expanded(
child: Column(
mainAxisAlignment:
MainAxisAlignment
    .center,

crossAxisAlignment:
CrossAxisAlignment
    .start,

children: [
Text(
  title.toLowerCase()
  ,

maxLines: 1,

overflow:
//TextOverflow
    .ellipsis,

  style: GoogleFonts.googleSansFlex(
    color: primary,
    fontSize: 30.sp,
    fontWeight: FontWeight.w300,
    height: .95,
    letterSpacing: -.3,
  ),
),

SizedBox(
height: 5.h,
),

Text(
'Pro collection',

style:
GoogleFonts
    .manrope(
color: muted,
fontSize: 10.5.sp,
fontWeight:
FontWeight.w500,
letterSpacing: -.15,
),
),
],
),
),

SizedBox(
width: 8.w,
),

// ==================================================
// COUNT PILL
// ==================================================

_FolderCountPill(
count: count,
tint: tint,
),
],
),
),
),
],
);
},
);
}
}

// ============================================================================
// FOLDER COUNT PILL
// ============================================================================

class _FolderCountPill
extends StatelessWidget {
final int count;
final Color tint;

const _FolderCountPill({
required this.count,
required this.tint,
});

@override
Widget build(BuildContext context) {
final dark =
Theme.of(context).brightness ==
Brightness.dark;

final foreground =
dark
? Colors.white
    : const Color(0xFF111111);

return ClipRRect(
borderRadius:
BorderRadius.circular(100.r),

child: BackdropFilter(
filter: ImageFilter.blur(
sigmaX: 14,
sigmaY: 14,
),

child: Container(
padding:
EdgeInsets.symmetric(
horizontal: 16.w,
vertical: 9.h,
),

decoration:
BoxDecoration(
color: dark
? Colors.white
    .withOpacity(.08)
    : Colors.white
    .withOpacity(.20),

borderRadius:
BorderRadius.circular(
100.r,
),

border: Border.all(
color: dark
? Colors.white
    .withOpacity(.15)
    : Colors.white
    .withOpacity(.30),
width: .7,
),
),

child: Text(
'$count Walls',

maxLines: 1,

style:
GoogleFonts.googleSansFlex(
color: foreground,
fontSize: 10.5.sp,
fontWeight:
FontWeight.w600,
letterSpacing: -.2,
),
),
),
),
);
}
}

// ============================================================================
// ADAPTIVE ACTION BUTTON
// ============================================================================

class _AdaptiveActionButton
extends StatefulWidget {
final String text;
final VoidCallback onTap;

const _AdaptiveActionButton({
required this.text,
required this.onTap,
});

@override
State<_AdaptiveActionButton>
createState() =>
_AdaptiveActionButtonState();
}

class _AdaptiveActionButtonState
extends State<
_AdaptiveActionButton> {
bool _pressed = false;

@override
Widget build(
BuildContext context,
) {
final dark =
Theme.of(context).brightness ==
Brightness.dark;

final background =
dark
? Colors.white
    .withOpacity(.11)
    : const Color(0xFF111111);

final foreground =
dark
? Colors.white
    : Colors.white;

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
scale:
_pressed ? .95 : 1,

duration:
const Duration(
milliseconds: 130,
),

child: ClipRRect(
borderRadius:
BorderRadius.circular(
100.r,
),

child: BackdropFilter(
filter:
ImageFilter.blur(
sigmaX: 12,
sigmaY: 12,
),

child: Container(
padding:
EdgeInsets.symmetric(
horizontal: 22.w,
vertical: 12.h,
),

decoration:
BoxDecoration(
color: background,

borderRadius:
BorderRadius.circular(
100.r,
),

border: Border.all(
color: dark
? Colors.white
    .withOpacity(.14)
    : Colors.transparent,
width: .7,
),

boxShadow: [
BoxShadow(
color: Colors.black
    .withOpacity(
dark ? .20 : .08,
),
blurRadius: 14,
offset:
const Offset(
0,
5,
),
),
],
),

child: Text(
widget.text,

style:
GoogleFonts.googleSansFlex(
color: foreground,
fontSize: 9.sp,
fontWeight:
FontWeight.w500,
letterSpacing: 1,
),
),
),
),
),
),
);
}
}

// ============================================================================
// FOLDER CLIPPER
// ============================================================================

class _FolderPanelClipper
extends CustomClipper<Path> {
const _FolderPanelClipper();

@override
Path getClip(
Size size,
) {
final double w = size.width;
final double h = size.height;

final Path path = Path();

// ============================================================
// FOLDER GEOMETRY
// ============================================================

final double radius = h * .18;

final double tabStart = w * .055;

final double tabEnd = w * .335;

final double folderTop = h * .20;

// ============================================================
// TOP LEFT
// ============================================================

path.moveTo(
tabStart,
0,
);

// ============================================================
// TAB
// ============================================================

path.lineTo(
tabEnd,
0,
);

// ============================================================
// SMALL TRANSITION
// ============================================================

path.cubicTo(
tabEnd + w * .005,
0,

tabEnd + w * .008,
folderTop * .15,

tabEnd + w * .012,
folderTop * .30,
);

// ============================================================
// MAIN CURVE
// ============================================================

path.cubicTo(
tabEnd + w * .015,
folderTop * .65,

tabEnd + w * .035,
folderTop,

w * .445,
folderTop,
);

// ============================================================
// FLAT TOP
// ============================================================

path.lineTo(
w - radius,
folderTop,
);

// ============================================================
// TOP RIGHT
// ============================================================

path.quadraticBezierTo(
w,
folderTop,

w,
folderTop + radius,
);

// ============================================================
// RIGHT EDGE
// ============================================================

path.lineTo(
w,
h - radius,
);

// ============================================================
// BOTTOM RIGHT
// ============================================================

path.quadraticBezierTo(
w,
h,

w - radius,
h,
);

// ============================================================
// BOTTOM
// ============================================================

path.lineTo(
radius,
h,
);

// ============================================================
// BOTTOM LEFT
// ============================================================

path.quadraticBezierTo(
0,
h,

0,
h - radius,
);

// ============================================================
// LEFT EDGE
// ============================================================

path.lineTo(
0,
radius,
);

// ============================================================
// TOP LEFT
// ============================================================

path.quadraticBezierTo(
0,
0,

tabStart,
0,
);

path.close();

return path;
}

@override
bool shouldReclip(
covariant
_FolderPanelClipper oldClipper,
) {
return false;
}
}
