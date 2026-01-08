class MockData {
  /// 🌍 GLOBAL STATISTICS (ใช้กับ Dashboard cards / overview)
  static final globalStats = {
    'total': 1240,            // จำนวนตรวจทั้งหมด
    'positive': 312,          // พบเชื้อมาลาเรีย
    'negative': 928,          // ไม่พบเชื้อ
    'accuracy': 96.4,         // ความแม่นยำของระบบ (%)
    'topModel': 'YOLOv8',     // โมเดลที่ใช้บ่อยสุด
    'lastUpdated': '2025-03-15',
  };

  /// 👤 USER DETECTION HISTORY
  static final userHistory = [
    {
      'patient': 'Patient A',
      'model': 'YOLOv8',
      'date': '2025-03-12',
      'result': 'Positive',
      'image': 'blood_smear_01.jpg',
    },
    {
      'patient': 'Patient B',
      'model': 'CNN-v2',
      'date': '2025-03-10',
      'result': 'Negative',
      'image': 'blood_smear_02.jpg',
    },
    {
      'patient': 'Patient C',
      'model': 'YOLOv8',
      'date': '2025-03-08',
      'result': 'Positive',
      'image': 'blood_smear_03.jpg',
    },
  ];
}
