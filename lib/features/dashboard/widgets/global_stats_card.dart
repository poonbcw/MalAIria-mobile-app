import 'package:flutter/material.dart';
import '../../../core/utils/mock_data.dart';

class GlobalStatsCard extends StatelessWidget {
  const GlobalStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = MockData.globalStats;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Global Statistics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Total detections: ${stats['total']}'),
            Text('Malaria detected: ${stats['positive']}'),
            Text('Most used model: ${stats['topModel']}'),
          ],
        ),
      ),
    );
  }
}
