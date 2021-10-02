import "dart:math";

const _sizes = ["Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];

String bytesToSize(num bytes) {
  if (bytes == 0) return "0 Bytes";

  final i = (log(bytes) / log(1024)).floor();

  return "${double.parse((bytes / pow(1024, i)).toStringAsFixed(2))} ${_sizes[i]}";
}
