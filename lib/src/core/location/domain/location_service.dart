import 'captured_location.dart';

abstract interface class LocationService {
  Future<CapturedLocation> captureCurrentLocation();

  Future<bool> openAppSettings();

  Future<bool> openLocationSettings();
}
