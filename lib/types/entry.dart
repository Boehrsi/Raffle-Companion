import 'package:json_annotation/json_annotation.dart';

part 'entry.g.dart';

@JsonSerializable()
class Entry {
  String name;
  String? key;
  String platform;
  bool used;
  String? tag;

  Entry(this.name, this.key, this.platform, this.tag, [this.used = false]);

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

  Map<String, dynamic> toJson() => _$EntryToJson(this);

  bool equals(Entry entry) => name == entry.name && key == entry.key && platform == entry.platform && used == entry.used && tag == entry.tag;
}

extension EntryList on List<Entry> {
  List<String> uniqueNameList() => map((entry) => entry.name).toSet().toList();
}
