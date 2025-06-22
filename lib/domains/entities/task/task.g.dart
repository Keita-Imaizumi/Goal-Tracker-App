// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskImpl _$$TaskImplFromJson(Map<String, dynamic> json) => _$TaskImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  deadline:
      json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
  done: json['done'] as bool? ?? false,
);

Map<String, dynamic> _$$TaskImplToJson(_$TaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'deadline': instance.deadline?.toIso8601String(),
      'done': instance.done,
    };
