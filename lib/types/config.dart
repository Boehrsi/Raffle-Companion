import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

part 'config.g.dart';

@JsonSerializable()
class Config {
  double width;
  double height;

  Config(this.width, this.height);

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigToJson(this);
}

extension SizeToConfig on Size {
  Config toConfig() => Config(width, height);
}
