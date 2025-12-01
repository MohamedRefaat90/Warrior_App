import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'talker_service.dart';

/// Isolate function for image compression.
Future<String?> _compressInIsolate(String imagePath) async {
  final file = File(imagePath);
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    quality: 85,
    minWidth: 1024,
    minHeight: 1024,
  );
  return result?.path;
}

/// Service for extracting text from images using ML Kit.
///
/// Uses Latin script recognizer which can handle both English and
/// Arabic numerals commonly found on nutrition labels.
class OcrService {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  bool _isDisposed = false;

  /// Compresses an image file for faster OCR processing.
  ///
  /// Runs compression in an isolate to avoid blocking the UI thread.
  Future<File?> compressImage(File file) async {
    try {
      final result = await compute(_compressInIsolate, file.absolute.path);
      if (result != null) {
        return File(result);
      }
      return file;
    } catch (e) {
      TalkerService.warning('Image compression failed, using original', 'OCR');
      return file;
    }
  }

  /// Releases all resources.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _textRecognizer.close();
  }

  /// Extracts text from an image file.
  Future<String> extractText(File imageFile) async {
    if (_isDisposed) {
      throw StateError('OcrService has been disposed');
    }

    try {
      // Compress image first (runs in isolate)
      final compressedFile = await compressImage(imageFile);
      final inputImage = InputImage.fromFile(compressedFile ?? imageFile);

      // Run text recognition
      final result = await _textRecognizer.processImage(inputImage);

      TalkerService.debug(
        'OCR extracted ${result.blocks.length} blocks, ${result.text.length} chars',
        'OCR',
      );

      return result.text;
    } catch (e, stackTrace) {
      TalkerService.error('OCR extraction failed', 'OCR', e, stackTrace);
      rethrow;
    }
  }
}
