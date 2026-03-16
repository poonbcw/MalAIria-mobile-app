import 'dart:io';
import 'dart:math';
import 'dart:typed_data'; // ✅ สำหรับจัดการข้อมูล Bytes
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';

class BoundingBox {
  final double x1, y1, x2, y2, cx, cy, w, h, maxConf;
  final int maxIdx;
  final String clsName;

  BoundingBox({
    required this.x1, required this.y1, required this.x2, required this.y2,
    required this.cx, required this.cy, required this.w, required this.h,
    required this.maxConf, required this.maxIdx, required this.clsName,
  });
}

class MLService {
  Interpreter? _interpreter;
  
  final List<String> labels = ["normal", "abnormal"];
  final double confidenceThreshold = 0.10; 
  final double iouThreshold = 0.20;        
  final int windowSize = 640;
  final int stride = 320;

  // ✅ โหลดโมเดลจากก้อนข้อมูล (Bytes) ที่ส่งเข้ามา
  // วิธีนี้ปลอดภัย 100% สำหรับการใช้ใน Isolate ทุกรุ่น
  Future<void> initModelFromBuffer(Uint8List modelBuffer) async {
    try {
      var options = InterpreterOptions();
      _interpreter = Interpreter.fromBuffer(
        modelBuffer,
        options: options,
      );
      debugPrint('✅ TFLite Model Loaded From Buffer Successfully');
    } catch (e) {
      debugPrint('❌ Model Load from Buffer Failed: $e');
    }
  }

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    if (_interpreter == null) throw Exception('Model not ready');

    final bytes = await imageFile.readAsBytes();
    img.Image? oriImage = img.decodeImage(bytes);
    if (oriImage == null) throw Exception('Cannot decode image');

    int imgWidth = oriImage.width;
    int imgHeight = oriImage.height;
    List<BoundingBox> allGlobalBoxes = [];

    if (imgWidth <= windowSize && imgHeight <= windowSize) {
       img.Image resized = img.copyResize(oriImage, width: windowSize, height: windowSize);
       allGlobalBoxes.addAll(_runInferenceAndMap(resized, 0, 0, imgWidth, imgHeight));
    } 
    else {
      for (int y = 0; y < imgHeight; y += stride) {
        int cropY = y;
        if (cropY + windowSize > imgHeight) cropY = max(0, imgHeight - windowSize);
        
        for (int x = 0; x < imgWidth; x += stride) {
          int cropX = x;
          if (cropX + windowSize > imgWidth) cropX = max(0, imgWidth - windowSize);

          img.Image crop = img.copyCrop(oriImage, x: cropX, y: cropY, width: windowSize, height: windowSize);
          allGlobalBoxes.addAll(_runInferenceAndMap(crop, cropX, cropY, imgWidth, imgHeight));
        }
      }
    }

    List<BoundingBox> finalBestBoxes = _nms(allGlobalBoxes);

    bool isPositive = false;
    double maxConfidence = 0.0;
    List<List<double>> detectedBoxes = []; 

    for (var box in finalBestBoxes) {
      if (box.clsName == "abnormal") {
        isPositive = true; 
        if (box.maxConf > maxConfidence) maxConfidence = box.maxConf;
        detectedBoxes.add([box.cx, box.cy, box.w, box.h]);
      }
    }

    return {
      'isPositive': isPositive,
      'confidence': isPositive ? maxConfidence : 0.0,
      'boxes': detectedBoxes, 
    };
  }

  List<BoundingBox> _runInferenceAndMap(img.Image cropImage, int cropX, int cropY, int originalImgWidth, int originalImgHeight) {
    var input = List.generate(1, (i) =>
        List.generate(windowSize, (y) =>
            List.generate(windowSize, (x) {
              final pixel = cropImage.getPixel(x, y);
              return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
            })));

    var outputShape = _interpreter!.getOutputTensor(0).shape;
    var output = List.generate(outputShape[0], (_) =>
        List.generate(outputShape[1], (_) =>
            List.filled(outputShape[2], 0.0)));

    _interpreter!.run(input, output);
    return _mapCoordinates(output[0], cropX, cropY, originalImgWidth, originalImgHeight);
  }

  List<BoundingBox> _mapCoordinates(List<List<double>> boxData, int cropX, int cropY, int imgWidth, int imgHeight) {
    int numDetect = boxData[0].length; 
    List<BoundingBox> mappedBoxes = [];

    for (int i = 0; i < numDetect; i++) {
      double maxConf = -1.0;
      int maxIdx = -1;

      for (int j = 4; j < boxData.length; j++) {
        if (boxData[j][i] > maxConf) {
          maxConf = boxData[j][i];
          maxIdx = j - 4;
        }
      }

      if (maxConf > confidenceThreshold) {
        String clsName = labels[maxIdx];

        double lx = boxData[0][i] > 1.5 ? boxData[0][i] : boxData[0][i] * windowSize;
        double ly = boxData[1][i] > 1.5 ? boxData[1][i] : boxData[1][i] * windowSize;
        double lw = boxData[2][i] > 1.5 ? boxData[2][i] : boxData[2][i] * windowSize;
        double lh = boxData[3][i] > 1.5 ? boxData[3][i] : boxData[3][i] * windowSize;

        double gCx = (cropX + lx) / imgWidth;
        double gCy = (cropY + ly) / imgHeight;
        double gW = lw / imgWidth;
        double gH = lh / imgHeight;

        mappedBoxes.add(BoundingBox(
          x1: gCx - (gW / 2), y1: gCy - (gH / 2),
          x2: gCx + (gW / 2), y2: gCy + (gH / 2),
          cx: gCx, cy: gCy, w: gW, h: gH,
          maxConf: maxConf, maxIdx: maxIdx, clsName: clsName,
        ));
      }
    }
    return mappedBoxes;
  }

  List<BoundingBox> _nms(List<BoundingBox> boxes) {
    if (boxes.isEmpty) return [];
    
    boxes.sort((a, b) => b.maxConf.compareTo(a.maxConf)); 
    List<BoundingBox> selected = [];

    while (boxes.isNotEmpty) {
      var current = boxes.removeAt(0);
      selected.add(current);

      boxes.removeWhere((next) {
        if (current.clsName != next.clsName) return false;
        return _calculateIoU(current, next) >= iouThreshold;
      });
    }
    return selected;
  }

  double _calculateIoU(BoundingBox b1, BoundingBox b2) {
    double interX = max(b1.x1, b2.x1);
    double interY = max(b1.y1, b2.y1);
    double interW = max(0, min(b1.x2, b2.x2) - interX);
    double interH = max(0, min(b1.y2, b2.y2) - interY);
    double interArea = interW * interH;
    return interArea / (b1.w * b1.h + b2.w * b2.h - interArea);
  }
}