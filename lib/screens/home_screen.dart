import 'package:flutter/material.dart';

import '../widgets/image_upload_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ super.key });

  @override
  State<HomeScreen> createState () => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasDressImage = false;
  bool _hasPersonImage = false;

  bool get _canSubmit => _hasDressImage && _hasPersonImage;

  void _pickDressImage() {
    setState(() => _hasDressImage = true);
  }

  void _pickPersonImage() {
    setState(() => _hasPersonImage = true);
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submitting to AI... (coming in Phase 5!)'))
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
                  height: 1.5,      // line height
                ),
              ),
              const SizedBox(height: 32),
               // ── Two upload panels side by side ────────────────────
              Row(
                children: [
                  Expanded(             // Expanded fills available width
                    child: ImageUploadPanel(
                      label: 'Dress photo',
                      icon: Icons.checkroom,
                      hasImage: _hasDressImage,
                      onTap: _pickDressImage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ImageUploadPanel(
                      label: 'Your photo',
                      icon: Icons.person,
                      hasImage: _hasPersonImage,
                      onTap: _pickPersonImage,
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

                    const SizedBox(height: 24),

                    // ── Submit button ─────────────────────────────────────
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _canSubmit ? _submit : null,  // null = disabled
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text(
                          'Try it on',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
            ],
          ),
        ),
      ),
    );
  }
}
