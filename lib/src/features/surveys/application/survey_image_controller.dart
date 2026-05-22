import 'package:flutter/foundation.dart';

import '../../../core/media/domain/image_capture_failure.dart';
import '../../../core/media/domain/image_capture_service.dart';
import '../domain/survey_draft.dart';
import '../domain/survey_image.dart';

enum SurveyImageStatus {
  loading,
  ready,
  capturing,
  failure,
}

class SurveyImageState {
  const SurveyImageState({
    required this.status,
    this.draft = const SurveyDraft(),
    this.failure,
  });

  const SurveyImageState.loading()
      : status = SurveyImageStatus.loading,
        draft = const SurveyDraft(),
        failure = null;

  final SurveyImageStatus status;
  final SurveyDraft draft;
  final ImageCaptureFailure? failure;

  bool get isBusy {
    return status == SurveyImageStatus.loading ||
        status == SurveyImageStatus.capturing;
  }
}

class SurveyImageController extends ChangeNotifier {
  SurveyImageController({
    required ImageCaptureService imageCaptureService,
  }) : _imageCaptureService = imageCaptureService;

  final ImageCaptureService _imageCaptureService;

  SurveyImageState _state = const SurveyImageState.loading();
  bool _isDisposed = false;

  SurveyImageState get state => _state;

  Future<void> load() async {
    try {
      final recoveredImages = await _imageCaptureService.recoverLostImages();

      _setState(
        SurveyImageState(
          status: SurveyImageStatus.ready,
          draft: SurveyDraft(images: recoveredImages),
        ),
      );
    } on ImageCaptureException catch (error) {
      _setState(
        SurveyImageState(
          status: SurveyImageStatus.failure,
          draft: _state.draft,
          failure: error.failure,
        ),
      );
    } catch (_) {
      _setState(
        SurveyImageState(
          status: SurveyImageStatus.failure,
          draft: _state.draft,
          failure: const ImageCaptureFailure(
            type: ImageCaptureFailureType.unknown,
            title: 'Images unavailable',
            message: 'Saved survey photos could not be loaded.',
          ),
        ),
      );
    }
  }

  Future<void> capture() async {
    if (_state.isBusy) {
      return;
    }

    _setState(
      SurveyImageState(
        status: SurveyImageStatus.capturing,
        draft: _state.draft,
      ),
    );

    try {
      final image = await _imageCaptureService.captureImageFromCamera();
      if (image == null) {
        _ready(_state.draft.images);
        return;
      }

      final images = [..._state.draft.images, image];
      _ready(images);
    } on ImageCaptureException catch (error) {
      _failure(error.failure);
    } catch (_) {
      _failure(
        const ImageCaptureFailure(
          type: ImageCaptureFailureType.fileSystem,
          title: 'Image storage failed',
          message: 'The photo path could not be saved locally.',
        ),
      );
    }
  }

  Future<void> retake(SurveyImage image) async {
    if (_state.isBusy) {
      return;
    }

    _setState(
      SurveyImageState(
        status: SurveyImageStatus.capturing,
        draft: _state.draft,
      ),
    );

    try {
      final replacement = await _imageCaptureService.captureImageFromCamera();
      if (replacement == null) {
        _ready(_state.draft.images);
        return;
      }

      final images = _state.draft.images
          .map((savedImage) => savedImage.id == image.id
              ? replacement
              : savedImage)
          .toList(growable: false);

      await _imageCaptureService.deleteImageFile(image);
      _ready(images);
    } on ImageCaptureException catch (error) {
      _failure(error.failure);
    } catch (_) {
      _failure(
        const ImageCaptureFailure(
          type: ImageCaptureFailureType.fileSystem,
          title: 'Retake failed',
          message: 'The replacement photo could not be saved locally.',
        ),
      );
    }
  }

  Future<void> delete(SurveyImage image) async {
    if (_state.isBusy) {
      return;
    }

    final images = _state.draft.images
        .where((savedImage) => savedImage.id != image.id)
        .toList(growable: false);

    try {
      await _imageCaptureService.deleteImageFile(image);
      _ready(images);
    } catch (_) {
      _failure(
        const ImageCaptureFailure(
          type: ImageCaptureFailureType.fileSystem,
          title: 'Delete failed',
          message: 'The photo could not be removed from local storage.',
        ),
      );
    }
  }

  Future<void> clear() async {
    final images = List<SurveyImage>.from(_state.draft.images);

    try {
      for (final image in images) {
        await _imageCaptureService.deleteImageFile(image);
      }

      _ready(const []);
    } catch (_) {
      _failure(
        const ImageCaptureFailure(
          type: ImageCaptureFailureType.fileSystem,
          title: 'Reset failed',
          message: 'Some local photo files could not be cleared.',
        ),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _ready(List<SurveyImage> images) {
    _setState(
      SurveyImageState(
        status: SurveyImageStatus.ready,
        draft: SurveyDraft(images: images),
      ),
    );
  }

  void _failure(ImageCaptureFailure failure) {
    _setState(
      SurveyImageState(
        status: SurveyImageStatus.failure,
        draft: _state.draft,
        failure: failure,
      ),
    );
  }

  void _setState(SurveyImageState value) {
    if (_isDisposed) {
      return;
    }

    _state = value;
    notifyListeners();
  }
}
