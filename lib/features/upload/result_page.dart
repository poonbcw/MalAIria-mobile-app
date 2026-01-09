import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/storage/auth_storage.dart';
import '../../core/storage/history_storage.dart';
import '../../core/models/history_item.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final File image = args['image'];
    final String model = args['model'];
    final String? hn = args['hn'];

    /// mock ผลลัพธ์
    final bool positive = args['positive'] as bool? ?? false;

    final Color resultColor = positive ? const Color(0xFFFF3B30) : Colors.white;
    final Color borderColor = positive
        ? resultColor.withOpacity(0.4)
        : Colors.white.withOpacity(0.1);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox(),
        title: Text(
          'ANALYSIS SUMMARY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // IMAGE
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: borderColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(27),
                child: Image.file(image, fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 48),

            // RESULT
            Column(
              children: [
                Text(
                  'DIAGNOSTIC STATUS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.3),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  positive ? 'POSITIVE' : 'NEGATIVE',
                  style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: resultColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  positive
                      ? 'ABNORMAL PATTERN DETECTED'
                      : 'NO ABNORMALITY FOUND',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.4),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // META
            Row(
              children: [
                _dataNode('HN', hn ?? 'N/A'),
                const SizedBox(width: 12),
                _dataNode('MODEL', model),
              ],
            ),

            const Spacer(),

            // FINISH
            SizedBox(
              height: 62,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (AuthStorage.isLoggedIn()) {
                    HistoryStorage.add(
                      HistoryItem(
                        model: model,
                        result: positive ? 'Positive' : 'Negative',
                        date: DateTime.now(),
                        patientId: hn,
                      ),
                    );
                  }

                  Navigator.popUntil(context, (route) => route.isFirst);
                },

                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    return Colors.white; // ✅ บังคับทุก state
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    return Colors.black;
                  }),
                  elevation: WidgetStateProperty.all(0),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                child: const Text(
                  'FINISH REPORT',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _dataNode(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.3),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
