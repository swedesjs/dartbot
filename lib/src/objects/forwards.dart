import "package:vklib/vklib.dart" show Json;

import "photoAttachment.dart";

class Forwards {
  Json options;

  Forwards(this.options);

  int get id => options["id"];
  int get senderId => options["from_id"];
  int get createdAt => options["date"];
  String get text => options["text"];
  int get conversationMessageId => options["conversation_message_id"];
  int get peerId => options["peer_id"];

  List<PhotoAttachment> get photo => (options["attachments"] as List)
      .where((element) => element["type"] == "photo")
      .map((e) => PhotoAttachment(e["photo"]))
      .toList();
}
