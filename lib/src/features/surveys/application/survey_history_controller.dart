import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/survey_repository.dart';
import '../domain/survey_storage_failure.dart';
import '../domain/survey_summary.dart';

enum SurveyHistoryStatus {
  loading,
  ready,
  empty,
  failure,
}

class SurveyHistoryState {
  const SurveyHistoryState({
    required this.status,
    this.summaries = const [],
    this.searchTerm = '',
    this.failure,
  });

  const SurveyHistoryState.loading()
      : status = SurveyHistoryStatus.loading,
        summaries = const [],
        searchTerm = '',
        failure = null;

  final SurveyHistoryStatus status;
  final List<SurveySummary> summaries;
  final String searchTerm;
  final SurveyStorageFailure? failure;

  SurveyHistoryState copyWith({
    SurveyHistoryStatus? status,
    List<SurveySummary>? summaries,
    String? searchTerm,
    SurveyStorageFailure? failure,
  }) {
    return SurveyHistoryState(
      status: status ?? this.status,
      summaries: summaries ?? this.summaries,
      searchTerm: searchTerm ?? this.searchTerm,
      failure: failure,
    );
  }
}

class SurveyHistoryController extends ChangeNotifier {
  SurveyHistoryController({
    required SurveyRepository repository,
  }) : _repository = repository;

  final SurveyRepository _repository;

  SurveyHistoryState _state = const SurveyHistoryState.loading();
  Timer? _debounce;
  bool _isDisposed = false;

  SurveyHistoryState get state => _state;

  Future<void> load() async {
    _setState(_state.copyWith(status: SurveyHistoryStatus.loading));

    try {
      final results = await _repository.fetchSurveySummaries(
        query: _state.searchTerm,
      );
      if (results.isEmpty) {
        _setState(
          _state.copyWith(
            status: SurveyHistoryStatus.empty,
            summaries: const [],
            failure: null,
          ),
        );
      } else {
        _setState(
          _state.copyWith(
            status: SurveyHistoryStatus.ready,
            summaries: results,
            failure: null,
          ),
        );
      }
    } on SurveyStorageException catch (error) {
      _setState(
        _state.copyWith(
          status: SurveyHistoryStatus.failure,
          failure: error.failure,
        ),
      );
    }
  }

  void setSearchTerm(String value) {
    _debounce?.cancel();
    _setState(_state.copyWith(searchTerm: value));
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => unawaited(load()),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounce?.cancel();
    super.dispose();
  }

  void _setState(SurveyHistoryState value) {
    if (_isDisposed) {
      return;
    }

    _state = value;
    notifyListeners();
  }
}
