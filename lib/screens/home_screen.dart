import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data'; // web image bytes
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:image_picker/image_picker.dart';

import '../widgets/image_upload_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ super.key });

  @override
  State<HomeScreen> createState () => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _dressImage;
  File? _personImage;

  // Web/Chrome ke liye alag bytes store karni hongi.
  Uint8List? _dressImageBytes;
  Uint8List? _personImageBytes;

  bool get _canSubmit {
    if (kIsWeb) {
      return _dressImageBytes != null && _personImageBytes != null;
    }

    return _dressImage != null && _personImage != null;
  }

  // Single picker method — reused for both panels
  Future<void> _pickImage({ required bool isDress }) async {
    // Show bottom sheet to choose gallery or camera
    final source = await _showSourcePicker();
    if(source == null) return;

    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxHeight: 1024,
      );

      if(picked == null) return; // user cancelled picker

      if (kIsWeb) {
        // ✅ await setState se bahar
        final bytes = await picked.readAsBytes();

        setState(() {
          if (isDress) {
            _dressImageBytes = bytes;
            _dressImage = null;
          } else {
            _personImageBytes = bytes;
            _personImage = null;
          }
        });
      } else {
        setState(() {
          if (isDress) {
            _dressImage = File(picked.path);
            _dressImageBytes = null;
          } else {
            _personImage = File(picked.path);
            _personImageBytes = null;
          }
        });
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

    // Shows a bottom sheet — returns ImageSource or null
  Future<ImageSource?> _showSourcePicker() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,   // sheet hugs its content
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.deepPurple),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.deepPurple),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: Colors.grey.shade400),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context, null),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Images ready! AI call coming in Phase 5 🚀'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('TryOn AI'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Virtual Try-On',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Upload a dress photo and your photo\nto see how it looks on you',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // ── Upload panels ─────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: ImageUploadPanel(
                      label: 'Dress photo',
                      icon: Icons.checkroom,
                      imageFile: _dressImage,         // pass real File
                      imageBytes: _dressImageBytes,   // for web image bytes
                      onTap: () => _pickImage(isDress: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ImageUploadPanel(
                      label: 'Your photo',
                      icon: Icons.person,
                      imageFile: _personImage,
                      imageBytes: _personImageBytes,
                      onTap: () => _pickImage(isDress: false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Result placeholder ────────────────────────────────
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.shade100),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: Colors.deepPurple.shade200,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _canSubmit
                          ? 'Ready! Hit the button below'
                          : 'Result will appear here',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _canSubmit
                          ? 'AI will generate your try-on'
                          : 'Upload both images first',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepPurple.shade300,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Submit button ─────────────────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _canSubmit ? _submit : null,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text(
                    'Try it on',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
