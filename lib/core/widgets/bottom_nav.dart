import 'package:flutter/material.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class FleckNavigationBar extends StatelessWidget {
const FleckNavigationBar({
super.key,
required this.selectedIndex,
required this.onDestinationSelected,
});

final int selectedIndex;
final ValueChanged<int> onDestinationSelected;

static const _items = <_FleckNavItem>[
_FleckNavItem(
icon: Hicons.imageLightOutline,
selectedIcon: Hicons.imageBold,
label: 'Wallpapers',
),
_FleckNavItem(
icon: Hicons.folder2LightOutline,
selectedIcon: Hicons.folder2Bold,
label: 'Collections',
),
_FleckNavItem(
icon: Hicons.heart2LightOutline,
selectedIcon: Hicons.heart2Bold,
label: 'Favorites',
),
_FleckNavItem(
icon: Hicons.profile1LightOutline,
selectedIcon: Hicons.profile1Bold,
label: 'Profile',
),
];

@override
Widget build(BuildContext context) {
final colors = Theme.of(context).colorScheme;

return Material(
color: colors.surface,
child: SafeArea(
top: false,
child: Container(
height: 82.h,
padding: EdgeInsets.fromLTRB(
14.w,
7.h,
14.w,
5.h,
),
decoration: BoxDecoration(
color: colors.surface,
boxShadow: [
BoxShadow(
color: colors.shadow.withValues(
alpha: 0.035,
),
blurRadius: 18,
offset: const Offset(
0,
-4,
),
),
],
),
child: Row(
children: List.generate(
_items.length,
(index) {
return Expanded(
child: _NavigationDestination(
item: _items[index],
selected: selectedIndex == index,
onTap: () {
onDestinationSelected(index);
},
),
);
},
),
),
),
),
);
}
}

/* ========================================================================= */
/* DESTINATION                                                               */
/* ========================================================================= */

class _NavigationDestination extends StatelessWidget {
const _NavigationDestination({
required this.item,
required this.selected,
required this.onTap,
});

final _FleckNavItem item;
final bool selected;
final VoidCallback onTap;

@override
Widget build(BuildContext context) {
final colors = Theme.of(context).colorScheme;

return Material(
color: Colors.transparent,
child: InkWell(
onTap: onTap,
borderRadius: BorderRadius.circular(24.r),
splashColor: colors.primary.withValues(
alpha: 0.08,
),
highlightColor: colors.primary.withValues(
alpha: 0.04,
),
child: SizedBox(
height: 70.h,
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
/* -----------------------------------------------------------------
               * ICON
               *
               * No square / pill background.
               * ----------------------------------------------------------------- */

AnimatedSwitcher(
duration: const Duration(
milliseconds: 180,
),
switchInCurve: Curves.easeOutBack,
switchOutCurve: Curves.easeIn,
transitionBuilder: (
child,
animation,
) {
return ScaleTransition(
scale: animation,
child: child,
);
},
child: Icon(
selected
? item.selectedIcon
    : item.icon,
key: ValueKey(selected),
size: selected ? 24.sp : 23.sp,
color: selected
? colors.primary
    : colors.onSurfaceVariant,
),
),

/* -----------------------------------------------------------------
               * LABEL
               *
               * Only the selected item displays its name.
               * ----------------------------------------------------------------- */

AnimatedSize(
duration: const Duration(
milliseconds: 220,
),
curve: Curves.easeOutCubic,
child: selected
? Padding(
padding: EdgeInsets.only(
top: 3.h,
),
child: Text(
item.label,
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: TextStyle(
fontSize: 12.sp,
fontWeight: FontWeight.w600,
color: colors.primary,
height: 1.1,
letterSpacing: -0.1,
),
),
)
    : const SizedBox.shrink(),
),
],
),
),
),
);
}
}

/* ========================================================================= */
/* MODEL                                                                     */
/* ========================================================================= */

class _FleckNavItem {
const _FleckNavItem({
required this.icon,
required this.selectedIcon,
required this.label,
});

final IconData icon;
final IconData selectedIcon;
final String label;
}