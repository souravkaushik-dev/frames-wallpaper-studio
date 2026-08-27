import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fleck_app_bar.dart';
import '../../../data/models/wallpaper.dart';
import '../../../data/repositories/wallpaper_repository.dart';
import '../../categories/{presentation/widgets}/preview.dart';
import '../../favorites/presentation/widgets/ffav_store.dart';

class FleckHomeScreen extends StatefulWidget {
const FleckHomeScreen({
super.key,
});

@override
State<FleckHomeScreen> createState() =>
_FleckHomeScreenState();
}

class _FleckHomeScreenState
extends State<FleckHomeScreen> {
final WallpaperRepository _repository =
WallpaperRepository();

late Future<WallpaperData> _future;

@override
void initState() {
super.initState();

_future = _repository.getAll();
}

Future<void> _refresh() async {
final future = _repository.getAll();

setState(() {
_future = future;
});

await future;
}

@override
void dispose() {
_repository.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
final colors = Theme.of(context).colorScheme;

return Scaffold(
backgroundColor: colors.surface,
body: SafeArea(
bottom: false,
child: FutureBuilder<WallpaperData>(
future: _future,
builder: (
context,
snapshot,
) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const _LoadingView();
}

if (snapshot.hasError ||
snapshot.data == null) {
return _ErrorView(
onRetry: _refresh,
);
}

return _HomeContent(
data: snapshot.data!,
onRefresh: _refresh,
);
},
),
),
);
}
}

// =============================================================================
// HOME CONTENT
// =============================================================================

class _HomeContent extends StatefulWidget {
const _HomeContent({
required this.data,
required this.onRefresh,
});

final WallpaperData data;
final Future<void> Function() onRefresh;

@override
State<_HomeContent> createState() =>
_HomeContentState();
}

class _HomeContentState
extends State<_HomeContent>
with SingleTickerProviderStateMixin {
String _query = '';

late final AnimationController
_entranceController;

@override
void initState() {
super.initState();

_entranceController =
AnimationController(
vsync: this,
duration: const Duration(
milliseconds: 1100,
),
)..forward();
}

@override
void dispose() {
_entranceController.dispose();
super.dispose();
}

List<Wallpaper> get _allWallpapers {
final wallpapers = <Wallpaper>[];
final seen = <String>{};

final source = [
...widget.data.trending,
...widget.data.categories.expand(
(category) => category.wallpapers,
),
];

for (final wallpaper in source) {
if (seen.add(wallpaper.url)) {
wallpapers.add(wallpaper);
}
}

return wallpapers;
}

// ===========================================================================
// SEARCH
// ===========================================================================

List<Wallpaper> get _filteredWallpapers {
final query = _query.trim().toLowerCase();

if (query.isEmpty) {
return widget.data.trending;
}

// Search the complete Fleck wallpaper collection, not only Trending.
// A wallpaper can be discovered by:
// - category (e.g. Foliage, Floral, Ferro, Smudges)
// - wallpaper title derived from the image filename
// - words contained in its image URL / filename
// - multiple words typed in any order
final terms = query
    .split(RegExp(r'[^a-z0-9]+'))
    .where((term) => term.isNotEmpty)
    .toList();

return _allWallpapers.where((wallpaper) {
final url = wallpaper.url.toLowerCase();
final category =
wallpaper.category?.trim().toLowerCase() ?? '';

// The wallpaper preview derives its display title from the
// image filename in the URL. Use the same title for search.
final title = _wallpaperTitle(wallpaper.url);

final searchableText = [
title,
category,
url,
].join(' ');

// Every word must be present. This makes searches such as
// "dark foliage" predictable instead of requiring an exact phrase.
return terms.every(searchableText.contains);
}).toList();
}

String _wallpaperTitle(String url) {
final uri = Uri.tryParse(url);

if (uri == null || uri.pathSegments.isEmpty) {
return '';
}

var filename = uri.pathSegments.last;

filename = filename.split('?').first;
filename = filename.split('#').first;

filename = filename.replaceFirst(
RegExp(
r'\.(jpg|jpeg|png|webp|avif|gif)$',
caseSensitive: false,
),
'',
);

filename = filename.replaceAll(
RegExp(r'[_\-]+'),
' ',
);

filename = filename.replaceAll(
RegExp(r'\s+'),
' ',
).trim().toLowerCase();

return filename;
}

void _onSearch(String value) {
final nextQuery = value.trim();

if (_query == nextQuery) {
return;
}

setState(() {
_query = nextQuery;
});
}

@override
Widget build(BuildContext context) {
final colors = Theme.of(context).colorScheme;

final searching = _query.isNotEmpty;
final wallpapers =
_filteredWallpapers;

return RefreshIndicator.adaptive(
color: FleckTheme.seedColor,
backgroundColor:
colors.surfaceContainerHigh,
onRefresh: widget.onRefresh,
displacement: 36.h,
child: CustomScrollView(
physics: const BouncingScrollPhysics(
parent:
AlwaysScrollableScrollPhysics(),
),
slivers: [
// ===================================================================
// APP BAR
// ===================================================================

SliverToBoxAdapter(
child: _ExpressiveEntrance(
controller:
_entranceController,
begin: 0,
end: .28,
child: FleckAppBar(
title: 'Fleck',
searchHint:
'Search wallpapers',
onSearchChanged:
_onSearch,
),
),
),

// ===================================================================
// DISCOVER
// ===================================================================

SliverToBoxAdapter(
child: AnimatedSwitcher(
duration: const Duration(
milliseconds: 420,
),
reverseDuration:
const Duration(
milliseconds: 260,
),
switchInCurve:
Curves.easeOutCubic,
switchOutCurve:
Curves.easeInCubic,
transitionBuilder: (
child,
animation,
) {
return FadeTransition(
opacity: animation,
child: SizeTransition(
sizeFactor: animation,
axisAlignment: -1,
child: child,
),
);
},
child: _DiscoverHeader(
key: ValueKey(
'${searching}_$_query',
),
title: searching
? 'Results'
    : 'Discover',
count: searching
? wallpapers.length
    : widget.data.trending.length,
searching: searching,
),
),
),

// ===================================================================
// WALLPAPERS
// ===================================================================

if (searching)
if (wallpapers.isEmpty)
const SliverFillRemaining(
hasScrollBody: false,
child: _EmptySearch(),
)
else
SliverPadding(
padding: EdgeInsets.fromLTRB(
20.w,
0,
20.w,
0,
),
sliver: _WallpaperGrid(
wallpapers: wallpapers,
),
)
else ...[
SliverPadding(
padding: EdgeInsets.symmetric(
horizontal: 20.w,
),
sliver: _WallpaperGrid(
wallpapers:
widget.data.trending,
),
),

// ===============================================================
// COLLECTION HEADER
// ===============================================================

SliverToBoxAdapter(
child: Padding(
padding: EdgeInsets.fromLTRB(
20.w,
44.h,
20.w,
18.h,
),
child: _CollectionHeader(
count:
widget.data.categories.length,
onPressed: () {
if (widget
    .data
    .categories
    .isEmpty) {
return;
}

Navigator.of(context)
    .push(
MaterialPageRoute<void>(
builder: (_) =>
_CollectionWallpapersScreen(
category: widget
    .data
    .categories
    .first,
),
),
);
},
),
),
),

// ===============================================================
// COLLECTIONS
// ===============================================================

SliverToBoxAdapter(
child: _Collections(
categories:
widget.data.categories,
),
),
],

SliverToBoxAdapter(
child: SizedBox(
height: 120.h,
),
),
],
),
);
}
}

// =============================================================================
// DISCOVER HEADER
// =============================================================================

class _DiscoverHeader
extends StatelessWidget {
const _DiscoverHeader({
super.key,
required this.title,
required this.count,
required this.searching,
});

final String title;
final int count;
final bool searching;

@override
Widget build(BuildContext context) {
final theme =
Theme.of(context);
final colors = theme.colorScheme;

return Padding(
padding: EdgeInsets.fromLTRB(
20.w,
28.h,
20.w,
20.h,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Expanded(
child: Text(
title,
style: theme.textTheme
    .displaySmall
    ?.copyWith(
fontSize: 40.sp,
height: 1,
fontWeight:
FontWeight.w800,
letterSpacing: -2.4,
),
),
),

const SizedBox(width: 12),

_AnimatedCountBadge(
count: count,
),
],
),

SizedBox(height: 9.h),

AnimatedSwitcher(
duration: const Duration(
milliseconds: 280,
),
child: Text(
searching
? 'Results from your Fleck collection.'
    : 'A little something for every mood.',
key: ValueKey(searching),
style: theme.textTheme
    .bodyLarge
    ?.copyWith(
color:
colors.onSurfaceVariant,
fontWeight:
FontWeight.w500,
height: 1.35,
),
),
),
],
),
);
}
}

// =============================================================================
// COUNT BADGE
// =============================================================================

class _AnimatedCountBadge
extends StatelessWidget {
const _AnimatedCountBadge({
required this.count,
});

final int count;

@override
Widget build(BuildContext context) {
final colors = Theme.of(context).colorScheme;

return TweenAnimationBuilder<double>(
tween: Tween<double>(
begin: .72,
end: 1,
),
duration: const Duration(
milliseconds: 520,
),
curve: Curves.easeOutBack,
builder: (
context,
scale,
child,
) {
return Transform.scale(
scale: scale,
child: child,
);
},
child: Material(
color: colors.secondaryContainer,
borderRadius:
BorderRadius.circular(17.r),
child: Padding(
padding: EdgeInsets.symmetric(
horizontal: 12.w,
vertical: 8.h,
),
child: Text(
'$count',
style: TextStyle(
color:
colors.onSecondaryContainer,
fontSize: 13.sp,
fontWeight: FontWeight.w800,
),
),
),
),
);
}
}

// =============================================================================
// COLLECTION HEADER
// =============================================================================

class _CollectionHeader
extends StatelessWidget {
const _CollectionHeader({
required this.count,
required this.onPressed,
});

final int count;
final VoidCallback onPressed;

@override
Widget build(BuildContext context) {
final theme =
Theme.of(context);
final colors = theme.colorScheme;

return Row(
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Collections',
style: theme.textTheme
    .headlineMedium
    ?.copyWith(
fontSize: 30.sp,
fontWeight:
FontWeight.w800,
letterSpacing: -1.3,
),
),
SizedBox(height: 4.h),
Text(
'$count collections to explore',
style: theme.textTheme
    .bodyMedium
    ?.copyWith(
color:
colors.onSurfaceVariant,
fontWeight:
FontWeight.w500,
),
),
],
),
),

_ExpressiveIconButton(
icon:
Hicons.right2LightOutline,
onPressed: onPressed,
size: 48.w,
),
],
);
}
}

// =============================================================================
// WALLPAPER GRID
// =============================================================================

class _WallpaperGrid
extends StatelessWidget {
const _WallpaperGrid({
required this.wallpapers,
});

final List<Wallpaper> wallpapers;

@override
Widget build(BuildContext context) {
return SliverGrid(
delegate:
SliverChildBuilderDelegate(
(context, index) {
return _WallpaperCard(
wallpaper:
wallpapers[index],
index: index,
);
},
childCount: wallpapers.length,
),
gridDelegate:
SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
crossAxisSpacing: 12.w,
mainAxisSpacing: 14.h,
childAspectRatio: .68,
),
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
});

final Wallpaper wallpaper;
final int index;

@override
State<_WallpaperCard> createState() =>
_WallpaperCardState();
}

class _WallpaperCardState
extends State<_WallpaperCard> {
bool _pressed = false;

void _openPreview() {
HapticFeedback.selectionClick();

Navigator.of(context).push(
PageRouteBuilder<void>(
transitionDuration:
const Duration(
milliseconds: 650,
),
reverseTransitionDuration:
const Duration(
milliseconds: 450,
),
pageBuilder: (
context,
animation,
secondaryAnimation,
) {
return WallpaperPreviewScreen(
wallpaper:
widget.wallpaper,
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
curve: Curves.easeOutCubic,
reverseCurve:
Curves.easeInCubic,
);

return FadeScaleTransition(
animation: curve,
child: child,
);
},
),
);
}

@override
Widget build(BuildContext context) {
final colors = Theme.of(context).colorScheme;

final delay =
420 +
(widget.index
    .clamp(0, 8)
    .toInt() *
55);

return TweenAnimationBuilder<double>(
tween: Tween<double>(
begin: 0,
end: 1,
),
duration: Duration(
milliseconds: delay,
),
curve: Curves.easeOutCubic,
builder: (
context,
value,
child,
) {
return Opacity(
opacity: value,
child: Transform.translate(
offset: Offset(
0,
26.h * (1 - value),
),
child: Transform.scale(
scale:
.94 + (.06 * value),
child: child,
),
),
);
},
child: AnimatedScale(
scale: _pressed ? .955 : 1,
duration: const Duration(
milliseconds: 180,
),
curve: Curves.easeOutBack,
child: GestureDetector(
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
},
onTap: _openPreview,
child: Material(
color:
colors.surfaceContainerLow,
borderRadius:
BorderRadius.circular(26.r),
clipBehavior:
Clip.antiAlias,
elevation: 0,
child: Stack(
fit: StackFit.expand,
children: [
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
width: 24.w,
height: 24.w,
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
_,
_,
_,
) {
return ColoredBox(
color: colors
    .surfaceContainerHighest,
child: Icon(
Hicons
    .imageLightOutline,
color: colors
    .onSurfaceVariant,
size: 30.sp,
),
);
},
),
),

// -----------------------------------------------------------
// EXPRESSIVE SCRIM
// -----------------------------------------------------------

const Positioned.fill(
child:
_WallpaperScrim(),
),

// -----------------------------------------------------------
// FAVORITE
// -----------------------------------------------------------

Positioned(
right: 10.w,
bottom: 10.h,
child:
ValueListenableBuilder<
Set<String>>(
valueListenable:
FleckFavoritesStore
    .urls,
builder: (
context,
favoriteUrls,
_,
) {
return _FavoriteButton(
liked:
favoriteUrls.contains(
widget.wallpaper.url,
),
onPressed: () {
HapticFeedback
    .lightImpact();

FleckFavoritesStore
    .toggle(
widget.wallpaper,
);
},
);
},
),
),

// -----------------------------------------------------------
// CATEGORY
// -----------------------------------------------------------

],
),
),
),
),
);
}
}


// =============================================================================
// WALLPAPER SCRIM
// =============================================================================

class _WallpaperScrim
extends StatelessWidget {
const _WallpaperScrim();

@override
Widget build(BuildContext context) {
return DecoratedBox(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
stops: const [
0,
.55,
1,
],
colors: [
Colors.transparent,
Colors.transparent,
Colors.black.withValues(
alpha: .48,
),
],
),
),
);
}
}


// =============================================================================
// FAVORITE

// =============================================================================

class _FavoriteButton extends StatelessWidget {
const _FavoriteButton({
required this.liked,
required this.onPressed,
});

final bool liked;
final VoidCallback onPressed;

@override
Widget build(BuildContext context) {
return AnimatedScale(
scale: liked ? 1.04 : 1,
duration: const Duration(
milliseconds: 220,
),
curve: Curves.easeOutBack,
child: IconButton.filled(
onPressed: onPressed,
tooltip: liked
? 'Remove from favorites'
    : 'Add to favorites',
style: IconButton.styleFrom(
backgroundColor: liked
? FleckTheme.seedColor
    : Theme.of(context)
    .colorScheme
    .surfaceContainerHigh,
foregroundColor: liked
? FleckTheme.onPrimary
    : Theme.of(context)
    .colorScheme
    .onSurfaceVariant,
minimumSize: Size(
44.w,
44.w,
),
maximumSize: Size(
44.w,
44.w,
),
padding: EdgeInsets.zero,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(16.r),
),
elevation: 0,
),
icon: AnimatedSwitcher(
duration: const Duration(
milliseconds: 260,
),
switchInCurve:
Curves.easeOutBack,
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
liked
? Hicons.heart2Bold
    : Hicons.heart2LightOutline,
key: ValueKey(liked),
size: 20.sp,
),
),
),
);
}
}

// =============================================================================
// COLLECTIONS

// =============================================================================

class _Collections
extends StatelessWidget {
const _Collections({
required this.categories,
});

final List<dynamic> categories;

@override
Widget build(BuildContext context) {
return SizedBox(
height: 198.h,
child: ListView.separated(
padding:
EdgeInsets.symmetric(
horizontal: 20.w,
),
scrollDirection:
Axis.horizontal,
physics:
const BouncingScrollPhysics(),
itemCount: categories.length,
separatorBuilder: (
_,
_,
) =>
SizedBox(width: 14.w),
itemBuilder: (
context,
index,
) {
final category =
categories[index];

return TweenAnimationBuilder<
double>(
tween: Tween<double>(
begin: .88,
end: 1,
),
duration: Duration(
milliseconds:
480 +
index
    .clamp(
0,
7,
)
    .toInt() *
65,
),
curve:
Curves.easeOutBack,
builder: (
context,
scale,
child,
) {
return Transform.scale(
scale: scale,
child: child,
);
},
child: _CollectionCard(
category: category,
),
);
},
),
);
}
}

// =============================================================================
// COLLECTION CARD
// =============================================================================

class _CollectionCard
extends StatefulWidget {
const _CollectionCard({
required this.category,
});

final dynamic category;

@override
State<_CollectionCard> createState() =>
_CollectionCardState();
}

class _CollectionCardState
extends State<_CollectionCard> {
bool _pressed = false;

void _openCollection() {
HapticFeedback.selectionClick();

Navigator.of(context).push(
PageRouteBuilder<void>(
transitionDuration:
const Duration(
milliseconds: 520,
),
reverseTransitionDuration:
const Duration(
milliseconds: 360,
),
pageBuilder: (
context,
animation,
secondaryAnimation,
) {
return _CollectionWallpapersScreen(
category:
widget.category,
);
},
transitionsBuilder: (
context,
animation,
secondaryAnimation,
child,
) {
final curved =
CurvedAnimation(
parent: animation,
curve:
Curves.easeOutCubic,
reverseCurve:
Curves.easeInCubic,
);

return FadeTransition(
opacity: curved,
child: ScaleTransition(
scale: Tween<double>(
begin: .94,
end: 1,
).animate(curved),
child: child,
),
);
},
),
);
}

@override
Widget build(BuildContext context) {
final colors = Theme.of(context).colorScheme;

return AnimatedScale(
duration: const Duration(
milliseconds: 180,
),
curve: Curves.easeOutBack,
scale: _pressed ? .965 : 1,
child: SizedBox(
width: 290.w,
child: GestureDetector(
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
},
onTap: _openCollection,
child: Material(
color:
colors.surfaceContainerLow,
borderRadius:
BorderRadius.circular(28.r),
clipBehavior:
Clip.antiAlias,
child: Stack(
fit: StackFit.expand,
children: [
Image.network(
widget.category.thumbnail,
fit: BoxFit.cover,
errorBuilder: (
_,
_,
_,
) {
return ColoredBox(
color: colors
    .surfaceContainerHighest,
child: Icon(
Hicons
    .imageLightOutline,
color: colors
    .onSurfaceVariant,
size: 30.sp,
),
);
},
),

// -----------------------------------------------------------
// SCRIM
// -----------------------------------------------------------

DecoratedBox(
decoration:
BoxDecoration(
gradient:
LinearGradient(
begin:
Alignment.topCenter,
end: Alignment
    .bottomCenter,
colors: [
Colors.transparent,
Colors.black.withValues(
alpha: .68,
),
],
),
),
),

// -----------------------------------------------------------
// CONTENT
// -----------------------------------------------------------

Positioned(
left: 17.w,
right: 15.w,
bottom: 15.h,
child: Row(
children: [
Expanded(
child: Text(
widget.category.name,
maxLines: 1,
overflow:
TextOverflow
    .ellipsis,
style: TextStyle(
color: Colors.white,
fontSize: 20.sp,
fontWeight:
FontWeight.w800,
letterSpacing:
-.6,
),
),
),
SizedBox(
width: 8.w,
),
Material(
color: Colors.white
    .withValues(
alpha: .20,
),
borderRadius:
BorderRadius
    .circular(
13.r,
),
child: Padding(
padding:
EdgeInsets
    .symmetric(
horizontal:
10.w,
vertical: 7.h,
),
child: Text(
'${widget.category.wallpapers.length}',
style:
TextStyle(
color:
Colors.white,
fontSize:
12.sp,
fontWeight:
FontWeight
    .w800,
),
),
),
),
],
),
),
],
),
),
),
),
);
}
}

// =============================================================================
// COLLECTION WALLPAPERS
// =============================================================================

class _CollectionWallpapersScreen
extends StatelessWidget {
const _CollectionWallpapersScreen({
required this.category,
});

final dynamic category;

@override
Widget build(BuildContext context) {
final theme =
Theme.of(context);
final colors = theme.colorScheme;

final List<Wallpaper> wallpapers =
List<Wallpaper>.from(
category.wallpapers,
);

return Scaffold(
backgroundColor:
colors.surface,
body: SafeArea(
bottom: false,
child: Column(
children: [
FleckAppBar(
title: category.name,
searchHint:
'Search wallpapers',
onSearchChanged: (_) {},
),

Expanded(
child: wallpapers.isEmpty
? _CollectionEmpty()
    : CustomScrollView(
physics:
const BouncingScrollPhysics(
parent:
AlwaysScrollableScrollPhysics(),
),
slivers: [
SliverPadding(
padding:
EdgeInsets.fromLTRB(
20.w,
8.h,
20.w,
110.h,
),
sliver:
SliverGrid(
delegate:
SliverChildBuilderDelegate(
(
context,
index,
) {
return _WallpaperCard(
wallpaper:
wallpapers[
index],
index:
index,
);
},
childCount:
wallpapers
    .length,
),
gridDelegate:
SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount:
2,
crossAxisSpacing:
12.w,
mainAxisSpacing:
14.h,
childAspectRatio:
.68,
),
),
),
],
),
),
],
),
),
);
}
}

// =============================================================================
// EMPTY COLLECTION
// =============================================================================

class _CollectionEmpty
extends StatelessWidget {
@override
Widget build(BuildContext context) {
final theme =
Theme.of(context);
final colors = theme.colorScheme;

return Center(
child: Padding(
padding:
EdgeInsets.all(28.w),
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [
Container(
width: 82.w,
height: 82.w,
decoration:
BoxDecoration(
color:
colors.secondaryContainer,
shape:
BoxShape.circle,
),
child: Icon(
Hicons
    .imageLightOutline,
size: 32.sp,
color: colors
    .onSecondaryContainer,
),
),

SizedBox(height: 18.h),

Text(
'Nothing here yet',
style: theme.textTheme
    .headlineSmall
    ?.copyWith(
fontWeight:
FontWeight.w800,
),
),

SizedBox(height: 6.h),

Text(
'This collection does not have any wallpapers yet.',
textAlign:
TextAlign.center,
style: theme.textTheme
    .bodyLarge
    ?.copyWith(
color:
colors.onSurfaceVariant,
),
),
],
),
),
);
}
}

// =============================================================================
// EXPRESSIVE ICON BUTTON
// =============================================================================

class _ExpressiveIconButton
extends StatefulWidget {
const _ExpressiveIconButton({
required this.icon,
required this.onPressed,
this.background,
this.foreground,
this.size,
});

final IconData icon;
final VoidCallback onPressed;
final Color? background;
final Color? foreground;
final double? size;

@override
State<_ExpressiveIconButton> createState() =>
_ExpressiveIconButtonState();
}

class _ExpressiveIconButtonState
extends State<_ExpressiveIconButton> {
bool _pressed = false;

@override
Widget build(BuildContext context) {
final colors = Theme.of(context).colorScheme;

final size =
widget.size ?? 56.w;

return AnimatedScale(
duration: const Duration(
milliseconds: 170,
),
curve: Curves.easeOutBack,
scale: _pressed ? .88 : 1,
child: Material(
color: widget.background ??
colors.surfaceContainerHigh,
borderRadius:
BorderRadius.circular(18.r),
clipBehavior:
Clip.antiAlias,
child: InkWell(
borderRadius:
BorderRadius.circular(18.r),
onTap: widget.onPressed,
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
},
child: SizedBox(
width: size,
height: size,
child: Icon(
widget.icon,
size: 22.sp,
color: widget.foreground ??
colors.onSurfaceVariant,
),
),
),
),
);
}
}

// =============================================================================
// EMPTY SEARCH
// =============================================================================

class _EmptySearch
extends StatelessWidget {
const _EmptySearch();

@override
Widget build(BuildContext context) {
final theme =
Theme.of(context);
final colors = theme.colorScheme;

return Center(
child: TweenAnimationBuilder<double>(
tween: Tween<double>(
begin: .78,
end: 1,
),
duration: const Duration(
milliseconds: 650,
),
curve: Curves.easeOutBack,
builder: (
context,
scale,
child,
) {
return Transform.scale(
scale: scale,
child: child,
);
},
child: Padding(
padding:
EdgeInsets.all(28.w),
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [
Container(
width: 82.w,
height: 82.w,
decoration:
BoxDecoration(
color:
colors.secondaryContainer,
shape:
BoxShape.circle,
),
child: Icon(
Hicons
    .search1LightOutline,
size: 31.sp,
color: colors
    .onSecondaryContainer,
),
),

SizedBox(height: 18.h),

Text(
'Nothing here yet',
style: theme.textTheme
    .headlineSmall
    ?.copyWith(
fontWeight:
FontWeight.w800,
),
),

SizedBox(height: 6.h),

Text(
'Try another search.',
style: theme.textTheme
    .bodyLarge
    ?.copyWith(
color:
colors.onSurfaceVariant,
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
// LOADING
// =============================================================================

class _LoadingView
extends StatelessWidget {
const _LoadingView();

@override
Widget build(BuildContext context) {
final colors = Theme.of(context).colorScheme;

return Center(
child: TweenAnimationBuilder<double>(
tween: Tween<double>(
begin: .65,
end: 1,
),
duration: const Duration(
milliseconds: 700,
),
curve: Curves.easeOutBack,
builder: (
context,
scale,
child,
) {
return Transform.scale(
scale: scale,
child: child,
);
},
child: Container(
width: 72.w,
height: 72.w,
decoration: BoxDecoration(
color:
colors.secondaryContainer,
shape: BoxShape.circle,
),
child: Padding(
padding:
EdgeInsets.all(22.w),
child:
CircularProgressIndicator(
strokeWidth: 2.5,
color: FleckTheme.seedColor,
),
),
),
),
);
}
}

// =============================================================================
// ERROR
// =============================================================================

class _ErrorView
extends StatelessWidget {
const _ErrorView({
required this.onRetry,
});

final Future<void> Function() onRetry;

@override
Widget build(BuildContext context) {
final theme =
Theme.of(context);
final colors = theme.colorScheme;

return Center(
child: Padding(
padding:
EdgeInsets.all(28.w),
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [
Container(
width: 78.w,
height: 78.w,
decoration:
BoxDecoration(
color:
colors.errorContainer,
shape:
BoxShape.circle,
),
child: Icon(
Hicons
    .stopLightOutline,
size: 31.sp,
color:
colors.onErrorContainer,
),
),

SizedBox(height: 18.h),

Text(
'Could not load Fleck',
style: theme.textTheme
    .headlineSmall
    ?.copyWith(
fontWeight:
FontWeight.w800,
),
),

SizedBox(height: 6.h),

Text(
'Check your connection and try again.',
textAlign:
TextAlign.center,
style: theme.textTheme
    .bodyLarge
    ?.copyWith(
color:
colors.onSurfaceVariant,
),
),

SizedBox(height: 20.h),

FilledButton.icon(
onPressed: onRetry,
icon: Icon(
Hicons
    .refresh1LightOutline,
),
label:
const Text('Try again'),
),
],
),
),
);
}
}

// =============================================================================
// ENTRANCE
// =============================================================================

class _ExpressiveEntrance
extends StatelessWidget {
const _ExpressiveEntrance({
required this.controller,
required this.begin,
required this.end,
required this.child,
});

final AnimationController controller;
final double begin;
final double end;
final Widget child;

@override
Widget build(BuildContext context) {
final animation =
CurvedAnimation(
parent: controller,
curve: Interval(
begin.clamp(0.0, 1.0).toDouble(),
end.clamp(0.001, 1.0).toDouble(),
curve:
Curves.easeOutCubic,
),
);

return AnimatedBuilder(
animation: animation,
child: child,
builder: (
context,
child,
) {
final value = animation
    .value
    .clamp(0.0, 1.0)
    .toDouble();

return Opacity(
opacity: value,
child: Transform.translate(
offset: Offset(
0,
22.h * (1 - value),
),
child: Transform.scale(
scale:
.96 + (.04 * value),
child: child,
),
),
);
},
);
}
}
