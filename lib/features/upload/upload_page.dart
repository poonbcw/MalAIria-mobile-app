import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ นำเข้า Riverpod

import '../../core/storage/auth_storage.dart';
// ✅ นำเข้าคิวที่เราเพิ่งสร้าง (แก้ path ให้ตรงกับที่คุณเก็บไฟล์ไว้นะครับ)
import '../../core/providers/analysis_queue_provider.dart'; 

// ✅ เปลี่ยนจาก StatefulWidget เป็น ConsumerStatefulWidget เพื่อใช้ Riverpod
class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key});

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  File? _image;
  final TextEditingController _hnController = TextEditingController();

  // ---------------- Image Picker ----------------
  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  // ---------------- Submit (แบบโยนเข้าคิว) ----------------
  void _submit() {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // ==========================================
    // 🚀 โยนงานเข้า Queue เบื้องหลังทันที! (ไม่ต้องรอ)
    // ==========================================
    final hn = _hnController.text.trim().isEmpty ? null : _hnController.text.trim();
    
    // เรียกใช้ addTask จาก Provider
    ref.read(analysisQueueProvider.notifier).addTask(_image!, hn);

    // 🟢 แสดงข้อความสำเร็จว่ารับงานแล้ว
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Added to analysis queue!'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    // 🧹 ล้างหน้าจอเพื่อเตรียมรับรูปต่อไปทันที
    setState(() {
      _image = null;
      _hnController.clear();
    });
    
    // เด้งกลับไปหน้า Dashboard อัตโนมัติ เพื่อให้ผู้ใช้ไปรอดูสถานะคิว
    Navigator.pop(context); 
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthStorage.isLoggedIn();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 27, 50), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'NEW ANALYSIS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('TARGET IMAGE'),
            const SizedBox(height: 12),
            _buildImagePicker(),

            if (isLoggedIn) ...[
              const SizedBox(height: 32),
              _sectionTitle('PATIENT IDENTIFICATION'),
              const SizedBox(height: 12),
              _buildHNInputField(),
            ],

            const SizedBox(height: 48),
            _buildSubmitButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ---------------- Widgets ----------------
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickFromGallery, 
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: _image != null ? Colors.white : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_image!, fit: BoxFit.cover),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_outlined, 
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined, 
                    color: Colors.white.withOpacity(0.5),
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHNInputField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _hnController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'HN Number (optional)',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Icon(
            Icons.badge_outlined,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _submit, // ✅ ไม่ต้องเช็คตัวแปร _loading แล้ว เพราะกดปุ๊บเสร็จปั๊บ!
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: const Text(
          'SUBMIT',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white.withOpacity(0.4),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hnController.dispose();
    super.dispose();
  }
}