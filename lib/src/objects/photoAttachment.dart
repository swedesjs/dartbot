import "package:vklib/vklib.dart" show Json;

const _smallSizes = ["m", "s"];
const _mediumSizes = ["y", "r", "q", "p", ..._smallSizes];
const _largeSizes = ["w", "z", ..._mediumSizes];

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

  String get text => options["text"];

  /// Possible key, only for replay
  int? get userId => options["user_id"];

  /// Returns the URL of a small photo
  /// (130 or 75)
  String? get smallSizeUrl {
    final sizes = getSizes(_smallSizes);
    if (sizes.isEmpty) return null;
    return sizes[0].url;
  }

  /// Returns the URL of a medium photo
  /// (807 or 604 or less)
  String? get mediumSizeUrl {
    final sizes = getSizes(_mediumSizes);
    if (sizes.isEmpty) return null;
    return sizes[0].url;
  }

  /// Returns the URL of a large photo
  /// (2560 or 1280 or less)
  String? get largeSizeUrl {
    final sizes = getSizes(_largeSizes);
    if (sizes.isEmpty) return null;
    return sizes[0].url;
  }

  List<_PhotoAttachmentSizes> getSizes(List<String> sizeTypes) {
    if (sizes.isEmpty) return [];

    return sizeTypes
        .map<_PhotoAttachmentSizes?>((sizeType) {
          try {
            return sizes.lastWhere((element) => element.type == sizeType);
          } catch (error) {
            return null;
          }
        })
        .where((element) => element != null)
        .toList()
        .cast<_PhotoAttachmentSizes>();
  }
}
