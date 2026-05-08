import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ImageUploadPanel extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final File? imageFile;      // ← changed: real File instead of bool
  final Uint8List? imageBytes;  // Web

  const ImageUploadPanel({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.imageFile,           // null = no image picked yet
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = kIsWeb ? imageBytes != null : imageFile != null;  // derive from File

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: hasImage
              ? Colors.deepPurple.shade50
              : Colors.white,
          border: Border.all(
            color: hasImage
                ? Colors.deepPurple
                : Colors.grey.shade300,
            width: hasImage ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        // ── Show image if picked, otherwise show placeholder ──
        child: hasImage
            ? ClipRRect(                          // clips image to rounded corners
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  fit: StackFit.expand,           // stack fills the container
                  children: [
                    kIsWeb
                    ? Image.memory(
                        imageBytes!,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        imageFile!,                 // ! safe — we checked hasImage
                        fit: BoxFit.cover,          // like CSS object-fit: cover
                      ),
                    // Dark overlay at bottom for the label
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          'Tap to change',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(                             // placeholder state
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to upload',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}