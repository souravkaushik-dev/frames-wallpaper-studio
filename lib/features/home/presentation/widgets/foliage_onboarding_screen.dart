import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';

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

class _FoliageOnboardingScreenState
    extends State<FoliageOnboardingScreen> {
  // ===========================================================================
  // CONTROLLERS
  // ===========================================================================

  late final PageController _pageController;

  final TextEditingController _nameController =
  TextEditingController();

  final FocusNode _nameFocusNode =
  FocusNode();

  // ===========================================================================
  // STATE
  // ===========================================================================

  int _currentPage = 0;

  bool _saving = false;

  // ===========================================================================
  // CONSTANTS
  // ===========================================================================

  static const Color _seedColor =
  Color(0xFF6678A6);

  static const String _nameKey =
      'foliage_user_name';

  static const String _onboardingKey =
      'foliage_onboarding_completed';

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _pageController =
        PageController();

    _nameController.addListener(
      _onNameChanged,
    );
  }

  // ===========================================================================
  // NAME
  // ===========================================================================

  void _onNameChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  String get _name =>
      _nameController.text.trim();

  bool get _hasName =>
      _name.length >= 2;

  String get _initial {
    final value = _name.trim();

    if (value.isEmpty) {
      return 'F';
    }

    return value.characters.first
        .toUpperCase();
  }

  // ===========================================================================
  // PAGE
  // ===========================================================================

  void _onPageChanged(
      int page,
      ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _next() async {
    if (_saving) {
      return;
    }

    HapticFeedback.selectionClick();

    if (_currentPage <
        _pages.length - 1) {
      await _pageController.nextPage(
        duration:
        const Duration(
          milliseconds: 480,
        ),
        curve:
        Curves.easeOutCubic,
      );

      return;
    }

    await _complete();
  }

  void _back() {
    if (_currentPage <= 0 ||
        _saving) {
      return;
    }

    HapticFeedback.selectionClick();

    _pageController.previousPage(
      duration:
      const Duration(
        milliseconds: 420,
      ),
      curve:
      Curves.easeOutCubic,
    );
  }

  // ===========================================================================
  // COMPLETE
  // ===========================================================================

  Future<void> _complete() async {
    if (_saving) {
      return;
    }

    if (!_hasName) {
      HapticFeedback.heavyImpact();

      _nameFocusNode.requestFocus();

      _showMessage(
        'Enter your name to continue.',
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    HapticFeedback.mediumImpact();

    try {
      final prefs =
      await SharedPreferences
          .getInstance();

      await prefs.setString(
        _nameKey,
        _name,
      );

      await prefs.setBool(
        _onboardingKey,
        true,
      );

      await widget.onCompleted(
        _name,
      );
    } catch (error) {
      debugPrint(
        'Foliage onboarding error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
      });

      _showMessage(
        'Could not finish setup. Try again.',
      );
    }
  }

  // ===========================================================================
  // SKIP
  // ===========================================================================

  Future<void> _skip() async {
    if (_saving) {
      return;
    }

    HapticFeedback.selectionClick();

    try {
      final prefs =
      await SharedPreferences
          .getInstance();

      await prefs.setBool(
        _onboardingKey,
        true,
      );

      await widget.onCompleted(
        '',
      );
    } catch (error) {
      debugPrint(
        'Foliage skip error: $error',
      );
    }
  }

  // ===========================================================================
  // MESSAGE
  // ===========================================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    final colors =
        Theme.of(context)
            .colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior:
          SnackBarBehavior.floating,
          backgroundColor:
          colors.inverseSurface,
          elevation: 0,
          margin:
          EdgeInsets.fromLTRB(
            16.w,
            0,
            16.w,
            18.h,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              18.r,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color:
              colors.onInverseSurface,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),
      );
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();

    super.dispose();
  }

  // ===========================================================================
  // PAGES
  // ===========================================================================

  List<_OnboardingPage> get _pages =>
      const [
        _OnboardingPage(
          eyebrow: 'WELCOME TO FOLIAGE',
          title:
          'Wallpaper,\nyour way.',
          description:
          'A calm place to discover wallpapers '
              'that make your screen feel like yours.',
          type:
          _OnboardingVisual.welcome,
        ),
        _OnboardingPage(
          eyebrow: 'DISCOVER',
          title:
          'Find a style\nthat feels right.',
          description:
          'Explore carefully picked collections '
              'from foliage and floral to ferro and smudges.',
          type:
          _OnboardingVisual.discover,
        ),
        _OnboardingPage(
          eyebrow: 'MAKE IT YOURS',
          title:
          'Save the ones\nyou love.',
          description:
          'Favorite wallpapers, download them '
              'and apply them directly to your device.',
          type:
          _OnboardingVisual.save,
        ),
        _OnboardingPage(
          eyebrow: 'ONE LAST THING',
          title:
          'What should\nwe call you?',
          description:
          'Your name is used only to personalize '
              'your Foliage experience.',
          type:
          _OnboardingVisual.name,
        ),
      ];

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final colors =
        theme.colorScheme;

    return Scaffold(
      backgroundColor:
      colors.surface,

      body: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // TOP BAR
            // =================================================================

            Padding(
              padding:
              EdgeInsets.fromLTRB(
                20.w,
                12.h,
                20.w,
                0,
              ),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration:
                    const Duration(
                      milliseconds: 260,
                    ),
                    switchInCurve:
                    Curves.easeOutCubic,
                    switchOutCurve:
                    Curves.easeInCubic,
                    child:
                    _currentPage > 0
                        ? _OnboardingIconButton(
                      key:
                      const ValueKey(
                        'back',
                      ),
                      icon:
                      Icons
                          .arrow_back_rounded,
                      onPressed:
                      _back,
                    )
                        : SizedBox(
                      key:
                      const ValueKey(
                        'empty',
                      ),
                      width: 42.w,
                      height: 42.w,
                    ),
                  ),

                  const Spacer(),

                  const _FoliageMark(),

                  const Spacer(),

                  AnimatedOpacity(
                    opacity:
                    _currentPage <
                        _pages.length -
                            1
                        ? 1
                        : 0,
                    duration:
                    const Duration(
                      milliseconds: 220,
                    ),
                    child:
                    IgnorePointer(
                      ignoring:
                      _currentPage ==
                          _pages.length -
                              1,
                      child:
                      TextButton(
                        onPressed:
                        _skip,
                        style:
                        TextButton.styleFrom(
                          foregroundColor:
                          colors
                              .onSurfaceVariant,
                          padding:
                          EdgeInsets
                              .symmetric(
                            horizontal:
                            8.w,
                          ),
                          minimumSize:
                          Size(
                            42.w,
                            42.w,
                          ),
                        ),
                        child:
                        const Text(
                          'Skip',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =================================================================
            // PAGE VIEW
            // =================================================================

            Expanded(
              child:
              PageView.builder(
                controller:
                _pageController,
                itemCount:
                _pages.length,
                onPageChanged:
                _onPageChanged,
                physics:
                const BouncingScrollPhysics(),
                itemBuilder:
                    (
                    context,
                    index,
                    ) {
                  final page =
                  _pages[index];

                  return _OnboardingContent(
                    page: page,
                    nameController:
                    _nameController,
                    nameFocusNode:
                    _nameFocusNode,
                    showNameField:
                    index ==
                        _pages.length -
                            1,
                    onNameSubmitted:
                        (_) => _complete(),
                  );
                },
              ),
            ),

            // =================================================================
            // BOTTOM CONTROLS
            // =================================================================

            Padding(
              padding:
              EdgeInsets.fromLTRB(
                20.w,
                0,
                20.w,
                18.h,
              ),
              child: Column(
                children: [
                  _ExpressivePageIndicator(
                    count:
                    _pages.length,
                    current:
                    _currentPage,
                  ),

                  SizedBox(
                    height: 18.h,
                  ),

                  // -----------------------------------------------------------
                  // MAIN ACTION
                  // -----------------------------------------------------------

                  SizedBox(
                    width:
                    double.infinity,
                    height: 56.h,
                    child:
                    FilledButton(
                      onPressed:
                      _saving
                          ? null
                          : _next,
                      style:
                      FilledButton.styleFrom(
                        backgroundColor:
                        colors.primary,
                        foregroundColor:
                        colors
                            .onPrimary,
                        disabledBackgroundColor:
                        colors
                            .primary
                            .withValues(
                          alpha: .45,
                        ),
                        elevation: 0,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            18.r,
                          ),
                        ),
                      ),
                      child:
                      AnimatedSwitcher(
                        duration:
                        const Duration(
                          milliseconds: 220,
                        ),
                        child:
                        _saving
                            ? SizedBox(
                          key:
                          const ValueKey(
                            'loading',
                          ),
                          width:
                          21.w,
                          height:
                          21.w,
                          child:
                          CircularProgressIndicator(
                            strokeWidth:
                            2.2,
                            color:
                            colors
                                .onPrimary,
                          ),
                        )
                            : Text(
                          _currentPage ==
                              _pages.length -
                                  1
                              ? 'Start exploring'
                              : 'Continue',
                          key:
                          ValueKey(
                            _currentPage ==
                                _pages.length -
                                    1
                                ? 'start'
                                : 'continue',
                          ),
                          style:
                          TextStyle(
                            fontFamily:
                            GoogleFonts
                                .inter()
                                .fontFamily,
                            fontWeight:
                            FontWeight
                                .w700,
                            fontSize:
                            16.sp,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 8.h,
                  ),

                  AnimatedSwitcher(
                    duration:
                    const Duration(
                      milliseconds: 220,
                    ),
                    child: Text(
                      _currentPage ==
                          _pages.length -
                              1
                          ? 'Your preferences stay on your device.'
                          : 'Swipe to explore',
                      key: ValueKey(
                        _currentPage ==
                            _pages.length -
                                1
                            ? 'privacy'
                            : 'swipe',
                      ),
                      style:
                      theme.textTheme.bodySmall
                          ?.copyWith(
                        color:
                        colors
                            .onSurfaceVariant,
                        fontWeight:
                        FontWeight.w500,
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
// PAGE MODEL
// =============================================================================

enum _OnboardingVisual {
  welcome,
  discover,
  save,
  name,
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.type,
  });

  final String eyebrow;
  final String title;
  final String description;
  final _OnboardingVisual type;
}

// =============================================================================
// CONTENT
// =============================================================================

class _OnboardingContent
    extends StatelessWidget {
  const _OnboardingContent({
    required this.page,
    required this.nameController,
    required this.nameFocusNode,
    required this.showNameField,
    required this.onNameSubmitted,
  });

  final _OnboardingPage page;

  final TextEditingController
  nameController;

  final FocusNode nameFocusNode;

  final bool showNameField;

  final ValueChanged<String>
  onNameSubmitted;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final colors =
        theme.colorScheme;

    return SingleChildScrollView(
      physics:
      const BouncingScrollPhysics(),

      padding:
      EdgeInsets.fromLTRB(
        20.w,
        10.h,
        20.w,
        24.h,
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // ===================================================================
          // VISUAL
          // ===================================================================

          SizedBox(
            height: 310.h,
            child:
            _OnboardingVisualCard(
              type:
              page.type,
              initial:
              nameController.text
                  .trim()
                  .isEmpty
                  ? 'F'
                  : nameController
                  .text
                  .trim()
                  .characters
                  .first
                  .toUpperCase(),
            ),
          ),

          SizedBox(
            height: 24.h,
          ),

          // ===================================================================
          // EYEBROW
          // ===================================================================

          _SmallPill(
            label:
            page.eyebrow,
          ),

          SizedBox(
            height: 12.h,
          ),

          // ===================================================================
          // TITLE
          // ===================================================================

          Text(
            page.title,
            style: theme
                .textTheme
                .displaySmall
                ?.copyWith(
              fontWeight:
              FontWeight.w800,
              letterSpacing:
              -1.7,
              height:
              .98,
            ),
          ),

          SizedBox(
            height: 13.h,
          ),

          // ===================================================================
          // DESCRIPTION
          // ===================================================================

          Text(
            page.description,
            style: theme
                .textTheme
                .bodyLarge
                ?.copyWith(
              color:
              colors
                  .onSurfaceVariant,
              height:
              1.45,
              fontWeight:
              FontWeight.w500,
            ),
          ),

          // ===================================================================
          // NAME FIELD
          // ===================================================================

          if (showNameField) ...[
            SizedBox(
              height: 22.h,
            ),

            TextField(
              controller:
              nameController,
              focusNode:
              nameFocusNode,
              textCapitalization:
              TextCapitalization.words,
              textInputAction:
              TextInputAction.done,
              onSubmitted:
              onNameSubmitted,
              maxLength: 40,
              style: theme
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight:
                FontWeight.w600,
              ),
              decoration:
              InputDecoration(
                counterText:
                '',
                hintText:
                'Your name',
                prefixIcon:
                Icon(
                  Icons
                      .person_outline_rounded,
                  color:
                  colors.primary,
                ),
                filled: true,
                fillColor:
                colors
                    .surfaceContainerLow,
                contentPadding:
                EdgeInsets
                    .symmetric(
                  horizontal:
                  18.w,
                  vertical:
                  16.h,
                ),
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    18.r,
                  ),
                  borderSide:
                  BorderSide(
                    color:
                    colors
                        .outlineVariant,
                  ),
                ),
                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    18.r,
                  ),
                  borderSide:
                  BorderSide(
                    color:
                    colors
                        .outlineVariant,
                  ),
                ),
                focusedBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    18.r,
                  ),
                  borderSide:
                  BorderSide(
                    color:
                    colors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 8.h,
            ),

            Row(
              children: [
                Icon(
                  Icons
                      .lock_outline_rounded,
                  size: 15.sp,
                  color:
                  colors
                      .onSurfaceVariant,
                ),
                SizedBox(
                  width: 6.w,
                ),
                Expanded(
                  child: Text(
                    'Only used for your personal '
                        'Foliage experience.',
                    style: theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color:
                      colors
                          .onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// VISUAL CARD
// =============================================================================

class _OnboardingVisualCard
    extends StatelessWidget {
  const _OnboardingVisualCard({
    required this.type,
    required this.initial,
  });

  final _OnboardingVisual type;
  final String initial;

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Container(
      decoration:
      BoxDecoration(
        color:
        colors.surfaceContainerLow,
        borderRadius:
        BorderRadius.circular(
          30.r,
        ),
      ),
      child: Center(
        child: _buildVisual(
          context,
        ),
      ),
    );
  }

  Widget _buildVisual(
      BuildContext context,
      ) {
    switch (type) {
      case _OnboardingVisual.welcome:
        return const _WelcomeVisual();

      case _OnboardingVisual.discover:
        return const _DiscoverVisual();

      case _OnboardingVisual.save:
        return const _SaveVisual();

      case _OnboardingVisual.name:
        return _NameVisual(
          initial: initial,
        );
    }
  }
}

// =============================================================================
// WELCOME VISUAL
// =============================================================================

class _WelcomeVisual
    extends StatelessWidget {
  const _WelcomeVisual();

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Stack(
      alignment:
      Alignment.center,
      children: [
        Transform.rotate(
          angle: -.07,
          child: Container(
            width: 170.w,
            height: 220.h,
            decoration:
            BoxDecoration(
              color:
              colors.primaryContainer,
              borderRadius:
              BorderRadius.circular(
                30.r,
              ),
            ),
          ),
        ),

        Transform.rotate(
          angle: .06,
          child: Container(
            width: 170.w,
            height: 220.h,
            decoration:
            BoxDecoration(
              color:
              colors.surfaceContainerHighest,
              borderRadius:
              BorderRadius.circular(
                30.r,
              ),
            ),
          ),
        ),

        Container(
          width: 170.w,
          height: 220.h,
          decoration:
          BoxDecoration(
            color:
            colors.primary,
            borderRadius:
            BorderRadius.circular(
              30.r,
            ),
          ),
          child: Center(
            child: Icon(
              Icons
                  .filter_vintage_rounded,
              color:
              colors.onPrimary,
              size: 64.sp,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// DISCOVER VISUAL
// =============================================================================

class _DiscoverVisual
    extends StatelessWidget {
  const _DiscoverVisual();

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Column(
      mainAxisSize:
      MainAxisSize.min,
      children: [
        Container(
          width: 205.w,
          height: 165.h,
          decoration:
          BoxDecoration(
            color:
            colors.primaryContainer,
            borderRadius:
            BorderRadius.circular(
              28.r,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 22.h,
                left: 22.w,
                child: Icon(
                  Icons.eco_rounded,
                  size: 68.sp,
                  color:
                  colors
                      .onPrimaryContainer,
                ),
              ),
              Positioned(
                right: 18.w,
                bottom: 16.h,
                child: Icon(
                  Icons
                      .local_florist_rounded,
                  size: 54.sp,
                  color: colors
                      .onPrimaryContainer
                      .withValues(
                    alpha: .55,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 14.h,
        ),

        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          alignment:
          WrapAlignment.center,
          children: const [
            _MiniCategoryPill(
              label: 'Foliage',
              selected: true,
            ),
            _MiniCategoryPill(
              label: 'Floral',
            ),
            _MiniCategoryPill(
              label: 'Ferro',
            ),
            _MiniCategoryPill(
              label: 'Smudges',
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// SAVE VISUAL
// =============================================================================

class _SaveVisual
    extends StatelessWidget {
  const _SaveVisual();

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Stack(
      alignment:
      Alignment.center,
      children: [
        Container(
          width: 215.w,
          height: 180.h,
          decoration:
          BoxDecoration(
            color:
            colors.surfaceContainerHighest,
            borderRadius:
            BorderRadius.circular(
              30.r,
            ),
          ),
        ),

        Positioned(
          left: 22.w,
          top: 18.h,
          child: Container(
            width: 92.w,
            height: 136.h,
            decoration:
            BoxDecoration(
              color:
              colors.secondaryContainer,
              borderRadius:
              BorderRadius.circular(
                23.r,
              ),
            ),
            child: Icon(
              Icons
                  .favorite_rounded,
              color:
              colors
                  .onSecondaryContainer,
              size: 38.sp,
            ),
          ),
        ),

        Positioned(
          right: 22.w,
          bottom: 18.h,
          child: Container(
            width: 92.w,
            height: 136.h,
            decoration:
            BoxDecoration(
              color:
              colors.primaryContainer,
              borderRadius:
              BorderRadius.circular(
                23.r,
              ),
            ),
            child: Icon(
              Icons
                  .wallpaper_rounded,
              color:
              colors
                  .onPrimaryContainer,
              size: 38.sp,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// NAME VISUAL
// =============================================================================

class _NameVisual
    extends StatelessWidget {
  const _NameVisual({
    required this.initial,
  });

  final String initial;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final colors =
        theme.colorScheme;

    return AnimatedSwitcher(
      duration:
      const Duration(
        milliseconds: 300,
      ),
      switchInCurve:
      Curves.easeOutBack,
      switchOutCurve:
      Curves.easeInCubic,
      transitionBuilder:
          (
          child,
          animation,
          ) {
        return FadeTransition(
          opacity:
          animation,
          child:
          ScaleTransition(
            scale:
            Tween<double>(
              begin: .78,
              end: 1,
            ).animate(
              animation,
            ),
            child:
            child,
          ),
        );
      },
      child: Container(
        key:
        ValueKey(initial),
        width: 158.w,
        height: 158.w,
        decoration:
        BoxDecoration(
          color:
          colors.primaryContainer,
          borderRadius:
          BorderRadius.circular(
            48.r,
          ),
        ),
        alignment:
        Alignment.center,
        child: Text(
          initial,
          style: theme
              .textTheme
              .displayLarge
              ?.copyWith(
            color:
            colors
                .onPrimaryContainer,
            fontSize: 72.sp,
            fontWeight:
            FontWeight.w800,
            height: 1,
            letterSpacing:
            -3,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SMALL PILL
// =============================================================================

class _SmallPill
    extends StatelessWidget {
  const _SmallPill({
    required this.label,
  });

  final String label;

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Container(
      padding:
      EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration:
      BoxDecoration(
        color:
        colors.primaryContainer,
        borderRadius:
        BorderRadius.circular(
          99.r,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color:
          colors
              .onPrimaryContainer,
          fontSize: 9.5.sp,
          fontWeight:
          FontWeight.w800,
          letterSpacing:
          .7,
        ),
      ),
    );
  }
}

// =============================================================================
// MINI CATEGORY PILL
// =============================================================================

class _MiniCategoryPill
    extends StatelessWidget {
  const _MiniCategoryPill({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Container(
      padding:
      EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration:
      BoxDecoration(
        color: selected
            ? colors.primary
            : colors
            .surfaceContainerHighest,
        borderRadius:
        BorderRadius.circular(
          99.r,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected
              ? colors.onPrimary
              : colors
              .onSurfaceVariant,
          fontSize: 10.sp,
          fontWeight:
          FontWeight.w700,
        ),
      ),
    );
  }
}

// =============================================================================
// FOLIAGE MARK
// =============================================================================

class _FoliageMark
    extends StatelessWidget {
  const _FoliageMark();

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Container(
      width: 40.w,
      height: 40.w,
      decoration:
      BoxDecoration(
        color:
        colors.primaryContainer,
        borderRadius:
        BorderRadius.circular(
          14.r,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.eco_rounded,
          color:
          colors
              .onPrimaryContainer,
          size: 21.sp,
        ),
      ),
    );
  }
}

// =============================================================================
// ICON BUTTON
// =============================================================================

class _OnboardingIconButton
    extends StatelessWidget {
  const _OnboardingIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Material(
      color:
      colors
          .surfaceContainerHighest,
      borderRadius:
      BorderRadius.circular(
        14.r,
      ),
      clipBehavior:
      Clip.antiAlias,
      child: InkWell(
        onTap:
        onPressed,
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Icon(
            icon,
            size: 19.sp,
            color:
            colors.onSurface,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// EXPRESSIVE PAGE INDICATOR
// =============================================================================

class _ExpressivePageIndicator
    extends StatelessWidget {
  const _ExpressivePageIndicator({
    required this.count,
    required this.current,
  });

  final int count;
  final int current;

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children:
      List.generate(
        count,
            (index) {
          final selected =
              index == current;

          return AnimatedContainer(
            duration:
            const Duration(
              milliseconds: 360,
            ),
            curve:
            Curves.easeOutCubic,
            margin:
            EdgeInsets.symmetric(
              horizontal: 3.w,
            ),
            width:
            selected
                ? 28.w
                : 7.w,
            height: 7.w,
            decoration:
            BoxDecoration(
              color: selected
                  ? colors.primary
                  : colors
                  .outlineVariant,
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