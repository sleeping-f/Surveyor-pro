import 'package:flutter/material.dart';

import '../features/surveys/presentation/new_survey_screen.dart';

abstract final class AppRoutes {
  static const String newSurvey = '/surveys/new';

  static Map<String, WidgetBuilder> get routes {
    return {
      newSurvey: (_) => const NewSurveyScreen(),
    };
  }
}
