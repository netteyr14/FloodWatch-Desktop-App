import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final double? current;
  final double? forecast;
  final IconData icon;
  final bool showTrend;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.current,
    this.forecast,
    this.showTrend = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ---------------------------
    // Trend Calculation
    // ---------------------------
    double? trend;
    if (current != null && forecast != null && current != 0) {
      trend = (forecast! - current!) / current!;
    }

    final bool up = (trend ?? 0) > 0;

    // 🔥 Danger if higher, Green if lower
    final Color chipColor = up
        ? const Color(0xFFEF4444)     // red
        : const Color(0xFF22C55E);    // green

    // ---------------------------
    // INNER CARD COLORS
    // Light Mode  → darker inner card
    // Dark Mode   → lighter inner card (but still dark)
    // ---------------------------
    final Color cardColor = isDark
        ? const Color(0xFF2B2B2B)      // lighter dark (inner)
        : const Color(0xFFE7E6D4);      // darker cream (inner)

    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      scheme.primary.withValues(alpha: isDark ? 0.25 : 0.20),
                  child: Icon(icon, color: scheme.primary),
                ),
                const Spacer(),
                if (showTrend && trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: chipColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          up ? Icons.north_east : Icons.south_east,
                          size: 16,
                          color: chipColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(trend.abs() * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: chipColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
              ],
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 
                        isDark ? 0.7 : 0.55),
                  ),
            ),

            const SizedBox(height: 4),

            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
