import 'survey_image.dart';

abstract interface class SurveyImageRepository {
  Future<List<SurveyImage>> loadImages();

  Future<void> saveImages(List<SurveyImage> images);

  Future<void> clearImages();
}
