import 'package:flutter/material.dart';

class CurvedHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool compact;

  const CurvedHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.compact = false,
  });

  // ---- Color helpers --------------------------------------------------------
  Color _lighten(Color c, double amount, {double sat = 0}) {
    final h = HSLColor.fromColor(c);
    return h
        .withLightness((h.lightness + amount).clamp(0.0, 1.0))
        .withSaturation((h.saturation + sat).clamp(0.0, 1.0))
        .toColor();
  }

  Color _darken(Color c, double amount, {double sat = 0}) {
    final h = HSLColor.fromColor(c);
    return h
        .withLightness((h.lightness - amount).clamp(0.0, 1.0))
        .withSaturation((h.saturation + sat).clamp(0.0, 1.0))
        .toColor();
  }

  Color _withBlackScrim(Color c, double opacity) =>
      Color.alphaBlend(Colors.black.withOpacity(opacity), c);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = compact ? 180.0 : 260.0;

    final Color brand = scheme.primary;

    // ── LIGHTER, SOFTER HEADER TONES ─────────────────────────────────────────
    // Light mode: a bit brighter than primary.
    // Dark mode: only slightly darker than primary + a very soft scrim.
    final Color baseForHeader = isDark
        ? _withBlackScrim(
            _lighten(brand, 0.04, sat: -0.02), // mild lift from the base
            0.05,                              // softer scrim than before
          )
        : _lighten(brand, 0.10, sat: 0.05);

    // Gradient stops
    final Color g1 = isDark
        ? _lighten(baseForHeader, 0.03) // lighter top-left
        : _lighten(baseForHeader, 0.06);
    final Color g2 = isDark
        ? _darken(baseForHeader, 0.06)  // slightly darker bottom-right
        : _darken(baseForHeader, 0.03);

    // Text/icon colors per mode.
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black54;

    // Bubbles tint (a bit stronger so they read on lighter header)
    final Color bubbleColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.12);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Background gradient
          Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [g1, g2],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(48),
              ),
            ),
          ),

          // Softer scrim than before, just to add depth.
          if (isDark)
            Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.05), // was 0.10
                    Colors.transparent,
                  ],
                ),
              ),
            ),

          // Soft bubbles
          Positioned.fill(
            child: CustomPaint(
              painter: _BubblesPainter(bubbleColor),
            ),
          ),

          // Content row
          Positioned(
            left: 20,
            right: 20,
            bottom: compact ? 20 : 28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: bubbleColor,
                  child: Icon(icon, color: textColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BubblesPainter extends CustomPainter {
  final Color color;
  const _BubblesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final circles = [
      Offset(size.width * .20, size.height * .25),
      Offset(size.width * .75, size.height * .18),
      Offset(size.width * .60, size.height * .45),
    ];
    for (var i = 0; i < circles.length; i++) {
      canvas.drawCircle(circles[i], 36 - i * 8, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
