import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A reusable app-wide loading indicator widget themed for restaurants and food.
/// Features a central pulsing hot pot badge with rising steam and orbiting food items.
class AppLoader extends StatefulWidget {
  /// The base size of the loader widget. Defaults to 80.
  final double size;

  const AppLoader({super.key, this.size = 80});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double centerCircleSize = widget.size * 0.65;
    final double orbitRadius = widget.size * 0.70;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(235), // equivalent to withOpacity(0.92)
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20), // equivalent to withOpacity(0.08)
              blurRadius: 24.0,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white.withAlpha(153), // equivalent to withOpacity(0.6)
            width: 1.5,
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double value = _controller.value;
            final double rotationAngle = value * 2 * math.pi;

            // Pulse scale for the central badge
            final double pulseScale = 1.0 + 0.06 * math.sin(value * 2 * math.pi * 2);

            return SizedBox(
              width: widget.size * 1.5,
              height: widget.size * 1.5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // --- Steaming Particles ---
                  ...List.generate(3, (index) {
                    final double t = (value + index / 3.0) % 1.0;
                    final double dy = -centerCircleSize / 2 - (t * 24);
                    final double dx = math.sin(t * 2 * math.pi * 1.5) * 6;
                    final double opacity = math.sin(t * math.pi); // Fades in then fades out

                    return Positioned(
                      top: (widget.size * 1.5) / 2 + dy,
                      left: (widget.size * 1.5) / 2 + dx - 2,
                      child: Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xCCFF5216), // 0xCC represents alpha 204 (0.8 opacity) of Color(0xFFFF5216)
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),

                  // --- Central Cooking Pot Badge ---
                  Transform.scale(
                    scale: pulseScale,
                    child: Container(
                      width: centerCircleSize,
                      height: centerCircleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFA07A), // Light Salmon
                            Color(0xFFFF5216), // Saimpex Brand Primary
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF5216).withAlpha(76), // equivalent to withOpacity(0.3)
                            blurRadius: 10.0,
                            spreadRadius: 1.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.soup_kitchen, // Hot steaming cooking pot
                          color: Colors.white,
                          size: widget.size * 0.35,
                        ),
                      ),
                    ),
                  ),

                  // --- Orbiting Food Elements ---
                  ...List.generate(4, (index) {
                    final double iconAngle = rotationAngle + (index * math.pi / 2);
                    final double x = math.cos(iconAngle) * orbitRadius;
                    final double y = math.sin(iconAngle) * orbitRadius;

                    IconData foodIcon;
                    switch (index) {
                      case 0:
                        foodIcon = Icons.local_pizza; // Pizza slice
                        break;
                      case 1:
                        foodIcon = Icons.lunch_dining; // Burger
                        break;
                      case 2:
                        foodIcon = Icons.ramen_dining; // Hot soup/ramen bowl
                        break;
                      case 3:
                      default:
                        foodIcon = Icons.icecream; // Dessert/Ice cream
                        break;
                    }

                    // Spin the orbiting icon itself to keep it dynamic and upright
                    final double iconSelfRotation = -rotationAngle * 1.5;

                    return Transform.translate(
                      offset: Offset(x, y),
                      child: Transform.rotate(
                        angle: iconSelfRotation,
                        child: Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20), // equivalent to withOpacity(0.08)
                                blurRadius: 4.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFFFF5216).withAlpha(38), // equivalent to withOpacity(0.15)
                              width: 1.0,
                            ),
                          ),
                          child: Icon(
                            foodIcon,
                            color: const Color(0xFFFF5216),
                            size: widget.size * 0.20,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
