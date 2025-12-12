import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'talker_service.dart';

/// Service for cropping images before OCR processing.
///
/// Provides a user-friendly cropping interface to isolate
/// nutrition labels and improve OCR accuracy by removing noise.
class ImageCropperService {
  /// Shows a crop screen and returns the cropped image file.
  ///
  /// Returns the cropped image file, or null if the user cancels.
  Future<File?> cropImage({
    required String imagePath,
    required BuildContext context,
  }) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Nutrition Label',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Nutrition Label',
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(
              width: 520,
              height: 520,
            ),
          ),
        ],
      );

      if (croppedFile != null) {
        final file = File(croppedFile.path);
        TalkerService.info(
          'Image cropped successfully: ${file.path}',
          'CROPPER',
        );
        return file;
      }

      TalkerService.debug('Image cropping cancelled by user', 'CROPPER');
      return null;
    } catch (e, stackTrace) {
      TalkerService.error('Image cropping failed', 'CROPPER', e, stackTrace);
      return null;
    }
  }
}
