// ignore_for_file: non_constant_identifier_names

class EditOptions {
  num? lat, long;
  bool? keep_snippets, dont_parse_links;
  String? attachment;
  EditOptions({this.lat, this.long, this.keep_snippets, this.dont_parse_links, this.attachment});
}