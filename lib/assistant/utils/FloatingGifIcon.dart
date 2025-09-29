import 'dart:math' as math;

import 'package:flutter/material.dart';

class FloatingGifIcon extends StatefulWidget {
  final double size; // base size of the visible shape (px)
  final double
  cornerRadiusFraction; // fraction of `size` to use as corner radius

  const FloatingGifIcon({
    Key? key,
    this.size = 60,
    this.cornerRadiusFraction = 0.5, // tweak this to match image precisely
  }) : super(key: key);

  @override
  State<FloatingGifIcon> createState() => _FloatingGifIconState();
}

class _FloatingGifIconState extends State<FloatingGifIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The outer box is fixed so scaling ripples won't change the view size.
    final double baseSize = widget.size;
    final double outerBox =
        baseSize * 3.0; // must be large enough for ripple expansion
    final double cornerRadiusPx = widget.cornerRadiusFraction * baseSize;

    return SizedBox(
      width: outerBox,
      height: outerBox,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // layered ripples (scale & fade but do NOT change outer box size)
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // phase shift so ripples are generated continuously
                final progress = (_controller.value + index * 0.33) % 1.0;
                final scale = 1.0 + (progress * 1.0); // adjust expansion amount
                final opacity = (1.0 - progress).clamp(0.0, 1.0);

                // base ripple box equals baseSize so clipper scales around same shape
                final rippleChild = ClipPath(
                  clipper: OppositeCornerRoundClipper(cornerRadiusPx),
                  child: SizedBox(
                    width: baseSize,
                    height: baseSize,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.9),
                      ),
                    ),
                  ),
                );

                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.center,
                    child: rippleChild,
                  ),
                );
              },
            );
          }),

          // The static shaped container with GIF inside (won't move)
          ClipPath(
            clipper: OppositeCornerRoundClipper(cornerRadiusPx),
            child: Container(
              width: baseSize,
              height: baseSize,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Container(
                height: 20,
                width: 20,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/ic_launcher.png',),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OppositeCornerRoundClipper extends CustomClipper<Path> {
  final double r;

  OppositeCornerRoundClipper(this.r);

  @override
  Path getClip(Size size) {
    final double radius = math.min(r, math.min(size.width, size.height) / 2);
    final path = Path();

    // Start at top-left
    path.moveTo(0, 0);

    // Top edge -> to before top-right rounded corner
    path.lineTo(size.width - radius, 0);

    // Top-right quarter arc to (size.width, radius)
    path.arcToPoint(
      Offset(size.width, radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    // Right edge down to bottom-right (sharp)
    path.lineTo(size.width, size.height);

    // Bottom edge left to before bottom-left rounded corner
    path.lineTo(radius, size.height);

    // Bottom-left quarter arc to (0, size.height - radius)
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    // Left edge up to top-left
    path.lineTo(0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant OppositeCornerRoundClipper oldClipper) =>
      oldClipper.r != r;
}
