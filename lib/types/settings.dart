import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

@JsonSerializable()
class Settings {
  String defaultPlatform;
  String defaultMailPreset;

  Settings({required this.defaultPlatform, required this.defaultMailPreset});

  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  Settings copyWith({String? defaultPlatform, String? defaultMailPreset}) {
    return Settings(
      defaultPlatform: defaultPlatform ?? this.defaultPlatform,
      defaultMailPreset: defaultMailPreset ?? this.defaultMailPreset,
    );
  }
}
