import "extension.dart";

String separator(num number, [String separator = ",", String dotSymbol = "."]) {
  final splittedNumber = number.abs().toString().split(".");

  final array = splittedNumber[0].split("").reversed;

  splittedNumber[0] =
      List.from(array.mapIndexed((index, value) => (index > 0 && (index < array.length)) && (index % 3) == 0 ? "$value$separator" : value))
          .reversed
          .join("");

  return "${number.sign < 0 ? "-" : ""}${splittedNumber.join(dotSymbol)}";
}