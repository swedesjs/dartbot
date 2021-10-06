import "package:dio/dio.dart" show Dio;
import "package:vklib/vklib.dart" show Json;

class Reporter {
  Json options;

  Reporter(this.options);

  int get id => options["id"];
  String get statusText => options["status_text"];
  int get reportsCount => options["reports_count"];
  int get topPosition => options["top_position"];

  bool get tester => options["tester"];

  Json get profile => options["profile"];
}

class TesterResponse {
  Json options;

  TesterResponse(this.options);

  Reporter get reporter => Reporter(options["reporter"]);
}

Future<TesterResponse> getTester(int id) async {
  final response = (await Dio().get("https://ssapi.ru/vk-bugs-api",
          queryParameters: {"method": "getReporter", "reporter_id": id}))
      .data["response"];

  return TesterResponse(response);
}
