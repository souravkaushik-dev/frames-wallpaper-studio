import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class FoliageSplashScreen extends StatefulWidget {
  const FoliageSplashScreen({
    super.key,
    this.onFinished,
  });

  final VoidCallback? onFinished;

  @override
  State<FoliageSplashScreen> createState() =>
      _FoliageSplashScreenState();
}

class _FoliageSplashScreenState
    extends State<FoliageSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<double> _markRotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1100,
      ),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0,
        .65,
        curve: Curves.easeOutBack,
      ),
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0,
        .45,
        curve: Curves.easeOut,
      ),
    );

    _markRotation = Tween<double>(
      begin: -.08,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0,
          .75,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _controller.forward();

    Future<void>.delayed(
      const Duration(
        milliseconds: 1500,
      ),
          () {
        if (!mounted) {
          return;
        }

        HapticFeedback.selectionClick();

        widget.onFinished?.call();
      },
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

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // -------------------------------------------------------------------
          // SUBTLE EXPRESSIVE BACKGROUND
          // -------------------------------------------------------------------

          Positioned(
            top: -100,
            right: -90,
            child: _BackgroundShape(
              size: 260,
              opacity: .055,
            ),
          ),

          Positioned(
            bottom: -120,
            left: -100,
            child: _BackgroundShape(
              size: 300,
              opacity: .04,
            ),
          ),

          // -------------------------------------------------------------------
          // CENTER
          // -------------------------------------------------------------------

          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (
                  context,
                  child,
                  ) {
                return FadeTransition(
                  opacity: _opacity,
                  child: Transform.scale(
                    scale:
                    .82 +
                        (_scale.value * .18),
                    child: Transform.rotate(
                      angle:
                      _markRotation.value,
                      child: child,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  // -----------------------------------------------------------
                  // FOLIAGE MARK
                  // -----------------------------------------------------------

                  Container(
                    width: 86,
                    height: 86,
                    decoration:
                    BoxDecoration(
                      color:
                      FleckTheme.seedColor,
                      borderRadius:
                      BorderRadius.circular(
                        29,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.eco_rounded,
                        color:
                        Colors.white,
                        size: 46,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // -----------------------------------------------------------
                  // NAME
                  // -----------------------------------------------------------

                  Text(
                    'Foliage',
                    style: theme
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w800,
                      letterSpacing:
                      -1.2,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    'Wallpaper, your way.',
                    style: theme
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color:
                      colors
                          .onSurfaceVariant,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // BOTTOM BRANDING
          // -------------------------------------------------------------------

          Positioned(
            left: 0,
            right: 0,
            bottom: 34,
            child: FadeTransition(
              opacity: _opacity,
              child: Text(
                'FOLIAGE',
                textAlign:
                TextAlign.center,
                style: theme
                    .textTheme
                    .labelSmall
                    ?.copyWith(
                  color: colors
                      .onSurfaceVariant
                      .withValues(
                    alpha: .65,
                  ),
                  fontWeight:
                  FontWeight.w700,
                  letterSpacing:
                  2.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BACKGROUND SHAPE
// =============================================================================

class _BackgroundShape
    extends StatelessWidget {
  const _BackgroundShape({
    required this.size,
    required this.opacity,
  });

  final double size;
  final double opacity;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: size,
      height: size,
      decoration:
      BoxDecoration(
        color:
        FleckTheme.seedColor
            .withValues(
          alpha: opacity,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}