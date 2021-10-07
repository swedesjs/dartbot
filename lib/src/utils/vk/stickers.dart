import "dart:convert";

import "package:vklib/vklib.dart";

import "../chunkArray.dart";
import "../total.dart";

class _UserStickerPack {
  int id;
  bool isStyle;

  _UserStickerPack({required this.id, required this.isStyle});
}

class _StickersPackInfo {
  String title;
  num price;
  bool isFree, isStyle;
  int id;

  _StickersPackInfo({
    required this.title,
    required this.price,
    required this.isFree,
    required this.isStyle,
    required this.id
  });
}

class _UserStickerPackExtend implements _StickersPackInfo, _UserStickerPack {
  @override
  int id;

  @override
  bool isFree;

  @override
  bool isStyle;

  @override
  num price;

  @override
  String title;

  _UserStickerPackExtend(
      {required this.id,
      required this.isFree,
      required this.isStyle,
      required this.price,
      required this.title});
}

class _GetUserStickerPacks {
  int count, paid;

  _GetUserStickerPacks({required this.count, required this.paid});
}

class _GetUserStickerStats {
  int total;
  _GetUserStickerPacks packs;

  _GetUserStickerStats({required this.total, required this.packs});
}

class GetUserSticker {
  List<_UserStickerPackExtend> items;

  num totalPrice;
  _GetUserStickerStats stats;

  GetUserSticker({required this.items, required this.totalPrice, required this.stats});
}

class Stickers {
  // ignore: unused_field
  final String _token;

  final API _api;

  Stickers(this._token) : _api = API(_token, v: "5.157");

  Future<List<_StickersPackInfo>> _getStickerPacksInfo(List<int> stickerPackIds) async {
    final output = <_StickersPackInfo>[];

    for (final chunk in chunkArray(stickerPackIds, 350)) {
      final data = (await _api.request("store.getStockItems",
          {"type": "stickers", "product_ids": jsonEncode(chunk), "lang": "ru"}))["response"];

      output.addAll((data["items"] as List).map((e) {
        final product = e["product"];

        final price = e["old_price"] ?? e["price"] ?? 0;
        final isFree = price == 0;

        final isStyle = product["style_sticker_ids"] != null;

        return _StickersPackInfo(
            title: product["title"],
            price: price,
            isFree: isFree,
            isStyle: isStyle,
            id: product["id"]
          );
        })
      );
    }
    return output;
  }

  Future<GetUserSticker> getUserStickerPacks(int userId) async {
    final userStickerPacks = (await _api.request("store.getProducts",
        {"type": "stickers", "filters": "purchased", "user_id": userId}))["response"];

    final parsedUserStickerPacks = (userStickerPacks["items"] as List)
        .map((e) => _UserStickerPack(id: e["id"], isStyle: e["base_id"] != null));

    final extendsStickerPackInfo =
        await _getStickerPacksInfo(parsedUserStickerPacks.map((e) => e.id).toList());

    final output = <_UserStickerPackExtend>[];

    for (final stickerPack in extendsStickerPackInfo) {
      final userStickerPackInfo =
          parsedUserStickerPacks.lastWhere((element) => element.id == stickerPack.id);

      output.add(
        _UserStickerPackExtend(
          id: stickerPack.id,
          isFree: stickerPack.isFree,
          isStyle: userStickerPackInfo.isStyle,
          price: stickerPack.price,
          title: stickerPack.title
        )
      );
    }

    final packsCount = output.where((x) => !x.isStyle).length;
    final paidPacksCount = output.where((x) => !x.isFree && !x.isStyle).length;

    return GetUserSticker(
        items: output,
        totalPrice: total(output.map((e) => e.price).toList()),
        stats: _GetUserStickerStats(
            total: output.length,
            packs: _GetUserStickerPacks(
              count: packsCount, 
              paid: paidPacksCount
            )
          )
        );
  }
}
