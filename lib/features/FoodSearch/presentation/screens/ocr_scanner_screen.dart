import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/services/image_cropper_service.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/nutrition_facts.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/ocr_scanner_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/scanning_overlay_painter.dart';
import 'package:camera/camera.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Screen for scanning nutrition labels using OCR.
class OcrScannerScreen extends ConsumerStatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  ConsumerState<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

/// Action button for gallery/manual options.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 28),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
              ),
        ),
      ],
    );
  }
}

/// Camera preview widget with proper aspect ratio handling.
class _CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;

  const _CameraPreviewWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized and not disposed before accessing
    if (!controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Double-check controller is still valid during build
        if (!controller.value.isInitialized) {
          return const SizedBox.shrink();
        }

        final size = constraints.biggest;
        final cameraAspectRatio = controller.value.aspectRatio;
        var scale = size.aspectRatio * cameraAspectRatio;

        if (scale < 1) scale = 1 / scale;

        return ClipRect(
          child: Transform.scale(
            scale: scale,
            child: Center(child: CameraPreview(controller)),
          ),
        );
      },
    );
  }
}

/// Main capture button with loading state.
class _CaptureButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _CaptureButton({
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLoading ? Colors.grey : Colors.white,
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.camera_alt, size: 32, color: Colors.black),
        ),
      ),
    );
  }
}

class _OcrScannerScreenState extends ConsumerState<OcrScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isTorchOn = false;
  String? _initError;
  bool _hasHandledSuccess = false;

  final ImagePicker _imagePicker = ImagePicker();
  final ImageCropperService _imageCropper = ImageCropperService();
  late ConfettiController _confettiController;

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(ocrScannerProvider);
    final theme = Theme.of(context);
    final isLoading = scanState is OcrScanLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          context.l10n.scanNutritionLabel,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          if (_isInitialized)
            IconButton(
              icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
              onPressed: _toggleTorch,
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          _buildCameraPreview(),

          // Animated scanning overlay (replaces old static overlay)
          ScanningOverlay(
            isScanning: !isLoading,
            accentColor: Theme.of(context).colorScheme.primary,
          ),

          // Instructions
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 0,
            right: 0,
            child: Center(
              child: ScannerInstructions(
                  text: 'positionNutritionLabel'.tr(context)),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(context, theme, scanState),
          ),

          // Loading overlay
          if (isLoading) _buildLoadingOverlay(context, scanState),

          // Error dialog
          if (scanState is OcrScanError)
            _buildErrorOverlay(context, theme, scanState),

          // Success - auto return with confetti
          if (scanState is OcrScanSuccess)
            _handleSuccess(context, scanState.facts),

          // Confetti overlay
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.orange,
                Colors.purple,
                Colors.pink,
              ],
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    // Reset OCR state when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ocrScannerProvider.notifier).reset();
    });
    _initializeCamera();
  }

  Widget _buildBottomControls(
    BuildContext context,
    ThemeData theme,
    OcrScanState state,
  ) {
    final isLoading = state is OcrScanLoading;

    return Container(
      padding: EdgeInsets.all(context.largeSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.captureAndCropInstructions,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.largeSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.photo_library,
                  label: 'gallery'.tr(context),
                  onPressed: isLoading ? null : _pickFromGallery,
                ),
                _CaptureButton(
                  onPressed:
                      (isLoading || !_isInitialized) ? null : _captureImage,
                  isLoading: isLoading,
                ),
                _ActionButton(
                  icon: Icons.edit,
                  label: 'manual'.tr(context),
                  onPressed: isLoading ? null : () => context.pop(null),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_initError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              _initError!,
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    // Check if camera is properly initialized and not disposed
    if (!_isInitialized ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return _CameraPreviewWidget(controller: _cameraController!);
  }

  Widget _buildErrorOverlay(
    BuildContext context,
    ThemeData theme,
    OcrScanError error,
  ) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(context.extraLargeSpacing),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(context.largeSpacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(height: context.mediumSpacing),
                  Text(
                    'ocrFailed'.tr(context),
                    style: theme.textTheme.titleLarge,
                  ),
                  SizedBox(height: context.smallSpacing),
                  Text(
                    error.message,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.largeSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (error.canRetry)
                        OutlinedButton.icon(
                          onPressed: () {
                            ref.read(ocrScannerProvider.notifier).reset();
                            _hasHandledSuccess = false;
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text('retake'.tr(context)),
                        ),
                      ElevatedButton.icon(
                        onPressed: () => context.pop(null),
                        icon: const Icon(Icons.edit),
                        label: Text('manualEntry'.tr(context)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context, OcrScanState state) {
    final message = state is OcrScanLoading ? state.message : 'Processing...';

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            SizedBox(height: context.mediumSpacing),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      HapticFeedback.mediumImpact();
      final XFile image = await _cameraController!.takePicture();

      // Allow user to crop the image for better OCR accuracy
      if (!mounted) return;
      final croppedImage = await _imageCropper.cropImage(
        imagePath: image.path,
        context: context,
      );

      if (croppedImage != null) {
        await ref
            .read(ocrScannerProvider.notifier)
            .processImage(croppedImage.path);
      } else {
        TalkerService.debug('Image cropping cancelled', 'OCR');
      }
    } catch (e) {
      TalkerService.error('Failed to capture image', 'OCR', e);
    }
  }

  Widget _handleSuccess(BuildContext context, NutritionFacts facts) {
    // Only handle success once to prevent multiple pops
    if (!_hasHandledSuccess) {
      _hasHandledSuccess = true;
      debugPrint(
          'OCR Success: Handling success with ${facts.populatedFieldCount} fields');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        HapticFeedback.heavyImpact();
        _confettiController.play();

        // Delay pop to show confetti - facts are already in provider
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            debugPrint('OCR Success: Popping - facts are in provider');
            context.pop(); // No need to pass facts, they're in provider
          }
        });
      });
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(height: context.mediumSpacing),
            Text(
              'scanComplete'.tr(context),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${facts.populatedFieldCount} fields detected',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (!mounted) return;

      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _initError = 'No cameras available';
        });
        return;
      }

      // Use back camera
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      TalkerService.error('Camera initialization failed', 'OCR', e);
      if (mounted) {
        setState(() {
          _initError = 'Failed to initialize camera';
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      HapticFeedback.mediumImpact();

      // Allow user to crop the image for better OCR accuracy
      if (!mounted) return;
      final croppedImage = await _imageCropper.cropImage(
        imagePath: image.path,
        context: context,
      );

      if (croppedImage != null) {
        await ref
            .read(ocrScannerProvider.notifier)
            .processImage(croppedImage.path);
      } else {
        TalkerService.debug('Image cropping cancelled', 'OCR');
      }
    }
  }

  Future<void> _toggleTorch() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      _isTorchOn = !_isTorchOn;
      await _cameraController!.setFlashMode(
        _isTorchOn ? FlashMode.torch : FlashMode.off,
      );
      if (mounted) setState(() {});
    } catch (e) {
      TalkerService.warning('Torch not available', 'OCR');
    }
  }
}
