import 'package:flutter/foundation.dart';

import '../../../core/location/domain/captured_location.dart';
import '../../../core/location/domain/location_failure.dart';
import '../../../core/location/domain/location_service.dart';

enum GpsCaptureStatus {
  idle,
  loading,
  success,
  failure,
}

class GpsCaptureState {
  const GpsCaptureState({
    required this.status,
    this.location,
    this.failure,
  });

  const GpsCaptureState.idle()
      : status = GpsCaptureStatus.idle,
        location = null,
        failure = null;

  final GpsCaptureStatus status;
  final CapturedLocation? location;
  final LocationFailure? failure;

  bool get isLoading => status == GpsCaptureStatus.loading;

  GpsCaptureState copyWith({
    required GpsCaptureStatus status,
    CapturedLocation? location,
    LocationFailure? failure,
  }) {
    return GpsCaptureState(
      status: status,
      location: location,
      failure: failure,
    );
  }
}

class GpsCaptureController extends ChangeNotifier {
  GpsCaptureController({
    required LocationService locationService,
  }) : _locationService = locationService;

  final LocationService _locationService;

  GpsCaptureState _state = const GpsCaptureState.idle();
  int _requestId = 0;
  bool _isDisposed = false;

  GpsCaptureState get state => _state;

  Future<void> capture() async {
    if (_state.isLoading) {
      return;
    }

    final requestId = ++_requestId;
    _setState(_state.copyWith(status: GpsCaptureStatus.loading));

    try {
      final location = await _locationService.captureCurrentLocation();
      if (requestId != _requestId) {
        return;
      }

      _setState(
        GpsCaptureState(
          status: GpsCaptureStatus.success,
          location: location,
        ),
      );
    } on LocationCaptureException catch (error) {
      if (requestId != _requestId) {
        return;
      }

      _setState(
        GpsCaptureState(
          status: GpsCaptureStatus.failure,
          failure: error.failure,
        ),
      );
    }
  }

  Future<bool> openAppSettings() {
    return _locationService.openAppSettings();
  }

  Future<bool> openLocationSettings() {
    return _locationService.openLocationSettings();
  }

  void reset() {
    _requestId++;
    _setState(const GpsCaptureState.idle());
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _setState(GpsCaptureState value) {
    if (_isDisposed) {
      return;
    }

    _state = value;
    notifyListeners();
  }
}
