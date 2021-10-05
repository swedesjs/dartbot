import "dart:convert";

import "package:dio/dio.dart";
import "package:vklib/vklib.dart";

class Upload {
  API _api;
  Upload(this._api);

  Future<String> privateMessage(String url, {int? peerId}) async {
    final futureWait = await Future.wait([
      Dio().get(url, options: Options(responseType: ResponseType.bytes)),
      _api.photos.getMessagesUploadServer(peer_id: peerId)
    ]);

    final getBytes = futureWait[0] as Response<dynamic>,
        getServer = (futureWait[1] as Json)["response"],
        formData = FormData.fromMap(
            {"photo": MultipartFile.fromBytes(getBytes.data, filename: url.split("/").last)});

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
