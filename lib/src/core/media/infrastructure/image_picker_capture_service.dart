import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/image_capture_failure.dart';
import '../domain/image_capture_service.dart';
import '../domain/local_image.dart';

class ImagePickerCaptureService implements ImageCaptureService {
  ImagePickerCaptureService({
    ImagePicker? imagePicker,
  }) : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<LocalImage?> captureImageFromCamera() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        requestFullMetadata: false,
      );

      if (image == null) {
        return null;
      }

      return _persistImage(image);
    } on PlatformException catch (error) {
      throw ImageCaptureException(_failureFromPlatformException(error));
    } on FileSystemException {
      throw const ImageCaptureException(
        ImageCaptureFailure(
          type: ImageCaptureFailureType.fileSystem,
          title: 'Image storage failed',
          message: 'The photo could not be saved on this device.',
        ),
      );
    } catch (_) {
      throw const ImageCaptureException(
        ImageCaptureFailure(
          type: ImageCaptureFailureType.unknown,
          title: 'Camera capture failed',
          message: 'The camera could not return a photo. Try again.',
        ),
      );
    }
  }

  @override
  Future<List<LocalImage>> recoverLostImages() async {
    try {
      final response = await _imagePicker.retrieveLostData();
      if (response.isEmpty) {
        return const [];
      }

      final files = response.files ??
          [
            if (response.file != null) response.file!,
          ];

      if (files.isEmpty) {
        final exception = response.exception;
        if (exception != null) {
          throw ImageCaptureException(
            _failureFromPlatformException(exception),
          );
        }
        return const [];
      }

      final recoveredImages = <LocalImage>[];
      for (final file in files) {
        recoveredImages.add(await _persistImage(file));
      }

      return recoveredImages;
    } on ImageCaptureException {
      rethrow;
    } catch (_) {
      throw const ImageCaptureException(
        ImageCaptureFailure(
          type: ImageCaptureFailureType.unknown,
          title: 'Image recovery failed',
          message: 'A previously captured photo could not be restored.',
        ),
      );
    }
  }

  @override
  Future<void> deleteImageFile(LocalImage image) async {
    final file = File(image.path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<LocalImage> _persistImage(XFile source) async {
    final capturedAt = DateTime.now();
    final directory = await _imageDirectory();
    final id = 'survey_${capturedAt.microsecondsSinceEpoch}';
    final path = '${directory.path}${Platform.pathSeparator}$id.jpg';

    await source.saveTo(path);

    return LocalImage(
      id: id,
      path: path,
      capturedAt: capturedAt,
    );
  }

  Future<Directory> _imageDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final imageDirectory = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}survey_images',
    );

    if (!await imageDirectory.exists()) {
      await imageDirectory.create(recursive: true);
    }

    return imageDirectory;
  }

  ImageCaptureFailure _failureFromPlatformException(PlatformException error) {
    final code = error.code.toLowerCase();

    if (code.contains('permission') ||
        code.contains('denied') ||
        code.contains('restricted')) {
      return const ImageCaptureFailure(
        type: ImageCaptureFailureType.permissionDenied,
        title: 'Camera permission needed',
        message: 'Allow camera access to capture survey photos.',
      );
    }

    if (code.contains('camera') || code.contains('unavailable')) {
      return const ImageCaptureFailure(
        type: ImageCaptureFailureType.cameraUnavailable,
        title: 'Camera unavailable',
        message: 'The camera is not available on this device right now.',
      );
    }

    return const ImageCaptureFailure(
      type: ImageCaptureFailureType.unknown,
      title: 'Camera capture failed',
      message: 'The camera could not return a photo. Try again.',
    );
  }
}
