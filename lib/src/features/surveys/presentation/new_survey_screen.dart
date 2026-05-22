import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/location/domain/location_service.dart';
import '../../../core/location/infrastructure/geolocator_location_service.dart';
import '../../../core/media/domain/image_capture_service.dart';
import '../../../core/media/infrastructure/image_picker_capture_service.dart';
import '../../../core/storage/app_database.dart';
import '../application/gps_capture_controller.dart';
import '../application/survey_image_controller.dart';
import '../domain/survey_form_options.dart';
import '../domain/survey_record.dart';
import '../domain/survey_repository.dart';
import '../domain/survey_storage_failure.dart';
import '../data/sqflite_survey_repository.dart';
import 'widgets/gps_capture_card.dart';
import 'widgets/new_survey_action_bar.dart';
import 'widgets/survey_choice_group.dart';
import 'widgets/survey_dropdown_field.dart';
import 'widgets/survey_form_section.dart';
import 'widgets/survey_images_card.dart';
import 'widgets/survey_text_field.dart';

class NewSurveyScreen extends StatefulWidget {
  NewSurveyScreen({
    this.locationService = const GeolocatorLocationService(),
    ImageCaptureService? imageCaptureService,
    SurveyRepository? surveyRepository,
    super.key,
  })  : imageCaptureService =
            imageCaptureService ?? ImagePickerCaptureService(),
        surveyRepository = surveyRepository ??
            SqfliteSurveyRepository(database: AppDatabase.instance);

  final LocationService locationService;
  final ImageCaptureService imageCaptureService;
  final SurveyRepository surveyRepository;

  @override
  State<NewSurveyScreen> createState() => _NewSurveyScreenState();
}

class _NewSurveyScreenState extends State<NewSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _roadNameController = TextEditingController();
  final _chainageController = TextEditingController();
  final _notesController = TextEditingController();
  late final GpsCaptureController _gpsCaptureController;
  late final SurveyImageController _surveyImageController;

  RoadSide? _roadSide;
  String? _distressType;
  SurveySeverity? _severity;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _gpsCaptureController = GpsCaptureController(
      locationService: widget.locationService,
    );
    _surveyImageController = SurveyImageController(
      imageCaptureService: widget.imageCaptureService,
    )..load();
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _roadNameController.dispose();
    _chainageController.dispose();
    _notesController.dispose();
    _gpsCaptureController.dispose();
    _surveyImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('New survey'),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
                  AppSpacing.pagePaddingFor(constraints.maxWidth);
              final useTwoColumns = constraints.maxWidth >= 840;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  AppSpacing.md,
                  horizontalPadding,
                  AppSpacing.xxl + 88,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSpacing.maxContentWidth,
                    ),
                    child: useTwoColumns
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _RoadDetailsSection(
                                      projectNameController:
                                          _projectNameController,
                                      roadNameController: _roadNameController,
                                      chainageController: _chainageController,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    GpsCaptureCard(
                                      controller: _gpsCaptureController,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    SurveyImagesCard(
                                      controller: _surveyImageController,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _ConditionSection(
                                  roadSide: _roadSide,
                                  distressType: _distressType,
                                  severity: _severity,
                                  notesController: _notesController,
                                  onRoadSideChanged: (value) {
                                    setState(() => _roadSide = value);
                                  },
                                  onDistressTypeChanged: (value) {
                                    setState(() => _distressType = value);
                                  },
                                  onSeverityChanged: (value) {
                                    setState(() => _severity = value);
                                  },
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _RoadDetailsSection(
                                projectNameController:
                                    _projectNameController,
                                roadNameController: _roadNameController,
                                chainageController: _chainageController,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              GpsCaptureCard(
                                controller: _gpsCaptureController,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SurveyImagesCard(
                                controller: _surveyImageController,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _ConditionSection(
                                roadSide: _roadSide,
                                distressType: _distressType,
                                severity: _severity,
                                notesController: _notesController,
                                onRoadSideChanged: (value) {
                                  setState(() => _roadSide = value);
                                },
                                onDistressTypeChanged: (value) {
                                  setState(() => _distressType = value);
                                },
                                onSeverityChanged: (value) {
                                  setState(() => _severity = value);
                                },
                              ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: NewSurveyActionBar(
          onReset: _resetForm,
          onSubmit: _submitForm,
          isSaving: _isSaving,
        ),
      ),
    );
  }

  void _resetForm({bool deleteImages = true}) {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.reset();
    _projectNameController.clear();
    _roadNameController.clear();
    _chainageController.clear();
    _notesController.clear();
    _gpsCaptureController.reset();
    unawaited(_surveyImageController.clear(deleteFiles: deleteImages));
    setState(() {
      _roadSide = null;
      _distressType = null;
      _severity = null;
    });
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    if (_isSaving) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check the highlighted fields before continuing.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final record = SurveyRecord(
      projectName: _projectNameController.text.trim(),
      roadName: _roadNameController.text.trim(),
      chainage: _chainageController.text.trim(),
      roadSide: _roadSide!,
      distressType: _distressType!.trim(),
      severity: _severity!,
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
      location: _gpsCaptureController.state.location,
      images: _surveyImageController.state.draft.images,
    );

    try {
      await widget.surveyRepository.createSurvey(record);
      if (!mounted) {
        return;
      }
      _resetForm(deleteImages: false);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Survey saved locally for offline access.'),
        ),
      );
    } on SurveyStorageException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.failure.message),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _RoadDetailsSection extends StatelessWidget {
  const _RoadDetailsSection({
    required this.projectNameController,
    required this.roadNameController,
    required this.chainageController,
  });

  final TextEditingController projectNameController;
  final TextEditingController roadNameController;
  final TextEditingController chainageController;

  @override
  Widget build(BuildContext context) {
    return SurveyFormSection(
      title: 'Road details',
      icon: Icons.route,
      children: [
        SurveyTextField(
          controller: projectNameController,
          label: 'Project name',
          hintText: 'Example: North Link Rehabilitation',
          icon: Icons.business_center_outlined,
          textInputAction: TextInputAction.next,
          validator: (value) => _requiredText(value, 'Project name'),
        ),
        SurveyTextField(
          controller: roadNameController,
          label: 'Road name',
          hintText: 'Example: R-304 Approach Road',
          icon: Icons.signpost_outlined,
          textInputAction: TextInputAction.next,
          validator: (value) => _requiredText(value, 'Road name'),
        ),
        SurveyTextField(
          controller: chainageController,
          label: 'Chainage',
          hintText: 'Example: 0+250 or 250.0',
          icon: Icons.straighten,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.none,
          validator: _validateChainage,
        ),
      ],
    );
  }
}

class _ConditionSection extends StatelessWidget {
  const _ConditionSection({
    required this.roadSide,
    required this.distressType,
    required this.severity,
    required this.notesController,
    required this.onRoadSideChanged,
    required this.onDistressTypeChanged,
    required this.onSeverityChanged,
  });

  final RoadSide? roadSide;
  final String? distressType;
  final SurveySeverity? severity;
  final TextEditingController notesController;
  final ValueChanged<RoadSide?> onRoadSideChanged;
  final ValueChanged<String?> onDistressTypeChanged;
  final ValueChanged<SurveySeverity?> onSeverityChanged;

  @override
  Widget build(BuildContext context) {
    return SurveyFormSection(
      title: 'Condition assessment',
      icon: Icons.fact_check_outlined,
      children: [
        SurveyChoiceGroup<RoadSide>(
          key: ValueKey<RoadSide?>(roadSide),
          label: 'Road side',
          initialValue: roadSide,
          onChanged: onRoadSideChanged,
          validator: (value) {
            if (value == null) {
              return 'Select a road side.';
            }
            return null;
          },
          options: RoadSide.values
              .map(
                (side) => SurveyChoiceOption<RoadSide>(
                  value: side,
                  label: side.label,
                  icon: side.icon,
                ),
              )
              .toList(),
        ),
        SurveyDropdownField<String>(
          key: ValueKey<String?>(distressType),
          label: 'Distress type',
          hintText: 'Select distress type',
          icon: Icons.warning_amber_outlined,
          initialValue: distressType,
          onChanged: onDistressTypeChanged,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Select a distress type.';
            }
            return null;
          },
          items: SurveyFormOptions.distressTypes
              .map(
                (type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                ),
              )
              .toList(),
        ),
        SurveyChoiceGroup<SurveySeverity>(
          key: ValueKey<SurveySeverity?>(severity),
          label: 'Severity',
          initialValue: severity,
          onChanged: onSeverityChanged,
          validator: (value) {
            if (value == null) {
              return 'Select severity.';
            }
            return null;
          },
          options: SurveySeverity.values
              .map(
                (severity) => SurveyChoiceOption<SurveySeverity>(
                  value: severity,
                  label: severity.label,
                  icon: severity.icon,
                ),
              )
              .toList(),
        ),
        SurveyTextField(
          controller: notesController,
          label: 'Notes',
          hintText: 'Add field observations',
          icon: Icons.notes_outlined,
          minLines: 4,
          maxLines: 6,
          maxLength: 500,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          validator: (value) {
            if (value != null && value.trim().length > 500) {
              return 'Notes must stay under 500 characters.';
            }
            return null;
          },
        ),
      ],
    );
  }
}

String? _requiredText(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required.';
  }

  if (value.trim().length < 2) {
    return '$fieldName is too short.';
  }

  return null;
}

String? _validateChainage(String? value) {
  final trimmedValue = value?.trim() ?? '';

  if (trimmedValue.isEmpty) {
    return 'Chainage is required.';
  }

  final chainagePattern = RegExp(r'^(\d+(\.\d+)?|\d+\+\d{1,3})$');
  if (!chainagePattern.hasMatch(trimmedValue)) {
    return 'Use a value like 0+250 or 250.0.';
  }

  return null;
}
