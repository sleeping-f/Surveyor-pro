import 'package:flutter/foundation.dart';

import '../../surveys/domain/survey_repository.dart';
import '../../surveys/domain/survey_storage_failure.dart';
import '../data/survey_csv_export_service.dart';
import '../domain/survey_export_failure.dart';
import '../domain/survey_export_result.dart';

enum SurveyExportStatus {
  idle,
  exporting,
  success,
  empty,
  failure,
}

class SurveyExportState {
  const SurveyExportState({
    required this.status,
    this.result,
    this.failure,
  });

  const SurveyExportState.idle()
      : status = SurveyExportStatus.idle,
        result = null,
        failure = null;

  final SurveyExportStatus status;
  final SurveyExportResult? result;
  final SurveyExportFailure? failure;

  bool get isBusy => status == SurveyExportStatus.exporting;

  SurveyExportState copyWith({
    SurveyExportStatus? status,
    SurveyExportResult? result,
    SurveyExportFailure? failure,
  }) {
    return SurveyExportState(
      status: status ?? this.status,
      result: result ?? this.result,
      failure: failure,
    );
  }
}

class SurveyExportController extends ChangeNotifier {
  SurveyExportController({
    required SurveyRepository repository,
    required SurveyCsvExportService exportService,
  })  : _repository = repository,
        _exportService = exportService;

  final SurveyRepository _repository;
  final SurveyCsvExportService _exportService;

  SurveyExportState _state = const SurveyExportState.idle();
  bool _isDisposed = false;

  SurveyExportState get state => _state;

  Future<void> exportAll() async {
    if (_state.isBusy) {
      return;
    }

    _setState(_state.copyWith(status: SurveyExportStatus.exporting));

    try {
      final surveys = await _repository.fetchAllSurveys();
      if (surveys.isEmpty) {
        _setState(
          const SurveyExportState(
            status: SurveyExportStatus.empty,
          ),
        );
        return;
      }

      final result = await _exportService.exportSurveys(surveys);
      _setState(
        SurveyExportState(
          status: SurveyExportStatus.success,
          result: result,
        ),
      );
    } on SurveyStorageException catch (error) {
      _setState(
        SurveyExportState(
          status: SurveyExportStatus.failure,
          failure: SurveyExportFailure(
            type: SurveyExportFailureType.storage,
            title: 'Survey storage unavailable',
            message: error.failure.message,
          ),
        ),
      );
    } on SurveyExportException catch (error) {
      _setState(
        SurveyExportState(
          status: SurveyExportStatus.failure,
          failure: error.failure,
        ),
      );
    } catch (_) {
      _setState(
        const SurveyExportState(
          status: SurveyExportStatus.failure,
          failure: SurveyExportFailure(
            type: SurveyExportFailureType.unknown,
            title: 'Export failed',
            message: 'The export could not be completed.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _setState(SurveyExportState value) {
    if (_isDisposed) {
      return;
    }

    _state = value;
    notifyListeners();
  }
}
