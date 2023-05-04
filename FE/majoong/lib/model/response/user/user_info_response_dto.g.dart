// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfoResponseDto _$UserInfoResponseDtoFromJson(Map<String, dynamic> json) =>
    UserInfoResponseDto(
      userId: json['userId'] as int,
      phoneNumber: json['phoneNumber'] as String,
      nickname: json['nickname'] as String,
      profileImage: json['profileImage'] as String,
      alarmCount: json['alarmCount'] as int,
    );

Map<String, dynamic> _$UserInfoResponseDtoToJson(
        UserInfoResponseDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'phoneNumber': instance.phoneNumber,
      'nickname': instance.nickname,
      'profileImage': instance.profileImage,
      'alarmCount': instance.alarmCount,
    };
