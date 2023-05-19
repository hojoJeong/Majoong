import 'package:json_annotation/json_annotation.dart';

part 'friend_response_dto.g.dart';

@JsonSerializable()
class FriendResponseDto {
  final int userId;
  final String phoneNumber;
  final String nickname;
  final String profileImage;

  FriendResponseDto(
      {required this.userId,
      required this.phoneNumber,
      required this.nickname,
      required this.profileImage});

  factory FriendResponseDto.fromJson(Map<String, dynamic> json) =>
      _$FriendResponseDtoFromJson(json);
}
