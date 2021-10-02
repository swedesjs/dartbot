import "dart:convert";

import "package:dio/dio.dart";

const peerChatIdOffset = 2e9;
final _dio = Dio();

enum MessageSource { CHAT, GROUP, USER }

MessageSource getPeerType(int id) {
  if (peerChatIdOffset < id) return MessageSource.CHAT;

  if (id < 0) return MessageSource.GROUP;

  return MessageSource.USER;
}

class _Status {
  String section, status;
  int perfomance;
  double uptime;

  _Status(
      {required this.section,
      required this.status,
      required this.perfomance,
      required this.uptime});
}

Future<List<_Status>> statusVKApi() async {
  final data = (await _dio.post("https://vk.com/dev/health")).data as String;
  var positionX = data.indexOf("var content = {");
  var positionY = data.indexOf("'header': ['");

  final newData = data.substring(positionX, positionY);
  positionX = newData.indexOf("[[");
  positionY = newData.indexOf("]]");

  final arrayWithSections = jsonDecode(
    newData.substring(positionX, positionY + 2)
  ) as List;

  final outputArray = <_Status>[];

  for (final element in arrayWithSections) {
    outputArray.add(
      _Status(
        section: element[0],
        status: (element[1] as String).replaceFirstMapped(
          RegExp(r"<div class='(.*?)'>(.*?)</div>"), (match) => match.group(1)!
        ),
        perfomance: element[2],
        uptime: element[3]
      )
    );
  }
  return outputArray;
}

Future<int> getVkRegDate(int id) async {
  final data =
      (await _dio.post("https://vk.com/foaf.php", queryParameters: {"id": id})).data as String;
  final splitted = data.split("<ya:created dc:date=\"")[1].split("\"/>")[0];
  return DateTime.parse(splitted).millisecondsSinceEpoch;
}
