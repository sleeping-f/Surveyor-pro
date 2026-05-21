import 'package:flutter/material.dart';

import 'app_routes.dart';
import '../core/theme/app_theme.dart';
import 'presentation/app_shell.dart';

class SurveyorProApp extends StatelessWidget {
  const SurveyorProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surveyor Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routes: AppRoutes.routes,
      home: const AppShell(),
    );
  }
}
