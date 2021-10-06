import "package:vklib/vklib.dart" show Json;

class _PhotoAttachmentSizes {
  Json options;
  _PhotoAttachmentSizes(this.options);

  int get height => options["height"];
  String get url => options["url"];
  String get type => options["type"];
  int get width => options["width"];
}

class PhotoAttachment {
  Json options;

  PhotoAttachment(this.options);

  int get albumId => options["aldum_id"];
  int get createdAt => options["date"];

  int get id => options["id"];
  int get ownerId => options["owner_id"];

  bool get hasTags => options["has_tags"];

  String get accessKey => options["access_key"];

  List<_PhotoAttachmentSizes> get sizes =>
      (options["sizes"] as List).map((e) => _PhotoAttachmentSizes(e)).toList();
}
