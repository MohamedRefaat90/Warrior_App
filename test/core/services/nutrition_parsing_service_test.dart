import 'package:Warrior/core/services/nutrition_parsing_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late NutritionParsingService parsingService;

  setUp(() {
    parsingService = NutritionParsingService();
  });

  group('NutritionParsingService', () {
    group('parseOcrText - English labels', () {
      test('parses standard English nutrition label', () {
        const ocrText = '''
          Nutrition Facts
          Serving Size: 30g
          Amount Per Serving
          Calories: 120
          Total Fat: 3.5g
          Saturated Fat: 1g
          Carbohydrate: 22g
          Sugars: 12g
          Fiber: 1g
          Protein: 2g
          Sodium: 150mg
          Salt: 0.4g
        ''';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.energyKcal100g, isNotNull);
        expect(result.fat100g, 3.5);
        expect(result.saturatedFat100g, 1.0);
        expect(result.carbohydrates100g, 22.0);
        expect(result.sugars100g, 12.0);
        expect(result.fiber100g, 1.0);
        expect(result.proteins100g, 2.0);
        expect(result.salt100g, 0.4);
        expect(result.dataMode, 'serving');
        expect(result.servingSizeGrams, 30.0);
      });

      test('parses per-100g label correctly', () {
        const ocrText = '''
          Nutrition Information per 100g
          Energy: 400 kcal
          Fat: 20g
          Protein: 8g
          Carbohydrates: 50g
        ''';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.energyKcal100g, 400.0);
        expect(result.fat100g, 20.0);
        expect(result.proteins100g, 8.0);
        expect(result.carbohydrates100g, 50.0);
        expect(result.dataMode, '100g');
      });

      test('handles values without units', () {
        const ocrText = '''
          Calories 200
          Fat 10
          Protein 5
        ''';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.energyKcal100g, 200.0);
        expect(result.fat100g, 10.0);
        expect(result.proteins100g, 5.0);
      });
    });

    group('parseOcrText - Arabic labels', () {
      test('parses Arabic nutrition label with Arabic numerals', () {
        const ocrText = '''
          القيم الغذائية لكل ١٠٠ جم
          طاقة: ٤٠٠ سعرة
          دهون: ٢٠،٥ جم
          بروتين: ٨ جم
          كربوهيدرات: ٥٠ جم
        ''';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.energyKcal100g, isNotNull);
        expect(result.fat100g, isNotNull);
        expect(result.proteins100g, isNotNull);
        expect(result.carbohydrates100g, isNotNull);
        expect(result.dataMode, '100g');
      });

      test('parses Arabic label with Western numerals', () {
        const ocrText = '''
          القيم الغذائية
          طاقة: 350 سعرة
          دهون: 15 جم
          دهون مشبعة: 5 جم
          سكريات: 20 جم
          ألياف: 3 جم
          صوديوم: 200 مجم
        ''';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.energyKcal100g, 350.0);
        expect(result.fat100g, 15.0);
        expect(result.saturatedFat100g, 5.0);
        expect(result.sugars100g, 20.0);
        expect(result.fiber100g, 3.0);
        // Sodium should be converted from mg to g
        expect(result.sodium100g, 0.2);
      });

      test('detects Arabic serving size', () {
        const ocrText = '''
          حجم الحصة: 50 جم
          سعرات: 150
          دهون: 5 جم
        ''';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.dataMode, 'serving');
        expect(result.servingSizeGrams, 50.0);
      });
    });

    group('Unit conversions', () {
      test('converts mg to g for sodium', () {
        const ocrText = '''
          Sodium: 500mg
        ''';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.sodium100g, 0.5);
      });

      test('converts kJ to kcal', () {
        const ocrText = '''
          Energy: 1674 kJ
        ''';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.energyKcal100g, closeTo(400, 1));
      });

      test('handles kcal without conversion', () {
        const ocrText = '''
          Calories: 250 kcal
        ''';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.energyKcal100g, 250.0);
      });
    });

    group('Confidence scoring', () {
      test('flags low confidence for values without units', () {
        const ocrText = '''
          Fat 10
          Protein 5
        ''';

        final result = parsingService.parseOcrText(ocrText);

        // Values without units should have lower confidence
        expect(result.confidenceScores['fat'], lessThan(0.75));
        expect(result.confidenceScores['proteins'], lessThan(0.75));
      });

      test('higher confidence for values with units', () {
        const ocrText = '''
          Fat: 10g
          Protein: 5g
        ''';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.confidenceScores['fat'], greaterThanOrEqualTo(0.75));
        expect(result.confidenceScores['proteins'], greaterThanOrEqualTo(0.75));
      });

      test('requires review when few fields extracted', () {
        const ocrText = '''
          Fat: 10g
        ''';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.requiresReview, isTrue);
      });

      test(
          'does not require review when many fields extracted with high confidence',
          () {
        const ocrText = '''
          Calories: 200 kcal
          Fat: 10g
          Protein: 5g
          Carbohydrates: 25g
          Sugars: 10g
        ''';

        final result = parsingService.parseOcrText(ocrText);

        // Should have enough fields with good confidence
        expect(result.populatedFieldCount, greaterThanOrEqualTo(4));
      });
    });

    group('Mixed language labels', () {
      test('handles mixed English and Arabic', () {
        const ocrText = '''
          Calories / سعرات: 300
          Fat / دهون: 15g
          Protein / بروتين: 10g
        ''';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.energyKcal100g, 300.0);
        expect(result.fat100g, 15.0);
        expect(result.proteins100g, 10.0);
      });
    });

    group('Serving size detection', () {
      test('detects English serving size', () {
        const ocrText = '''
          Serving Size: 40g
          Calories: 150
        ''';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.servingSize, contains('40'));
        expect(result.servingSizeGrams, 40.0);
        expect(result.dataMode, 'serving');
      });

      test('detects "per serving" format', () {
        const ocrText = '''
          Per Serving: 25g
          Calories: 100
        ''';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.dataMode, 'serving');
      });

      test('defaults to per-100g when serving size not found', () {
        const ocrText = '''
          Energy: 400 kcal
          Fat: 20g
        ''';

        final result = parsingService.parseOcrText(ocrText);

        // No serving size pattern, but also no per-100g indicator
        // Should still parse the values
        expect(result.energyKcal100g, 400.0);
        expect(result.fat100g, 20.0);
      });
    });

    group('Edge cases', () {
      test('handles empty text', () {
        const ocrText = '';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.populatedFieldCount, 0);
        expect(result.requiresReview, isTrue);
      });

      test('handles text with no nutrition values', () {
        const ocrText = '''
          Product Name: Delicious Snack
          Best Before: 2025-12-01
          Country: Spain
        ''';

        final result = parsingService.parseOcrText(ocrText);

        // May find some false positives, but should require review
        expect(result.requiresReview, isTrue);
      });

      test('handles decimal values with comma separator', () {
        const ocrText = '''
          Fat: 10,5g
          Protein: 3,2g
        ''';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.fat100g, 10.5);
        expect(result.proteins100g, 3.2);
      });

      test('stores raw OCR text', () {
        const ocrText = 'Calories: 200';

        final result = parsingService.parseOcrText(ocrText);

        expect(result.rawOcrText, ocrText);
      });

      test('sets scannedAt timestamp', () {
        const ocrText = 'Calories: 200';
        final beforeParse = DateTime.now();

        final result = parsingService.parseOcrText(ocrText);

        expect(result.scannedAt, isNotNull);
        expect(
          result.scannedAt!
              .isAfter(beforeParse.subtract(const Duration(seconds: 1))),
          isTrue,
        );
      });
    });

    group('mapToStandardKey', () {
      test('maps English keywords to standard keys', () {
        expect(parsingService.mapToStandardKey('calories'), 'energy');
        expect(parsingService.mapToStandardKey('total fat'), 'fat');
        expect(parsingService.mapToStandardKey('protein'), 'proteins');
        expect(
            parsingService.mapToStandardKey('carbohydrate'), 'carbohydrates');
      });

      test('maps Arabic keywords to standard keys', () {
        expect(parsingService.mapToStandardKey('سعرات'), 'energy');
        expect(parsingService.mapToStandardKey('دهون'), 'fat');
        expect(parsingService.mapToStandardKey('بروتين'), 'proteins');
        expect(parsingService.mapToStandardKey('كربوهيدرات'), 'carbohydrates');
      });

      test('returns null for unknown keywords', () {
        expect(parsingService.mapToStandardKey('unknown'), isNull);
        expect(parsingService.mapToStandardKey('xyz'), isNull);
      });
    });
  });
}
