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
        // MINIMAL HEADER
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Your History',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // MAIN CONTAINER
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE8E8E8),
              width: 1,
            ),
          ),
          child: Column(
            children: List.generate(history.length, (index) {
              final item = history[index];
              final bool positive = item['result'] == 'Positive';

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        // MINIMAL RESULT ICON
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: positive
                                ? const Color(0xFFFFF5F5)
                                : const Color(0xFFF0F9F4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            positive
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline_rounded,
                            color: positive
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF059669),
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // PATIENT INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['patient'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Color(0xFF0A0A0A),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.science_outlined,
                                    size: 13,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    item['model'].toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[500],
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 13,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    item['date'].toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[500],
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // MINIMAL RESULT INDICATOR
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: positive
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF059669),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item['result'].toString(),
                              style: TextStyle(
                                color: positive
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF059669),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // SUBTLE DIVIDER
                  if (index != history.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Container(
                        height: 1,
                        color: const Color(0xFFF5F5F5),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}