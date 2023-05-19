import 'package:json_annotation/json_annotation.dart';

part 'friend_request_request_dto.g.dart';
@JsonSerializable()
class FriendRequestRequestDto {
  final int userId, friendId;

  FriendRequestRequestDto({required this.userId, required this.friendId});

  Map<String, dynamic> toJson() => _$FriendRequestRequestDtoToJson(this);
}
