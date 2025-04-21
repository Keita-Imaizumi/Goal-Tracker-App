// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goals.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GoalImpl _$$GoalImplFromJson(Map<String, dynamic> json) => _$GoalImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  status: json['status'] as String,
  detail: json['detail'] as String?,
  deadline:
      json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
  done: json['done'] as bool? ?? false,
);

Map<String, dynamic> _$$GoalImplToJson(_$GoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'status': instance.status,
      'detail': instance.detail,
      'deadline': instance.deadline?.toIso8601String(),
      'done': instance.done,
    };
