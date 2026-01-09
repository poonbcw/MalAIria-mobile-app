import 'package:flutter/material.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/storage/history_storage.dart';
import '../../../core/models/history_item.dart';
import '../../../routes/app_routes.dart'; // ตรวจสอบ Path ของ AppRoutes ด้วยนะครับ

class UserHistoryList extends StatelessWidget {
  const UserHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthStorage.isLoggedIn();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 16),

        if (!isLoggedIn)
          _buildPlaceholder(
            icon: Icons.lock_person_outlined,
            title: 'Authentication Required',
            subtitle: 'Sign in to sync and view your clinical history.',
          )
        else
          ValueListenableBuilder<List<HistoryItem>>(
            valueListenable: HistoryStorage.itemsNotifier,
            builder: (context, items, child) {
              if (items.isEmpty) {
                return _buildPlaceholder(
                  icon: Icons.biotech_outlined,
                  title: 'No Records Found',
                  subtitle: 'Start your first analysis to see results here.',
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _buildHistoryTile(context, items[index]), // ✅ ส่ง context เข้าไป
              );
            },
          ),
      ],
    );
  }

  // --- Header สไตล์ Minimal ---
  Widget _buildSectionHeader() {
    return Row(
      children: [
        const Text(
          'HISTORY',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(height: 1, color: Colors.black.withOpacity(0.05)),
        ),
      ],
    );
  }

  // --- Placeholder สำหรับ Not Login และ Empty State ---
  Widget _buildPlaceholder({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.black12),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withOpacity(0.4),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // --- รายการประวัติสไตล์ Technical (เพิ่ม Click Action) ---
  Widget _buildHistoryTile(BuildContext context, HistoryItem item) { // ✅ เพิ่ม context
    final bool isPositive = item.result.toUpperCase() == 'POSITIVE';
    final Color statusColor = isPositive ? const Color(0xFFFF3B30) : const Color(0xFF34C759);

    return InkWell( // ✅ บรรทัดที่เพิ่ม: หุ้มเพื่อให้กดได้
      onTap: () {
        // ✅ บรรทัดที่เพิ่ม: ส่งกลับหน้า Result พร้อมแนบข้อมูลเดิมไป
        Navigator.pushNamed(
          context,
          AppRoutes.result,
          arguments: {
            'image': item.imagePath, // ต้องมี File image ใน HistoryItem ตามที่คุยกันก่อนหน้า
            'model': item.model,
            'hn': item.patientId,
            'positive': isPositive,
            'fromHistory': true, // บอกหน้า Result ว่าดูประวัติย้อนหลังนะ
          },
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
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
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.model.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.patientId != null ? 'HN: ${item.patientId}' : 'General Patient',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.result.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.date.day}/${item.date.month}/${item.date.year}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.black.withOpacity(0.1)), // เพิ่มไอคอนลูกศรให้รู้ว่ากดได้
          ],
        ),
      ),
    );
  }
}