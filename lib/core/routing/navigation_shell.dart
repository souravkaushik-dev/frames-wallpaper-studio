import 'package:fleck/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';

import '../../data/models/wallpaper_category.dart';
import '../../data/repositories/wallpaper_repository.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';

/// Main Fleck application shell.
///
/// The shell owns:
/// - Favorites count
/// - Current navigation destination
/// - Wallpaper categories
///
/// ThemeMode remains owned by FleckApp and is passed through to Profile.
class FleckShell extends StatefulWidget {
  const FleckShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<FleckShell> createState() => _FleckShellState();
}

class _FleckShellState extends State<FleckShell> {
  // ===========================================================================
  // REPOSITORY
  // ===========================================================================

  late final WallpaperRepository _repository;

  // ===========================================================================
  // PROFILE
  // ===========================================================================

  final ValueNotifier<int> _favoriteCount =
  ValueNotifier<int>(0);

  // ===========================================================================
  // CATEGORIES
  // ===========================================================================

  List<WallpaperCategory> _categories =
  <WallpaperCategory>[];

  bool _loading = true;
  String? _error;

  // ===========================================================================
  // NAVIGATION
  // ===========================================================================

  int _selectedIndex = 0;

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _repository = WallpaperRepository();

    _loadCategories();
  }

  // ===========================================================================
  // LOAD CATEGORIES
  // ===========================================================================

  Future<void> _loadCategories() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final response = await _repository.getAll();

      if (!mounted) {
        return;
      }

      setState(() {
        _categories = response.categories;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  // ===========================================================================
  // NAVIGATION
  // ===========================================================================

  void _onDestinationSelected(int index) {
    if (index < 0 || index > 3) {
      return;
    }

    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _openFavorites() {
    _onDestinationSelected(2);
  }

  // ===========================================================================
  // FAVORITES COUNT
  // ===========================================================================

  void setFavoriteCount(int count) {
    _favoriteCount.value = count < 0 ? 0 : count;
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _favoriteCount.dispose();
    _repository.dispose();

    super.dispose();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _ShellLoading();
    }

    if (_error != null) {
      return _ShellError(
        onRetry: _loadCategories,
      );
    }

    final screens = <Widget>[
      const FleckHomeScreen(),

      CollectionsScreen(
        categories: _categories,
      ),

      const FleckFavoritesScreen(),

      ProfileScreen(
        favoriteCount: _favoriteCount,
        themeMode: widget.themeMode,
        onFavorites: _openFavorites,
        onThemeModeChanged:
        widget.onThemeModeChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: FleckNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected:
        _onDestinationSelected,
      ),
    );
  }
}

// =============================================================================
// LOADING
// =============================================================================

class _ShellLoading extends StatefulWidget {
  const _ShellLoading();

  @override
  State<_ShellLoading> createState() =>
      _ShellLoadingState();
}

class _ShellLoadingState extends State<_ShellLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1100,
      ),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final value = Curves.easeInOutCubic
                .transform(_controller.value);

            return Transform.scale(
              scale: .94 + (value * .06),
              child: child,
            );
          },
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: FleckTheme.primarySoft,
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(
                    FleckTheme.seedColor,
                  ),
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
// ERROR
// =============================================================================

class _ShellError extends StatelessWidget {
  const _ShellError({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 360,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius:
                    BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.cloud_off_outlined,
                    size: 31,
                    color:
                    colors.onErrorContainer,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'Could not load Fleck',
                  textAlign: TextAlign.center,
                  style: theme.textTheme
                      .headlineSmall
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w700,
                    letterSpacing: -.5,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  'Check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(
                    color:
                    colors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 22),

                FilledButton.icon(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                    FleckTheme.seedColor,
                    foregroundColor:
                    FleckTheme.onPrimary,
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 13,
                    ),
                  ),
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  label: const Text(
                    'Try again',
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
