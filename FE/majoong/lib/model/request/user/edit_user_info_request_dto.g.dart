// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_user_info_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditUserInfoRequestDto _$EditUserInfoRequestDtoFromJson(
        Map<String, dynamic> json) =>
    EditUserInfoRequestDto(
      nickname: json['nickname'] as String,
      phoneNumber: json['phoneNumber'] as String,
      profileImage:
          EditUserInfoRequestDto._fileFromJson(json['profileImage'] as String),
    );

Map<String, dynamic> _$EditUserInfoRequestDtoToJson(
        EditUserInfoRequestDto instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'phoneNumber': instance.phoneNumber,
      'profileImage': EditUserInfoRequestDto._fileToJson(instance.profileImage),
    };
