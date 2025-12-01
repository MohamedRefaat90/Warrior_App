import 'dart:io';

import 'package:Warrior/core/services/nutrition_parsing_service.dart';
import 'package:Warrior/core/services/ocr_service.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/nutrition_facts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for NutritionParsingService instance.
final nutritionParsingServiceProvider = Provider<NutritionParsingService>(
  (ref) => NutritionParsingService(),
);

/// Provider for OCR scanner state and actions.
final ocrScannerProvider =
    NotifierProvider.autoDispose<OcrScannerNotifier, OcrScanState>(
  OcrScannerNotifier.new,
);

/// Provider for OcrService instance.
final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Scan failed with error.
class OcrScanError extends OcrScanState {
  final String message;
  final bool canRetry;

  const OcrScanError({required this.message, this.canRetry = true});
}

/// Initial state - ready to scan.
class OcrScanInitial extends OcrScanState {
  const OcrScanInitial();
}

/// Processing image.
class OcrScanLoading extends OcrScanState {
  final String message;
  const OcrScanLoading([this.message = 'Processing...']);
}

/// Notifier for managing OCR scanning state.
class OcrScannerNotifier extends Notifier<OcrScanState> {
  @override
  OcrScanState build() {
    ref.keepAlive();
    return const OcrScanInitial();
  }

  /// Processes an image file and extracts nutrition facts.
  Future<void> processImage(String imagePath) async {
    state = const OcrScanLoading('Extracting text...');

    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        state = const OcrScanError(
          message: 'Image file not found',
          canRetry: false,
        );
        return;
      }

      // Extract text using OCR
      final ocrService = ref.read(ocrServiceProvider);
      final rawText = await ocrService.extractText(file);

      if (rawText.trim().isEmpty) {
        state = const OcrScanError(
          message: 'No text found in image. Try a clearer photo.',
          canRetry: true,
        );
        return;
      }

      TalkerService.debug('OCR extracted: ${rawText.length} chars', 'OCR');

      // Parse nutrition facts from text
      state = const OcrScanLoading('Parsing nutrition facts...');
      final parsingService = ref.read(nutritionParsingServiceProvider);
      final facts = parsingService.parseOcrText(rawText);

      // Check if we got any useful data
      if (facts.populatedFieldCount == 0) {
        state = const OcrScanError(
          message: 'Could not find nutrition information. '
              'Make sure the nutrition label is clearly visible.',
          canRetry: true,
        );
        return;
      }

      TalkerService.info(
        'Parsed ${facts.populatedFieldCount} nutrition fields',
        'OCR',
      );

      // Log parsed nutrition data for debugging
      _logParsedNutrition(facts, rawText);

      state = OcrScanSuccess(facts: facts);
    } catch (e, stackTrace) {
      TalkerService.error('OCR processing failed', 'OCR', e, stackTrace);
      state = OcrScanError(
        message: 'Failed to process image: ${e.toString()}',
        canRetry: true,
      );
    }
  }

  /// Resets state to initial.
  void reset() {
    state = const OcrScanInitial();
  }

  String _formatConfidence(NutritionFacts facts, String field) {
    final confidence = facts.getFieldConfidence(field);
    final percentage = (confidence * 100).toStringAsFixed(0);
    return '$percentage%';
  }

  /// Logs parsed nutrition data for debugging.
  void _logParsedNutrition(NutritionFacts facts, String rawText) {
    final buffer = StringBuffer();
    buffer.writeln('═══ PARSED NUTRITION DATA ═══');
    buffer.writeln('Data Mode: ${facts.dataMode}');
    buffer.writeln('Requires Review: ${facts.requiresReview}');
    buffer.writeln('');
    buffer.writeln('── Values ──');

    if (facts.energyKcal100g != null) {
      buffer.writeln('  Energy: ${facts.energyKcal100g} kcal '
          '(confidence: ${_formatConfidence(facts, 'energy')})');
    }
    if (facts.fat100g != null) {
      buffer.writeln('  Fat: ${facts.fat100g}g '
          '(confidence: ${_formatConfidence(facts, 'fat')})');
    }
    if (facts.saturatedFat100g != null) {
      buffer.writeln('  Saturated Fat: ${facts.saturatedFat100g}g '
          '(confidence: ${_formatConfidence(facts, 'saturatedFat')})');
    }
    if (facts.carbohydrates100g != null) {
      buffer.writeln('  Carbohydrates: ${facts.carbohydrates100g}g '
          '(confidence: ${_formatConfidence(facts, 'carbohydrates')})');
    }
    if (facts.sugars100g != null) {
      buffer.writeln('  Sugars: ${facts.sugars100g}g '
          '(confidence: ${_formatConfidence(facts, 'sugars')})');
    }
    if (facts.fiber100g != null) {
      buffer.writeln('  Fiber: ${facts.fiber100g}g '
          '(confidence: ${_formatConfidence(facts, 'fiber')})');
    }
    if (facts.proteins100g != null) {
      buffer.writeln('  Proteins: ${facts.proteins100g}g '
          '(confidence: ${_formatConfidence(facts, 'proteins')})');
    }
    if (facts.sodium100g != null) {
      buffer.writeln('  Sodium: ${facts.sodium100g}g '
          '(confidence: ${_formatConfidence(facts, 'sodium')})');
    }
    if (facts.salt100g != null) {
      buffer.writeln('  Salt: ${facts.salt100g}g '
          '(confidence: ${_formatConfidence(facts, 'salt')})');
    }

    if (facts.servingSize != null) {
      buffer.writeln('');
      buffer.writeln('── Serving Info ──');
      buffer.writeln('  Serving Size: ${facts.servingSize}');
      buffer.writeln('  Serving Grams: ${facts.servingSizeGrams}');
    }

    final lowConfidence = facts.getLowConfidenceFields();
    if (lowConfidence.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('⚠️ Low Confidence Fields: ${lowConfidence.join(', ')}');
    }

    buffer.writeln('');
    buffer.writeln('── Raw OCR Text ──');
    buffer.writeln(
        rawText.length > 500 ? '${rawText.substring(0, 500)}...' : rawText);
    buffer.writeln('═══════════════════════════════');

    TalkerService.debug(buffer.toString(), 'OCR-RESULT');
  }
}

/// State for OCR scanning process.
sealed class OcrScanState {
  const OcrScanState();
}

/// Scan successful with extracted nutrition facts.
class OcrScanSuccess extends OcrScanState {
  final NutritionFacts facts;

  const OcrScanSuccess({required this.facts});
}
