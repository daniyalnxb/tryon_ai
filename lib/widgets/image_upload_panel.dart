import 'package:flutter/material.dart';

class ImageUploadPanel extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool hasImage;

  const ImageUploadPanel({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.hasImage = false,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasImage ? Icons.check_circle : icon,
              size: 40,
              color: hasImage
                ? Colors.deepPurple
                : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: hasImage
                  ? Colors.deepPurple
                  : Colors.grey.shade600,
              )
            ),
            const SizedBox(height: 4),
            Text(
              hasImage ? 'Tap to change' : 'Tap to upload',
              style: TextStyle(
                fontSize: 11,
                color: hasImage
                    ? Colors.deepPurple.shade300
                    : Colors.deepPurple,
              ),
            ),
          ],
        )
      ),
    );
  } 
}