import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:surveyor_pro/src/app/surveyor_pro_app.dart';

void main() {
  testWidgets('opens the new survey screen from home', (tester) async {
    await tester.pumpWidget(const SurveyorProApp());

    expect(find.text('Surveyor Pro'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'New survey'));
    await tester.pumpAndSettle();

    expect(find.text('New survey'), findsOneWidget);
    expect(find.text('Project name'), findsOneWidget);
    expect(find.text('Road side'), findsOneWidget);
  });
}
