import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import 'foliage_SHEET.dart';

/// Theme-aware Fleck colors.
///
/// Fleck has one brand source of truth:
///   FleckTheme.seedColor = Color(0xFF4B5D8B)
///
/// Every default color in this file comes from the active Material 3
/// Expressive ColorScheme generated from that seed. No independent brand
/// colors are defined here.
abstract final class FleckHeaderTheme {
  static Color searchContainer(BuildContext context) {
    return M3ETheme.of(context).colorScheme.primaryContainer;
  }

  static Color searchIcon(BuildContext context) {
    return M3ETheme.of(context).colorScheme.onPrimaryContainer;
  }

  static Color searchPressed(BuildContext context) {
    return M3ETheme.of(context).colorScheme.primary;
  }

  static Color searchPressedIcon(BuildContext context) {
    return M3ETheme.of(context).colorScheme.onPrimary;
  }

  static Color backgroundPressed(BuildContext context) {
    return M3ETheme.of(context).colorScheme.primary;
  }

  static Color fieldBackground(BuildContext context) {
    return M3ETheme.of(context).colorScheme.surfaceContainerLow;
  }

  static Color icon(BuildContext context) {
    return M3ETheme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color primaryIcon(BuildContext context) {
    return M3ETheme.of(context).colorScheme.primary;
  }

  static Color text(BuildContext context) {
    return M3ETheme.of(context).colorScheme.onSurface;
  }

  static Color hint(BuildContext context) {
    return M3ETheme.of(context).colorScheme.onSurfaceVariant
        .withValues(alpha: .72);
  }

  static Color outline(BuildContext context) {
    return M3ETheme.of(context).colorScheme.outlineVariant;
  }

  static Color closeContainer(BuildContext context) {
    return M3ETheme.of(context).colorScheme.secondaryContainer;
  }

  static Color closeIcon(BuildContext context) {
    return M3ETheme.of(context).colorScheme.onSecondaryContainer;
  }

  static Color bottomSheet(BuildContext context) {
    return M3ETheme.of(context).colorScheme.surfaceContainerHigh;
  }

  static Color pressedOverlay(BuildContext context) {
    return M3ETheme.of(context).colorScheme.onSurface.withValues(alpha: .045);
  }

  static Color highlightOverlay(BuildContext context) {
    return M3ETheme.of(context).colorScheme.onSurface.withValues(alpha: .025);
  }

  static Color sheetHandle(BuildContext context) {
    return M3ETheme.of(context).colorScheme.onSurfaceVariant
        .withValues(alpha: .20);
  }

  static Color scrim(BuildContext context) {
    return M3ETheme.of(context).colorScheme.scrim.withValues(alpha: .36);
  }
}

/// ============================================================================
/// REUSABLE ANIMATED SEARCH BAR
/// ============================================================================
///
/// Collapsed:
///   [ search icon ]
///
/// Expanded:
///   [ search icon ] Search wallpapers     [ x ]
///
/// Designed to be:
/// - minimal
/// - fast
/// - smooth
/// - tactile
/// - keyboard friendly
/// - compatible with existing Fleck screens
class ReusableAnimatedSearchBar extends StatefulWidget {
  const ReusableAnimatedSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Search wallpapers',
    this.width,
    this.height,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.onChanged,
    this.onOpened,
    this.onClosed,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  final String hintText;

  final double? width;
  final double? height;

  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  final ValueChanged<String>? onChanged;
  final VoidCallback? onOpened;
  final VoidCallback? onClosed;

  @override
  State<ReusableAnimatedSearchBar> createState() =>
      _ReusableAnimatedSearchBarState();
}

class _ReusableAnimatedSearchBarState extends State<ReusableAnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool _ownsController = false;
  bool _ownsFocusNode = false;

  bool _isOpen = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();

    if (_ownsController) {
      _controller.dispose();
    }

    if (_ownsFocusNode) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  // ===========================================================================
  // OPEN
  // ===========================================================================

  void _openSearch() {
    if (_isOpen) {
      return;
    }

    HapticFeedback.selectionClick();

    setState(() {
      _isOpen = true;
    });

    _animationController.forward();

    widget.onOpened?.call();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _focusNode.requestFocus();
    });
  }

  // ===========================================================================
  // CLOSE
  // ===========================================================================

  void _closeSearch() {
    if (!_isOpen) {
      return;
    }

    HapticFeedback.selectionClick();

    _focusNode.unfocus();

    _controller.clear();

    setState(() {
      _isOpen = false;
    });

    _animationController.reverse();

    widget.onClosed?.call();
    widget.onChanged?.call('');
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.backgroundColor ?? FleckHeaderTheme.searchContainer(context);

    final iconColor = widget.iconColor ?? FleckHeaderTheme.searchIcon(context);

    final textColor = widget.textColor ?? FleckHeaderTheme.text(context);

    final screenWidth = MediaQuery.sizeOf(context).width;

    final collapsedWidth = widget.width ?? 48.w;

    final expandedWidth =
        widget.width ?? (screenWidth - 44.w).clamp(220.w, 520.w);

    final height = widget.height ?? 48.w;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = Curves.easeOutCubic.transform(_animationController.value);

        final currentWidth = _isOpen ? expandedWidth : collapsedWidth;

        return SizedBox(
          width: currentWidth,
          height: height,
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              // ===============================================================
              // COLLAPSED SEARCH
              // ===============================================================

              IgnorePointer(
                ignoring: _isOpen,
                child: Opacity(
                  opacity: 1 - value,
                  child: _CollapsedSearchButton(
                    width: collapsedWidth,
                    height: height,
                    backgroundColor: backgroundColor,
                    pressedColor: FleckHeaderTheme.backgroundPressed(context),
                    iconColor: iconColor,
                    onPressed: _openSearch,
                  ),
                ),
              ),

              // ===============================================================
              // EXPANDED SEARCH
              // ===============================================================
              IgnorePointer(
                ignoring: !_isOpen,
                child: Opacity(
                  opacity: value,
                  child: Transform.scale(
                    alignment: Alignment.centerRight,
                    scale: .985 + (.015 * value),
                    child: _ExpandedSearchField(
                      controller: _controller,
                      focusNode: _focusNode,
                      width: expandedWidth,
                      height: height,
                      backgroundColor: backgroundColor,
                      iconColor: iconColor,
                      textColor: textColor,
                      hintColor: FleckHeaderTheme.hint(context),
                      outlineColor: FleckHeaderTheme.outline(context),
                      hintText: widget.hintText,
                      onChanged: widget.onChanged,
                      onClose: _closeSearch,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ============================================================================
/// COLLAPSED SEARCH BUTTON
/// ============================================================================

class _CollapsedSearchButton extends StatefulWidget {
  const _CollapsedSearchButton({
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.pressedColor,
    required this.iconColor,
    required this.onPressed,
  });

  final double width;
  final double height;

  final Color backgroundColor;
  final Color pressedColor;
  final Color iconColor;

  final VoidCallback onPressed;

  @override
  State<_CollapsedSearchButton> createState() => _CollapsedSearchButtonState();
}

class _CollapsedSearchButtonState extends State<_CollapsedSearchButton> {
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
    return AnimatedScale(
      scale: _pressed ? .96 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: _pressed ? widget.pressedColor : widget.backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            splashColor: FleckHeaderTheme.pressedOverlay(context),
            highlightColor: FleckHeaderTheme.highlightOverlay(context),
            onTap: widget.onPressed,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: Icon(
                FluentIcons.search_24_regular,
                size: 21.sp,
                color: widget.iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// EXPANDED SEARCH FIELD
/// ============================================================================

class _ExpandedSearchField extends StatelessWidget {
  const _ExpandedSearchField({
    required this.controller,
    required this.focusNode,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.hintColor,
    required this.outlineColor,
    required this.hintText,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  final double width;
  final double height;

  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color hintColor;
  final Color outlineColor;

  final String hintText;

  final ValueChanged<String>? onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18.r),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: outlineColor, width: 1),
        ),
        child: Row(
          children: [
            SizedBox(width: 14.w),

            Icon(FluentIcons.search_24_regular, size: 20.sp, color: iconColor),

            SizedBox(width: 9.w),

            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                textCapitalization: TextCapitalization.sentences,
                style: M3ETheme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.2,
                ),
                cursorColor: FleckHeaderTheme.text(context),
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintStyle: M3ETheme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w500,
                    color: hintColor,
                  ),
                ),
              ),
            ),

            SizedBox(width: 4.w),

            // ===============================================================
            // CLOSE
            // ===============================================================
            _SearchCloseButton(onPressed: onClose),

            SizedBox(width: 4.w),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// SEARCH CLOSE BUTTON
/// ============================================================================

class _SearchCloseButton extends StatefulWidget {
  const _SearchCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_SearchCloseButton> createState() => _SearchCloseButtonState();
}

class _SearchCloseButtonState extends State<_SearchCloseButton> {
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
    return AnimatedScale(
      scale: _pressed ? .92 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      child: Material(
        color: FleckHeaderTheme.closeContainer(context),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          splashColor: Colors.black.withValues(alpha: .045),
          onTap: widget.onPressed,
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          child: SizedBox(
            width: 38.w,
            height: 38.w,
            child: Icon(
              FluentIcons.dismiss_24_regular,
              size: 18.sp,
              color: FleckHeaderTheme.closeIcon(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// FLECK HEADER
/// ============================================================================
///
///   [ profile ]             Fleck             [ search ]
///
class FleckHeader extends StatelessWidget {
  const FleckHeader({
    super.key,
    required this.onProfile,
    this.searchController,
    this.searchFocusNode,
    this.onSearchChanged,
  });

  final VoidCallback onProfile;

  final TextEditingController? searchController;

  final FocusNode? searchFocusNode;

  final ValueChanged<String>? onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        14.w,
        6.h,
        14.w,
        6.h,
      ),
      child: Row(
        children: [
          // ================================================================
          // PROFILE
          // ================================================================

          _HeaderIconButton(
            icon:
            FluentIcons.person_24_regular,

            onPressed: onProfile,

            backgroundColor:
            FleckHeaderTheme.searchContainer(
              context,
            ),

            iconColor:
            FleckHeaderTheme.searchIcon(
              context,
            ),
          ),

          // ================================================================
          // TITLE
          // ================================================================

          Expanded(
            child: Center(
              child: Text(
                'FOLIAGE',
                style: M3ETheme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                  color:
                  FleckHeaderTheme.text(
                    context,
                  ),
                  fontSize: 18.sp,
                  fontWeight:
                  FontWeight.w800,
                  letterSpacing: -.7,
                  height: 1,
                ),
              ),
            ),
          ),

          // ================================================================
          // SEARCH
          // ================================================================

          ReusableAnimatedSearchBar(
            controller:
            searchController,
            focusNode:
            searchFocusNode,
            onChanged:
            onSearchChanged,
          ),
        ],
      ),
    );
  }
}
/// ============================================================================
/// HEADER ICON BUTTON
/// ============================================================================

class _HeaderIconButton extends StatefulWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;

  final Color backgroundColor;
  final Color iconColor;

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
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
    return AnimatedScale(
      scale: _pressed ? .95 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: _pressed
              ? FleckHeaderTheme.backgroundPressed(context)
              : widget.backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            splashColor: FleckHeaderTheme.pressedOverlay(context),
            highlightColor: FleckHeaderTheme.highlightOverlay(context),
            onTap: widget.onPressed,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            child: SizedBox(
              width: 48.w,
              height: 48.w,
              child: Icon(widget.icon, size: 21.sp, color: widget.iconColor),
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// APP BOTTOM SHEET
/// ============================================================================
///
/// Centralized Fleck bottom-sheet helper.
///
/// Keeps the public API from the original file while giving the sheet:
/// - softer corners
/// - quieter barrier
/// - consistent handle
/// - safer horizontal spacing
class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool useSafeArea = true,
    bool isScrollControlled = false,
    bool showDragHandle = true,
    Color? barrierColor,
    Color? backgroundColor,
    double radius = 28,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useSafeArea: useSafeArea,
      isScrollControlled: isScrollControlled,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      barrierColor: barrierColor ?? FleckHeaderTheme.scrim(context),
      elevation: 0,
      builder: (context) {
        return AppBottomSheetContainer(
          backgroundColor: backgroundColor,
          radius: radius,
          showHandle: showDragHandle,
          child: builder(context),
        );
      },
    );
  }
}

/// ============================================================================
/// BOTTOM SHEET CONTAINER
/// ============================================================================

class AppBottomSheetContainer extends StatelessWidget {
  const AppBottomSheetContainer({
    super.key,
    required this.child,
    this.padding,
    this.radius = 28,
    this.backgroundColor,
    this.showHandle = true,
  });

  final Widget child;

  final EdgeInsets? padding;

  final double radius;

  final Color? backgroundColor;

  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? FleckHeaderTheme.bottomSheet(context),
      borderRadius: BorderRadius.vertical(top: Radius.circular(radius.r)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding ?? EdgeInsets.fromLTRB(20.w, 9.h, 20.w, 22.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHandle) ...[
                Center(
                  child: Container(
                    width: 34.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: FleckHeaderTheme.sheetHandle(context),
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
              ],

              child,
            ],
          ),
        ),
      ),
    );
  }
}
