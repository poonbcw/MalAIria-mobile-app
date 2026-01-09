import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../routes/app_routes.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _image;
  String? _selectedModel;
  final TextEditingController _hnController = TextEditingController();
  bool _loading = false;

  final List<String> models = [
    'ResNet50',
    'VGG16',
    'InceptionV3',
    'MobileNetV2',
  ];

  // ---------------- Image Picker ----------------

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  // ---------------- Submit ----------------

  Future<void> _submit() async {
    // validate เฉพาะที่จำเป็น
    if (_image == null || _selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select image and model'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    // mock analyze
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _loading = false);

    if (!mounted) return;
    bool isPositive = DateTime.now().second % 2 == 0;

    // route ไป ResultPage
    Navigator.pushNamed(
      context,
      AppRoutes.result,
      arguments: {
        'image': _image,
        'model': _selectedModel,
        'hn': _hnController.text.isEmpty ? null : _hnController.text,
        'positive': isPositive,
      },
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'DETECTION SETUP',
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

            const SizedBox(height: 32),
            _sectionTitle('AI ANALYSIS MODEL'),
            const SizedBox(height: 12),
            _buildModelSelector(),

            const SizedBox(height: 32),
            _sectionTitle('PATIENT IDENTIFICATION'),
            const SizedBox(height: 12),
            _buildHNInputField(),

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
      onTap: () => _pick(ImageSource.gallery),
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
                    Container(color: Colors.black26),
                    const Center(
                      child: Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: Colors.white.withOpacity(0.5),
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Upload Blood Smear',
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

  Widget _buildModelSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: models.map((model) {
          final bool isSelected = _selectedModel == model;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              onTap: () => setState(() => _selectedModel = model),
              title: Text(
                model,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.black)
                  : Icon(
                      Icons.circle_outlined,
                      color: Colors.white.withOpacity(0.2),
                    ),
            ),
          );
        }).toList(),
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
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.white10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black,
                ),
              )
            : const Text(
                'START ANALYSIS',
                style: TextStyle(
                  fontSize: 16,
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
