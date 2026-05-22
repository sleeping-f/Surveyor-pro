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
      location/
        domain/
          captured_location.dart
          location_failure.dart
          location_service.dart
        infrastructure/
          geolocator_location_service.dart
      media/
        domain/
          image_capture_failure.dart
          image_capture_service.dart
          local_image.dart
        infrastructure/
          image_picker_capture_service.dart
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
        application/
          gps_capture_controller.dart
          survey_image_controller.dart
        domain/
          survey_draft.dart
          survey_form_options.dart
          survey_image.dart
        presentation/
          new_survey_screen.dart
          widgets/
            gps_capture_card.dart
            new_survey_action_bar.dart
            survey_choice_group.dart
            survey_dropdown_field.dart
            survey_form_section.dart
            survey_images_card.dart
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
- `lib/src/core/location/domain/*` defines plugin-free GPS models, failures, and the reusable location service contract.
- `lib/src/core/location/infrastructure/geolocator_location_service.dart` implements location capture with `geolocator`.
- `lib/src/core/media/domain/*` defines plugin-free image capture models, failures, and the reusable image capture contract.
- `lib/src/core/media/infrastructure/image_picker_capture_service.dart` captures camera images and persists them from cache into app documents.
- `lib/src/core/theme/app_colors.dart` defines reusable brand/status colors and a `ThemeExtension` for semantic field states.
- `lib/src/core/theme/app_text_styles.dart` defines the app typography scale and reusable text helpers.
- `lib/src/core/theme/app_theme.dart` builds Material 3 light and dark themes.
- `lib/src/shared/widgets/app_card.dart` is the base app card with consistent radius, border, and tap behavior.
- `lib/src/shared/widgets/section_header.dart` standardizes section headings.
- `lib/src/shared/widgets/placeholder_feature_page.dart` gives future navigation tabs a clean temporary screen.
- `lib/src/features/home/presentation/home_screen.dart` composes the Home Screen and responsive layout.
- `lib/src/features/home/presentation/widgets/*` contains focused Home Screen widgets.
- `lib/src/features/surveys/domain/survey_form_options.dart` defines form options for road side, severity, and distress types.
- `lib/src/features/surveys/domain/survey_draft.dart` is the current in-memory survey session model and stores captured image paths.
- `lib/src/features/surveys/application/gps_capture_controller.dart` owns GPS capture state for the survey form.
- `lib/src/features/surveys/application/survey_image_controller.dart` owns image capture, retake, delete, recovery, and current-session image state.
- `lib/src/features/surveys/presentation/new_survey_screen.dart` contains the validated, keyboard-safe New Survey form.
- `lib/src/features/surveys/presentation/widgets/*` contains reusable form fields, choice controls, GPS/image capture UI, sections, and the sticky action bar.

## Dependencies

Runtime dependency:

```yaml
geolocator: ^14.0.2
image_picker: ^1.2.2
path_provider: ^2.1.5
```

Development dependency:

```yaml
flutter_lints: ^5.0.0
```

## Android location setup

The Android app is configured for foreground GPS and camera capture only.

- `android/app/src/main/AndroidManifest.xml` includes:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />

<uses-feature
    android:name="android.hardware.camera"
    android:required="false" />
```

- `android/app/build.gradle.kts` uses `compileSdk = 36`, matching the current Android plugin requirements.
- `android/app/build.gradle.kts` uses `minSdk = 24`, which supports Android 7+ and safely includes Android 10/11 field devices.
- Android 10/11 compatibility is preserved; `compileSdk` does not raise the minimum supported Android version.
- `android/gradle.properties` disables Kotlin incremental compilation and uses in-process Kotlin compilation to avoid Windows Kotlin cache registration failures during plugin builds.
- No external storage permission is used. Captured images are copied into the app documents directory.
- Background location, maps, cloud upload, database storage, and image compression are intentionally not enabled yet.

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
