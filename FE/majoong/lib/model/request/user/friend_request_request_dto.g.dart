// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_request_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendRequestRequestDto _$FriendRequestRequestDtoFromJson(
        Map<String, dynamic> json) =>
    FriendRequestRequestDto(
      userId: json['userId'] as int,
      friendId: json['friendId'] as int,
    );

Map<String, dynamic> _$FriendRequestRequestDtoToJson(
        FriendRequestRequestDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'friendId': instance.friendId,
    };
