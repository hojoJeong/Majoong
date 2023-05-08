// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendResponseDto _$FriendResponseDtoFromJson(Map<String, dynamic> json) =>
    FriendResponseDto(
      userId: json['userId'] as int,
      phoneNumber: json['phoneNumber'] as String,
      nickname: json['nickname'] as String,
      profileImage: json['profileImage'] as String,
    );

Map<String, dynamic> _$FriendResponseDtoToJson(FriendResponseDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'phoneNumber': instance.phoneNumber,
      'nickname': instance.nickname,
      'profileImage': instance.profileImage,
    };
