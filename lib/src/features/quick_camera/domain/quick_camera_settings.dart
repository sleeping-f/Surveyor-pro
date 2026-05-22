class QuickCameraSettings {
  const QuickCameraSettings({
    required this.includeChainage,
    required this.chainageInWatermark,
    required this.chainageInFileName,
  });

  factory QuickCameraSettings.initial() {
    return const QuickCameraSettings(
      includeChainage: false,
      chainageInWatermark: true,
      chainageInFileName: true,
    );
  }

  final bool includeChainage;
  final bool chainageInWatermark;
  final bool chainageInFileName;

  bool get shouldPromptChainage => includeChainage;

  QuickCameraSettings copyWith({
    bool? includeChainage,
    bool? chainageInWatermark,
    bool? chainageInFileName,
  }) {
    return QuickCameraSettings(
      includeChainage: includeChainage ?? this.includeChainage,
      chainageInWatermark: chainageInWatermark ?? this.chainageInWatermark,
      chainageInFileName: chainageInFileName ?? this.chainageInFileName,
    );
  }
}
