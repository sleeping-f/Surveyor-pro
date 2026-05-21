class LocalImage {
  const LocalImage({
    required this.id,
    required this.path,
    required this.capturedAt,
  });

  final String id;
  final String path;
  final DateTime capturedAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'path': path,
      'capturedAt': capturedAt.toIso8601String(),
    };
  }

  factory LocalImage.fromJson(Map<String, Object?> json) {
    return LocalImage(
      id: json['id'] as String,
      path: json['path'] as String,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
    );
  }
}
