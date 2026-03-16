import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/api/api_config.dart';

class GlobalStatsGrid extends StatefulWidget {
  const GlobalStatsGrid({super.key});

  @override
  State<GlobalStatsGrid> createState() => _GlobalStatsGridState();
}

class _GlobalStatsGridState extends State<GlobalStatsGrid> {
  Future<Map<String, dynamic>>? _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = _fetchGlobalStats();
    });
  }

  // 🧠 ยิง API ไปดึง "สถิติรวมของทุกคน" จาก Backend โดยตรง
  Future<Map<String, dynamic>> _fetchGlobalStats() async {
    try {
      // ⚠️ ต้องมี Endpoint นี้ที่ฝั่ง Backend (Node.js) ของคุณนะครับ
      final url = Uri.parse('${ApiConfig.baseUrl}/api/stats');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return {
          'total': data['total'] ?? 0,
          'positive': data['positive'] ?? 0,
          'topModel': data['topModel']?.toString().toUpperCase() ?? 'YOLOv8',
        };
      } else {
        print("⚠️ API ตอบกลับมาเป็น ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Fetch Global Stats Error: $e");
    }
    
    // ถ้าพัง ให้โชว์เลข 0 ไปก่อน
    return {'total': 0, 'positive': 0, 'topModel': 'N/A'};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        int total = 0;
        int positive = 0;
        String topModel = '...';
        bool isLoading = snapshot.connectionState == ConnectionState.waiting;

        if (snapshot.hasData && !isLoading) {
          total = snapshot.data!['total'] ?? 0;
          positive = snapshot.data!['positive'] ?? 0;
          topModel = snapshot.data!['topModel'] ?? 'N/A';
        }

        final double percent = total > 0 ? (positive / total) * 100 : 0;

        return Column(
          children: [
            // --- ส่วนที่ 1: กล่องกราฟ Donut ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20), 
                border: Border.all(color: Colors.black.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'GLOBAL DETECTION OVERVIEW', // ✅ เปลี่ยนชื่อให้ชัดเจนว่าเป็นของทุกคน
                        style: TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.w800, 
                          letterSpacing: 2.0, 
                          color: Colors.black45,
                        ),
                      ),
                      if (!isLoading)
                        GestureDetector(
                          onTap: _loadStats,
                          child: const Icon(Icons.refresh_rounded, size: 14, color: Colors.black26),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            height: 130,
                            child: isLoading 
                              ? const Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black12),
                                )
                              : CustomPaint(
                                  painter: DonutChartPainter(
                                    total: total,
                                    positive: positive,
                                  ),
                                ),
                          ),
                          if (!isLoading)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${percent.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Text(
                                  'POSITIVE',
                                  style: TextStyle(
                                    fontSize: 9, 
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black26,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatItem('TOTAL ANALYZED', isLoading ? '-' : total.toString(), Colors.black12),
                          const SizedBox(height: 20),
                          _buildStatItem('DETECTED CASES', isLoading ? '-' : positive.toString(), const Color(0xFFFF3B30)), 
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // --- ส่วนที่ 2: Top Model ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20), 
                border: Border.all(color: Colors.black.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_outlined, size: 20, color: Colors.black38),
                  const SizedBox(width: 16),
                  const Text(
                    'MOST USED MODEL',
                    style: TextStyle(
                      fontSize: 11, 
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  isLoading 
                    ? const SizedBox(
                        width: 12, height: 12, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black26)
                      )
                    : Text(
                        topModel,
                        style: const TextStyle(
                          fontSize: 13, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 0.5,
                          color: Colors.black87,
                        ),
                      ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 3, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(
              label, 
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black38),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value, 
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Colors.black87, letterSpacing: -0.5),
        ),
      ],
    );
  }
}

// --------------------------------------------------------
// Painter กราฟ (เหมือนเดิม 100%)
// --------------------------------------------------------
class DonutChartPainter extends CustomPainter {
  final int total;
  final int positive;
  DonutChartPainter({required this.total, required this.positive});

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    canvas.drawCircle(center, radius, Paint()
      ..color = const Color(0xFFF2F2F7) 
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth);

    if (total <= 0) return;

    double sweepAngle = (positive / total) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      Paint()
        ..color = const Color(0xFFFF3B30) 
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) => true;
}