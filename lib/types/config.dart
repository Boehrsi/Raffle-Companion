import 'package:fluent_ui/fluent_ui.dart';
import 'package:json_annotation/json_annotation.dart';

part 'config.g.dart';

@JsonSerializable()
class Config {
  double width;
  double height;
  String? theme;

  Config({required this.width, required this.height, required this.theme});

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigToJson(this);

  Config copyWith({Size? size, String? theme}) {
    return Config(
      width: size?.width ?? width,
      height: size?.height ?? height,
      theme: theme ?? this.theme,
    );
  }
}
