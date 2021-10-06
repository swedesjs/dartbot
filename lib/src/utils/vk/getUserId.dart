import "package:vklib/utils.dart" show resolveResource;
import "package:vklib/vklib.dart" show API;

import "../../context/message_context.dart" show MessageContext;

Future<int> getUserId(MessageContext context, API api) async =>
    context.replyMessage?.senderId ??
    (await resolveResource(context.match[0].group(1), api))["id"] as int;
