
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/wallpaper.dart';
import '../../../../data/models/wallpaper_category.dart';
import '../../{presentation/widgets}/preview.dart';

class CategoryWallpapersScreen extends StatefulWidget {
const CategoryWallpapersScreen({
super.key,
required this.category,
});

final WallpaperCategory category;

@override
State<CategoryWallpapersScreen> createState() =>
_CategoryWallpapersScreenState();
}

class _CategoryWallpapersScreenState
extends State<CategoryWallpapersScreen>
with SingleTickerProviderStateMixin {
late final AnimationController _controller;

bool _shuffling = false;

@override
void initState() {
super.initState();

_controller = AnimationController(
vsync: this,
duration: const Duration(
milliseconds: 760,
),
)..forward();
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

// ===========================================================================
// SHUFFLE
// ===========================================================================

Future<void> _shuffle() async {
if (_shuffling) {
return;
}

HapticFeedback.mediumImpact();

setState(() {
_shuffling = true;
});

await _controller.animateBack(
0,
duration: const Duration(
milliseconds: 260,
),
curve: Curves.easeInCubic,
);

if (!mounted) {
return;
}

await Future<void>.delayed(
const Duration(
milliseconds: 70,
),
);

if (!mounted) {
return;
}

await _controller.animateTo(
1,
duration: const Duration(
milliseconds: 620,
),
curve: Curves.easeOutCubic,
);

if (!mounted) {
return;
}

setState(() {
_shuffling = false;
});
}

// ===========================================================================
// PREVIEW
// ===========================================================================

void _openPreview(
Wallpaper wallpaper,
) {
HapticFeedback.selectionClick();

Navigator.of(context).push(
PageRouteBuilder<void>(
transitionDuration:
const Duration(
milliseconds: 420,
),
reverseTransitionDuration:
const Duration(
milliseconds: 300,
),
pageBuilder: (
context,
animation,
secondaryAnimation,
) {
return WallpaperPreviewScreen(
wallpaper: wallpaper,
);
},
transitionsBuilder: (
context,
animation,
secondaryAnimation,
child,
) {
final curve = CurvedAnimation(
parent: animation,
curve: Curves.easeOutCubic,
reverseCurve:
Curves.easeInCubic,
);

return FadeTransition(
opacity: curve,
child: ScaleTransition(
scale: Tween<double>(
begin: .975,
end: 1,
).animate(curve),
child: child,
),
);
},
),
);
}

// ===========================================================================
// BUILD
// ===========================================================================

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colors = theme.colorScheme;

final wallpapers =
widget.category.wallpapers;

return Scaffold(
backgroundColor: colors.surface,
body: SafeArea(
bottom: false,
child: CustomScrollView(
physics:
const BouncingScrollPhysics(
parent:
AlwaysScrollableScrollPhysics(),
),
slivers: [
// =================================================================
// HEADER
// =================================================================

SliverToBoxAdapter(
child: _CategoryHeader(
controller: _controller,
category: widget.category,
shuffling: _shuffling,
onShuffle: _shuffle,
),
),

// =================================================================
// EMPTY
// =================================================================

if (wallpapers.isEmpty)
const SliverFillRemaining(
hasScrollBody: false,
child: _EmptyCategory(),
)

// =================================================================
// WALLPAPER GRID
// =================================================================

else
SliverPadding(
padding:
EdgeInsets.fromLTRB(
16.w,
18.h,
16.w,
110.h,
),
sliver: SliverGrid(
delegate:
SliverChildBuilderDelegate(
(
context,
index,
) {
return _WallpaperEntrance(
controller:
_controller,
index: index,
child: _WallpaperCard(
wallpaper:
wallpapers[index],
index: index,
onTap: () {
_openPreview(
wallpapers[index],
);
},
),
);
},
childCount:
wallpapers.length,
),
gridDelegate:
SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
crossAxisSpacing: 10.w,
mainAxisSpacing: 10.h,
childAspectRatio: .70,
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
// CATEGORY HEADER
// =============================================================================

class _CategoryHeader
extends StatelessWidget {
const _CategoryHeader({
required this.controller,
required this.category,
required this.shuffling,
required this.onShuffle,
});

final AnimationController controller;
final WallpaperCategory category;
final bool shuffling;
final VoidCallback onShuffle;

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colors = theme.colorScheme;

return AnimatedBuilder(
animation: controller,
builder: (
context,
child,
) {
final value = Curves
    .easeOutCubic
    .transform(
controller.value
    .clamp(
0.0,
1.0,
)
    .toDouble(),
);

return Opacity(
opacity: value,
child: Transform.translate(
offset: Offset(
0,
16.h * (1 - value),
),
child: Transform.scale(
scale:
.985 + (.015 * value),
child: child,
),
),
);
},
child: Padding(
padding: EdgeInsets.fromLTRB(
16.w,
8.h,
16.w,
0,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// =================================================================
// TOP BAR
// =================================================================

SizedBox(
height: 52.w,
child: Row(
children: [
_ExpressiveIconButton(
icon:
Hicons.left2LightOutline,
onPressed: () {
HapticFeedback
    .selectionClick();

Navigator.of(context)
    .maybePop();
},
),

const Spacer(),

_ExpressiveIconButton(
icon: Hicons
    .menuHamburger1LightOutline,
onPressed: () {},
),
],
),
),

SizedBox(height: 18.h),

// =================================================================
// TITLE
// =================================================================

Row(
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Expanded(
child: Hero(
tag:
'category-title-${category.name}',
child: Material(
color:
Colors.transparent,
child: Text(
category.name,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: theme
    .textTheme
    .displaySmall
    ?.copyWith(
fontSize: 34.sp,
height: 1,
fontWeight:
FontWeight.w800,
letterSpacing:
-1.5,
),
),
),
),
),

SizedBox(width: 10.w),

_ShuffleButton(
shuffling: shuffling,
onPressed: onShuffle,
),
],
),

SizedBox(height: 10.h),

// =================================================================
// METADATA
// =================================================================

Row(
children: [
AnimatedSwitcher(
duration:
const Duration(
milliseconds: 220,
),
transitionBuilder: (
child,
animation,
) {
return FadeTransition(
opacity: animation,
child:
SlideTransition(
position:
Tween<Offset>(
begin:
const Offset(
0,
.08,
),
end:
Offset.zero,
).animate(
animation,
),
child: child,
),
);
},
child: Text(
'${category.wallpapers.length}',
key: ValueKey(
category.wallpapers
    .length,
),
style: theme
    .textTheme
    .titleSmall
    ?.copyWith(
fontWeight:
FontWeight.w800,
color:
FleckTheme.seedColor,
),
),
),

SizedBox(width: 5.w),

Text(
category.wallpapers.length ==
1
? 'wallpaper'
    : 'wallpapers',
style: theme
    .textTheme
    .bodyMedium
    ?.copyWith(
color: colors
    .onSurfaceVariant
    .withValues(
alpha: .72,
),
fontWeight:
FontWeight.w500,
),
),
],
),

SizedBox(height: 7.h),

Text(
_description(
category.name,
),
maxLines: 2,
overflow:
TextOverflow.ellipsis,
style: theme
    .textTheme
    .bodyMedium
    ?.copyWith(
color: colors
    .onSurfaceVariant
    .withValues(
alpha: .72,
),
height: 1.35,
),
),

SizedBox(height: 18.h),

Container(
height: 1,
color: colors
    .outlineVariant
    .withValues(
alpha: .28,
),
),
],
),
),
);
}
}

// =============================================================================
// TOP ICON BUTTON
// =============================================================================

class _ExpressiveIconButton
extends StatefulWidget {
const _ExpressiveIconButton({
required this.icon,
required this.onPressed,
});

final IconData icon;
final VoidCallback onPressed;

@override
State<_ExpressiveIconButton> createState() =>
_ExpressiveIconButtonState();
}

class _ExpressiveIconButtonState
extends State<_ExpressiveIconButton> {
bool _pressed = false;

void _setPressed(bool value) {
if (_pressed == value) {
return;
}

setState(() {
_pressed = value;
});
}

@override
Widget build(BuildContext context) {
final colors =
Theme.of(context).colorScheme;

return AnimatedScale(
scale: _pressed ? .94 : 1,
duration:
const Duration(
milliseconds: 120,
),
curve: Curves.easeOutCubic,
child: Material(
color:
colors.surfaceContainerLow,
borderRadius:
BorderRadius.circular(16.r),
clipBehavior:
Clip.antiAlias,
child: InkWell(
borderRadius:
BorderRadius.circular(16.r),
onTap:
widget.onPressed,
onTapDown: (_) =>
_setPressed(true),
onTapCancel: () =>
_setPressed(false),
onTapUp: (_) =>
_setPressed(false),
child: SizedBox(
width: 46.w,
height: 46.w,
child: Icon(
widget.icon,
size: 20.sp,
color: colors
    .onSurfaceVariant,
),
),
),
),
);
}
}

// =============================================================================
// SHUFFLE BUTTON
// =============================================================================

class _ShuffleButton
extends StatefulWidget {
const _ShuffleButton({
required this.shuffling,
required this.onPressed,
});

final bool shuffling;
final VoidCallback onPressed;

@override
State<_ShuffleButton> createState() =>
_ShuffleButtonState();
}

class _ShuffleButtonState
extends State<_ShuffleButton> {
bool _pressed = false;

void _setPressed(bool value) {
if (_pressed == value) {
return;
}

setState(() {
_pressed = value;
});
}

@override
Widget build(BuildContext context) {
final colors =
Theme.of(context).colorScheme;

return AnimatedScale(
scale: _pressed ? .94 : 1,
duration:
const Duration(
milliseconds: 120,
),
curve: Curves.easeOutCubic,
child: Material(
color: FleckTheme.seedColor,
borderRadius:
BorderRadius.circular(16.r),
clipBehavior:
Clip.antiAlias,
child: InkWell(
borderRadius:
BorderRadius.circular(16.r),
onTap: widget.shuffling
? null
    : widget.onPressed,
onTapDown: widget.shuffling
? null
    : (_) =>
_setPressed(true),
onTapCancel: widget.shuffling
? null
    : () =>
_setPressed(false),
onTapUp: widget.shuffling
? null
    : (_) =>
_setPressed(false),
child: SizedBox(
width: 48.w,
height: 48.w,
child: Center(
child: AnimatedSwitcher(
duration:
const Duration(
milliseconds: 220,
),
transitionBuilder: (
child,
animation,
) {
return ScaleTransition(
scale: animation,
child: FadeTransition(
opacity: animation,
child: child,
),
);
},
child: widget.shuffling
? SizedBox(
key:
const ValueKey(
'loading',
),
width: 19.w,
height: 19.w,
child:
CircularProgressIndicator(
strokeWidth: 2,
color: colors
    .onSecondaryContainer,
),
)
    : Icon(
Hicons
    .shuffle1LightOutline,
key:
const ValueKey(
'shuffle',
),
size: 19.sp,
color: colors
    .onPrimaryContainer,
),
),
),
),
),
),
);
}
}

// =============================================================================
// WALLPAPER ENTRANCE
// =============================================================================

class _WallpaperEntrance
extends StatelessWidget {
const _WallpaperEntrance({
required this.controller,
required this.index,
required this.child,
});

final AnimationController controller;
final int index;
final Widget child;

@override
Widget build(BuildContext context) {
final start = (0.04 +
(index * .035))
    .clamp(
0.0,
.58,
)
    .toDouble();

final end = (start + .30)
    .clamp(
start + .001,
.96,
)
    .toDouble();

final animation =
CurvedAnimation(
parent: controller,
curve: Interval(
start,
end,
curve: Curves.easeOutCubic,
),
);

return AnimatedBuilder(
animation: animation,
child: child,
builder: (
context,
child,
) {
final value =
animation.value
    .clamp(
0.0,
1.0,
)
    .toDouble();

return Opacity(
opacity: value,
child: Transform.translate(
offset: Offset(
0,
18.h * (1 - value),
),
child: Transform.scale(
scale:
.985 + (.015 * value),
child: child,
),
),
);
},
);
}
}

// =============================================================================
// WALLPAPER CARD
// =============================================================================

class _WallpaperCard
extends StatefulWidget {
const _WallpaperCard({
required this.wallpaper,
required this.index,
required this.onTap,
});

final Wallpaper wallpaper;
final int index;
final VoidCallback onTap;

@override
State<_WallpaperCard> createState() =>
_WallpaperCardState();
}

class _WallpaperCardState
extends State<_WallpaperCard> {
bool _pressed = false;
bool _favorite = false;

void _setPressed(bool value) {
if (_pressed == value) {
return;
}

setState(() {
_pressed = value;
});
}

void _toggleFavorite() {
HapticFeedback.lightImpact();

setState(() {
_favorite = !_favorite;
});

// Keep your existing:
// FleckFavoritesStore.toggle(...)
// call here if this screen already
// uses the store.
}

@override
Widget build(BuildContext context) {
final colors =
Theme.of(context).colorScheme;

return AnimatedScale(
scale: _pressed ? .975 : 1,
duration:
const Duration(
milliseconds: 120,
),
curve: Curves.easeOutCubic,
child: Material(
color:
colors.surfaceContainerLow,
borderRadius:
BorderRadius.circular(20.r),
clipBehavior:
Clip.antiAlias,
child: InkWell(
borderRadius:
BorderRadius.circular(20.r),
onTap: widget.onTap,
onTapDown: (_) =>
_setPressed(true),
onTapCancel: () =>
_setPressed(false),
onTapUp: (_) =>
_setPressed(false),
child: Stack(
fit: StackFit.expand,
children: [
// =================================================================
// WALLPAPER
// =================================================================

Hero(
tag:
'wallpaper-preview-${widget.wallpaper.url}',
child: Image.network(
widget.wallpaper.url,
fit: BoxFit.cover,
filterQuality:
FilterQuality.medium,
loadingBuilder: (
context,
child,
progress,
) {
if (progress == null) {
return child;
}

return ColoredBox(
color: colors
    .surfaceContainerLow,
child: Center(
child: SizedBox(
width: 20.w,
height: 20.w,
child:
CircularProgressIndicator(
strokeWidth: 2,
color:
FleckTheme.seedColor,
),
),
),
);
},
errorBuilder: (
context,
error,
stackTrace,
) {
return ColoredBox(
color: colors
    .surfaceContainerHighest,
child: Center(
child: Icon(
Hicons
    .imageLightOutline,
color: colors
    .onSurfaceVariant
    .withValues(
alpha: .72,
),
size: 25.sp,
),
),
);
},
),
),

// =================================================================
// SCRIM
// =================================================================

Positioned(
left: 0,
right: 0,
bottom: 0,
height: 74.h,
child:
IgnorePointer(
child: DecoratedBox(
decoration:
BoxDecoration(
gradient:
LinearGradient(
begin: Alignment
    .topCenter,
end: Alignment
    .bottomCenter,
colors: [
Colors.transparent,
Colors.black
    .withValues(
alpha: .52,
),
],
),
),
),
),
),

// =================================================================
// FAVORITE
// =================================================================

Positioned(
right: 8.w,
bottom: 8.w,
child: _FavoriteButton(
favorite: _favorite,
onPressed:
_toggleFavorite,
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
// FAVORITE BUTTON
// =============================================================================

class _FavoriteButton
extends StatefulWidget {
const _FavoriteButton({
required this.favorite,
required this.onPressed,
});

final bool favorite;
final VoidCallback onPressed;

@override
State<_FavoriteButton> createState() =>
_FavoriteButtonState();
}

class _FavoriteButtonState
extends State<_FavoriteButton> {
bool _pressed = false;

void _setPressed(bool value) {
if (_pressed == value) {
return;
}

setState(() {
_pressed = value;
});
}

@override
Widget build(BuildContext context) {
final colors =
Theme.of(context).colorScheme;

final background = widget.favorite
? FleckTheme.seedColor
    : colors.surfaceContainerHigh
    .withValues(
alpha: .90,
);

final foreground = widget.favorite
? FleckTheme.onPrimary
    : colors.onSurfaceVariant;

return AnimatedScale(
scale: _pressed ? .90 : 1,
duration:
const Duration(
milliseconds: 110,
),
curve: Curves.easeOutCubic,
child: Material(
color: background,
borderRadius:
BorderRadius.circular(15.r),
clipBehavior:
Clip.antiAlias,
child: InkWell(
borderRadius:
BorderRadius.circular(15.r),
onTap: widget.onPressed,
onTapDown: (_) =>
_setPressed(true),
onTapCancel: () =>
_setPressed(false),
onTapUp: (_) =>
_setPressed(false),
child: SizedBox(
width: 40.w,
height: 40.w,
child: Center(
child: AnimatedSwitcher(
duration:
const Duration(
milliseconds: 180,
),
transitionBuilder: (
child,
animation,
) {
return ScaleTransition(
scale: animation,
child: FadeTransition(
opacity: animation,
child: child,
),
);
},
child: Icon(
widget.favorite
? Hicons.heart2Bold
    : Hicons
    .heart2LightOutline,
key: ValueKey(
widget.favorite,
),
size: 19.sp,
color: foreground,
),
),
),
),
),
),
);
}
}

// =============================================================================
// EMPTY CATEGORY
// =============================================================================

class _EmptyCategory
extends StatefulWidget {
const _EmptyCategory();

@override
State<_EmptyCategory> createState() =>
_EmptyCategoryState();
}

class _EmptyCategoryState
extends State<_EmptyCategory>
with SingleTickerProviderStateMixin {
late final AnimationController
_controller;

@override
void initState() {
super.initState();

_controller = AnimationController(
vsync: this,
duration:
const Duration(
milliseconds: 1800,
),
)..repeat(
reverse: true,
);
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colors = theme.colorScheme;

return Center(
child: AnimatedBuilder(
animation: _controller,
builder: (
context,
child,
) {
final value = Curves
    .easeInOutCubic
    .transform(
_controller.value,
);

return Transform.translate(
offset: Offset(
0,
-4.h * value,
),
child: child,
);
},
child: Padding(
padding:
EdgeInsets.symmetric(
horizontal: 28.w,
),
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [
M3EShapeContainer
    .clover4Leaf(
width: 94.w,
height: 94.w,
color:
FleckTheme.primarySoft,
child: Icon(
Hicons
    .imageLightOutline,
size: 29.sp,
color: colors
    .onPrimaryContainer,
),
),

SizedBox(height: 20.h),

Text(
'Nothing here yet',
textAlign:
TextAlign.center,
style: theme
    .textTheme
    .headlineSmall
    ?.copyWith(
fontWeight:
FontWeight.w800,
letterSpacing: -.7,
),
),

SizedBox(height: 7.h),

Text(
'This collection does not have '
'any wallpapers yet.',
textAlign:
TextAlign.center,
style: theme
    .textTheme
    .bodyMedium
    ?.copyWith(
color: colors
    .onSurfaceVariant
    .withValues(
alpha: .70,
),
height: 1.4,
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
// DESCRIPTION
// =============================================================================

String _description(
String name,
) {
final value =
name.toLowerCase();

if (value.contains('liqu')) {
return 'Colorful gradient fluid';
}

if (value.contains('glob')) {
return 'Holy drop of color magma';
}

if (value.contains('tile')) {
return 'Colorful tile inspired shapes';
}

if (value.contains('glass')) {
return 'Dazzling glassy reflections';
}

if (value.contains('fold')) {
return 'Layers shaped into space';
}

return 'A curated collection of wallpapers.';
}