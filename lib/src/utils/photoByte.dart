import "dart:typed_data";

import "package:dio/dio.dart";

Future<Uint8List> photoByteUrl(String url) async {
  final response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
  return response.data;
}
