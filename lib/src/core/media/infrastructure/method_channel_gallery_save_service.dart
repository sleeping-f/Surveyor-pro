import 'package:flutter/services.dart';

import '../domain/gallery_save_service.dart';

class GallerySaveException implements Exception {
  const GallerySaveException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MethodChannelGallerySaveService implements GallerySaveService {
  MethodChannelGallerySaveService({
    MethodChannel? channel,
  }) : _channel = channel ?? const MethodChannel(_channelName);

  static const String _channelName = 'surveyor_pro/gallery';

  final MethodChannel _channel;

  @override
  Future<String> saveImage({
    required String filePath,
    required String fileName,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'saveImage',
        {
          'filePath': filePath,
          'fileName': fileName,
        },
      );
      if (result == null || result.isEmpty) {
        throw const GallerySaveException('Gallery save failed.');
      }
      return result;
    } on PlatformException catch (error) {
      throw GallerySaveException(error.message ?? 'Gallery save failed.');
    }
  }
}
