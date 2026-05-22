class AppFormatters {
  static String shortDateTime(DateTime timestamp) {
    final local = timestamp.toLocal();
    return '${local.year}-${_two(local.month)}-${_two(local.day)} '
        '${_two(local.hour)}:${_two(local.minute)}';
  }

  static String fileTimestamp(DateTime timestamp) {
    final local = timestamp.toLocal();
    return '${local.year}${_two(local.month)}${_two(local.day)}_'
        '${_two(local.hour)}${_two(local.minute)}${_two(local.second)}';
  }

  static String readableFileTimestamp(DateTime timestamp) {
    final local = timestamp.toLocal();
    return '${local.year}-${_two(local.month)}-${_two(local.day)}_'
        '${_two(local.hour)}-${_two(local.minute)}';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
