class HistoryItem {
  final String patientId;
  final String model;
  final String result;
  final String imagePath;
  final DateTime date;
  final List<dynamic>? boxes; 

  HistoryItem({
    required this.patientId,
    required this.model,
    required this.result,
    required this.imagePath,
    required this.date,
    this.boxes, 
  });
}
