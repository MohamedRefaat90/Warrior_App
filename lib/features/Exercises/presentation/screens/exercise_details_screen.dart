import 'dart:io';

import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/extensions/translation_ext.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/settings/app_settings_provider.dart';
import 'package:Warrior/core/widgets/banner_ad_widget.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/loading_widget.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  final ExerciseModel exercise;

  /// Optional WorkoutItemModel containing sets, progress data, etc.
  /// When provided, the workout logging section will be displayed.
  final WorkoutItemModel? workoutItem;

  /// Optional workout set ID for API calls.
  final int? workoutSetId;

  const ExerciseDetailsScreen({
    super.key,
    required this.exercise,
    this.workoutItem,
    this.workoutSetId,
  });

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

/// Compact input field for reps/weight.
class _CompactInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isDark;
  final bool allowDecimal;

  const _CompactInput({
    required this.controller,
    required this.label,
    required this.isDark,
    this.allowDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        if (allowDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 11,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkSecondary : AppColors.primaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

/// Mutable set data for editing.
class _EditableSet {
  int? id;
  int setNumber;
  TextEditingController repsController;
  TextEditingController weightController;

  _EditableSet({
    this.id,
    required this.setNumber,
    required int reps,
    required num weight,
  })  : repsController = TextEditingController(text: reps.toString()),
        weightController = TextEditingController(
          text: weight
              .toStringAsFixed(weight.truncateToDouble() == weight ? 0 : 2),
        );

  void dispose() {
    repsController.dispose();
    weightController.dispose();
  }

  Map<String, dynamic> toApiMap() {
    return {
      'set_number': setNumber,
      'reps': int.tryParse(repsController.text) ?? 0,
      'weight': double.tryParse(weightController.text) ?? 0.0,
    };
  }
}

/// Editable set row with text fields for reps and weight.
class _EditableSetRow extends ConsumerWidget {
  final int setNumber;
  final TextEditingController repsController;
  final TextEditingController weightController;
  final String? equipmentType;
  final VoidCallback onDelete;

  const _EditableSetRow({
    required this.setNumber,
    required this.repsController,
    required this.weightController,
    this.equipmentType,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appSettings = ref.watch(appSettingsProvider.notifier);
    final isMachine = equipmentType == 'machine';
    final weightUnit = isMachine ? context.l10n.bar : context.l10n.kg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Set number badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSecondary.withOpacity(0.3)
                  : AppColors.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$setNumber',
                style: TextStyle(
                  fontFamily: appSettings.fontFamily(),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark ? AppColors.darkSecondary : AppColors.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Reps input
          Expanded(
            child: _CompactInput(
              controller: repsController,
              label: context.l10n.reps,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),
          // Weight input
          Expanded(
            child: _CompactInput(
              controller: weightController,
              label: weightUnit,
              isDark: isDark,
              allowDecimal: true,
            ),
          ),
          const SizedBox(width: 8),
          // Delete button
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: Colors.red.withOpacity(0.7),
              size: 22,
            ),
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            padding: EdgeInsets.zero,
            tooltip: context.l10n.deleteSet,
          ),
        ],
      ),
    );
  }
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  CachedVideoPlayerPlus? _player;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;
  String? _videoErrorMessage;

  /// Current workout item (can be updated after saving sets)
  WorkoutItemModel? _workoutItem;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.black87,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const BannerAdWidget(
              adUnitId: "ca-app-pub-7417773148722475/6306035388"),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    _ExerciseVideoPlayer(
                      player: _player,
                      isInitialized: _isVideoInitialized,
                      hasError: _hasVideoError,
                      errorMessage: _videoErrorMessage,
                    ),
                    const SizedBox(height: 20),
                    _ExerciseTitle(name: widget.exercise.name),
                    // Show workout logging section only when coming from workout
                    if (_workoutItem != null) ...[
                      const SizedBox(height: 24),
                      _WorkoutLoggingSection(
                        workoutItem: _workoutItem!,
                        workoutSetId: widget.workoutSetId,
                        onWorkoutItemUpdated: _onWorkoutItemUpdated,
                      ),
                    ],
                    const SizedBox(height: 24),
                    _TargetedMusclesSection(
                      imageUrl: widget.exercise.targetedMuscles,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void deactivate() {
    try {
      if (_player != null && _isVideoInitialized) {
        _player!.controller.pause();
      }
    } catch (e) {
      TalkerService.warning(
        'Error pausing video in deactivate',
        'EXERCISE_DETAILS',
      );
    }
    super.deactivate();
  }

  @override
  void dispose() {
    try {
      if (_player != null && _isVideoInitialized) {
        _player!.controller.pause();
      }
      _player?.dispose();
    } catch (e) {
      TalkerService.warning(
        'Error disposing video player',
        'EXERCISE_DETAILS',
      );
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _workoutItem = widget.workoutItem;
    _initializeVideoPlayer();
  }

  void _initializeLocalVideo() {
    try {
      final file = File(widget.exercise.video);

      _player = CachedVideoPlayerPlus.file(
        file,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      _player!.initialize().then((_) {
        if (mounted && _player != null) {
          setState(() => _isVideoInitialized = true);
          try {
            _player!.controller
              ..setVolume(0)
              ..play()
              ..setLooping(true);
            TalkerService.info(
              'Local video initialized successfully',
              'EXERCISE_DETAILS',
            );
          } catch (e) {
            TalkerService.error(
              'Error configuring local video after initialization',
              'EXERCISE_DETAILS',
              e,
            );
          }
        }
      }).catchError((error) {
        TalkerService.error(
          'Local video initialization failed',
          'EXERCISE_DETAILS',
          error,
        );
        if (mounted) {
          setState(() {
            _hasVideoError = true;
            _videoErrorMessage = 'Video not available';
          });
        }
      });
    } catch (e, stackTrace) {
      TalkerService.error(
        'Local video setup failed',
        'EXERCISE_DETAILS',
        e,
        stackTrace,
      );
      if (mounted) {
        setState(() {
          _hasVideoError = true;
          _videoErrorMessage = 'Video file error';
        });
      }
    }
  }

  void _initializeNetworkVideo() {
    try {
      final uri = Uri.tryParse(widget.exercise.video);
      if (uri == null) {
        throw Exception('Invalid video URL: ${widget.exercise.video}');
      }

      _player = CachedVideoPlayerPlus.networkUrl(
        uri,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      _player!.initialize().then((_) {
        if (mounted && _player != null) {
          setState(() => _isVideoInitialized = true);
          try {
            _player!.controller
              ..setVolume(0)
              ..play()
              ..setLooping(true);
            TalkerService.info(
              'Network video initialized successfully',
              'EXERCISE_DETAILS',
            );
          } catch (e) {
            TalkerService.error(
              'Error configuring network video after initialization',
              'EXERCISE_DETAILS',
              e,
            );
          }
        }
      }).catchError((error) {
        TalkerService.error(
          'Network video initialization failed',
          'EXERCISE_DETAILS',
          error,
        );
        if (mounted) {
          _initializeLocalVideo();
        }
      });
    } catch (e, stackTrace) {
      TalkerService.error(
        'Network video setup failed',
        'EXERCISE_DETAILS',
        e,
        stackTrace,
      );
      _initializeLocalVideo();
    }
  }

  void _initializeVideoPlayer() {
    try {
      final isOnline = ConnectivityChecker.isOnline;

      if (isOnline == null) {
        TalkerService.warning(
          'Connectivity status unknown, attempting network video',
          'EXERCISE_DETAILS',
        );
      }

      if (isOnline == true || isOnline == null) {
        _initializeNetworkVideo();
      } else {
        _initializeLocalVideo();
      }
    } catch (e, stackTrace) {
      TalkerService.error(
        'Exception in video initialization',
        'EXERCISE_DETAILS',
        e,
        stackTrace,
      );
      if (mounted) {
        setState(() {
          _hasVideoError = true;
          _videoErrorMessage = 'Failed to initialize video';
        });
      }
    }
  }

  /// Called when sets are saved and fresh data is fetched
  void _onWorkoutItemUpdated(WorkoutItemModel updatedItem) {
    setState(() {
      _workoutItem = updatedItem;
    });
  }
}

class _ExerciseTitle extends StatelessWidget {
  final String name;

  const _ExerciseTitle({required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkSecondary.withOpacity(0.3)
              : AppColors.primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.darkSecondary.withOpacity(0.2)
                : AppColors.primaryColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        AppColors.darkSecondary,
                        AppColors.darkPrimary,
                      ]
                    : [
                        AppColors.primaryColor,
                        AppColors.red,
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseVideoPlayer extends StatelessWidget {
  final CachedVideoPlayerPlus? player;
  final bool isInitialized;
  final bool hasError;
  final String? errorMessage;

  const _ExerciseVideoPlayer({
    required this.player,
    required this.isInitialized,
    required this.hasError,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 280,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkSecondary.withOpacity(0.3)
              : AppColors.primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.darkSecondary.withOpacity(0.2)
                : AppColors.primaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _buildVideoContent(),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (hasError) {
      return _VideoErrorWidget(errorMessage: errorMessage);
    }

    if (!isInitialized || player == null || !player!.isInitialized) {
      return const Center(child: CustomLoadingWidget());
    }

    try {
      final controller = player!.controller;
      final aspectRatio = controller.value.aspectRatio;

      return AspectRatio(
        aspectRatio: aspectRatio,
        child: VideoPlayer(controller),
      );
    } catch (e) {
      return const Center(child: CustomLoadingWidget());
    }
  }
}

class _ImageErrorWidget extends StatelessWidget {
  final String imageUrl;

  const _ImageErrorWidget({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    TalkerService.warning(
      'Failed to load targeted muscles image from network: $imageUrl',
      'EXERCISE_DETAILS',
    );

    final file = File(imageUrl);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: 200,
        errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(),
      );
    }

    return const _ImagePlaceholder();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1a1a2e).withOpacity(0.5)
            : const Color(0xFFf5f7fa),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_rounded,
              size: 48,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Image not available',
              style: TextStyle(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Smart progress indicator showing weight change feedback.
/// Displays subtle visual hints based on progress direction.
class _ProgressIndicator extends StatelessWidget {
  final num? weightChange;
  final num? previousMaxWeight;

  const _ProgressIndicator({
    required this.weightChange,
    required this.previousMaxWeight,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show indicator if no weight change data
    if (weightChange == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine indicator properties based on weight change
    final Color backgroundColor;
    final Color iconColor;
    final IconData icon;

    if (weightChange! > 0) {
      // Positive progress - green accent
      backgroundColor = Colors.green.withOpacity(0.15);
      iconColor = Colors.green;
      icon = Icons.trending_up_rounded;
    } else if (weightChange! < 0) {
      // Regression - soft neutral (not punishing)
      backgroundColor = isDark
          ? Colors.orange.withOpacity(0.12)
          : Colors.orange.withOpacity(0.1);
      iconColor = Colors.orange.shade400;
      icon = Icons.trending_down_rounded;
    } else {
      // No change - neutral gray
      backgroundColor = isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.grey.withOpacity(0.12);
      iconColor = isDark ? Colors.white54 : Colors.grey;
      icon = Icons.trending_flat_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
          if (weightChange != 0) ...[
            const SizedBox(width: 4),
            Text(
              '${weightChange! > 0 ? '+' : ''}${weightChange!.toStringAsFixed(weightChange!.truncateToDouble() == weightChange ? 0 : 1)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TargetedMusclesSection extends ConsumerWidget {
  final String imageUrl;

  const _TargetedMusclesSection({required this.imageUrl});

  bool get _isNetworkUrl {
    return imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appSettings = ref.watch(appSettingsProvider.notifier);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkSecondary.withOpacity(0.3)
              : AppColors.primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.darkSecondary.withOpacity(0.15)
                : AppColors.primaryColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppColors.darkSecondary,
                            AppColors.darkPrimary,
                          ]
                        : [
                            AppColors.primaryColor,
                            AppColors.red,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.accessibility_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.targetedMuscles,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: appSettings.fontFamily(),
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF121212).withOpacity(0.5)
                  : const Color(0xFFf5f5f5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _isNetworkUrl
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      fadeInDuration: const Duration(milliseconds: 200),
                      placeholder: (context, url) => const SizedBox(
                        height: 200,
                        child: Center(child: CustomLoadingWidget()),
                      ),
                      errorWidget: (context, url, error) =>
                          _ImageErrorWidget(imageUrl: imageUrl),
                    )
                  : Image.file(
                      File(imageUrl),
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const _ImagePlaceholder(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoErrorWidget extends StatelessWidget {
  final String? errorMessage;

  const _VideoErrorWidget({this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF2a2a3e) : const Color(0xFFfef2f2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.videocam_off_rounded,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Video Unavailable',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Collapsible section displaying workout sets for logging.
/// Only shown when navigating from a workout context.
class _WorkoutLoggingSection extends ConsumerStatefulWidget {
  final WorkoutItemModel workoutItem;
  final int? workoutSetId;
  final void Function(WorkoutItemModel updatedItem)? onWorkoutItemUpdated;

  const _WorkoutLoggingSection({
    required this.workoutItem,
    this.workoutSetId,
    this.onWorkoutItemUpdated,
  });

  @override
  ConsumerState<_WorkoutLoggingSection> createState() =>
      _WorkoutLoggingSectionState();
}

class _WorkoutLoggingSectionState
    extends ConsumerState<_WorkoutLoggingSection> {
  static const int _maxSets = 5;

  bool _isExpanded = true;
  bool _isLoading = false;
  late List<_EditableSet> _editableSets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appSettings = ref.watch(appSettingsProvider.notifier);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkSecondary.withOpacity(0.3)
              : AppColors.primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.darkSecondary.withOpacity(0.2)
                : AppColors.primaryColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with collapse toggle
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.darkSecondary, AppColors.darkPrimary]
                            : [AppColors.primaryColor, AppColors.red],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.format_list_numbered_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.workoutSets,
                          style: TextStyle(
                            fontFamily: appSettings.fontFamily(),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_editableSets.length} ${_editableSets.length == 1 ? 'set' : 'sets'}',
                          style: TextStyle(
                            fontFamily: appSettings.fontFamily(),
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress indicator
                  if (widget.workoutItem.weightChange != null)
                    _ProgressIndicator(
                      weightChange: widget.workoutItem.weightChange,
                      previousMaxWeight: widget.workoutItem.previousMaxWeight,
                    ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isDark ? Colors.white70 : Colors.black54,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Collapsible content
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildSetsContent(isDark, appSettings),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final set in _editableSets) {
      set.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeEditableSets();
  }

  void _addSet() {
    if (_editableSets.length >= _maxSets) return;

    // Default values for new set
    final lastSet = _editableSets.isNotEmpty ? _editableSets.last : null;
    final defaultReps = lastSet != null
        ? (int.tryParse(lastSet.repsController.text) ?? 10)
        : 10;
    final defaultWeight = lastSet != null
        ? (double.tryParse(lastSet.weightController.text) ?? 0.0)
        : 0.0;

    setState(() {
      _editableSets.add(_EditableSet(
        setNumber: _editableSets.length + 1,
        reps: defaultReps,
        weight: defaultWeight,
      ));
    });
  }

  Widget _buildSetsContent(bool isDark, dynamic appSettings) {
    return Column(
      children: [
        Divider(
          height: 1,
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
        if (_editableSets.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                context.l10n.noSetsRecorded,
                style: TextStyle(
                  fontFamily: appSettings.fontFamily(),
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _editableSets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final set = _editableSets[index];
              return _EditableSetRow(
                setNumber: index + 1,
                repsController: set.repsController,
                weightController: set.weightController,
                equipmentType: widget.workoutItem.exercise.equipmentType,
                onDelete: () => _confirmDeleteSet(index),
              );
            },
          ),
        // Add Set Button
        if (_editableSets.length < _maxSets)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: _addSet,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(context.l10n.addSet),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    isDark ? AppColors.darkSecondary : AppColors.primaryColor,
                side: BorderSide(
                  color: isDark
                      ? AppColors.darkSecondary.withOpacity(0.5)
                      : AppColors.primaryColor.withOpacity(0.5),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              context.l10n.maxSetsReached,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ),
        // Save Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: CustomBTN(
            widget: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.saveSets,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
            width: double.infinity,
            padding: 14,
            radius: 12,
            color: AppColors.primaryColor,
            press: _isLoading ? null : _saveSets,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteSet(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            context.l10n.deleteSet,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            context.l10n.confirmDeleteSet,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                context.l10n.cancel,
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                context.l10n.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        _editableSets[index].dispose();
        _editableSets.removeAt(index);
        // Update set numbers
        for (int i = 0; i < _editableSets.length; i++) {
          _editableSets[i].setNumber = i + 1;
        }
      });
    }
  }

  void _initializeEditableSets() {
    final sets = widget.workoutItem.sets ?? [];
    _editableSets = sets.asMap().entries.map((entry) {
      final index = entry.key;
      final set = entry.value;
      return _EditableSet(
        id: set.id,
        setNumber: index + 1,
        reps: set.reps,
        weight: set.weight,
      );
    }).toList();
  }

  /// Refreshes the editable sets with fresh data from the server.
  void _refreshEditableSets(WorkoutItemModel updatedItem) {
    // Dispose old controllers
    for (final set in _editableSets) {
      set.dispose();
    }

    // Create new editable sets from updated data
    final sets = updatedItem.sets ?? [];
    _editableSets = sets.asMap().entries.map((entry) {
      final index = entry.key;
      final set = entry.value;
      return _EditableSet(
        id: set.id,
        setNumber: index + 1,
        reps: set.reps,
        weight: set.weight,
      );
    }).toList();

    setState(() {});
  }

  Future<void> _saveSets() async {
    if (widget.workoutSetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.errorUpdatingSets),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final setsData = _editableSets
          .asMap()
          .entries
          .map((entry) => {
                'set_number': entry.key + 1,
                'reps': int.tryParse(entry.value.repsController.text) ?? 0,
                'weight':
                    double.tryParse(entry.value.weightController.text) ?? 0.0,
              })
          .toList();

      // Use provider to update sets (handles online/offline automatically)
      final updatedItem =
          await ref.read(workoutsProvider.notifier).updateExerciseSets(
                workoutSetId: widget.workoutSetId,
                exerciseId: widget.workoutItem.exercise.id,
                sets: setsData,
              );

      if (mounted) {
        if (updatedItem != null) {
          // Notify parent of updated data
          widget.onWorkoutItemUpdated?.call(updatedItem);

          // Update local editable sets with fresh data from server
          _refreshEditableSets(updatedItem);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.setsUpdated),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Check if we're offline - still show success for queued operations
          if (!ConnectivityChecker.isOnline!) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.setsUpdatedOffline),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.errorUpdatingSets),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      TalkerService.error('Error saving sets', 'EXERCISE_DETAILS', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.errorUpdatingSets),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
