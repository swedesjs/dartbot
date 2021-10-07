// ignore_for_file: non_constant_identifier_names

import "package:vklib/src/core/utils/keyboard.dart";
import "package:vklib/vklib.dart";

import "../objects/editOptions.dart";
import "../objects/forwards.dart";
import "../objects/photoAttachment.dart";
import "../objects/reply.dart";
import "../utils/utils.dart";

class MessageContext {
  final int _idParam;
  final API _api;

  // ignore: avoid_init_to_null
  late List<Match> match;
  late Json options;

  MessageContext(this._api, this._idParam);

  int get id => options["id"];

  int get peerId => options["peer_id"];

  int get createdAt => options["date"];

  String? get text => options["text"];

  int get senderId => options["from_id"];

  int? get chatId => isChat ? (peerId - peerChatIdOffset).toInt() : null;

  Reply? get replyMessage =>
      options["reply_message"] != null ? Reply(options["reply_message"]) : null;

  List<Forwards> get forwards => (options["fwd_messages"] as List).map((e) => Forwards(e)).toList();

  List<PhotoAttachment> get photo => (options["attachments"] as List)
      .where((element) => element["type"] == "photo")
      .map((e) => PhotoAttachment(e["photo"]))
      .toList();

  bool get hasReply => replyMessage != null;
  bool get hasForwards => forwards.isNotEmpty;
  bool get hasPhoto => photo.isNotEmpty;

  bool get isChat => peerType == MessageSource.CHAT;
  bool get isUser => senderType == MessageSource.USER;
  bool get isGroup => senderType == MessageSource.GROUP;

  bool get isFromUser => peerType == MessageSource.USER;
  bool get isFromGroup => peerType == MessageSource.GROUP;

  bool get isDM => isFromUser || isFromGroup;

  MessageSource get peerType => getPeerType(peerId);
  MessageSource get senderType => getPeerType(senderId);

  Future<int> send(String message,
          {int? user_id,
          int? random_id,
          int? peer_id,
          List<dynamic>? peer_ids,
          String? domain,
          int? chat_id,
          List<dynamic>? user_ids,
          dynamic lat,
          dynamic long,
          String? attachment,
          int? reply_to,
          List<dynamic>? forward_messages,
          String? forward,
          int? sticker_id,
          int? group_id,
          KeyboardBuilder? keyboard,
          String? template,
          String? payload,
          String? content_source,
          bool? dont_parse_links,
          bool? disable_mentions,
          String? intent,
          int? subscribe_id}) async =>
      (await _api.messages.send(
          peer_id: peer_id ?? peerId,
          message: message,
          random_id: random_id,
          attachment: attachment,
          chat_id: chat_id,
          content_source: content_source,
          disable_mentions: disable_mentions,
          domain: domain,
          dont_parse_links: dont_parse_links,
          forward: forward,
          forward_messages: forward_messages,
          group_id: group_id,
          intent: intent,
          keyboard: keyboard,
          lat: lat,
          long: long,
          payload: payload,
          peer_ids: peer_ids,
          reply_to: reply_to,
          sticker_id: sticker_id,
          subscribe_id: subscribe_id,
          template: template,
          user_id: user_id,
          user_ids: user_ids))["response"];

  Future<int> editMessage(String message,
          {dynamic lat,
          dynamic long,
          String? attachment,
          bool? keep_forward_messages,
          bool? keep_snippets,
          int? group_id,
          bool? dont_parse_links,
          int? message_id,
          int? conversation_message_id,
          String? template,
          KeyboardBuilder? keyboard}) async =>
      (await _api.messages.edit(
          peer_id: peerId,
          message: message,
          lat: lat,
          long: long,
          attachment: attachment,
          keep_forward_messages: keep_forward_messages,
          keep_snippets: keep_snippets,
          group_id: group_id,
          dont_parse_links: dont_parse_links,
          message_id: message_id ?? id,
          conversation_message_id: conversation_message_id,
          template: template,
          keyboard: keyboard?.toString()))["response"];

  Future<bool> editDelete(String message,
      {Duration duration = const Duration(minutes: 1), EditOptions? edit}) async {
    try {
      try {
        await editMessage(message,
            lat: edit?.lat,
            long: edit?.long,
            keep_snippets: edit?.keep_snippets,
            dont_parse_links: edit?.dont_parse_links,
            attachment: edit?.attachment);
      } catch (error) {
        await editMessage(error.toString());
      }

      await Future.delayed(duration);

      return await deleteMessage(message_ids: [id], delete_for_all: true);
    } catch (error) {
      try {
        await send(error.toString());
        // ignore: empty_catches
      } catch (err) {}
    }

    return false;
  }

  Future<bool> deleteMessage(
          {List<dynamic>? message_ids,
          bool? spam,
          int? group_id,
          bool? delete_for_all,
          int? peer_id,
          List<dynamic>? conversation_message_ids}) async =>
      ((await _api.messages.delete(
              peer_id: peer_id ?? peerId,
              message_ids: message_ids ?? [id],
              spam: spam,
              group_id: group_id,
              delete_for_all: delete_for_all,
              conversation_message_ids: conversation_message_ids))["response"] as Map)
          .values
          .every((element) => element as int == 1);

  Future<void> loadMessagePayload() async => options =
      (await _api.messages.getById(message_ids: [_idParam]))["response"]["items"][0] as Json;
}
