import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/survey_image.dart';
import '../domain/survey_image_repository.dart';

class SharedPreferencesSurveyImageRepository implements SurveyImageRepository {
  SharedPreferencesSurveyImageRepository({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _imagesKey = 'new_survey_draft_image_records';

  final SharedPreferencesAsync _preferences;

  @override
  Future<List<SurveyImage>> loadImages() async {
    final records = await _preferences.getStringList(_imagesKey) ?? const [];
    final images = <SurveyImage>[];
    var removedMissingFiles = false;

    for (final record in records) {
      try {
        final decoded = jsonDecode(record) as Map<String, Object?>;
        final image = SurveyImage.fromJson(decoded);
        if (await File(image.path).exists()) {
          images.add(image);
        } else {
          removedMissingFiles = true;
        }
      } catch (_) {
        removedMissingFiles = true;
      }
    }

    if (removedMissingFiles) {
      await saveImages(images);
    }

    return images;
  }

  @override
  Future<void> saveImages(List<SurveyImage> images) async {
    final records = images
        .map((image) => jsonEncode(image.toJson()))
        .toList(growable: false);

    await _preferences.setStringList(_imagesKey, records);
  }

  @override
  Future<void> clearImages() {
    return _preferences.remove(_imagesKey);
  }
}
