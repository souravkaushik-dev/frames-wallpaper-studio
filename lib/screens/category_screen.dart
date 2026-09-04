import 'package:dotty/constants/app_colors.dart';
import 'package:dotty/screens/previewscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryScreen extends StatefulWidget {
final String title;
final List<String> wallpapers;

const CategoryScreen({
super.key,
required this.title,
required this.wallpapers,
});

@override
State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
with SingleTickerProviderStateMixin {
late final AnimationController _headerController;

@override
void initState() {
super.initState();

_headerController = AnimationController(
vsync: this,
duration: const Duration(seconds: 18),
)..repeat();
}

@override
void dispose() {
_headerController.dispose();
super.dispose();
}

// ============================================================
// THEME
// ============================================================

bool _isDark(BuildContext context) {
return Theme.of(context).brightness == Brightness.dark;
}

Color _background(BuildContext context) {
return _isDark(context)
? AppColors.darkBackground
    : AppColors.lightBackground;
}

Color _surface(BuildContext context) {
return _isDark(context)
? AppColors.darkSurface
    : AppColors.lightSurface;
}

Color _primary(BuildContext context) {
return _isDark(context)
? AppColors.darkPrimary
    : AppColors.lightPrimary;
}

Color _muted(BuildContext context) {
return _isDark(context)
? AppColors.darkMuted
    : AppColors.lightMuted;
}

Color get _accent => AppColors.accent;

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
final background = _background(context);
final surface = _surface(context);
final primary = _primary(context);
final muted = _muted(context);

return Scaffold(
backgroundColor: background,
body: CustomScrollView(
physics: const BouncingScrollPhysics(
parent: AlwaysScrollableScrollPhysics(),
),
cacheExtent: 900,
slivers: [
// ======================================================
// BIG MOVING CATEGORY NAME
// ======================================================

SliverToBoxAdapter(
child: SafeArea(
bottom: false,
child: Padding(
padding: EdgeInsets.only(
top: 6.h,
bottom: 12.h,
),
child: _BigCategoryHeader(
title: widget.title,
controller: _headerController,
primary: primary,
accent: _accent,
),
),
),
),

// ======================================================
// BACK + COUNT GLASS CONTROLS
// ======================================================

SliverToBoxAdapter(
child: Padding(
padding: EdgeInsets.fromLTRB(
14.w,
0,
14.w,
16.h,
),
child: Row(
children: [
_BackButton(
onTap: () {
HapticFeedback.selectionClick();
Navigator.pop(context);
},
),

const Spacer(),

_GlassCountPill(
count: widget.wallpapers.length,
),
],
),
),
),

// ======================================================
// EMPTY STATE
// ======================================================

if (widget.wallpapers.isEmpty)
SliverFillRemaining(
hasScrollBody: false,
child: _EmptyState(
primary: primary,
muted: muted,
accent: _accent,
),
)

// ======================================================
// WALLPAPER GRID
// ======================================================

else
SliverPadding(
padding: EdgeInsets.fromLTRB(
14.w,
0,
14.w,
70.h,
),
sliver: SliverMasonryGrid.count(
crossAxisCount: 2,
mainAxisSpacing: 12.h,
crossAxisSpacing: 10.w,
childCount: widget.wallpapers.length,
itemBuilder: (
context,
index,
) {
final image = widget.wallpapers[index];

return RepaintBoundary(
key: ValueKey(image),
child: _WallpaperCard(
image: image,
index: index,
accent: _accent,
surface: surface,
primary: primary,
muted: muted,
onTap: () {
_openPreview(
context,
image,
);
},
),
);
},
),
),

// ======================================================
// END MARK
// ======================================================

SliverToBoxAdapter(
child: Padding(
padding: EdgeInsets.only(
bottom: 90.h,
),
child: _EndMark(
divider: _isDark(context)
? AppColors.darkDivider
    : AppColors.lightDivider,
muted: muted,
),
),
),
],
),
);
}

// ============================================================
// OPEN PREVIEW
// ============================================================

void _openPreview(
BuildContext context,
String image,
) {
HapticFeedback.selectionClick();

Navigator.push(
context,
PageRouteBuilder(
transitionDuration: const Duration(
milliseconds: 450,
),
reverseTransitionDuration: const Duration(
milliseconds: 350,
),
pageBuilder: (
context,
animation,
secondaryAnimation,
) {
return PreviewScreen(
imageUrl: image,
category: widget.title,
);
},
transitionsBuilder: (
context,
animation,
secondaryAnimation,
child,
) {
final curved = CurvedAnimation(
parent: animation,
curve: Curves.easeOutCubic,
reverseCurve: Curves.easeInCubic,
);

return FadeTransition(
opacity: Tween<double>(
begin: 0,
end: 1,
).animate(curved),
child: ScaleTransition(
scale: Tween<double>(
begin: .95,
end: 1,
).animate(curved),
child: child,
),
);
},
),
);
}
}

// ============================================================================
// ADAPTIVE GLASS SYSTEM
// ============================================================================

class _GlassStyle {
static bool isDark(BuildContext context) {
return Theme.of(context).brightness == Brightness.dark;
}

// ------------------------------------------------------------
// GLASS BACKGROUND
// ------------------------------------------------------------

static Color background(BuildContext context) {
if (isDark(context)) {
return Colors.white.withOpacity(.085);
}

return Colors.white.withOpacity(.72);
}

// ------------------------------------------------------------
// GLASS BORDER
// ------------------------------------------------------------

static Color border(BuildContext context) {
if (isDark(context)) {
return Colors.white.withOpacity(.15);
}

return Colors.white.withOpacity(.62);
}

// ------------------------------------------------------------
// MAIN FOREGROUND
// ------------------------------------------------------------

static Color foreground(BuildContext context) {
if (isDark(context)) {
return Colors.white;
}

return const Color(0xFF111111);
}

// ------------------------------------------------------------
// SECONDARY FOREGROUND
// ------------------------------------------------------------

static Color mutedForeground(BuildContext context) {
if (isDark(context)) {
return Colors.white.withOpacity(.56);
}

return const Color(0xFF111111).withOpacity(.52);
}

// ------------------------------------------------------------
// SHADOW
// ------------------------------------------------------------

static List<BoxShadow> shadow(BuildContext context) {
if (isDark(context)) {
return [
BoxShadow(
color: Colors.black.withOpacity(.20),
blurRadius: 18,
offset: const Offset(
0,
6,
),
),
];
}

return [
BoxShadow(
color: Colors.black.withOpacity(.065),
blurRadius: 16,
offset: const Offset(
0,
5,
),
),
];
}

// ------------------------------------------------------------
// PRESSED GLASS
// ------------------------------------------------------------

static Color pressedBackground(BuildContext context) {
if (isDark(context)) {
return Colors.white.withOpacity(.14);
}

return Colors.white.withOpacity(.86);
}
}

// ============================================================================
// BIG MOVING CATEGORY HEADER
// ============================================================================

class _BigCategoryHeader extends StatelessWidget {
final String title;
final AnimationController controller;
final Color primary;
final Color accent;

const _BigCategoryHeader({
required this.title,
required this.controller,
required this.primary,
required this.accent,
});

TextStyle get _titleStyle {
return GoogleFonts.bebasNeue(
color: primary,
fontSize: 94.sp,
fontWeight: FontWeight.w900,
height: .78,
letterSpacing: -1.8,
);
}

@override
Widget build(BuildContext context) {
final text = title.toUpperCase();

final gap = 22.w;
final symbolWidth = 58.w;

return SizedBox(
height: 118.h,
child: ClipRect(
child: LayoutBuilder(
builder: (
context,
constraints,
) {
final painter = TextPainter(
text: TextSpan(
text: text,
style: _titleStyle,
),
textDirection: TextDirection.ltr,
maxLines: 1,
)..layout();

final cycleWidth =
painter.width +
gap +
symbolWidth +
gap;

return AnimatedBuilder(
animation: controller,
builder: (
context,
child,
) {
final offset =
-cycleWidth +
(cycleWidth * controller.value);

return Transform.translate(
offset: Offset(
offset,
0,
),
child: OverflowBox(
alignment: Alignment.centerLeft,
maxWidth: double.infinity,
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
_MarqueeTitle(
text: text,
style: _titleStyle,
gap: gap,
symbolWidth: symbolWidth,
accent: accent,
),
_MarqueeTitle(
text: text,
style: _titleStyle,
gap: gap,
symbolWidth: symbolWidth,
accent: accent,
),
_MarqueeTitle(
text: text,
style: _titleStyle,
gap: gap,
symbolWidth: symbolWidth,
accent: accent,
),
_MarqueeTitle(
text: text,
style: _titleStyle,
gap: gap,
symbolWidth: symbolWidth,
accent: accent,
),
],
),
),
);
},
);
},
),
),
);
}
}

// ============================================================================
// MARQUEE ITEM
// ============================================================================

class _MarqueeTitle extends StatelessWidget {
final String text;
final TextStyle style;
final double gap;
final double symbolWidth;
final Color accent;

const _MarqueeTitle({
required this.text,
required this.style,
required this.gap,
required this.symbolWidth,
required this.accent,
});

@override
Widget build(BuildContext context) {
return Row(
mainAxisSize: MainAxisSize.min,
children: [
Text(
text,
maxLines: 1,
softWrap: false,
style: style,
),

SizedBox(
width: gap,
),

SizedBox(
width: symbolWidth,
child: Text(
'✱',
textAlign: TextAlign.center,
style: GoogleFonts.googleSansFlex(
color: const Color(0xFF79B85B),
fontSize: 42.sp,
height: .8,
fontWeight: FontWeight.w600,
),
),
),

SizedBox(
width: gap,
),
],
);
}
}

// ============================================================================
// ADAPTIVE GLASS BACK BUTTON
// ============================================================================

class _BackButton extends StatefulWidget {
final VoidCallback onTap;

const _BackButton({
required this.onTap,
});

@override
State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
bool _pressed = false;

@override
Widget build(BuildContext context) {
final foreground = _GlassStyle.foreground(context);

return AnimatedScale(
scale: _pressed ? .92 : 1,
duration: const Duration(
milliseconds: 120,
),
curve: Curves.easeOutCubic,
child: Material(
color: Colors.transparent,
child: InkWell(
borderRadius: BorderRadius.circular(16.r),
splashColor: foreground.withOpacity(.08),
highlightColor: Colors.transparent,
onTap: widget.onTap,
onHighlightChanged: (value) {
setState(() {
_pressed = value;
});
},
child: Ink(
width: 46.w,
height: 46.w,
child: Icon(
Hicons.left2LightOutline,
color: foreground,
size: 15.sp,
),
),
),
),
);
}
}

// ============================================================================
// WALLPAPER CARD
// ============================================================================

class _WallpaperCard extends StatefulWidget {
final String image;
final int index;

final Color accent;
final Color surface;
final Color primary;
final Color muted;

final VoidCallback onTap;

const _WallpaperCard({
required this.image,
required this.index,
required this.accent,
required this.surface,
required this.primary,
required this.muted,
required this.onTap,
});

@override
State<_WallpaperCard> createState() => _WallpaperCardState();
}

class _WallpaperCardState extends State<_WallpaperCard> {
bool _pressed = false;

static const List<double> _heights = [
285,
340,
250,
320,
300,
350,
];

// ============================================================
// RESOLUTION
// ============================================================

String _wallpaperResolution(String url) {
final value = url.toLowerCase();

if (RegExp(
r'7680\s*[x×]\s*4320',
).hasMatch(value)) {
return '8K';
}

if (RegExp(
r'5120\s*[x×]\s*2880',
).hasMatch(value)) {
return '5K';
}

if (RegExp(
r'4096\s*[x×]\s*2160',
).hasMatch(value)) {
return '4K';
}

if (RegExp(
r'3840\s*[x×]\s*2160',
).hasMatch(value)) {
return '4K';
}

if (RegExp(
r'2560\s*[x×]\s*1440',
).hasMatch(value)) {
return '2K';
}

if (RegExp(
r'2048\s*[x×]\s*1080',
).hasMatch(value)) {
return '2K';
}

if (RegExp(
r'1920\s*[x×]\s*1080',
).hasMatch(value)) {
return 'FULL HD';
}

if (RegExp(
r'1280\s*[x×]\s*720',
).hasMatch(value)) {
return 'HD';
}

if (RegExp(
r'\b8k\b',
).hasMatch(value)) {
return '8K';
}

if (RegExp(
r'\b5k\b',
).hasMatch(value)) {
return '5K';
}

if (RegExp(
r'\b4k\b',
).hasMatch(value)) {
return '4K';
}

if (RegExp(
r'\b2k\b',
).hasMatch(value)) {
return '2K';
}

if (RegExp(
r'\b1k\b',
).hasMatch(value)) {
return '1K';
}

if (RegExp(
r'\b(full[\s_-]?hd|fhd)\b',
).hasMatch(value)) {
return 'FULL HD';
}

if (RegExp(
r'\bhd\b',
).hasMatch(value)) {
return 'HD';
}

if (RegExp(
r'\b2160p\b',
).hasMatch(value)) {
return '4K';
}

if (RegExp(
r'\b1440p\b',
).hasMatch(value)) {
return '2K';
}

if (RegExp(
r'\b1080p\b',
).hasMatch(value)) {
return 'FULL HD';
}

if (RegExp(
r'\b720p\b',
).hasMatch(value)) {
return 'HD';
}

return 'HD';
}

@override
Widget build(BuildContext context) {
final height =
_heights[
widget.index % _heights.length
].h;

final resolution = _wallpaperResolution(
widget.image,
);

final glassForeground =
_GlassStyle.foreground(context);

return GestureDetector(
onTapDown: (_) {
setState(() {
_pressed = true;
});

HapticFeedback.selectionClick();
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
scale: _pressed ? .965 : 1,
duration: const Duration(
milliseconds: 150,
),
curve: Curves.easeOutCubic,
child: AnimatedContainer(
duration: const Duration(
milliseconds: 150,
),
curve: Curves.easeOutCubic,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(24.r),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(
_pressed ? .025 : .055,
),
blurRadius: _pressed ? 8 : 18,
offset: Offset(
0,
_pressed ? 3 : 8,
),
),
],
),
child: ClipRRect(
borderRadius: BorderRadius.circular(24.r),
child: SizedBox(
height: height,
child: Stack(
fit: StackFit.expand,
children: [
// ==================================================
// IMAGE
// ==================================================

Image.network(
widget.image,
fit: BoxFit.cover,
cacheWidth: 700,
filterQuality: FilterQuality.medium,
gaplessPlayback: true,
errorBuilder: (
context,
error,
stackTrace,
) {
return Container(
color: widget.surface,
alignment: Alignment.center,
child: Icon(
Icons.broken_image_outlined,
color: widget.muted,
size: 25.sp,
),
);
},
),

// ==================================================
// SUBTLE IMAGE GRADIENT
// ==================================================

Positioned.fill(
child: IgnorePointer(
child: DecoratedBox(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
stops: const [
0,
.65,
1,
],
colors: [
Colors.black.withOpacity(.02),
Colors.transparent,
Colors.black.withOpacity(.13),
],
),
),
),
),
),

// ==================================================
// ADAPTIVE GLASS RESOLUTION PILL
// ==================================================

Positioned(
top: 11.h,
left: 11.w,
child: _GlassResolutionPill(
text: resolution,
),
),

// ==================================================
// ADAPTIVE GLASS OPEN BUTTON
// ==================================================

Positioned(
right: 11.w,
bottom: 11.h,
child: AnimatedContainer(
duration: const Duration(
milliseconds: 140,
),
width: _pressed ? 34.w : 38.w,
height: _pressed ? 34.w : 38.w,
decoration: BoxDecoration(
color: _pressed
? _GlassStyle.pressedBackground(
context,
)
    : _GlassStyle.background(
context,
),
shape: BoxShape.circle,
border: Border.all(
color: _GlassStyle.border(
context,
),
width: .7,
),
boxShadow:
_GlassStyle.shadow(
context,
),
),
child: Icon(
Icons.arrow_outward_rounded,
color: glassForeground,
size: 15.sp,
),
),
),
],
),
),
),
),
),
);
}
}

// ============================================================================
// GLASS RESOLUTION PILL
// ============================================================================

class _GlassResolutionPill extends StatelessWidget {
final String text;

const _GlassResolutionPill({
required this.text,
});

@override
Widget build(BuildContext context) {
final foreground =
_GlassStyle.foreground(context);

return Container(
padding: EdgeInsets.symmetric(
horizontal: 9.w,
vertical: 6.h,
),
decoration: BoxDecoration(
color: _GlassStyle.background(context),
borderRadius: BorderRadius.circular(10.r),
border: Border.all(
color: _GlassStyle.border(context),
width: .7,
),
boxShadow: _GlassStyle.shadow(context),
),
child: Text(
text,
style: GoogleFonts.googleSansFlex(
color: foreground,
fontSize: 6.5.sp,
fontWeight: FontWeight.w400,
letterSpacing: .8,
),
),
);
}
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class _EmptyState extends StatelessWidget {
final Color primary;
final Color muted;
final Color accent;

const _EmptyState({
required this.primary,
required this.muted,
required this.accent,
});

@override
Widget build(BuildContext context) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Container(
width: 62.w,
height: 62.w,
decoration: BoxDecoration(
color: accent.withOpacity(.08),
shape: BoxShape.circle,
),
child: Icon(
Icons.image_not_supported_outlined,
color: accent,
size: 26.sp,
),
),

SizedBox(
height: 15.h,
),

Text(
'EMPTY',
style: GoogleFonts.bebasNeue(
color: primary,
fontSize: 27.sp,
height: .9,
),
),

SizedBox(
height: 5.h,
),

Text(
'Nothing here yet.',
style: GoogleFonts.googleSansFlex(
color: muted,
fontSize: 10.sp,
fontWeight: FontWeight.w400,
),
),
],
),
);
}
}

// ============================================================================
// END MARK
// ============================================================================

class _EndMark extends StatelessWidget {
final Color divider;
final Color muted;

const _EndMark({
required this.divider,
required this.muted,
});

@override
Widget build(BuildContext context) {
return Column(
children: [
Container(
width: 30.w,
height: 1,
color: divider,
),

SizedBox(
height: 10.h,
),

Text(
'END',
style: GoogleFonts.googleSansFlex(
color: muted.withOpacity(.35),
fontSize: 6.sp,
fontWeight: FontWeight.w500,
letterSpacing: 2,
),
),
],
);
}
}

// ============================================================================
// ADAPTIVE GLASS COUNT PILL
// ============================================================================

class _GlassCountPill extends StatelessWidget {
final int count;

const _GlassCountPill({
required this.count,
});

@override
Widget build(BuildContext context) {
final foreground =
_GlassStyle.foreground(context);

return Container(
padding: EdgeInsets.symmetric(
horizontal: 13.w,
vertical: 9.h,
),
decoration: BoxDecoration(
color: _GlassStyle.background(context),
borderRadius: BorderRadius.circular(14.r),
border: Border.all(
color: _GlassStyle.border(context),
width: .8,
),
boxShadow: _GlassStyle.shadow(context),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
// --------------------------------------------------------
// DOT
// --------------------------------------------------------

Container(
width: 5.w,
height: 5.w,
decoration: BoxDecoration(
color: foreground.withOpacity(.55),
shape: BoxShape.circle,
),
),

SizedBox(
width: 7.w,
),

// --------------------------------------------------------
// COUNT
// --------------------------------------------------------

Text(
count.toString().padLeft(2, '0'),
style: GoogleFonts.googleSansFlex(
color: foreground,
fontSize: 9.sp,
fontWeight: FontWeight.w500,
letterSpacing: .4,
),
),

SizedBox(
width: 5.w,
),

// --------------------------------------------------------
// LABEL
// --------------------------------------------------------

Text(
'WALLPAPERS',
style: GoogleFonts.googleSansFlex(
color: _GlassStyle.mutedForeground(
context,
),
fontSize: 6.sp,
fontWeight: FontWeight.w400,
letterSpacing: .8,
),
),
],
),
);
}
}
