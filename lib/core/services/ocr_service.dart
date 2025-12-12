import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'talker_service.dart';

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
  /// Note: Compression runs on the main isolate because platform channels
  /// (used by FlutterImageCompress) don't work in separate isolates.
  /// However, the compression is fast enough (~100-200ms) to not block UI.
  Future<File?> compressImage(File file) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
        quality: 85,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (result != null) {
        TalkerService.debug('Image compressed successfully', 'OCR');
        return File(result.path);
      }

      TalkerService.debug('Compression returned null, using original', 'OCR');
      return file;
    } catch (e, _) {
      TalkerService.warning(
        'Image compression failed: $e, using original',
        'OCR',
      );
      return file;
    }
  }

  /// Releases all resources.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _textRecognizer.close();
  }

  /// Extracts text from an image file using spatial ordering.
  ///
  /// This method reconstructs text in reading order (top-to-bottom,
  /// left-to-right within each row) by analyzing the bounding boxes
  /// of text elements. This is crucial for nutrition labels where
  /// labels and values appear side by side.
  Future<String> extractText(File imageFile) async {
    if (_isDisposed) {
      throw StateError('OcrService has been disposed');
    }

    try {
      // Compress image first
      final compressedFile = await compressImage(imageFile);
      final inputImage = InputImage.fromFile(compressedFile ?? imageFile);

      // Run text recognition
      final result = await _textRecognizer.processImage(inputImage);

      TalkerService.debug(
        'OCR extracted ${result.blocks.length} blocks, ${result.text.length} chars',
        'OCR',
      );

      // Use spatial ordering to reconstruct text in reading order
      final orderedText = _extractTextInReadingOrder(result);

      return orderedText;
    } catch (e, stackTrace) {
      TalkerService.error('OCR extraction failed', 'OCR', e, stackTrace);
      rethrow;
    }
  }

  /// Extracts text from RecognizedText in reading order.
  ///
  /// Groups text lines by their vertical position (Y coordinate),
  /// then sorts each row by horizontal position (X coordinate).
  /// This ensures "Label    Value" on the same row stays together.
  String _extractTextInReadingOrder(RecognizedText recognizedText) {
    // Collect all lines with their bounding boxes
    final lines = <_PositionedLine>[];

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final boundingBox = line.boundingBox;
        lines.add(_PositionedLine(
          text: line.text,
          top: boundingBox.top,
          bottom: boundingBox.bottom,
          left: boundingBox.left,
          height: boundingBox.height,
        ));
      }
    }

    if (lines.isEmpty) {
      return recognizedText.text;
    }

    // Sort by vertical position (top of each line)
    lines.sort((a, b) => a.top.compareTo(b.top));

    // Group lines that are on the same visual row
    // Use center-point comparison with height-based tolerance
    final rows = <List<_PositionedLine>>[];
    List<_PositionedLine> currentRow = [];
    double? rowCenterY;
    double? rowHeight;

    for (final line in lines) {
      if (currentRow.isEmpty) {
        currentRow.add(line);
        rowCenterY = line.centerY;
        rowHeight = line.height;
      } else {
        // Check if this line's center is within tolerance of the row's center
        // Tolerance = 40% of the row's height (not expanding tolerance)
        final tolerance = rowHeight! * 0.4;
        final centerDiff = (line.centerY - rowCenterY!).abs();

        if (centerDiff <= tolerance) {
          currentRow.add(line);
          // Update row center to be average of all lines
          rowCenterY =
              currentRow.map((l) => l.centerY).reduce((a, b) => a + b) /
                  currentRow.length;
        } else {
          rows.add(currentRow);
          currentRow = [line];
          rowCenterY = line.centerY;
          rowHeight = line.height;
        }
      }
    }
    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    // Sort each row by horizontal position and build output
    final buffer = StringBuffer();
    for (final row in rows) {
      row.sort((a, b) => a.left.compareTo(b.left));
      final rowText =
          row.map((l) => l.text).join('  '); // Double space between columns
      buffer.writeln(rowText);
    }

    return buffer.toString().trim();
  }
}

/// Helper class to hold a text line with its position.
class _PositionedLine {
  final String text;
  final double top;
  final double bottom;
  final double left;
  final double height;

  _PositionedLine({
    required this.text,
    required this.top,
    required this.bottom,
    required this.left,
    required this.height,
  });

  double get centerY => (top + bottom) / 2;
}
