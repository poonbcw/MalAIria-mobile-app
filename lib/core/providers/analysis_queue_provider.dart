import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; 
import '../../core/api/api_config.dart';
import '../../core/services/ml_service.dart';
import 'package:firebase_auth/firebase_auth.dart';  
import 'dart:convert';

enum TaskStatus { pending, processing, completed, error }

class AnalysisTask {
  final String id;
  final File image;
  final String? hn;
  final TaskStatus status;
  final bool? isPositive;
  final double? confidence;
  final List<dynamic>? boxes;
  final String? errorMessage;

  AnalysisTask({
    required this.id,
    required this.image,
    this.hn,
    this.status = TaskStatus.pending,
    this.isPositive,
    this.confidence,
    this.boxes,
    this.errorMessage,
  });

  AnalysisTask copyWith({
    TaskStatus? status,
    bool? isPositive,
    double? confidence,
    List<dynamic>? boxes,
    String? errorMessage,
  }) {
    return AnalysisTask(
      id: id,
      image: image,
      hn: hn,
      status: status ?? this.status,
      isPositive: isPositive ?? this.isPositive,
      confidence: confidence ?? this.confidence,
      boxes: boxes ?? this.boxes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

Future<Map<String, dynamic>> _runInferenceInIsolate(Map<String, dynamic> data) async {
  final String path = data['path'];
  final Uint8List modelBuffer = data['modelData']; 

  final mlService = MLService();
  await mlService.initModelFromBuffer(modelBuffer); 
  
  return await mlService.analyzeImage(File(path));
}

class AnalysisQueueNotifier extends StateNotifier<List<AnalysisTask>> {
  AnalysisQueueNotifier() : super([]);

  bool _isProcessingQueue = false;

  void addTask(File image, String? hn) {
    final newTask = AnalysisTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      image: image,
      hn: hn,
    );
    state = [...state, newTask]; 
    _processNextTask();
  }

  Future<void> _processNextTask() async {
    if (_isProcessingQueue) return;
    
    final pendingTaskIndex = state.indexWhere((task) => task.status == TaskStatus.pending);
    if (pendingTaskIndex == -1) return; 

    _isProcessingQueue = true; 
    final targetTask = state[pendingTaskIndex];

    try {
      _updateTask(targetTask.id, targetTask.copyWith(status: TaskStatus.processing));

      final ByteData byteData = await rootBundle.load('assets/models/best_window_int8.tflite');
      final Uint8List modelBytes = byteData.buffer.asUint8List();

      // 🏃‍♂️ สั่ง AI รันใน Isolate
      final result = await compute(_runInferenceInIsolate, {
        'path': targetTask.image.path,
        'modelData': modelBytes, 
      });
      
      // 🛑 [เพิ่มโค้ดส่วนนี้] 🛑 
      // หลังจาก AI คิดเสร็จ ให้หันกลับมาเช็คว่าผู้ใช้กดยกเลิก (ลบ Task ออกจาก state) ไปหรือยัง?
      final taskStillExists = state.any((t) => t.id == targetTask.id);
      if (!taskStillExists) {
        debugPrint('🚫 Task ${targetTask.id} was cancelled by user. Discarding result.');
        return; // ออกจากฟังก์ชันไปเลย ไม่ต้องส่งขึ้น Cloud และไม่ต้องอัปเดต UI!
      }
      // =======================

      final bool isPositive = result['isPositive'];
      final double confidence = result['confidence'];
      final List<dynamic> boxes = result['boxes'];
      final String fixedModelName = 'YOLOv8 (Offline)';

      final completedTask = targetTask.copyWith(
        status: TaskStatus.completed,
        isPositive: isPositive,
        confidence: confidence,
        boxes: boxes,
      );

      // ถ้าไม่ถูกยกเลิก ก็ส่งขึ้น Cloud ตามปกติ
      await _syncToCloud(completedTask, isPositive, confidence, fixedModelName);

      _updateTask(targetTask.id, completedTask);

    } catch (e) {
      // ดัก error เผื่อไว้ แต่ถ้าถูกยกเลิกไปแล้วก็ไม่ต้องแสดง error ให้รกจอ
      if (state.any((t) => t.id == targetTask.id)) {
        _updateTask(targetTask.id, targetTask.copyWith(
          status: TaskStatus.error,
          errorMessage: e.toString(),
        ));
      }
    } finally {
      _isProcessingQueue = false; 
      _processNextTask(); // เรียกคิวต่อไปมารัน
    }
  }

  Future<void> _syncToCloud(AnalysisTask task, bool isPositive, double confidence, String modelName) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/upload');
      var request = http.MultipartRequest('POST', url);
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken(); 
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      if (task.hn != null && task.hn!.isNotEmpty) request.fields['hn'] = task.hn!;
      request.fields['model'] = modelName;
      request.fields['result'] = isPositive ? 'POSITIVE' : 'NEGATIVE';
      request.fields['confidence'] = confidence.toString();
      
      if (task.boxes != null && task.boxes!.isNotEmpty) {
        request.fields['boxes'] = jsonEncode(task.boxes);
      }

      request.files.add(await http.MultipartFile.fromPath('image', task.image.path));
      await request.send();
    } catch (e) {
      debugPrint('⚠️ Cloud sync failed: $e');
    }
  }

  void _updateTask(String id, AnalysisTask updatedTask) {
    state = state.map((task) => task.id == id ? updatedTask : task).toList();
  }

  void removeTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }
}

final analysisQueueProvider = StateNotifierProvider<AnalysisQueueNotifier, List<AnalysisTask>>((ref) {
  return AnalysisQueueNotifier();
});