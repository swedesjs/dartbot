import "package:vklib/vklib.dart";

import "photoAttachment.dart";

class Reply {
  Json options;
  Reply(this.options);

  int get id => options["id"];
  int get senderId => options["from_id"];
  int get createdAt => options["date"];
  String? get text => options["text"];
  
  List<PhotoAttachment> get photo => (options["attachments"] as List)
      .where((element) => element["type"] == "photo")
      .map((e) => PhotoAttachment(e["photo"]))
      .toList();
}
