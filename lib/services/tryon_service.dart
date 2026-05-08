import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TryOnService {
  static const String _baseUrl = 'http://localhost:8080/api';

  Future<String> generateTryOn({
    File? dressFile,
    File? personFile,
    Uint8List? dressBytes,
    Uint8List? personBytes,
  }) async {
    // Convert both images to base64
    final String dressBase64 = await _toBase64(file: dressFile, bytes: dressBytes);
    final String personBase64 = await _toBase64(file: personFile, bytes: personBytes);

    // Step 1: describe the dress
    final String description = await _describeDress(dressBase64);

    // Step 2: generate try-on image
    final String resultBase64 = await _generateTryOn(
      personBase64: personBase64,
      dressBase64: dressBase64,
      description: description,
    );

    // Return as a data URI so Flutter can display it directly
    return 'data:image/png;base64,$resultBase64';
  }

  Future<String> _toBase64({File? file, Uint8List? bytes}) async {
    late Uint8List imageBytes;
    if (kIsWeb) {
      imageBytes = bytes!;
    } else {
      imageBytes = await file!.readAsBytes();
    }
    return base64Encode(imageBytes);  // raw base64, no data URI prefix
  }

  Future<String> _describeDress(String dressBase64) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/describe'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'imageBase64': dressBase64,
        'mimeType': 'image/jpeg',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to describe dress: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final String description = data['description'] ?? 'clothing item';
    return description;
  }

  Future<String> _generateTryOn({
    required String personBase64,
    required String dressBase64,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/tryon'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'personBase64': personBase64,
        'dressBase64': dressBase64,
        'personMime': 'image/jpeg',
        'dressMime': 'image/jpeg',
        'description': description,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini try-on failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['imageBase64'] as String;
  }
}