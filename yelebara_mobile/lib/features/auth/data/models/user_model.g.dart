// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  phone: json['phone'] as String,
  name: json['name'] as String?,
  role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.client,
  token: json['token'] as String?,
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'name': instance.name,
      'role': _$UserRoleEnumMap[instance.role]!,
      'token': instance.token,
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.client: 'client',
  UserRole.presseur: 'presseur',
  UserRole.other: 'other',
};
