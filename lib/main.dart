// ignore_for_file: avoid_as, empty_catches

import "dart:convert";
import "dart:io";

import "package:crypto/crypto.dart";
import "package:dart_ping/dart_ping.dart";
import "package:dio/dio.dart";
import "package:dotenv/dotenv.dart" show env, load;
import "package:image/image.dart";
import "package:system_info/system_info.dart";
import "package:vklib/src/core/utils/resolveResource.dart";
import "package:vklib/vklib.dart";

import "src/context/message_context.dart";
import "src/objects/editOptions.dart";
import "src/utils/ip.dart";
import "src/utils/utils.dart";

// ignore: non_constant_identifier_names
RegExp BasePattern(String reg) => RegExp(reg, caseSensitive: false);

String fixed(num element, [bool del = false]) =>
    (del ? element / 1000 : element).toStringAsFixed(2);

const onlineEnum = [
  "none",
  "Modile",
  "IPhone",
  "IPad",
  "Android",
  "WindowsPhone",
  "DesktopWindows10",
  "FullVersion"
];

final demotivator = File("asserts/demotivator.jpg").readAsBytesSync();
final demotivatorFont =
    File("asserts/demotivator.fnt").readAsStringSync(encoding: Encoding.getByName("utf-8")!);
final demotivatorPng = File("asserts/demotivator.words.png").readAsBytesSync();
final fontDemotivator = readFont(demotivatorFont, decodePng(demotivatorPng)!);

const bogId = 651129803;
final count = (1000 / 200).ceil();
Future<void> main() async {
  load();
  final vk = VkLib(token: env["TOKEN"]!);
  final upload = Upload(vk.api);

  final processUptime = dateNow();

  final longpoll = UserLongPoll(vk.api);
  final hearManager = HearManager();

  longpoll.on(UserLongPollEventsEnum.messageNew, (ctx) async {
    final from = ctx.object[6]["from"] as String?;

    final context = MessageContext(vk.api, ctx.object[1] as int);
    var isLoad = false;

    if (from == null) {
      await context.loadMessagePayload();
      isLoad = true;

      if (context.senderId != bogId) return;
    } else {
      if (int.parse(ctx.object[6]["from"]) != bogId) return;
    }

    if (!isLoad) await context.loadMessagePayload();
    await hearManager.middleware(context);
  });

  /// Сервер
  hearManager.hear(BasePattern(r"^(?:сервер)$"), (context) async {
    final stopwatch = Stopwatch()..start();

    // ignore: await_only_futures
    final disk = await Disk()
      // ignore: unawaited_futures
      ..load();

    final pingStream = await Ping("api.vk.com", count: 2).stream.toList();
    final timeList = pingStream
        .where((element) => element.response?.time != null)
        .map((elements) => elements.response!.time!.inMilliseconds)
        .toList();

    final freeRam = SysInfo.getFreePhysicalMemory(),
        totalRam = SysInfo.getTotalPhysicalMemory(),
        usedRam = totalRam - freeRam;

    await context.editDelete("""
    Информация о сервере:
⚙ | Оперативка: ${bytesToSize(usedRam)} из ${bytesToSize(totalRam)} (${fixed(usedRam / totalRam * 100)} %)
💽 | Диск: ${bytesToSize(disk.usage!)} из ${bytesToSize(disk.total!)} (${fixed(disk.usage! / disk.total! * 100)} %)
⏳ | Запущен: ${unixStampTime(dateNow() - processUptime)}

🔨 | Обработка заняла — ${fixed(dateNow() - context.createdAt * 1000, true)} с.
⚒ | Время отправки — ${fixed(stopwatch.elapsed.inMilliseconds, true)} с.
🏓 | Средний пинг: ${fixed(timeList.reduce((value, element) => value + element) / timeList.length)}ms

💻 | Система: ${SysInfo.kernelName}""");
  });

  /// MD5
  hearManager.hear(
      BasePattern(r"^(?:md5) (.*)$"),
      (context) async => await context
          .editDelete("MD5: ${md5.convert(utf8.encode(context.match[0].group(1)!)).toString()}"));

  /// Разведка
  hearManager.hear(BasePattern(r"^(?:разведка) ?(.*)?$"), (context) async {
    try {
      final text = context.replyMessage?.text ?? context.match[0].group(1);

      if (text == null) {
        await context.send("не найдено ссылки!");
        return;
      }

      final checkLink = RegExp(r"(vk.me\/join\/([a-z0-9=/\_]+))", caseSensitive: false)
          .allMatches(text)
          .toList()[0];

      final getChat = (await VkLib(token: env["TOKEN"]!, v: "5.21")
          .api
          .messages
          .getChatPreview(link: checkLink.group(0), fields: ["online", "last_seen"]))["response"];

      final groups = getChat["groups"] as List?,
          preview = getChat["preview"] as Map,
          profiles = getChat["profiles"] as List?;

      final adminId = preview["admin_id"] as int;
      var groupAdmin, userAdmin;

      try {
        userAdmin = profiles?.lastWhere((element) => element["id"] == adminId);
      } catch (error) {}

      try {
        groupAdmin = groups?.lastWhere((element) => element["id"] == adminId.abs());
      } catch (error) {}

      final lastSeen = userAdmin?["last_seen"];

      await context.editDelete("""
Название: ${preview["title"]}
Создатель: ${adminId < 0 ? "@club${groupAdmin["id"]} (${groupAdmin["name"]})" : "@id${userAdmin["id"]} (${userAdmin["first_name"]} ${userAdmin["last_name"]}) - ${userAdmin["online"] == 0 ? "не онлайн (${unixTime(lastSeen["time"] * 1000)})" : "онлайн (${onlineEnum[lastSeen["platform"]]})"}"}
Онлайн: ${profiles?.where((element) => element["online"] != 0).length ?? "нет пользователей"}
Участников: ${preview["members_count"]}
Боты в беседе: ${groups?.map((e) => "@club${e["id"]} (${e["name"]})").join(", ") ?? "отсуствуют"}
""");
    } catch (error) {
      await context.editDelete(error is RangeError ? "ссылки не обнаружено!" : error.toString());
    }
  });

  /// Удалить сообщения
  hearManager.hear(BasePattern(r"(?:deleteMessage|delm|delmessage)\s(all|([0-9]+))$"),
      (context) async {
    try {
      // ignore: prefer_final_locals
      var messageIds = <int>[];

      for (var i = 0; i < count; i++) {
        final getMessage =
            await vk.api.messages.getHistory(peer_id: context.peerId, offset: i * 200, count: 200);

        messageIds.addAll((getMessage["response"]["items"] as List)
            .where((element) =>
                element["from_id"] == context.senderId &&
                dateNow() - 86400000 < element["date"] * 1000)
            .map<int>((e) => e["id"] as int));
      }
      final text = context.match[0].group(1)!;
      final sliceOrNo =
          messageIds.sublist(1, text == "all" ? messageIds.length : int.parse(text) + 1);

      chunkArray(sliceOrNo, 200).forEach((element) async => await vk.api.messages
          .delete(peer_id: context.peerId, message_ids: element, delete_for_all: true));

      await context.editDelete("Удалено ${sliceOrNo.length} ${declOfNum(sliceOrNo.length, [
            "сообщение",
            "сообщения",
            "сообщений"
          ])}");
    } catch (error) {
      await context.editDelete(error.toString());
    }
  });

  /// Рестарт
  hearManager.hear(BasePattern(r"^(?:restart|рестарт)$"),
      (context) async => await Process.run("pm2", ["restart", "0"]));

  /// ConvertLayout
  hearManager.hear(BasePattern(r"^(?:!t(r|e))$"), (context) async {
    final text = context.replyMessage?.text;

    if (text == null) {
      await context.editDelete("Ответь на сообщение с текстом!");
      return;
    }

    final convert = ConvertKeyboard(
        keys: ".exportsfunc\"#\$&',/:;<>?@[]^`abdghijklmqvwyz{|}~",
        values: "юучзщкеыагтсЭ№;?эб.ЖжБЮ,\"хъ:ёфивпршолдьймцняХ/ЪЁ")
      ..convert(text);

    await context.editDelete(
        context.match[0].group(1)!.toUpperCase() == "R" ? convert.russian! : convert.english!);
  });

  /// Информация о чате
  hearManager.hear(BasePattern(r"^(?:chatinfo)$"), (context) async {
    try {
      final chatInfo = (await vk.api.messages
          .getChat(chat_id: context.chatId, fields: ["online", "last_seen"]))["response"];

      final adminId = chatInfo["admin_id"] as int;
      final users = chatInfo["users"] as List;

      final profiles = users.where((element) => element["type"] == "profile");
      final groups = users.where((element) => element["type"] == "group");
      var userAdmin, groupAdmin;

      try {
        userAdmin = profiles.lastWhere((element) => element["id"] == adminId);
      } catch (error) {}
      try {
        groupAdmin = groups.lastWhere((element) => element["id"] == adminId.abs());
      } catch (error) {}

      await context.editDelete("""
Название: ${chatInfo["title"]}
Создатель: ${adminId < 0 ? "@club${groupAdmin["id"]} (${groupAdmin["name"]})" : "@id${userAdmin["id"]} (${userAdmin["first_name"]} ${userAdmin["last_name"]}) - ${userAdmin["online"] as int > 0 ? "онлайн (${onlineEnum[userAdmin["last_seen"]["platform"]]})" : "не онлайн (${unixTime(userAdmin["last_seen"]["time"] * 1000)})"}"}
Онлайн: ${profiles.where((element) => element["online"] != 0).length}
Участников: ${chatInfo["members_count"]}
Боты в беседе: ${groups.isNotEmpty ? groups.map((e) => "@club${e["id"]} (${e["name"]})").join(", ") : "Отсуствуют"}
    """);
    } catch (error) {
      await context.editDelete(error.toString());
    }
  });

  /// Статус VK-API
  hearManager.hear(BasePattern(r"^(?:status|статус)$"), (context) async {
    final status = await statusVKApi();
    await context.editDelete(
        "Состояние VK API на ${unixTime(dateNow())}:\n\n${status.map((e) => "${e.section} [${e.perfomance}ms] ${e.status == "dev_status_okay" ? "Work" : "NoWork"} (uptime: ${double.parse(e.uptime.toStringAsFixed(2))}%)").join("\n")}");
  });

  /// Дата регистрации VK
  hearManager.hear(BasePattern(r"^(?:дата)\s?(.*)?$"), (context) async {
    try {
      final userId = await getUserId(context, vk.api);

      if (userId == null) {
        await context.editDelete("Не найден ID по которому нужно найти дату!");
        return;
      }

      final futureWait = await Future.wait([
        getVkRegDate(userId),
        vk.api.users.get(user_ids: [userId], name_case: "gen")
      ]);

      final dataReg = futureWait[0] as int, user = (futureWait[1] as Json)["response"][0];

      await context.editDelete(
          "Дата регистрации @id${user["id"]} (${user["first_name"]} ${user["last_name"]}): ${unixTime(dataReg)}\nТоесть в вк он: ${unixStampTime(dateNow() - dataReg)}");
    } catch (error) {
      await context.editDelete(error.toString());
    }
  });

  hearManager.hear(BasePattern(r"^(?:stickers|стикеры)\s?(.*)?$"), (context) async {
    try {
      final ms = dateNow();

      final userId = await getUserId(context, vk.api);
      if (userId == null) {
        await context.editDelete("Не найден ID юзера");
        return;
      }

      final futureWait = await Future.wait([
        vk.api.users.get(user_ids: [userId], name_case: "gen"),
        Stickers(env["VKME_TOKEN"]!).getUserStickerPacks(userId)
      ]);

      final userStickers = futureWait[1] as GetUserSticker;
      final getUser = (futureWait[0] as Json)["response"][0] as Json;

      final packs = userStickers.stats.packs;

      await context.editDelete(
          """У @id$userId (${getUser["first_name"]} ${getUser["last_name"]}) ${packs.paid}/${userStickers.stats.total} платных наборов стикеров (${separator(userStickers.totalPrice)} ${declOfNum(userStickers.totalPrice, [
            "голос",
            "голоса",
            "голосов"
          ])}/${separator(userStickers.totalPrice * 7)}₽)

${(userStickers.items.length < 120 ? userStickers.items : userStickers.items.sublist(0, 120)).where((element) => !element.isFree).map((e) => e.title).join(", ")}

Обработалось за: ${unixStampTime(dateNow() - ms)}
""");
    } catch (error) {
      await context.editDelete(error.toString());
    }
  });

  hearManager.hear(BasePattern(r"^(?:1000-7)$"), (context) async {
    var text = "";

    for (var i = 1000; i > 0; i -= 7) {
      text += "$i - 7 = ${i - 7}\n";
    }

    await context.editDelete(text);
  });

  hearManager.hear(BasePattern(r"^(?:ip)\s(.*)$"), (context) async {
    try {
      final response = await IpService(Uri.parse(context.match[0].group(1)!)).load();

      if (response.status == IpResponseStatus.FAIL) {
        await context.editDelete("Произошла ошибка! Сообщение: ${response.message}");
        return;
      }

      await context.editDelete("""
Информация об IP-адресе: 

🃏 IP: ${response.query}
⛵ Континент: ${response.continent}
🌍 Страна: ${response.country}
🗽 Регион: ${response.regionName}
🌆 Город: ${response.city}
🛰 Провайдер: ${response.isp}
🖥 Организация: ${response.district == "" ? "Неизвестно" : response.district}
🔎 AS: ${response.as}
📋 AS-NAME: ${response.asname}
🧲 DNS сервер: ${response.reverse}
📲 Мобильная сеть: ${response.mobile ? "Используется" : "Не используется"}
🔒 Прокси/VPN: ${response.proxy ? "Используется" : "Не используется"}
🚀 Хостинг: ${response.hosting ? "Используется" : "Не используется"}
    """,
          edit: EditOptions(
              lat: response.lat,
              long: response.lon,
              dont_parse_links: false,
              keep_snippets: false));
    } catch (error) {
      await context.editDelete(error.toString());
    }
  });

  hearManager.hear(BasePattern(r"^(?:addchat|добавить)\s(.*)$"), (context) async {
    if (!context.isChat) {
      await context.editDelete("Введи команду в беседе!");
      return;
    }

    try {
      final recourse = await resolveResource(context.match[0].group(1), vk.api);

      switch (recourse["type"]) {
        case "group":
          await VkLib(token: env["BOTPOD"]!)
              .api
              .request("bot.addBotToChat", {"peer_id": context.peerId, "bot_id": -recourse["id"]});
          break;
        case "user":
          await vk.api.messages.addChatUser(chat_id: context.chatId, user_id: recourse["id"]);
          break;
        default:
          await context
              .editDelete("Тип ссылки не подходит! Выявленный тип: ${recourse["type"] ?? "null"}");
      }
    } catch (error) {
      await context.editDelete(error is APIException
          ? (error.code == 15
              ? "Невозможно добавить, возможно потому, что он находится в беседе или закрыл доступ к приглашениям"
              : (error.code == 925 ? "В беседу могут приглашать только админы!" : error.toString()))
          : error.toString());
    }
  });

  hearManager.hear(BasePattern(r"^(?:!token|!токен)\s(.*)$"), (context) async {
    final token = context.match[0].group(1)!;

    if (token.length < 85 || token.length > 85) {
      await context.editDelete("Токен должен содержать ровно 85 символов!");
      return;
    }

    try {
      validateToken(token);
      final vklib = VkLib(token: token);
      try {
        final futureWait = await Future.wait([
              vklib.api.groups.getTokenPermissions(),
              vklib.api.groups.getById(fields: const ["members_count", "verified"])
            ]),
            getTokenPermissions = futureWait[0]["response"]["permissions"] as List,
            getInfo = futureWait[1]["response"][0],
            isClosed = getInfo["is_closed"] as int,
            attachment = await upload.privateMessageAsUrl(getInfo["photo_200"]);

        await context.editDelete("""
Информация о токене группы:
        
ID: @${getInfo["screen_name"]} (${getInfo["id"]})
Имя: ${getInfo["name"]}
Участников: ${separator(getInfo["members_count"])}

${getInfo["verifed"] == 1 ? "✔ Сообщество верифицированно" : ""}
Тип группы: ${isClosed == 0 ? "открытая" : (isClosed == 1 ? "закрытая" : (isClosed == 2 ? "частная" : "неизвестно"))}
Права токена: ${getTokenPermissions.map((e) => e["name"]).join(", ")}
        """, edit: EditOptions(attachment: attachment));
      } catch (error) {
        final userInfo = (await vklib.api.users.get(fields: const [
              "photo_max_orig",
              "online",
              "followers_count",
              "counters"
            ]))["response"][0],
            attachment = await upload.privateMessageAsUrl(userInfo["photo_max_orig"]);

        await context.editDelete("""
Информация о пользователе: 

Полное имя: @id${userInfo["id"]} (${userInfo["first_name"]} ${userInfo["last_name"]})
Количество подписчиков: ${separator(userInfo["followers_count"])}
Количество друзей: ${separator(userInfo["counters"]["friends"])}
Тип профиля: ${userInfo["is_closed"] as bool ? "закрытый" : "открытый"}
Онлайн: ${userInfo["online"] == 1 ? "да" : "нет"}
        """, edit: EditOptions(attachment: attachment));
      }
    } catch (error) {
      await context.editDelete(error.toString());
    }
  });

  hearManager.hear(BasePattern(r"^(?:дем|демотиватор|dem)\s(.*)$"), (context) async {
    try {
      if (!context.hasPhoto &&
          !(context.hasReply && context.replyMessage!.hasPhoto) &&
          !(context.hasForwards && context.forwards[0].hasPhoto)) {
        await context.editDelete("Прикрепите или ответьте на сообщение с изображением!");
        return;
      }

      String? url;

      if (context.hasPhoto) url = context.photo[0].largeSizeUrl;

      if (context.hasReply && context.replyMessage!.hasPhoto)
        url ??= context.replyMessage?.photo[0].largeSizeUrl;

      if (context.hasForwards && context.forwards[0].hasPhoto)
        url ??= context.forwards[0].photo[0].largeSizeUrl;

      final photoByte = await Dio().get(url!, options: Options(responseType: ResponseType.bytes));

      final image = decodeImage(demotivator)!;
      final image2 = copyResize(decodeImage(photoByte.data)!,
          width: 560, height: 410, interpolation: Interpolation.cubic);

      drawImage(image, image2, dstX: 70, dstY: 46);

      drawStringCentered(image, fontDemotivator, context.match[0].group(1)!, y: 500);

      final attachment = await upload.privateMessageAsBytes(encodePng(image));

      await context.editDelete("",
          edit: EditOptions(attachment: attachment), duration: const Duration(minutes: 2));
    } catch (error) {
      await context.editDelete(error.toString());
    }
  });

  hearManager.hear(BasePattern(r"^(?:!tester)\s?(.*)?$"), (context) async {
    try {
      final userId = await getUserId(context, vk.api);

      if (userId == null) {
        await context.editDelete("Не найден ID пользователя");
        return;
      }

      final tester = await getTester(userId);

      await context.editDelete("""
Пользователь: @id${tester.reporter.id}

Статус: ${tester.reporter.statusText}
Позиция в топе: ${tester.reporter.topPosition}
Количество отчетов: ${tester.reporter.reportsCount}

https://vk.com/bugs?act=reporter&id=${tester.reporter.id}
""");
    } catch (error) {
      await context.editDelete(error.toString());
    }
  });
  longpoll.start();
}
