import 'package:flutter/material.dart';
import '../../../core/utils/mock_data.dart';

class UserHistoryList extends StatelessWidget {
  const UserHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final history = MockData.userHistory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Detection History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...history.map(
          (item) => Card(
            child: ListTile(
              leading: const Icon(Icons.image),
              title: Text(item['patient'].toString()),
              subtitle: Text(
                  'Model: ${item['model']} | ${item['date']}'),
            ),
          ),
        )
      ],
    );
  }
}
