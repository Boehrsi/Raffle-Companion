// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) => Config(
  width: (json['width'] as num).toDouble(),
  height: (json['height'] as num).toDouble(),
  theme: json['theme'] as String?,
);

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{
  'width': instance.width,
  'height': instance.height,
  'theme': instance.theme,
};
