import 'survey_image.dart';

class SurveyDraft {
  const SurveyDraft({
    this.images = const [],
  });

  final List<SurveyImage> images;

  List<String> get imagePaths {
    return images.map((image) => image.path).toList(growable: false);
  }

  SurveyDraft copyWith({
    List<SurveyImage>? images,
  }) {
    return SurveyDraft(
      images: images ?? this.images,
    );
  }
}
