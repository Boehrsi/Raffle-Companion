// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entry _$EntryFromJson(Map<String, dynamic> json) => Entry(
  json['name'] as String,
  json['key'] as String?,
  json['platform'] as String,
  json['tag'] as String?,
  json['used'] as bool? ?? false,
);

Map<String, dynamic> _$EntryToJson(Entry instance) => <String, dynamic>{
  'name': instance.name,
  'key': instance.key,
  'platform': instance.platform,
  'used': instance.used,
  'tag': instance.tag,
};
