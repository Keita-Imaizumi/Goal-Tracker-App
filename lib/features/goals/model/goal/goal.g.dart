// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GoalImpl _$$GoalImplFromJson(Map<String, dynamic> json) => _$GoalImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  status: json['status'] as String,
  detail: json['detail'] as String?,
  deadline: _fromTimestamp(json['deadline']),
  done: json['done'] as bool? ?? false,
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$GoalImplToJson(_$GoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'status': instance.status,
      'detail': instance.detail,
      'deadline': _toTimestamp(instance.deadline),
      'done': instance.done,
      'tags': instance.tags,
    };
