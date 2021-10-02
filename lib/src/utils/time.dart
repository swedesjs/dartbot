import "declOfNum.dart";

String unixStampTime(num stamp) {
  stamp = (stamp / 1e3);

  final second = stamp % 60;
  stamp = (stamp - second) / 60;

  final minutes = stamp % 60;
  stamp = (stamp - minutes) / 60;

  final house = stamp % 24;
  stamp = (stamp - house) / 24;

  final day = stamp % 31;
  stamp = (stamp - day) / 31;

  final mes = stamp % 12;
  final year = (stamp - mes) / 12;

  return "${year > 0 ? "${year.floor()} ${declOfNum(year, [
          "г",
          "л",
          "л"
        ])}. " : ""}${mes > 0 ? "${mes.floor()} мес. " : ""}${day > 0 ? "${day.floor()} д. " : ""}${house > 0 ? "${house.floor()} ч. " : ""}${minutes > 0 ? "${minutes.floor()} м. " : ""}${second > 0 ? "${second.floor()} с. " : ""}";
}

String unixTime(int stamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(stamp);

  return "${_condition(date.day)}.${_condition(date.month)}.${_condition(date.year)}, ${_condition(date.hour)}:${_condition(date.minute)}:${_condition(date.second)}";
}

String _condition(int value) => value < 10 ? "0$value" : value.toString();
