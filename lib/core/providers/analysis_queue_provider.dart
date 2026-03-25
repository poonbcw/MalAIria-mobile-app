import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; 
import '../../core/api/api_config.dart';
import '../../core/services/ml_service.dart';
// 🟢 Import เพิ่มสำหรับทำ Local DB และดักจับ Internet
import '../../core/services/local_db_service.dart'; 
import 'package:connectivity_plus/connectivity_plus.dart';
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

  // 🟢 เพิ่มฟังก์ชันแปลง Object เป็น Map เพื่อเซฟลง SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': image.path, 
      'hn': hn ?? '',
      'status': status.index,  
      'isPositive': isPositive == true ? 1 : 0, 
      'confidence': confidence ?? 0.0,
      'boxes': boxes != null ? jsonEncode(boxes) : '[]', 
      'errorMessage': errorMessage ?? '',
    };
  }

  // 🟢 เพิ่มฟังก์ชันแปลง Map จาก SQLite กลับมาเป็น Object
  factory AnalysisTask.fromMap(Map<String, dynamic> map) {
    return AnalysisTask(
      id: map['id'],
      image: File(map['imagePath']),
      hn: map['hn'] == '' ? null : map['hn'],
      status: TaskStatus.values[map['status']],
      isPositive: map['isPositive'] == 1,
      confidence: map['confidence'],
      boxes: jsonDecode(map['boxes']),
      errorMessage: map['errorMessage'] == '' ? null : map['errorMessage'],
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
  AnalysisQueueNotifier() : super([]) {
    _loadInitialTasks();    
    _initNetworkListener(); 
  }

  bool _isProcessingQueue = false;

  // 🟢 1. แก้ไข: เช็คสถานะ Guest ให้ครอบคลุมทั้ง null และแบบ Anonymous!
  bool get _isGuest {
    final user = FirebaseAuth.instance.currentUser;
    return user == null || user.isAnonymous; // 👈 ดักผู้ใช้ชั่วคราวไว้ตรงนี้
  }

  Future<void> _loadInitialTasks() async {
    if (_isGuest) return; 

    try {
      final tasksFromDB = await LocalDBService.getAllTasks();
      final restoredTasks = tasksFromDB.map((t) {
        if (t.status == TaskStatus.processing) {
          return t.copyWith(status: TaskStatus.pending);
        }
        return t;
      }).toList();

      state = restoredTasks; 
      if (state.any((t) => t.status == TaskStatus.pending)) {
        _processNextTask();
      }
    } catch (e) {
      debugPrint('⚠️ Error loading initial tasks: $e');
    }
  }

  void addTask(File image, String? hn) async { 
    final newTask = AnalysisTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      image: image,
      hn: hn,
    );

    if (!_isGuest) {
      await LocalDBService.insertTask(newTask);
    }

    state = [...state, newTask]; 
    _processNextTask();
  }

  void _initNetworkListener() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        if (!_isGuest) { 
          debugPrint('🌐 Internet is back! Starting Auto-Sync...');
          _syncAllPendingTasks(); 
        }
      }
    });
  }

  Future<void> _syncAllPendingTasks() async {
    if (_isGuest) return; 

    try {
      final unsyncedTasks = await LocalDBService.getUnsyncedTasks();
      for (var task in unsyncedTasks) {
        await _attemptSync(task, task.isPositive ?? false, task.confidence ?? 0.0, 'YOLOv8');
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching unsynced tasks: $e');
    }
  }

  Future<void> _processNextTask() async {
    if (_isProcessingQueue) return;
    
    final pendingTaskIndex = state.indexWhere((task) => task.status == TaskStatus.pending);
    if (pendingTaskIndex == -1) return; 

    _isProcessingQueue = true; 
    final targetTask = state[pendingTaskIndex];

    try {
      final processingTask = targetTask.copyWith(status: TaskStatus.processing);
      _updateTask(targetTask.id, processingTask);
      
      if (!_isGuest) {
        await LocalDBService.insertTask(processingTask);
      }

      final ByteData byteData = await rootBundle.load('assets/models/best_fold4.tflite');
      final Uint8List modelBytes = byteData.buffer.asUint8List();

      final result = await compute(_runInferenceInIsolate, {
        'path': targetTask.image.path,
        'modelData': modelBytes, 
      });
      
      final taskStillExists = state.any((t) => t.id == targetTask.id);
      if (!taskStillExists) return;

      final bool isPositive = result['isPositive'];
      final double confidence = result['confidence'];
      final List<dynamic> boxes = result['boxes'];
      final String fixedModelName = 'YOLOv8';

      final completedTask = targetTask.copyWith(
        status: TaskStatus.completed,
        isPositive: isPositive,
        confidence: confidence,
        boxes: boxes,
      );

      _updateTask(targetTask.id, completedTask);

      if (_isGuest) {
        debugPrint('👤 Guest Mode: Result shown on screen. No DB save. No Cloud sync.');
      } else {
        await LocalDBService.insertTask(completedTask);
        await _attemptSync(completedTask, isPositive, confidence, fixedModelName);
      }

    } catch (e) {
      if (state.any((t) => t.id == targetTask.id)) {
        _updateTask(targetTask.id, targetTask.copyWith(
          status: TaskStatus.error,
          errorMessage: e.toString(),
        ));
      }
    } finally {
      _isProcessingQueue = false; 
      _processNextTask(); 
    }
  }

  Future<void> _attemptSync(AnalysisTask task, bool isPositive, double confidence, String modelName) async {
    // 🟢 2. เพิ่มเกราะป้องกันชั้นที่ 2: ถ้าเป็น Guest ให้เด้งออกทันที ห้ามส่ง API เด็ดขาด!
    if (_isGuest) return; 

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
      
      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        await LocalDBService.deleteTask(task.id);
        state = state.where((t) => t.id != task.id).toList();
        debugPrint('✅ Task ${task.id} synced to Cloud and removed from UI & Local DB!');
      } else {
        debugPrint('⚠️ Server returned ${response.statusCode}, keeping task ${task.id} in Local DB.');
      }

    } catch (e) {
      debugPrint('⚠️ Cloud sync failed. Keeping task ${task.id} in Local DB. Error: $e');
    }
  }

  void _updateTask(String id, AnalysisTask updatedTask) {
    state = state.map((task) => task.id == id ? updatedTask : task).toList();
  }

  void removeTask(String id) async { 
    try {
      final task = state.firstWhere((t) => t.id == id);
      
      if (!_isGuest && task.status != TaskStatus.completed) {
        await LocalDBService.deleteTask(id);
        debugPrint('🗑️ Cancelled task $id: Deleted from Local DB');
      }
    } catch (e) {
      debugPrint('⚠️ Task not found in state: $e');
    }

    state = state.where((task) => task.id != id).toList();
  }
}

final analysisQueueProvider = StateNotifierProvider<AnalysisQueueNotifier, List<AnalysisTask>>((ref) {
  return AnalysisQueueNotifier();
});