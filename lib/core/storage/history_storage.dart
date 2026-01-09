import 'package:flutter/foundation.dart';
import '../models/history_item.dart';

class HistoryStorage {
  static final ValueNotifier<List<HistoryItem>> itemsNotifier = ValueNotifier<List<HistoryItem>>([]);

  static List<HistoryItem> get items => itemsNotifier.value;

  static void add(HistoryItem item) {
    // เพิ่ม item ใหม่ไว้บนสุด และกระจาย List ใหม่เพื่อแจ้งเตือน UI
    itemsNotifier.value = [item, ...itemsNotifier.value];
  }

  // 🔥 เพิ่มฟังก์ชันสำหรับล้างประวัติ (เช่น ตอน User Logout)
  static void clear() {
    itemsNotifier.value = [];
  }
}
