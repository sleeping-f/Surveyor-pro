import 'package:flutter/material.dart';

import '../features/surveys/presentation/new_survey_screen.dart';
import '../features/quick_camera/presentation/quick_camera_screen.dart';

abstract final class AppRoutes {
  static const String newSurvey = '/surveys/new';
  static const String quickCamera = '/camera/quick';

  static Map<String, WidgetBuilder> get routes {
    return {
      newSurvey: (_) => NewSurveyScreen(),
      quickCamera: (_) => QuickCameraScreen(),
    };
  }
}
