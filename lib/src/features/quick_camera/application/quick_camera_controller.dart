import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/location/domain/location_failure.dart';
import '../../../core/location/domain/location_service.dart';
import '../../../core/media/domain/image_capture_failure.dart';
import '../../../core/media/domain/image_capture_service.dart';
import '../data/quick_camera_processing_service.dart';
import '../domain/quick_camera_failure.dart';
import '../domain/quick_camera_result.dart';
import '../domain/quick_camera_settings.dart';

enum QuickCameraStatus {
  idle,
  capturing,
  processing,
  success,
  failure,
}

class QuickCameraState {
  const QuickCameraState({
    required this.status,
    this.lastResult,
    this.failure,
  });

  const QuickCameraState.idle()
      : status = QuickCameraStatus.idle,
        lastResult = null,
        failure = null;

  final QuickCameraStatus status;
  final QuickCameraResult? lastResult;
  final QuickCameraFailure? failure;

  bool get isBusy =>
      status == QuickCameraStatus.capturing ||
      status == QuickCameraStatus.processing;
}

class QuickCameraController extends ChangeNotifier {
  QuickCameraController({
    required LocationService locationService,
    required ImageCaptureService imageCaptureService,
    required QuickCameraProcessingService processingService,
  })  : _locationService = locationService,
        _imageCaptureService = imageCaptureService,
        _processingService = processingService;

  final LocationService _locationService;
  final ImageCaptureService _imageCaptureService;
  final QuickCameraProcessingService _processingService;

  QuickCameraState _state = const QuickCameraState.idle();
  bool _isDisposed = false;

  QuickCameraState get state => _state;

  Future<void> capture({
    required QuickCameraSettings settings,
    required Future<String?> Function() requestChainage,
  }) async {
    if (_state.isBusy) {
      return;
    }

    _setState(const QuickCameraState(status: QuickCameraStatus.capturing));

    try {
      final location = await _locationService.captureCurrentLocation();
      final rawImage = await _imageCaptureService.captureImageFromCamera();
      if (rawImage == null) {
        _setState(const QuickCameraState.idle());
        return;
      }

      String? chainage;
      if (settings.shouldPromptChainage) {
        chainage = await requestChainage();
      }

      _setState(
        QuickCameraState(
          status: QuickCameraStatus.processing,
          lastResult: _state.lastResult,
        ),
      );

      final result = await _processingService.processCapture(
        rawImage: rawImage,
        location: location,
        settings: settings,
        chainage: chainage,
      );
      await _imageCaptureService.deleteImageFile(rawImage);

      _setState(
        QuickCameraState(
          status: QuickCameraStatus.success,
          lastResult: result,
        ),
      );
    } on LocationCaptureException catch (error) {
      _setFailure(
        QuickCameraFailure(
          type: QuickCameraFailureType.location,
          title: error.failure.title,
          message: error.failure.message,
        ),
      );
    } on ImageCaptureException catch (error) {
      _setFailure(
        QuickCameraFailure(
          type: QuickCameraFailureType.camera,
          title: error.failure.title,
          message: error.failure.message,
        ),
      );
    } on QuickCameraException catch (error) {
      _setFailure(error.failure);
    } catch (_) {
      _setFailure(
        const QuickCameraFailure(
          type: QuickCameraFailureType.unknown,
          title: 'Capture failed',
          message: 'The photo could not be saved. Try again.',
        ),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _setFailure(QuickCameraFailure failure) {
    _setState(
      QuickCameraState(
        status: QuickCameraStatus.failure,
        lastResult: _state.lastResult,
        failure: failure,
      ),
    );
  }

  void _setState(QuickCameraState value) {
    if (_isDisposed) {
      return;
    }

    _state = value;
    notifyListeners();
  }
}
