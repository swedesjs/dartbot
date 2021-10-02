// ignore_for_file: unnecessary_getters_setters, avoid_as

import "dart:io";

import "package:path/path.dart";

class Disk {
  int? _total, _free;
  num? _usage;

  Future<void> load([String path = "C"]) async {
    if (Platform.isWindows) {
      final process = await Process.run(
          join(current, "lib/src/utils/disk/drivespace.exe"), ["drive-$path"],
          runInShell: true);
      final diskInfo = (process.stdout as String).split(",");

      total = int.parse(diskInfo[0]);
      free = int.parse(diskInfo[1]);
      usage = total! - free!;
    } else {
      if (path == "C") path = "/";

      final process = await Process.run("df", ["-k", path]);
      final lines = (process.stdout as String).trim().split("\n");

      final strDiskInfo = lines[lines.length - 1].replaceAll(RegExp(r"[\s\n\r]+"), " ");
      final diskInfo = strDiskInfo.split(" ").sublist(1, 4).map(int.parse).toList();

      total = diskInfo[0] * 1024;
      usage = diskInfo[1] * 1024;
      free = diskInfo[2] * 1024;
    }
  }

  int? get total => _total;
  set total(int? count) => _total = count;

  num? get usage => _usage;
  set usage(num? count) => _usage = count;

  int? get free => _free;
  set free(int? count) => _free = count;
}
