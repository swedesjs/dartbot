import "package:vklib/utils.dart" show resolveResource;
import "package:vklib/vklib.dart" show API;

import "../../context/message_context.dart" show MessageContext;

Future<int?> getUserId(MessageContext context, API api) async {
  if (context.replyMessage != null) return context.replyMessage!.senderId;
  if (context.forwards.isNotEmpty) return context.forwards[0].senderId;

  try {
    final messageText = context.match[0].group(1);
    if (messageText != null) return (await resolveResource(messageText, api))["id"] as int;
    // ignore: empty_catches
  } catch (error) {}

  return null;
}
