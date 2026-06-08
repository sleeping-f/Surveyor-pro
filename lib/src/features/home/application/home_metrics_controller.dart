import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class HomeMetrics {
  const HomeMetrics({
    required this.storedImages,
  });

  const HomeMetrics.empty() : storedImages = 0;

  final int storedImages;
}

enum HomeMetricsStatus {
  loading,
  ready,
  failure,
}

class HomeMetricsState {
  const HomeMetricsState({
    required this.status,
    required this.metrics,
    this.message,
  });

  const HomeMetricsState.loading()
      : status = HomeMetricsStatus.loading,
        metrics = const HomeMetrics.empty(),
        message = null;

  const HomeMetricsState.failure(String message)
      : status = HomeMetricsStatus.failure,
        metrics = const HomeMetrics.empty(),
        message = message;

  final HomeMetricsStatus status;
  final HomeMetrics metrics;
  final String? message;

  bool get isLoading => status == HomeMetricsStatus.loading;
}

class HomeMetricsController extends ChangeNotifier {
  HomeMetricsController();

  HomeMetricsState _state = const HomeMetricsState.loading();
  bool _isDisposed = false;

  HomeMetricsState get state => _state;

  Future<void> load() async {
    try {
      final storedImages = await _countStoredImages();

      _setState(
        HomeMetricsState(
          status: HomeMetricsStatus.ready,
          metrics: HomeMetrics(
            storedImages: storedImages,
          ),
        ),
      );
    } catch (error) {
      _setState(
        const HomeMetricsState.failure(
          'Photo counts could not be loaded.',
        ),
      );
    }
  }

  Future<int> _countStoredImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDirectory = Directory(
      p.join(directory.path, 'camera_captures'),
    );

    if (!await imageDirectory.exists()) {
      return 0;
    }

    final files = imageDirectory
        .listSync(followLinks: false)
        .whereType<File>()
        .where((file) => p.extension(file.path).toLowerCase() == '.jpg');

    return files.length;
  }

  void _setState(HomeMetricsState value) {
    if (_isDisposed) {
      return;
    }

    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

