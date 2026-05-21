import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color seed = Color(0xFF136F63);
  static const Color surveyBlue = Color(0xFF1C64F2);
  static const Color safetyOrange = Color(0xFFE8743B);
  static const Color markerYellow = Color(0xFFF4B740);

  static const Color lightSurface = Color(0xFFF7F9FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightOutline = Color(0xFFD7DEE3);

  static const Color darkSurface = Color(0xFF101418);
  static const Color darkCard = Color(0xFF181D22);
  static const Color darkOutline = Color(0xFF2B333B);
}

@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.gps,
    required this.camera,
  });

  final Color success;
  final Color warning;
  final Color info;
  final Color gps;
  final Color camera;

  static const light = AppStatusColors(
    success: Color(0xFF2E7D32),
    warning: Color(0xFFB26A00),
    info: AppColors.surveyBlue,
    gps: AppColors.seed,
    camera: AppColors.safetyOrange,
  );

  static const dark = AppStatusColors(
    success: Color(0xFF7BD88F),
    warning: Color(0xFFFFC46B),
    info: Color(0xFF8AB4FF),
    gps: Color(0xFF63D5C4),
    camera: Color(0xFFFFA987),
  );

  @override
  AppStatusColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? gps,
    Color? camera,
  }) {
    return AppStatusColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      gps: gps ?? this.gps,
      camera: camera ?? this.camera,
    );
  }

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) {
      return this;
    }

    return AppStatusColors(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
      gps: Color.lerp(gps, other.gps, t) ?? gps,
      camera: Color.lerp(camera, other.camera, t) ?? camera,
    );
  }
}
