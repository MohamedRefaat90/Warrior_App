import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for body view toggle
final bodyDiagramProvider =
    NotifierProvider<BodyDiagramNotifier, BodyView>(BodyDiagramNotifier.new);

class BodyDiagramNotifier extends Notifier<BodyView> {
  @override
  BodyView build() => BodyView.front;

  void setView(BodyView view) => state = view;
  void toggleView() =>
      state = state == BodyView.front ? BodyView.back : BodyView.front;
}

/// Body view state (front/back)
enum BodyView { front, back }

/// Label position data
class MuscleLabel {
  final String muscleKey;
  final BodyView bodyView;
  final double labelX, labelY; // Card position (0-1)
  final double anchorX, anchorY; // Arrow endpoint (0-1)

  MuscleLabel(this.muscleKey, this.bodyView,
      {required this.labelX,
      required this.labelY,
      required this.anchorX,
      required this.anchorY});
}

/// Muscle label positions - use getter for hot reload support!
class MuscleLabelsData {
  static List<MuscleLabel> get labels => [
        // === FRONT BODY ===
        MuscleLabel(
          'chest',
          BodyView.front,
          labelX: 0.20,
          labelY: 0.085,
          anchorX: 0.40,
          anchorY: 0.25,
        ),
        MuscleLabel(
          'abs',
          BodyView.front,
          labelX: 0.2,
          labelY: 0.50,
          anchorX: 0.45,
          anchorY: 0.40,
        ),
        MuscleLabel(
          'biceps',
          BodyView.front,
          labelX: 0.8,
          labelY: 0.2,
          anchorX: 0.80,
          anchorY: 0.35,
        ),
        MuscleLabel(
          'legs',
          BodyView.front,
          labelX: 0.80,
          labelY: 0.82,
          anchorX: 0.67,
          anchorY: 0.72,
        ),

        // === BACK BODY ===
        MuscleLabel(
          'back',
          BodyView.back,
          labelX: 0.20,
          labelY: 0.1,
          anchorX: 0.55,
          anchorY: 0.28,
        ),
        MuscleLabel(
          'shoulders',
          BodyView.back,
          labelX: 0.2,
          labelY: 0.5,
          anchorX: 0.20,
          anchorY: 0.25,
        ),
        MuscleLabel(
          'triceps',
          BodyView.back,
          labelX: 0.7,
          labelY: 0.6,
          anchorX: 0.80,
          anchorY: 0.35,
        ),
      ];

  static List<MuscleLabel> forView(BodyView view) =>
      labels.where((l) => l.bodyView == view).toList();
}
