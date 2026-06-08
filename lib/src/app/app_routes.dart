import 'package:flutter/material.dart';

import '../features/quick_camera/presentation/quick_camera_screen.dart';

abstract final class AppRoutes {
  static const String quickCamera = '/camera/quick';

  static Map<String, WidgetBuilder> get routes {
    return {
      quickCamera: (_) => QuickCameraScreen(),
    };
  }
}
