import 'package:animations/animations.dart';
import 'package:fleck/features/categories/presentation/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../../core/widgets/fleck_app_bar.dart';
import '../../../data/models/wallpaper_category.dart';
import '../../../core/theme/app_theme.dart';

/// Fleck Collections
///
/// Minimal Material 3 Expressive redesign:
/// - Cleaner hierarchy
/// - Reduced decorative UI
/// - Tonal surfaces
/// - Subtle expressive shapes
/// - Smooth motion
/// - Minimal collection metadata
/// - Quiet filter interaction
/// - Large image-first collection cards
class CollectionsScreen extends StatefulWidget {
const CollectionsScreen({
super.key,
required this.categories,
this.onProfileTap,
});

final List<WallpaperCategory> categories;
final VoidCallback? onProfileTap;

@override
State<CollectionsScreen> createState() =>
_CollectionsScreenState();
}

class _CollectionsScreenState
extends State<CollectionsScreen>
with SingleTickerProviderStateMixin {
late final AnimationController _entrance;

String _query = '';
CollectionFilter _filter = CollectionFilter.all;

@override
void initState() {
super.initState();

_entrance = AnimationController(
vsync: this,
duration: const Duration(
milliseconds: 760,
),
)..forward();
}

@override
void dispose() {
_entrance.dispose();
super.dispose();
}

// ===========================================================================
// SEARCH
// ===========================================================================

void _onSearchChanged(String value) {
if (!mounted) {
return;
}

setState(() {
_query = value.trim();
});

_restartEntrance();
}

// ===========================================================================
// FILTER
// ===========================================================================

List<WallpaperCategory> get _filteredCategories {
Iterable<WallpaperCategory> result =
widget.categories;

final query = _query.toLowerCase();

if (query.isNotEmpty) {
result = result.where(
(category) => category.name
    .toLowerCase()
    .contains(query),
);
}

switch (_filter) {
case CollectionFilter.all:
break;

case CollectionFilter.popular:
result = result.toList()
..sort(
(a, b) => b.wallpapers.length.compareTo(
a.wallpapers.length,
),
);
break;

case CollectionFilter.small:
result = result.where(
(category) =>
category.wallpapers.length < 30,
);
break;

case CollectionFilter.large:
result = result.where(
(category) =>
category.wallpapers.length >= 30,
);
break;
}

return result.toList();
}

Future<void> _openFilter() async {
HapticFeedback.selectionClick();

final selected =
await showFleckExpressiveBottomSheet<
CollectionFilter>(
context: context,
child: _FilterSheet(
selected: _filter,
),
);

if (!mounted ||
selected == null ||
selected == _filter) {
return;
}

HapticFeedback.selectionClick();

setState(() {
_filter = selected;
});

_restartEntrance();
}

void _restartEntrance() {
_entrance
..reset()
..forward();
}

// ===========================================================================
// CATEGORY
// ===========================================================================

void _openCategory(
WallpaperCategory category,
) {
HapticFeedback.selectionClick();

Navigator.of(context).push(
PageRouteBuilder<void>(
transitionDuration: const Duration(
milliseconds: 400,
),
reverseTransitionDuration:
const Duration(
milliseconds: 280,
),
pageBuilder: (
_,
animation,
secondaryAnimation,
) {
return CategoryWallpapersScreen(
category: category,
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
reverseCurve: Curves.easeInCubic,
);

return FadeThroughTransition(
animation: curve,
secondaryAnimation:
secondaryAnimation,
child: child,
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

final categories = _filteredCategories;

return Scaffold(
backgroundColor: colors.surface,
body: SafeArea(
bottom: false,
child: Column(
children: [
FleckAppBar(
title: 'Fleck',
searchHint: 'Search collections',
onSearchChanged:
_onSearchChanged,
onProfilePressed:
widget.onProfileTap,
),
Expanded(
child: _CollectionsBody(
controller: _entrance,
categories: categories,
filter: _filter,
query: _query,
onFilter: _openFilter,
onCategory: _openCategory,
),
),
],
),
),
);
}
}

// =============================================================================
// FILTER
// =============================================================================

enum CollectionFilter {
all,
popular,
small,
large,
}

// =============================================================================
// BODY
// =============================================================================

class _CollectionsBody
extends StatelessWidget {
const _CollectionsBody({
required this.controller,
required this.categories,
required this.filter,
required this.query,
required this.onFilter,
required this.onCategory,
});

final AnimationController controller;
final List<WallpaperCategory> categories;
final CollectionFilter filter;
final String query;

final VoidCallback onFilter;
final ValueChanged<WallpaperCategory>
onCategory;

@override
Widget build(BuildContext context) {
return CustomScrollView(
physics: const BouncingScrollPhysics(
parent:
AlwaysScrollableScrollPhysics(),
),
clipBehavior: Clip.none,
slivers: [
// ---------------------------------------------------------------------
// FEATURE
// ---------------------------------------------------------------------

SliverToBoxAdapter(
child: _Stagger(
controller: controller,
begin: 0,
end: .38,
offset: 14.h,
child: const _HeroCarousel(),
),
),

// ---------------------------------------------------------------------
// HEADING
// ---------------------------------------------------------------------

SliverPadding(
padding: EdgeInsets.fromLTRB(
20.w,
22.h,
20.w,
16.h,
),
sliver: SliverToBoxAdapter(
child: _Stagger(
controller: controller,
begin: .10,
end: .50,
offset: 10.h,
child: _CollectionsHeading(
filter: filter,
query: query,
count: categories.length,
onFilter: onFilter,
),
),
),
),

// ---------------------------------------------------------------------
// EMPTY
// ---------------------------------------------------------------------

if (categories.isEmpty)
SliverFillRemaining(
hasScrollBody: false,
child: _EmptyCollections(
query: query,
),
)

// ---------------------------------------------------------------------
// COLLECTIONS
// ---------------------------------------------------------------------

else
SliverPadding(
padding: EdgeInsets.fromLTRB(
20.w,
0,
20.w,
110.h,
),
sliver: SliverList.builder(
itemCount: categories.length,
itemBuilder: (
context,
index,
) {
final category =
categories[index];

final begin = (.18 +
index * .045)
    .clamp(
0.0,
.72,
);

final end = (.50 +
index * .045)
    .clamp(
.01,
1.0,
);

return _Stagger(
controller: controller,
begin: begin,
end: end,
offset: 18.h,
child: _CollectionCard(
category: category,
index: index,
onTap: () =>
onCategory(category),
),
);
},
),
),
],
);
}
}

// =============================================================================
// HERO CAROUSEL
// =============================================================================

class _HeroCarousel
extends StatefulWidget {
const _HeroCarousel();

@override
State<_HeroCarousel> createState() =>
_HeroCarouselState();
}

class _HeroCarouselState
extends State<_HeroCarousel> {
late final PageController _controller;

int _current = 0;

static const List<_FleckFeature>
_features = [
_FleckFeature(
title: 'Every week',
subtitle: 'New wallpapers',
icon: Hicons.calender2LightOutline,
body:
'Fleck keeps the collection feeling fresh with new wallpaper picks added regularly, so there is always something new to discover.',
),
_FleckFeature(
title: 'Fresh picks',
subtitle: 'Made for your screen',
icon: Hicons.star2LightOutline,
body:
'Explore a changing mix of styles, colors and moods selected to work beautifully as phone wallpapers.',
),
_FleckFeature(
title: 'New wallpaper',
subtitle: 'Find your next look',
icon: Hicons.imageLightOutline,
body:
'Every wallpaper is presented for quick discovery and easy preview. Save the ones you love and build a personal collection.',
),
_FleckFeature(
title: 'Made for Fleck',
subtitle: 'Fresh every week',
icon: Hicons.stickerLightOutline,
body:
'Fleck brings wallpapers together into a clean, expressive browsing experience.',
),
];

@override
void initState() {
super.initState();

_controller = PageController(
viewportFraction: 1,
);
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

void _onPageChanged(int index) {
if (!mounted) {
return;
}

HapticFeedback.selectionClick();

setState(() {
_current = index;
});
}

Future<void> _showFeature(
_FleckFeature feature,
) async {
HapticFeedback.selectionClick();

await showGeneralDialog<void>(
context: context,
barrierDismissible: true,
barrierLabel: 'Close',
barrierColor:
Colors.black.withValues(
alpha: .34,
),
transitionDuration:
const Duration(
milliseconds: 280,
),
pageBuilder: (
context,
animation,
secondaryAnimation,
) {
return _FeatureInfoPopup(
feature: feature,
);
},
transitionBuilder: (
context,
animation,
secondaryAnimation,
child,
) {
final curved = CurvedAnimation(
parent: animation,
curve: Curves.easeOutCubic,
reverseCurve:
Curves.easeInCubic,
);

return FadeTransition(
opacity: curved,
child: ScaleTransition(
scale: Tween<double>(
begin: .96,
end: 1,
).animate(curved),
child: child,
),
);
},
);
}

@override
Widget build(BuildContext context) {
return Column(
mainAxisSize: MainAxisSize.min,
children: [
SizedBox(
height: 118.h,
width: double.infinity,
child: PageView.builder(
controller: _controller,
itemCount: _features.length,
physics:
const BouncingScrollPhysics(),
onPageChanged:
_onPageChanged,
itemBuilder: (
context,
index,
) {
return Padding(
padding:
EdgeInsets.symmetric(
horizontal: 20.w,
),
child: _FeatureCard(
feature:
_features[index],
onTap: () =>
_showFeature(
_features[index],
),
),
);
},
),
),

SizedBox(height: 10.h),

_FeatureIndicator(
count: _features.length,
current: _current,
),
],
);
}
}

// =============================================================================
// FEATURE MODEL
// =============================================================================

class _FleckFeature {
const _FleckFeature({
required this.title,
required this.subtitle,
required this.icon,
required this.body,
});

final String title;
final String subtitle;
final IconData icon;
final String body;
}

// =============================================================================
// FEATURE CARD
// =============================================================================

class _FeatureCard
extends StatefulWidget {
const _FeatureCard({
required this.feature,
required this.onTap,
});

final _FleckFeature feature;
final VoidCallback onTap;

@override
State<_FeatureCard> createState() =>
_FeatureCardState();
}

class _FeatureCardState
extends State<_FeatureCard> {
bool _pressed = false;

void _setPressed(bool value) {
if (!mounted) {
return;
}

setState(() {
_pressed = value;
});
}

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colors = theme.colorScheme;

return AnimatedScale(
scale: _pressed ? .985 : 1,
duration: const Duration(
milliseconds: 120,
),
curve: Curves.easeOutCubic,
child: Material(
color:
colors.surfaceContainerLow,
borderRadius:
BorderRadius.circular(22.r),
clipBehavior:
Clip.antiAlias,
child: InkWell(
borderRadius:
BorderRadius.circular(22.r),
onTap: widget.onTap,
onTapDown: (_) =>
_setPressed(true),
onTapCancel: () =>
_setPressed(false),
onTapUp: (_) =>
_setPressed(false),
child: Padding(
padding: EdgeInsets.symmetric(
horizontal: 13.w,
vertical: 12.h,
),
child: Row(
children: [
// ----------------------------------------------------------------
// ICON
// ----------------------------------------------------------------

M3EShapeContainer
    .clover4Leaf(
width: 48.w,
height: 48.w,
color:
FleckTheme.primarySoft,
child: Icon(
widget.feature.icon,
size: 21.sp,
color:
FleckTheme.primaryDark,
),
),

SizedBox(width: 12.w),

// ----------------------------------------------------------------
// TEXT
// ----------------------------------------------------------------

Expanded(
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
widget.feature.title,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: theme.textTheme
    .titleSmall
    ?.copyWith(
fontWeight:
FontWeight.w700,
letterSpacing: -.2,
),
),
SizedBox(height: 2.h),
Text(
widget.feature.subtitle,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: theme.textTheme
    .bodySmall
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
),

SizedBox(width: 8.w),

// ----------------------------------------------------------------
// ACTION
// ----------------------------------------------------------------

Icon(
Hicons.right2LightOutline,
size: 18.sp,
color: colors
    .onSurfaceVariant
    .withValues(
alpha: .58,
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
// FEATURE POPUP
// =============================================================================

class _FeatureInfoPopup
extends StatelessWidget {
const _FeatureInfoPopup({
required this.feature,
});

final _FleckFeature feature;

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colors = theme.colorScheme;

return SafeArea(
child: Center(
child: Padding(
padding:
EdgeInsets.symmetric(
horizontal: 20.w,
),
child: Material(
color:
colors.surfaceContainerHigh,
borderRadius:
BorderRadius.circular(26.r),
clipBehavior:
Clip.antiAlias,
child: ConstrainedBox(
constraints:
BoxConstraints(
maxWidth: 430.w,
),
child: Padding(
padding:
EdgeInsets.all(20.w),
child: Column(
mainAxisSize:
MainAxisSize.min,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
M3EShapeContainer
    .clover4Leaf(
width: 50.w,
height: 50.w,
color: colors
    .primaryContainer,
child: Icon(
feature.icon,
size: 21.sp,
color: colors
    .onPrimaryContainer,
),
),

SizedBox(width: 12.w),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
feature.title,
style: theme
    .textTheme
    .titleLarge
    ?.copyWith(
fontWeight:
FontWeight.w700,
letterSpacing:
-.4,
),
),
SizedBox(
height: 2.h,
),
Text(
feature.subtitle,
style: theme
    .textTheme
    .bodySmall
    ?.copyWith(
color: colors
    .onSurfaceVariant
    .withValues(
alpha: .72,
),
),
),
],
),
),

IconButton(
onPressed: () {
Navigator.of(
context,
).pop();
},
visualDensity:
VisualDensity
    .compact,
icon: Icon(
Hicons
    .closeLightOutline,
size: 18.sp,
),
),
],
),

SizedBox(height: 18.h),

Text(
feature.body,
style: theme.textTheme
    .bodyLarge
    ?.copyWith(
color: colors
    .onSurfaceVariant,
height: 1.45,
),
),
],
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
// INDICATOR
// =============================================================================

class _FeatureIndicator
extends StatelessWidget {
const _FeatureIndicator({
required this.count,
required this.current,
});

final int count;
final int current;

@override
Widget build(BuildContext context) {
final colors =
Theme.of(context).colorScheme;

return Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: List.generate(
count,
(index) {
final selected =
index == current;

return AnimatedContainer(
duration:
const Duration(
milliseconds: 240,
),
curve: Curves.easeOutCubic,
margin:
EdgeInsets.symmetric(
horizontal: 3.w,
),
width:
selected ? 18.w : 5.w,
height: 5.w,
decoration:
BoxDecoration(
color: selected
? FleckTheme.seedColor
    : colors.outlineVariant,
borderRadius:
BorderRadius.circular(
99.r,
),
),
);
},
),
);
}
}

// =============================================================================
// HEADING
// =============================================================================

class _CollectionsHeading
extends StatelessWidget {
const _CollectionsHeading({
required this.filter,
required this.query,
required this.count,
required this.onFilter,
});

final CollectionFilter filter;
final String query;
final int count;
final VoidCallback onFilter;

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
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
style: theme
    .textTheme
    .headlineMedium
    ?.copyWith(
fontSize: 30.sp,
fontWeight:
FontWeight.w800,
letterSpacing: -1.05,
height: 1.05,
),
),

SizedBox(height: 5.h),

AnimatedSwitcher(
duration:
const Duration(
milliseconds: 220,
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
child:
SlideTransition(
position:
Tween<Offset>(
begin:
const Offset(
0,
.08,
),
end: Offset.zero,
).animate(
animation,
),
child: child,
),
);
},
child: Text(
key: ValueKey(
query.isEmpty
? 'all-$count'
    : query,
),
query.isEmpty
? '$count collections'
    : 'Results for “$query”',
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: theme
    .textTheme
    .bodyMedium
    ?.copyWith(
color: colors
    .onSurfaceVariant
    .withValues(
alpha: .70,
),
fontWeight:
FontWeight.w500,
),
),
),
],
),
),

SizedBox(width: 12.w),

_FilterButton(
active:
filter != CollectionFilter.all,
onTap: onFilter,
),
],
);
}
}

// =============================================================================
// FILTER BUTTON
// =============================================================================

class _FilterButton
extends StatefulWidget {
const _FilterButton({
required this.active,
required this.onTap,
});

final bool active;
final VoidCallback onTap;

@override
State<_FilterButton> createState() =>
_FilterButtonState();
}

class _FilterButtonState
extends State<_FilterButton> {
bool _pressed = false;

@override
Widget build(BuildContext context) {
final colors =
Theme.of(context).colorScheme;

final background = widget.active
? FleckTheme.primarySoft
    : colors.surfaceContainerHigh;

final foreground = widget.active
? FleckTheme.primaryDark
    : colors.onSurfaceVariant;

return AnimatedScale(
scale: _pressed ? .96 : 1,
duration: const Duration(
milliseconds: 110,
),
curve: Curves.easeOutCubic,
child: Material(
color: background,
borderRadius:
BorderRadius.circular(17.r),
clipBehavior:
Clip.antiAlias,
child: InkWell(
borderRadius:
BorderRadius.circular(17.r),
onTap: widget.onTap,
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
child: AnimatedContainer(
duration:
const Duration(
milliseconds: 200,
),
curve: Curves.easeOutCubic,
width:
widget.active ? 58.w : 50.w,
height: 50.w,
child: Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Hicons
    .filter4LightOutline,
size: 20.sp,
color: foreground,
),
if (widget.active) ...[
SizedBox(width: 5.w),
Container(
width: 5.w,
height: 5.w,
decoration:
BoxDecoration(
color:
FleckTheme.seedColor,
shape: BoxShape.circle,
),
),
],
],
),
),
),
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
required this.index,
required this.onTap,
});

final WallpaperCategory category;
final int index;
final VoidCallback onTap;

@override
State<_CollectionCard> createState() =>
_CollectionCardState();
}

class _CollectionCardState
extends State<_CollectionCard> {
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
final theme = Theme.of(context);
final colors = theme.colorScheme;
final category = widget.category;

final imageUrl = _imageUrl(
category.wallpapers.isNotEmpty
? category.wallpapers.first
    : null,
);

return Padding(
padding:
EdgeInsets.only(bottom: 12.h),
child: AnimatedScale(
scale: _pressed ? .985 : 1,
duration:
const Duration(
milliseconds: 130,
),
curve: Curves.easeOutCubic,
child: Material(
color: Colors.transparent,
borderRadius:
BorderRadius.circular(24.r),
clipBehavior:
Clip.antiAlias,
child: InkWell(
onTap: widget.onTap,
onTapDown: (_) =>
_setPressed(true),
onTapCancel: () =>
_setPressed(false),
onTapUp: (_) =>
_setPressed(false),
child: SizedBox(
height: 196.h,
child: Stack(
fit: StackFit.expand,
children: [
// ===========================================================
// IMAGE
// ===========================================================

Hero(
tag:
'collection-${category.name}-${widget.index}',
child: _NetworkImage(
url: imageUrl,
fallback: colors
    .surfaceContainerHighest,
),
),

// ===========================================================
// GRADIENT
// ===========================================================

Positioned.fill(
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
Colors.black
    .withValues(
alpha: .02,
),
Colors.black
    .withValues(
alpha: .08,
),
Colors.black
    .withValues(
alpha: .68,
),
],
stops: const [
0,
.42,
1,
],
),
),
),
),

// ===========================================================
// TOP ACTION
// ===========================================================

Positioned(
top: 12.h,
right: 12.w,
child: _CardActionButton(
onTap: widget.onTap,
),
),

// ===========================================================
// CONTENT
// ===========================================================

Positioned(
left: 16.w,
right: 16.w,
bottom: 15.h,
child: Row(
crossAxisAlignment:
CrossAxisAlignment.end,
children: [
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
category.name,
maxLines: 1,
overflow:
TextOverflow
    .ellipsis,
style: theme
    .textTheme
    .titleLarge
    ?.copyWith(
color:
Colors.white,
fontSize:
23.sp,
fontWeight:
FontWeight.w800,
letterSpacing:
-.65,
height: 1.05,
shadows: const [
Shadow(
blurRadius:
8,
color:
Colors.black54,
),
],
),
),

SizedBox(
height: 4.h,
),

Row(
children: [
Flexible(
child:
Text(
_description(
category.name,
),
maxLines: 1,
overflow:
TextOverflow
    .ellipsis,
style: theme
    .textTheme
    .bodySmall
    ?.copyWith(
color: Colors
    .white
    .withValues(
alpha:
.84,
),
fontWeight:
FontWeight
    .w500,
),
),
),

SizedBox(
width: 7.w,
),

Container(
width: 4.w,
height: 4.w,
decoration:
const BoxDecoration(
color:
Colors.white70,
shape:
BoxShape.circle,
),
),

SizedBox(
width: 7.w,
),

Text(
'${category.wallpapers.length}',
style: theme
    .textTheme
    .labelMedium
    ?.copyWith(
color: Colors
    .white
    .withValues(
alpha:
.86,
),
fontWeight:
FontWeight
    .w700,
),
),
],
),
],
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
),
);
}
}

// =============================================================================
// CARD ACTION
// =============================================================================

class _CardActionButton
extends StatefulWidget {
const _CardActionButton({
required this.onTap,
});

final VoidCallback onTap;

@override
State<_CardActionButton> createState() =>
_CardActionButtonState();
}

class _CardActionButtonState
extends State<_CardActionButton> {
bool _pressed = false;

@override
Widget build(BuildContext context) {
return AnimatedScale(
scale: _pressed ? .91 : 1,
duration:
const Duration(
milliseconds: 110,
),
curve: Curves.easeOutCubic,
child: Material(
color: Colors.black.withValues(
alpha: .24,
),
shape:
const CircleBorder(),
clipBehavior:
Clip.antiAlias,
child: InkWell(
customBorder:
const CircleBorder(),
onTap: widget.onTap,
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
width: 40.w,
height: 40.w,
child: Icon(
Hicons.right2LightOutline,
size: 18.sp,
color: Colors.white,
),
),
),
),
);
}
}

// =============================================================================
// FILTER SHEET
// =============================================================================

class _FilterSheet
extends StatelessWidget {
const _FilterSheet({
required this.selected,
});

final CollectionFilter selected;

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colors = theme.colorScheme;

return Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Sort collections',
style: theme
    .textTheme
    .headlineSmall
    ?.copyWith(
fontWeight:
FontWeight.w800,
letterSpacing: -.7,
),
),

SizedBox(height: 5.h),

Text(
'Choose how your collections appear.',
style: theme
    .textTheme
    .bodyMedium
    ?.copyWith(
color:
colors.onSurfaceVariant,
),
),

SizedBox(height: 18.h),

_FilterOption(
icon: Hicons.categoryBold,
title: 'All collections',
subtitle: 'Show everything',
selected:
selected ==
CollectionFilter.all,
onTap: () =>
Navigator.pop(
context,
CollectionFilter.all,
),
),

_FilterOption(
icon:
Hicons.star2LightOutline,
title: 'Most wallpapers',
subtitle:
'Largest collections first',
selected:
selected ==
CollectionFilter.popular,
onTap: () =>
Navigator.pop(
context,
CollectionFilter.popular,
),
),

_FilterOption(
icon:
Hicons.categoryLightOutline,
title: 'Compact',
subtitle:
'Collections under 30 wallpapers',
selected:
selected ==
CollectionFilter.small,
onTap: () =>
Navigator.pop(
context,
CollectionFilter.small,
),
),

_FilterOption(
icon:
Hicons.categoryLightOutline,
title: 'Large',
subtitle:
'Collections with 30+ wallpapers',
selected:
selected ==
CollectionFilter.large,
onTap: () =>
Navigator.pop(
context,
CollectionFilter.large,
),
),
],
);
}
}

// =============================================================================
// FILTER OPTION
// =============================================================================

class _FilterOption
extends StatefulWidget {
const _FilterOption({
required this.icon,
required this.title,
required this.subtitle,
required this.selected,
required this.onTap,
});

final IconData icon;
final String title;
final String subtitle;
final bool selected;
final VoidCallback onTap;

@override
State<_FilterOption> createState() =>
_FilterOptionState();
}

class _FilterOptionState
extends State<_FilterOption> {
bool _pressed = false;

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colors = theme.colorScheme;

return Padding(
padding:
EdgeInsets.only(bottom: 7.h),
child: AnimatedScale(
scale: _pressed ? .985 : 1,
duration:
const Duration(
milliseconds: 120,
),
curve: Curves.easeOutCubic,
child: Material(
color: widget.selected
? FleckTheme.primarySoft
    : colors.surfaceContainer,
borderRadius:
BorderRadius.circular(19.r),
clipBehavior:
Clip.antiAlias,
child: InkWell(
borderRadius:
BorderRadius.circular(19.r),
onTap: widget.onTap,
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
child: Padding(
padding:
EdgeInsets.symmetric(
horizontal: 11.w,
vertical: 10.h,
),
child: Row(
children: [
AnimatedContainer(
duration:
const Duration(
milliseconds: 180,
),
width: 44.w,
height: 44.w,
decoration:
BoxDecoration(
color: widget.selected
? FleckTheme.seedColor
    : colors
    .surfaceContainerHigh,
shape: BoxShape.circle,
),
child: Icon(
widget.icon,
size: 19.sp,
color: widget.selected
? colors.onPrimary
    : colors
    .onSurfaceVariant,
),
),

SizedBox(width: 11.w),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
widget.title,
style: theme
    .textTheme
    .titleSmall
    ?.copyWith(
fontWeight:
FontWeight.w700,
color: widget
    .selected
? colors
    .onPrimaryContainer
    : null,
),
),
SizedBox(height: 2.h),
Text(
widget.subtitle,
style: theme
    .textTheme
    .bodySmall
    ?.copyWith(
color: widget
    .selected
? colors
    .onPrimaryContainer
    .withValues(
alpha: .68,
)
    : colors
    .onSurfaceVariant
    .withValues(
alpha: .72,
),
),
),
],
),
),

SizedBox(width: 8.w),

AnimatedSwitcher(
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
child:
FadeTransition(
opacity: animation,
child: child,
),
);
},
child: widget.selected
? Icon(
Hicons
    .tickLightOutline,
key:
const ValueKey(
'selected',
),
size: 21.sp,
color:
FleckTheme.seedColor,
)
    : Icon(
Hicons
    .right2LightOutline,
key:
const ValueKey(
'unselected',
),
size: 18.sp,
color: colors
    .onSurfaceVariant
    .withValues(
alpha: .48,
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

// =============================================================================
// EMPTY
// =============================================================================

class _EmptyCollections
extends StatefulWidget {
const _EmptyCollections({
required this.query,
});

final String query;

@override
State<_EmptyCollections> createState() =>
_EmptyCollectionsState();
}

class _EmptyCollectionsState
extends State<_EmptyCollections>
with SingleTickerProviderStateMixin {
late final AnimationController
_controller;

@override
void initState() {
super.initState();

_controller = AnimationController(
vsync: this,
duration: const Duration(
milliseconds: 1900,
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

final searching =
widget.query.isNotEmpty;

return Center(
child: Padding(
padding:
EdgeInsets.symmetric(
horizontal: 28.w,
),
child: AnimatedBuilder(
animation: _controller,
builder: (
context,
child,
) {
final value =
Curves.easeInOutCubic
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
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [
M3EShapeContainer
    .clover4Leaf(
width: 92.w,
height: 92.w,
color: searching
? FleckTheme.primarySoft
    : FleckTheme.primarySoft,
child: Icon(
searching
? Hicons
    .search1LightOutline
    : Hicons
    .categoryLightOutline,
size: 30.sp,
color: searching
? colors
    .onSecondaryContainer
    : colors
    .onPrimaryContainer,
),
),

SizedBox(height: 20.h),

Text(
searching
? 'Nothing found'
    : 'No collections yet',
textAlign:
TextAlign.center,
style: theme
    .textTheme
    .titleLarge
    ?.copyWith(
fontWeight:
FontWeight.w800,
letterSpacing: -.5,
),
),

SizedBox(height: 7.h),

ConstrainedBox(
constraints:
BoxConstraints(
maxWidth: 290.w,
),
child: Text(
searching
? 'Try another collection name.'
    : 'Your wallpaper collections will appear here.',
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
),
],
),
),
),
);
}
}

// =============================================================================
// STAGGER
// =============================================================================

class _Stagger
extends StatelessWidget {
const _Stagger({
required this.controller,
required this.begin,
required this.end,
required this.offset,
required this.child,
});

final AnimationController controller;
final double begin;
final double end;
final double offset;
final Widget child;

@override
Widget build(BuildContext context) {
final safeBegin =
begin.clamp(0.0, .999).toDouble();

final safeEnd =
end.clamp(
safeBegin + .001,
1.0,
).toDouble();

final animation =
CurvedAnimation(
parent: controller,
curve: Interval(
safeBegin,
safeEnd,
curve: Curves.easeOutCubic,
),
);

return AnimatedBuilder(
animation: animation,
child: child,
builder: (
_,
child,
) {
final value =
animation.value;

return Opacity(
opacity: value,
child: Transform.translate(
offset: Offset(
0,
offset * (1 - value),
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
// IMAGE
// =============================================================================

class _NetworkImage
extends StatelessWidget {
const _NetworkImage({
required this.url,
required this.fallback,
});

final String url;
final Color fallback;

@override
Widget build(BuildContext context) {
if (url.isEmpty) {
return ColoredBox(
color: fallback,
);
}

return Image.network(
url,
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
color: fallback,
child: Center(
child: SizedBox(
width: 20.w,
height: 20.w,
child:
CircularProgressIndicator(
strokeWidth: 2,
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
final colors =
Theme.of(context)
    .colorScheme;

return ColoredBox(
color: fallback,
child: Center(
child: Icon(
Hicons.imageLightOutline,
size: 28.sp,
color: colors
    .onSurfaceVariant
    .withValues(
alpha: .65,
),
),
),
);
},
);
}
}

// =============================================================================
// HELPERS
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

return 'Curated wallpapers';
}

String _imageUrl(
dynamic wallpaper,
) {
if (wallpaper == null) {
return '';
}

try {
final value =
wallpaper.imageUrl;

if (value is String &&
value.isNotEmpty) {
return value;
}
} catch (_) {}

try {
final value = wallpaper.url;

if (value is String &&
value.isNotEmpty) {
return value;
}
} catch (_) {}

try {
final value =
wallpaper.thumbnail;

if (value is String &&
value.isNotEmpty) {
return value;
}
} catch (_) {}

return '';
}
