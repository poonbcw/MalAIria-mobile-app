import 'package:flutter/material.dart';
import '../../../core/utils/mock_data.dart';

class GlobalStatsGrid extends StatelessWidget {
  const GlobalStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = MockData.globalStats;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Detections',
                value: stats['total'].toString(),
                icon: Icons.analytics_outlined,
                color: const Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Malaria Detected',
                value: stats['positive'].toString(),
                icon: Icons.coronavirus_outlined,
                color: const Color(0xFF2C2C2C),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _StatCard(
          title: 'Top Model Used',
          value: stats['topModel'].toString(),
          icon: Icons.memory_outlined,
          color: const Color(0xFF2C2C2C),
          fullWidth: true,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[500],
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF0A0A0A),
                      letterSpacing: 0.5,
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