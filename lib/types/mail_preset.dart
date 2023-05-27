import 'package:json_annotation/json_annotation.dart';

part 'mail_preset.g.dart';

@JsonSerializable()
class MailPreset {
  String name;
  String text;

  MailPreset(this.name, this.text);

  factory MailPreset.fromJson(Map<String, dynamic> json) => _$MailPresetFromJson(json);

  Map<String, dynamic> toJson() => _$MailPresetToJson(this);
}
