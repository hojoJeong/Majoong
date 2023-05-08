// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationResponseDto _$NotificationResponseDtoFromJson(
        Map<String, dynamic> json) =>
    NotificationResponseDto(
      notificationId: json['notificationId'] as String,
      userId: json['userId'] as int,
      profileImage: json['profileImage'] as String,
      nickname: json['nickname'] as String,
      phoneNumber: json['phoneNumber'] as String,
      type: json['type'] as int,
    );

Map<String, dynamic> _$NotificationResponseDtoToJson(
        NotificationResponseDto instance) =>
    <String, dynamic>{
      'notificationId': instance.notificationId,
      'userId': instance.userId,
      'profileImage': instance.profileImage,
      'nickname': instance.nickname,
      'phoneNumber': instance.phoneNumber,
      'type': instance.type,
    };
