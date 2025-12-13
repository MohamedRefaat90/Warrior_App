import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for body view state (front/back)
final bodyDiagramProvider =
    NotifierProvider<BodyDiagramNotifier, BodyView>(BodyDiagramNotifier.new);

/// Debug mode toggle provider (only used in debug builds)
final hotspotDebugModeProvider =
    NotifierProvider<HotspotDebugModeNotifier, bool>(
        HotspotDebugModeNotifier.new);

/// Hotspot data provider
/// Backend muscles: abs, triceps, shoulders, legs, chest, biceps, back
/// Front body: chest, abs, biceps, legs
/// Back body: back, shoulders, triceps
final muscleHotspotsProvider = Provider<List<MuscleHotspot>>((ref) {
  return const [
    // === FRONT BODY: chest, abs, biceps, legs ===
    MuscleHotspot(
      muscleKey: 'chest',
      bodyView: BodyView.front,
      shape: HotspotShape.polygon,
      coordinates: [
        0.25,
        0.12,
        0.50,
        0.10,
        0.75,
        0.12,
        0.70,
        0.22,
        0.50,
        0.24,
        0.30,
        0.22
      ],
    ),
    MuscleHotspot(
      muscleKey: 'abs',
      bodyView: BodyView.front,
      shape: HotspotShape.polygon,
      coordinates: [0.35, 0.24, 0.65, 0.24, 0.62, 0.45, 0.38, 0.45],
    ),
    MuscleHotspot(
      muscleKey: 'biceps',
      bodyView: BodyView.front,
      shape: HotspotShape.rect,
      coordinates: [0.06, 0.14, 0.14, 0.22], // Left bicep
    ),
    MuscleHotspot(
      muscleKey: 'biceps',
      bodyView: BodyView.front,
      shape: HotspotShape.rect,
      coordinates: [0.80, 0.14, 0.14, 0.22], // Right bicep
    ),
    MuscleHotspot(
      muscleKey: 'legs',
      bodyView: BodyView.front,
      shape: HotspotShape.rect,
      coordinates: [0.22, 0.48, 0.22, 0.38], // Left leg
    ),
    MuscleHotspot(
      muscleKey: 'legs',
      bodyView: BodyView.front,
      shape: HotspotShape.rect,
      coordinates: [0.56, 0.48, 0.22, 0.38], // Right leg
    ),

    // === BACK BODY: back, shoulders, triceps ===
    MuscleHotspot(
      muscleKey: 'back',
      bodyView: BodyView.back,
      shape: HotspotShape.polygon,
      coordinates: [0.28, 0.12, 0.72, 0.12, 0.68, 0.48, 0.32, 0.48],
    ),
    MuscleHotspot(
      muscleKey: 'shoulders',
      bodyView: BodyView.back,
      shape: HotspotShape.rect,
      coordinates: [0.08, 0.04, 0.20, 0.16], // Left shoulder
    ),
    MuscleHotspot(
      muscleKey: 'shoulders',
      bodyView: BodyView.back,
      shape: HotspotShape.rect,
      coordinates: [0.72, 0.04, 0.20, 0.16], // Right shoulder
    ),
    MuscleHotspot(
      muscleKey: 'triceps',
      bodyView: BodyView.back,
      shape: HotspotShape.rect,
      coordinates: [0.04, 0.18, 0.14, 0.20], // Left tricep
    ),
    MuscleHotspot(
      muscleKey: 'triceps',
      bodyView: BodyView.back,
      shape: HotspotShape.rect,
      coordinates: [0.82, 0.18, 0.14, 0.20], // Right tricep
    ),
  ];
});

class BodyDiagramNotifier extends Notifier<BodyView> {
  @override
  BodyView build() => BodyView.front;

  void setView(BodyView view) => state = view;

  void toggleView() =>
      state = state == BodyView.front ? BodyView.back : BodyView.front;
}

/// Body view state enum
enum BodyView { front, back }

/// Notifier for hotspot debug mode toggle
class HotspotDebugModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setEnabled(bool value) => state = value;
  void toggle() => state = !state;
}

/// Hotspot shape types
enum HotspotShape { rect, polygon }

/// Clickable region on body diagram - percentage-based coordinates (0.0-1.0)
class MuscleHotspot {
  /// Matches MuscleModel.name from backend
  final String muscleKey;
  final BodyView bodyView;
  final HotspotShape shape;

  /// For rect: [left%, top%, width%, height%]
  /// For polygon: [x1%, y1%, x2%, y2%, ...]
  final List<double> coordinates;

  const MuscleHotspot({
    required this.muscleKey,
    required this.bodyView,
    required this.shape,
    required this.coordinates,
  });

  /// Check if a point (in percentage coordinates) is inside this hotspot
  bool containsPoint(double x, double y) {
    return shape == HotspotShape.rect
        ? _containsPointRect(x, y)
        : _containsPointPolygon(x, y);
  }

  /// Ray-casting algorithm for polygon hit testing
  bool _containsPointPolygon(double x, double y) {
    int intersections = 0;
    for (int i = 0; i < coordinates.length; i += 2) {
      final x1 = coordinates[i];
      final y1 = coordinates[i + 1];
      final x2 = coordinates[(i + 2) % coordinates.length];
      final y2 = coordinates[(i + 3) % coordinates.length];

      if ((y1 <= y && y < y2) || (y2 <= y && y < y1)) {
        final xIntersect = x1 + (y - y1) / (y2 - y1) * (x2 - x1);
        if (x < xIntersect) intersections++;
      }
    }
    return intersections.isOdd;
  }

  bool _containsPointRect(double x, double y) {
    final left = coordinates[0];
    final top = coordinates[1];
    final width = coordinates[2];
    final height = coordinates[3];
    return x >= left && x <= left + width && y >= top && y <= top + height;
  }
}
