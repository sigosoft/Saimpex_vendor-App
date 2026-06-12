import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable app-wide loading indicator widget.
/// Uses the same Lottie dotted circular animation shown during login.
/// Drop-in replacement for all [CircularProgressIndicator] usages in the app.
class AppLoader extends StatelessWidget {
  /// The size of the Lottie animation. Defaults to 80.
  final double size;

  const AppLoader({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'lib/assets/images/loader.json',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// A premium retro pixel-art loading indicator widget representing a burger reveal & dissolve animation.
/// Specifically designed to be shown only during image upload/enhancement phases.
class PixelRevealLoader extends StatefulWidget {
  /// The base size of the loader widget. Defaults to 80.
  final double size;

  const PixelRevealLoader({super.key, this.size = 80});

  @override
  State<PixelRevealLoader> createState() => _PixelRevealLoaderState();
}

class _PixelRevealLoaderState extends State<PixelRevealLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Matrix representing the retro pixel burger:
  // 0: Empty/Transparent
  // 1: Bun (Orange: Color(0xFFFF5216))
  // 2: Cheese (Yellow: Color(0xFFE2B93B))
  // 3: Patty (Brown: Color(0xFF8B4513))
  // 4: Lettuce (Green: Color(0xFF27AE60))
  final List<List<int>> _burgerMatrix = const [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 1, 1, 1, 1, 0, 0, 0], // Top bun top
    [0, 0, 1, 1, 1, 1, 1, 1, 0, 0], // Top bun middle
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 0], // Top bun bottom
    [1, 2, 4, 2, 4, 2, 4, 2, 4, 1], // Lettuce and cheese layer
    [0, 3, 3, 3, 3, 3, 3, 3, 3, 0], // Patty
    [0, 3, 3, 3, 3, 3, 3, 3, 3, 0], // Patty
    [0, 0, 1, 1, 1, 1, 1, 1, 0, 0], // Bottom bun
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  ];

  final List<math.Point<int>> _activePixels = [];

  @override
  void initState() {
    super.initState();
    // Gather all active pixel coordinates
    for (int r = 0; r < 10; r++) {
      for (int c = 0; c < 10; c++) {
        if (_burgerMatrix[r][c] > 0) {
          _activePixels.add(math.Point(r, c));
        }
      }
    }
    // Shuffle to create a random scanning/reveal pattern
    _activePixels.shuffle();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(235), // Frosted glassmorphism background
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 24.0,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white.withAlpha(153),
            width: 1.5,
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double value = _controller.value;
            int activeCount = 0;
            double scale = 1.0;
            double opacity = 1.0;

            if (value < 0.4) {
              // Phase 1: Scan and reveal (0.0 to 0.4)
              final double localT = value / 0.4;
              activeCount = (localT * _activePixels.length).round();
            } else if (value < 0.6) {
              // Phase 2: Hold, pulse scale & glow (0.4 to 0.6)
              final double localT = (value - 0.4) / 0.2;
              activeCount = _activePixels.length;
              scale = 1.0 + 0.05 * math.sin(localT * math.pi);
            } else {
              // Phase 3: Dissolve pixels (0.6 to 1.0)
              final double localT = (value - 0.6) / 0.4;
              activeCount = _activePixels.length - (localT * _activePixels.length).round();
              opacity = (1.0 - localT).clamp(0.0, 1.0);
            }

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: widget.size,
                        height: widget.size,
                        child: CustomPaint(
                          painter: PixelRevealPainter(
                            matrix: _burgerMatrix,
                            activePixels: _activePixels,
                            activeCount: activeCount,
                            bunColor: const Color(0xFFFF5216),
                            cheeseColor: const Color(0xFFE2B93B),
                            pattyColor: const Color(0xFF8B4513),
                            lettuceColor: const Color(0xFF27AE60),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "ENHANCING IMAGE",
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFF5216),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Optimizing resolution & details...",
                        style: GoogleFonts.rubik(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PixelRevealPainter extends CustomPainter {
  final List<List<int>> matrix;
  final List<math.Point<int>> activePixels;
  final int activeCount;
  final Color bunColor;
  final Color cheeseColor;
  final Color pattyColor;
  final Color lettuceColor;

  PixelRevealPainter({
    required this.matrix,
    required this.activePixels,
    required this.activeCount,
    required this.bunColor,
    required this.cheeseColor,
    required this.pattyColor,
    required this.lettuceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double pixelWidth = size.width / 10;
    final double pixelHeight = size.height / 10;

    // Background faint blueprint grid lines
    final Paint gridPaint = Paint()
      ..color = const Color(0x12FF5216) // faint Saimpex orange grid line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int r = 0; r < 10; r++) {
      for (int c = 0; c < 10; c++) {
        canvas.drawRect(
          Rect.fromLTWH(
            c * pixelWidth,
            r * pixelHeight,
            pixelWidth,
            pixelHeight,
          ),
          gridPaint,
        );
      }
    }

    // Build map for quick lookups of revealed pixels
    final Set<String> revealed = {};
    for (int i = 0; i < activeCount && i < activePixels.length; i++) {
      final p = activePixels[i];
      revealed.add('${p.x},${p.y}');
    }

    final Paint paint = Paint()..isAntiAlias = false;

    for (int r = 0; r < 10; r++) {
      for (int c = 0; c < 10; c++) {
        final int type = matrix[r][c];
        if (type > 0 && revealed.contains('$r,$c')) {
          switch (type) {
            case 1:
              paint.color = bunColor;
              break;
            case 2:
              paint.color = cheeseColor;
              break;
            case 3:
              paint.color = pattyColor;
              break;
            case 4:
              paint.color = lettuceColor;
              break;
            default:
              paint.color = Colors.transparent;
          }

          // Draw the pixel block (with a tiny 1px margin to keep the blocky grid style distinct)
          canvas.drawRect(
            Rect.fromLTWH(
              c * pixelWidth + 0.5,
              r * pixelHeight + 0.5,
              pixelWidth - 1,
              pixelHeight - 1,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PixelRevealPainter oldDelegate) {
    return oldDelegate.activeCount != activeCount ||
        oldDelegate.activePixels != activePixels;
  }
}
