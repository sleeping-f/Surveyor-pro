# Surveyor Pro

Professional offline-first road survey app foundation for civil engineers.

## Structure

```text
lib/
  main.dart
  src/
    app/
      app_routes.dart
      surveyor_pro_app.dart
      presentation/
        app_destination.dart
        app_shell.dart
    core/
      constants/
        app_spacing.dart
      theme/
        app_colors.dart
        app_text_styles.dart
        app_theme.dart
    features/
      home/
        presentation/
          home_screen.dart
          widgets/
            field_status_card.dart
            home_header.dart
            quick_action_card.dart
            survey_overview_card.dart
      surveys/
        domain/
          survey_form_options.dart
        presentation/
          new_survey_screen.dart
          widgets/
            new_survey_action_bar.dart
            survey_choice_group.dart
            survey_dropdown_field.dart
            survey_form_section.dart
            survey_text_field.dart
    shared/
      widgets/
        app_card.dart
        placeholder_feature_page.dart
        section_header.dart
```

## Files

- `lib/main.dart` starts the Flutter app.
- `lib/src/app/app_routes.dart` defines named routes used by feature entry points.
- `lib/src/app/surveyor_pro_app.dart` owns `MaterialApp`, light/dark themes, and the root shell.
- `lib/src/app/presentation/app_shell.dart` provides adaptive navigation: bottom navigation on phones and a navigation rail on wider Android layouts.
- `lib/src/app/presentation/app_destination.dart` keeps navigation labels and icons in one small model.
- `lib/src/core/constants/app_spacing.dart` centralizes spacing, touch target, radius, and max-width values.
- `lib/src/core/theme/app_colors.dart` defines reusable brand/status colors and a `ThemeExtension` for semantic field states.
- `lib/src/core/theme/app_text_styles.dart` defines the app typography scale and reusable text helpers.
- `lib/src/core/theme/app_theme.dart` builds Material 3 light and dark themes.
- `lib/src/shared/widgets/app_card.dart` is the base app card with consistent radius, border, and tap behavior.
- `lib/src/shared/widgets/section_header.dart` standardizes section headings.
- `lib/src/shared/widgets/placeholder_feature_page.dart` gives future navigation tabs a clean temporary screen.
- `lib/src/features/home/presentation/home_screen.dart` composes the Home Screen and responsive layout.
- `lib/src/features/home/presentation/widgets/*` contains focused Home Screen widgets.
- `lib/src/features/surveys/domain/survey_form_options.dart` defines form options for road side, severity, and distress types.
- `lib/src/features/surveys/presentation/new_survey_screen.dart` contains the validated, keyboard-safe New Survey form.
- `lib/src/features/surveys/presentation/widgets/*` contains reusable form fields, choice controls, sections, and the sticky action bar.

## Dependencies

No runtime packages are added yet. The app currently uses only Flutter Material APIs.

Development dependency:

```yaml
flutter_lints: ^5.0.0
```

## Run locally

From the project root:

```bash
flutter pub get
flutter run
```

If platform files are ever missing, regenerate them with:

```bash
flutter create --platforms=android --org com.example .
```

Replace `com.example` with your real organization package before production work begins.
