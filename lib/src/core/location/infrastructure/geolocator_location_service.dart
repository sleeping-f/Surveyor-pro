import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../domain/captured_location.dart';
import '../domain/location_failure.dart';
import '../domain/location_service.dart';

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
    timeLimit: Duration(seconds: 24),
  );

  @override
  Future<CapturedLocation> captureCurrentLocation() async {
    try {
      await _ensureLocationAccess();

      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );

      return CapturedLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        timestamp: position.timestamp,
      );
    } on LocationCaptureException {
      rethrow;
    } on TimeoutException {
      throw const LocationCaptureException(
        LocationFailure(
          type: LocationFailureType.timeout,
          title: 'GPS fix timed out',
          message: 'Move to open sky and try capturing the position again.',
        ),
      );
    } on LocationServiceDisabledException {
      throw const LocationCaptureException(
        LocationFailure(
          type: LocationFailureType.serviceDisabled,
          title: 'Location is off',
          message: 'Turn on device location services to capture GPS.',
        ),
      );
    } on PermissionDeniedException {
      throw const LocationCaptureException(
        LocationFailure(
          type: LocationFailureType.permissionDenied,
          title: 'Location permission denied',
          message: 'Allow location access to capture survey coordinates.',
        ),
      );
    } catch (_) {
      throw const LocationCaptureException(
        LocationFailure(
          type: LocationFailureType.unknown,
          title: 'Unable to capture GPS',
          message: 'The device could not return a location. Try again.',
        ),
      );
    }
  }

  @override
  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }

  @override
  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  Future<void> _ensureLocationAccess() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationCaptureException(
        LocationFailure(
          type: LocationFailureType.serviceDisabled,
          title: 'Location is off',
          message: 'Turn on device location services to capture GPS.',
        ),
      );
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    switch (permission) {
      case LocationPermission.denied:
        throw const LocationCaptureException(
          LocationFailure(
            type: LocationFailureType.permissionDenied,
            title: 'Location permission denied',
            message: 'Allow location access to capture survey coordinates.',
          ),
        );
      case LocationPermission.deniedForever:
        throw const LocationCaptureException(
          LocationFailure(
            type: LocationFailureType.permissionDeniedForever,
            title: 'Permission blocked',
            message:
                'Location permission is blocked. Enable it from app settings.',
          ),
        );
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return;
      case LocationPermission.unableToDetermine:
        throw const LocationCaptureException(
          LocationFailure(
            type: LocationFailureType.unavailable,
            title: 'Permission unavailable',
            message: 'The device could not determine location permission.',
          ),
        );
    }
  }
}
