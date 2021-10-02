// ignore_for_file: unnecessary_getters_setters

class ConvertKeyboard {
  String keys, values;
  String? _english, _russian;

  ConvertKeyboard({required this.keys, required this.values});

  void convert(String message) {
    final reverse = <String, String>{};
    final full = <String, String>{};

    keys.split("").asMap().forEach((index, element) {
      full[element.toUpperCase()] = values[index].toUpperCase();
      full[element] = values[index];
    });

    Map.fromEntries(full.entries.toList()).forEach((en, ru) => reverse[ru] = en);

    String replacesTr([bool reverses = false]) => message.replaceAllMapped(RegExp(r"."),
        (substring) => (reverses ? reverse : full)[substring.group(0)!] ?? substring.group(0)!);

    russian = replacesTr();
    english = replacesTr(true);
  }

  String? get english => _english;
  set english(String? eng) => _english = eng;

  String? get russian => _russian;
  set russian(String? rus) => _russian = rus;
}
