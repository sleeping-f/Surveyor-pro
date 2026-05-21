import 'local_image.dart';

abstract interface class ImageCaptureService {
  Future<LocalImage?> captureImageFromCamera();

  Future<List<LocalImage>> recoverLostImages();

  Future<void> deleteImageFile(LocalImage image);
}
