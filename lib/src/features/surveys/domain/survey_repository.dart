import 'survey_record.dart';
import 'survey_summary.dart';

abstract interface class SurveyRepository {
  Future<int> createSurvey(SurveyRecord record);

  Future<void> updateSurvey(SurveyRecord record);

  Future<void> deleteSurvey(int id);

  Future<List<SurveyRecord>> fetchAllSurveys();

  Future<SurveyRecord?> fetchSurveyById(int id);

  Future<List<SurveySummary>> fetchSurveySummaries({String? query});
}
