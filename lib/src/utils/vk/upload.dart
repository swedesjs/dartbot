import "dart:convert";

import "package:dio/dio.dart";
import "package:vklib/vklib.dart";

import "../photoByte.dart";

class Upload {
  final API _api;
  Upload(this._api);

  Future<String> privateMessageAsBytes(List<int> byte, {int? peerId}) =>
      privateMessageConduct(byte, peerId: peerId);

  Future<String> privateMessageAsUrl(String url, {int? peerId}) async =>
      await privateMessageConduct(await photoByteUrl(url), peerId: peerId);

  Future<String> privateMessageConduct(List<int> source, {int? peerId}) async {
    final getServer = (await _api.photos.getMessagesUploadServer(peer_id: peerId))["response"],
        formData =
            FormData.fromMap({"photo": MultipartFile.fromBytes(source, filename: "test.png")});

    final response = jsonDecode((await Dio().post(getServer["upload_url"],
            data: formData, options: Options(contentType: "multipart/form-data")))
        .data);

    final getAttachment = (await _api.photos.saveMessagesPhoto(
        server: response["server"],
        photo: response["photo"],
        hash: response["hash"]))["response"][0];

    return "photo${getAttachment["owner_id"]}_${getAttachment["id"]}";
  }
}
