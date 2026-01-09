import 'package:flutter/material.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/storage/history_storage.dart';
import '../../../core/models/history_item.dart';

class UserHistoryList extends StatelessWidget {
  const UserHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    // Logic คงเดิมตามที่คุณให้มา
    final bool isLoggedIn = AuthStorage.isLoggedIn();
    final List<HistoryItem> items = HistoryStorage.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        
        if (!isLoggedIn)
          _buildPlaceholder(
            icon: Icons.lock_person_outlined,
            title: 'Authentication Required',
            subtitle: 'Sign in to sync and view your clinical history.',
          )
        else if (items.isEmpty)
          _buildPlaceholder(
            icon: Icons.biotech_outlined,
            title: 'No Records Found',
            subtitle: 'Start your first analysis to see results here.',
          )
        else
          // รายการประวัติ
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildHistoryTile(items[index]),
          ),
      ],
    );
  }

  // --- Header สไตล์ Minimal ---
  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'HISTORY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.5,
            color: Colors.black54,
          ),
        ),
        const Spacer(),
        Container(
          width: 40,
          height: 2,
          color: Colors.black12,
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

  // --- รายการประวัติสไตล์ Technical ---
  Widget _buildHistoryTile(HistoryItem item) {
    final bool isPositive = item.result.toUpperCase() == 'POSITIVE';
    
    // บรรทัดที่แก้: กำหนดสีหลักของสถานะ (แดงสำหรับ Pos / เขียวสำหรับ Neg)
    final Color statusColor = isPositive ? const Color(0xFFFF3B30) : const Color(0xFF34C759);

    return Container(
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
          // บรรทัดที่แก้: เปลี่ยนสี Indicator ตามสถานะ
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.5), // ใส่ความโปร่งใสเล็กน้อยเพื่อให้ดู Clean
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
                // บรรทัดที่แก้: แสดงผล Patient ID (HN) ต่อจากชื่อ หรือแสดง HN ตรงๆ
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
        ],
      ),
    );
  }
}