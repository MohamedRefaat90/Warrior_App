import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/services/image_cropper_service.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/nutrition_facts.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/ocr_scanner_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/ocr_scanner/ocr_bottom_controls.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/ocr_scanner/ocr_camera_preview.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/ocr_scanner/ocr_error_overlay.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/ocr_scanner/ocr_loading_overlay.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/ocr_scanner/ocr_success_overlay.dart';
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
    final isLoading = scanState is OcrScanLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          context.l10n.scanNutritionLabel,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
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
          OcrCameraPreview(
            controller: _cameraController,
            isInitialized: _isInitialized,
            initError: _initError,
          ),

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
                    text: context.l10n.positionNutritionLabel)),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: OcrBottomControls(
              isLoading: isLoading,
              isInitialized: _isInitialized,
              onGalleryPressed: _pickFromGallery,
              onCapturePressed: _captureImage,
            ),
          ),

          // Loading overlay
          if (isLoading) OcrLoadingOverlay(state: scanState),

          // Error dialog
          if (scanState is OcrScanError)
            OcrErrorOverlay(
              error: scanState,
              onRetry: () {
                ref.read(ocrScannerProvider.notifier).reset();
                _hasHandledSuccess = false;
              },
            ),

          // Success - auto return with confetti
          if (scanState is OcrScanSuccess)
            _buildSuccessOverlay(context, scanState.facts),

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

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.inactive) {
  //     TalkerService.info(
  //         'OCR Scanner Screen: App lifecycle state changed to inactive', 'OCR');
  //     // Dispose and nullify controller to prevent usage while inactive
  //     _cameraController?.dispose();
  //     if (mounted) {
  //       setState(() {
  //         _cameraController = null;
  //         _isInitialized = false;
  //       });
  //     }
  //   } else if (state == AppLifecycleState.resumed) {
  //     TalkerService.info(
  //         'OCR Scanner Screen: App lifecycle state changed to resumed', 'OCR');
  //     _initializeCamera();
  //   }
  // }

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
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    // Reset OCR state when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ocrScannerProvider.notifier).reset();
    });
    _initializeCamera();
  }

  Widget _buildSuccessOverlay(BuildContext context, NutritionFacts facts) {
    // Only handle success once to prevent multiple pops
    if (!_hasHandledSuccess) {
      _hasHandledSuccess = true;
      TalkerService.debug(
          'OCR Success: Handling success with ${facts.populatedFieldCount} fields',
          'OCR');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        HapticFeedback.heavyImpact();
        _confettiController.play();

        // Delay pop to show confetti - facts are already in provider
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            TalkerService.debug(
                'OCR Success: Popping - facts are in provider', 'OCR');
            context.pop(); // No need to pass facts, they're in provider
          }
        });
      });
    }

    return OcrSuccessOverlay(facts: facts);
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

  Future<void> _initializeCamera() async {
    try {
      _isTorchOn = false; // Reset torch state on initialization
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
        ResolutionPreset.ultraHigh,
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
