import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; 

import '../widgets/image_upload_panel.dart';
import '../services/tryon_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Image state (your web fix preserved) ─────────────────────────
  File? _dressImage;
  File? _personImage;
  Uint8List? _dressImageBytes;
  Uint8List? _personImageBytes;

  // ── AI result state ───────────────────────────────────────────────
  String? _resultImageUrl;      // URL returned by Replicate
  bool _isLoading = false;      // shows spinner while AI works
  String? _errorMessage;        // shows error if something fails
  String _statusMessage = '';   // "Processing... step 2/3" etc.

  final TryOnService _tryOnService = TryOnService();

  bool get _canSubmit {
    if (kIsWeb) {
      return _dressImageBytes != null && _personImageBytes != null;
    }
    return _dressImage != null && _personImage != null;
  }

  // ── Image picking (your web fix preserved) ────────────────────────
  Future<void> _pickImage({required bool isDress}) async {
    final source = await _showSourcePicker();
    if (source == null) return;

    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (picked == null) return;

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          if (isDress) {
            _dressImageBytes = bytes;
            _dressImage = null;
          } else {
            _personImageBytes = bytes;
            _personImage = null;
          }
          // clear previous result when new image picked
          _resultImageUrl = null;
          _errorMessage = null;
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
          _resultImageUrl = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  // ── Submit — calls AI service ─────────────────────────────────────
  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _resultImageUrl = null;
      _statusMessage = 'Uploading images...';
    });

    try {
      setState(() => _statusMessage = 'AI is processing your try-on...');

      final String url = await _tryOnService.generateTryOn(
        dressFile: _dressImage,
        personFile: _personImage,
        dressBytes: _dressImageBytes,
        personBytes: _personImageBytes,
      );

      if (mounted) {
        setState(() {
          _resultImageUrl = url;
          _isLoading = false;
          _statusMessage = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Something went wrong: $e';
          _isLoading = false;
          _statusMessage = '';
        });
      }
    }
  }

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
            mainAxisSize: MainAxisSize.min,
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

  // ── Result box — changes based on state ───────────────────────────
  Widget _buildResultBox() {
    if (_isLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.deepPurple.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.deepPurple),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              style: TextStyle(fontSize: 13, color: Colors.deepPurple.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              'Gemini is generating your try-on...',
              style: TextStyle(fontSize: 11, color: Colors.deepPurple.shade300),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 40, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.red.shade700),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _submit, child: const Text('Try again')),
          ],
        ),
      );
    }

    // ── Result: Gemini returns base64 → decode to bytes → Image.memory ──
    if (_resultImageUrl != null) {
      // Strip the data URI prefix to get raw base64
      final String base64Data = _resultImageUrl!.replaceFirst(
        RegExp(r'data:image/[^;]+;base64,'), '',
      );
      final Uint8List imageBytes = base64Decode(base64Data);

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(           // ← Image.memory for base64 data
          imageBytes,
          height: 350,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    // Default placeholder
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 48, color: Colors.deepPurple.shade200),
          const SizedBox(height: 12),
          Text(
            _canSubmit ? 'Ready! Hit the button below' : 'Result will appear here',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.deepPurple.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _canSubmit ? 'AI will generate your try-on' : 'Upload both images first',
            style: TextStyle(fontSize: 12, color: Colors.deepPurple.shade300),
          ),
        ],
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

              // ── Upload panels ──────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: ImageUploadPanel(
                      label: 'Dress photo',
                      icon: Icons.checkroom,
                      imageFile: _dressImage,
                      imageBytes: _dressImageBytes,
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

              // ── Result area (dynamic) ──────────────────────────────
              _buildResultBox(),

              const SizedBox(height: 24),

              // ── Submit button ──────────────────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  // disabled while loading or images not ready
                  onPressed: _canSubmit && !_isLoading ? _submit : null,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _isLoading ? 'Processing...' : 'Try it on',
                    style: const TextStyle(
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

              // ── Save button (only when result is ready) ────────────
              if (_resultImageUrl != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // Phase 6 — save to gallery
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Save feature coming in Phase 6!')),
                    );
                  },
                  icon: const Icon(Icons.download, color: Colors.deepPurple),
                  label: const Text(
                    'Save result',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.deepPurple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}