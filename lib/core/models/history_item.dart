class HistoryItem {
  final String model;
  final String result;
  final DateTime date;
  final String? patientId;
  final String imagePath;

  HistoryItem({
    required this.model,
    required this.result,
    required this.date,
    this.patientId,
    this.imagePath = '',
  });
}
