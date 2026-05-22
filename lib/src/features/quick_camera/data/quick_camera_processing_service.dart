import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/location/domain/captured_location.dart';
import '../../../core/media/domain/gallery_save_service.dart';
import '../../../core/media/domain/local_image.dart';
import '../../../core/media/infrastructure/method_channel_gallery_save_service.dart';
import '../../../core/utils/app_formatters.dart';
import '../domain/quick_camera_failure.dart';
import '../domain/quick_camera_result.dart';
import '../domain/quick_camera_settings.dart';

class QuickCameraProcessingService {
  QuickCameraProcessingService({
    GallerySaveService? gallerySaveService,
  }) : _gallerySaveService =
            gallerySaveService ?? MethodChannelGallerySaveService();

  final GallerySaveService _gallerySaveService;

  Future<QuickCameraResult> processCapture({
    required LocalImage rawImage,
    required CapturedLocation location,
    required QuickCameraSettings settings,
    String? chainage,
  }) async {
    final sanitizedChainage = _sanitizeChainage(chainage);
    final capturedAt = rawImage.capturedAt;
    final fileName = _buildFileName(
      capturedAt: capturedAt,
      location: location,
      chainage: sanitizedChainage,
      settings: settings,
    );

    try {
      final directory = await getApplicationDocumentsDirectory();
      final captureDirectory = Directory(
        p.join(directory.path, 'camera_captures'),
      );
      if (!await captureDirectory.exists()) {
        await captureDirectory.create(recursive: true);
      }

      final outputPath = p.join(captureDirectory.path, fileName);
      await _applyWatermark(
        sourcePath: rawImage.path,
        destinationPath: outputPath,
        location: location,
        chainage: sanitizedChainage,
        settings: settings,
      );

      final hasPermission = await _requestSavePermission();
      try {
        await _gallerySaveService.saveImage(
          filePath: outputPath,
          fileName: fileName,
        );
      } on GallerySaveException catch (error) {
        throw QuickCameraException(
          QuickCameraFailure(
            type: hasPermission
                ? QuickCameraFailureType.processing
                : QuickCameraFailureType.permission,
            title: 'Gallery save failed',
            message: error.message.isEmpty
                ? 'The photo could not be saved to the gallery.'
                : error.message,
          ),
        );
      }

      return QuickCameraResult(
        filePath: outputPath,
        capturedAt: capturedAt,
        location: location,
        chainage: sanitizedChainage,
      );
    } on QuickCameraException {
      rethrow;
    } on FileSystemException catch (error) {
      throw QuickCameraException(
        QuickCameraFailure(
          type: QuickCameraFailureType.processing,
          title: 'Image processing failed',
          message: error.message,
        ),
      );
    } catch (_) {
      throw const QuickCameraException(
        QuickCameraFailure(
          type: QuickCameraFailureType.unknown,
          title: 'Capture failed',
          message: 'The watermarked photo could not be saved.',
        ),
      );
    }
  }

  String _buildFileName({
    required DateTime capturedAt,
    required CapturedLocation location,
    required QuickCameraSettings settings,
    String? chainage,
  }) {
    final latitude = location.latitude.toStringAsFixed(5);
    final longitude = location.longitude.toStringAsFixed(5);
    final timestamp = AppFormatters.readableFileTimestamp(capturedAt);
    final buffer = StringBuffer()
      ..write('survey_')
      ..write(timestamp)
      ..write('_lat')
      ..write(latitude)
      ..write('_lon')
      ..write(longitude);

    if (settings.includeChainage &&
        settings.chainageInFileName &&
        chainage != null &&
        chainage.isNotEmpty) {
      buffer.write('_ch');
      buffer.write(chainage);
    }

    buffer.write('.jpg');
    return buffer.toString();
  }

  Future<void> _applyWatermark({
    required String sourcePath,
    required String destinationPath,
    required CapturedLocation location,
    required QuickCameraSettings settings,
    String? chainage,
  }) async {
    final bytes = await File(sourcePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const QuickCameraException(
        QuickCameraFailure(
          type: QuickCameraFailureType.processing,
          title: 'Image decode failed',
          message: 'The captured photo could not be processed.',
        ),
      );
    }

    final image = img.bakeOrientation(decoded);
    final font = img.arial24;
    final textLines = <String>[
      'Lat: ${location.latitude.toStringAsFixed(6)}',
      'Lon: ${location.longitude.toStringAsFixed(6)}',
      if (settings.includeChainage &&
          settings.chainageInWatermark &&
          chainage != null &&
          chainage.isNotEmpty)
        'Chainage: $chainage',
    ];

    final padding = 16;
    final lineHeight = font.lineHeight + 4;
    final textHeight = textLines.length * lineHeight + padding * 2;
    final startY = image.height - textHeight;
    final safeStartY = startY < 0 ? 0 : startY;

    img.fillRect(
      image,
      x1: 0,
      y1: safeStartY,
      x2: image.width,
      y2: image.height,
      color: img.ColorRgba8(0, 0, 0, 160),
    );

    var currentY = safeStartY + padding;
    for (final line in textLines) {
      img.drawString(
        image,
        line,
        font: font,
        x: padding,
        y: currentY,
        color: img.ColorRgba8(255, 255, 255, 255),
      );
      currentY += lineHeight;
    }

    final encoded = img.encodeJpg(image, quality: 92);
    await File(destinationPath).writeAsBytes(encoded, flush: true);
  }

  Future<bool> _requestSavePermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.request();
      return status.isGranted || status.isLimited;
    }

    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }
      final photosStatus = await Permission.photos.request();
      return photosStatus.isGranted || photosStatus.isLimited;
    }

    return true;
  }

  String? _sanitizeChainage(String? chainage) {
    final trimmed = chainage?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll('+', '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '');
  }
}
