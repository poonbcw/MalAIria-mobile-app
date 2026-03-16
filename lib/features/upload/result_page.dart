import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/storage/auth_storage.dart';
import '../../core/api/api_config.dart';

class ResultPage extends StatefulWidget { 
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _showBoxes = true; 

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final dynamic imageRaw = args['image'];
    final String model = args['model'] ?? 'Unknown Model';
    final String? hn = args['hn'];
    final bool positive = args['positive'] as bool? ?? false;
    final double confidence = args['confidence'] as double? ?? 0.0;
    final List<dynamic> boxes = args['boxes'] ?? []; 
    final bool fromHistory = args['fromHistory'] ?? false; 

    // ✅ โค้ดชุดใหม่: แยกแยะประเภทของรูปภาพให้ฉลาดขึ้น
    bool isNetworkImage = false;
    String imageUrl = '';
    File? localImage;

    if (imageRaw is String) {
      if (imageRaw.startsWith('http')) {
        isNetworkImage = true;
        imageUrl = imageRaw;
      } else if (imageRaw.startsWith('/uploads/')) { 
        // ถ้าเป็นพาทที่มาจาก Database (เช่น /uploads/xxx.jpg) ให้ต่อกับ BaseUrl
        isNetworkImage = true;
        imageUrl = '${ApiConfig.baseUrl}$imageRaw';
      } else {
        // ถ้าเป็น String ที่ขึ้นต้นด้วย /data/... แสดงว่าเป็นไฟล์ในเครื่อง
        isNetworkImage = false;
        localImage = File(imageRaw);
      }
    } else if (imageRaw is File) {
      // ดักเผื่อกรณีที่มีการส่งตัวแปร File มาตรงๆ
      isNetworkImage = false;
      localImage = imageRaw;
    }

    final bool isLoggedIn = AuthStorage.isLoggedIn();

    final Color resultColor = positive
        ? const Color(0xFFFF3B30)
        : const Color.fromARGB(255, 57, 191, 84);
    final Color borderColor = positive
        ? resultColor.withOpacity(0.4)
        : Colors.white.withOpacity(0.1);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 27, 50),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ===============================================
            // 📸 IMAGE DISPLAY AREA
            // ===============================================
            Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 1.0,
                      maxScale: 5.0,
                      child: Stack(
                        children: [
                          isNetworkImage
                              ? Image.network(imageUrl, width: double.infinity, fit: BoxFit.fitWidth)
                              : Image.file(localImage!, width: double.infinity, fit: BoxFit.fitWidth),
                          
                          // ✅ จะวาดกรอบแดง ก็ต่อเมื่อเปิดโหมด _showBoxes และผลเป็น Positive 
                          if (_showBoxes && positive)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: BoxPainter(boxes: boxes),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // ✅ ซ่อนปุ่มถ้าผลเป็น Negative
                if (positive) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showBoxes = !_showBoxes; 
                          });
                        },
                        icon: Icon(
                          _showBoxes ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.white70,
                          size: 18,
                        ),
                        label: Text(
                          _showBoxes ? "HIDE BOXES" : "SHOW BOXES",
                          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.05),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: 32),

            // RESULT STATUS
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

            // META DATA
            Row(
              children: [
                if (isLoggedIn) ...[
                  _dataNode('HN', hn ?? 'N/A'),
                  const SizedBox(width: 12),
                ],
                _dataNode('MODEL', model),
              ],
            ),

            const SizedBox(height: 48),

            // BUTTON
            SizedBox(
              height: 62,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (fromHistory) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/dashboard', 
                      (route) => false, 
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  fromHistory ? 'CLOSE' : 'FINISH REPORT',
                  style: const TextStyle(
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

class BoxPainter extends CustomPainter {
  final List<dynamic> boxes;
  BoxPainter({required this.boxes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF3B30)
      ..style = PaintingStyle.stroke 
      ..strokeWidth = 2.5; 

    for (var box in boxes) {
      double centerX = box[0] * size.width;
      double centerY = box[1] * size.height;
      double width = box[2] * size.width;
      double height = box[3] * size.height;

      double left = centerX - (width / 2);
      double top = centerY - (height / 2);

      canvas.drawRect(
        Rect.fromLTWH(left, top, width, height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true; 
}