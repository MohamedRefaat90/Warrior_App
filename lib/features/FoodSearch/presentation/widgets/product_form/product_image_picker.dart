import 'dart:io';

import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/product_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Image picker section with preview and fullscreen view.
class ProductImagePicker extends ConsumerWidget {
  final ValueChanged<String?> onImageChanged;

  const ProductImagePicker({
    super.key,
    required this.onImageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productForm = ref.watch(productFormProvider);
    TalkerService.info(
        'productForm.imagePath image path: ${productForm.imagePath}', 'FORM');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.productImage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (productForm.imagePath != null) ...[
              _ImagePreview(
                imagePath: productForm.imagePath!,
                onRemove: () => onImageChanged(null),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: () => _pickImage(context),
              icon: const Icon(Icons.camera_alt),
              label: Text(productForm.imagePath != null
                  ? context.l10n.changeImage
                  : context.l10n.takePhoto),
            ),
            SizedBox(height: context.smallSpacing),
            Text(
              context.l10n.imageTip,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      onImageChanged(image.path);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// Full screen image view with Hero animation and interactive gestures.
class _FullScreenImageView extends StatefulWidget {
  final String imagePath;
  final String heroTag;

  const _FullScreenImageView({
    required this.imagePath,
    required this.heroTag,
  });

  @override
  State<_FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<_FullScreenImageView> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Interactive image viewer with zoom/pan
            InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Hero(
                  tag: widget.heroTag,
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image_rounded,
                        size: 64,
                        color: Colors.white54,
                      );
                    },
                  ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(24),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            // Reset zoom button
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              right: 16,
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(24),
                child: Tooltip(
                  message: context.l10n.resetZoomToOriginalSize,
                  child: InkWell(
                    onTap: () {
                      _transformationController.value = Matrix4.identity();
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.fit_screen_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}

class _ImagePreview extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRemove;

  const _ImagePreview({
    required this.imagePath,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context),
      child: Hero(
        tag: 'product_image_$imagePath',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.file(
                File(imagePath),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_rounded,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.imageLoadError,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Fullscreen button - top left
              Positioned(
                top: 8,
                left: 8,
                child: _ActionButton(
                  icon: Icons.fullscreen_rounded,
                  onTap: () => _showFullScreenImage(context),
                ),
              ),
              // Close button - top right
              Positioned(
                top: 8,
                right: 8,
                child: _ActionButton(
                  icon: Icons.close,
                  onTap: onRemove,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenImageView(
            imagePath: imagePath,
            heroTag: 'product_image_$imagePath',
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
