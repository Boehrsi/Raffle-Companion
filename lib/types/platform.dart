import 'package:json_annotation/json_annotation.dart';

part 'platform.g.dart';

@JsonSerializable()
class Platform {
  String name;

  Platform(this.name);

  factory Platform.fromJson(Map<String, dynamic> json) =>
      _$PlatformFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformToJson(this);
}
