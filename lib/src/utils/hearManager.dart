import "../context/message_context.dart";

typedef _HearCallback = Future<void> Function(MessageContext context);

class _Command {
  List<dynamic> lastCommand;

  _Command(this.lastCommand);

  Pattern get pattern => lastCommand[0];
  _HearCallback get callback => lastCommand[1];
}

class HearManager {
  List<List<dynamic>> command = [];

  _HearCallback get middleware => (context) async {
        if (context.text == null) return;

        List<dynamic> getCommand;

        // ignore: omit_local_variable_types, avoid_init_to_null
        List<Match>? patternCommand = null;

        getCommand = command.where((element) {
          final patternCommands = _Command(element).pattern.allMatches(context.text!).toList();

          if (patternCommands.isNotEmpty) {
            patternCommand = patternCommands;
            return true;
          }

          return false;
        }).toList();

        if (getCommand.isEmpty) return;
        context.match = patternCommand!;

        // ignore: avoid_function_literals_in_foreach_calls
        getCommand.forEach((element) async => await _Command(element).callback(context));
      };

  void hear(Pattern pattern, _HearCallback callback) => command.add([pattern, callback]);
}
