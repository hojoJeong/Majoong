// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_user_info_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditUserInfoResponseDto _$EditUserInfoResponseDtoFromJson(
        Map<String, dynamic> json) =>
    EditUserInfoResponseDto(
      nickname: json['nickname'] as String,
      phoneNumber: json['phoneNumber'] as String,
      profileImage: json['profileImage'] as String,
    );

Map<String, dynamic> _$EditUserInfoResponseDtoToJson(
        EditUserInfoResponseDto instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'phoneNumber': instance.phoneNumber,
      'profileImage': instance.profileImage,
    };
