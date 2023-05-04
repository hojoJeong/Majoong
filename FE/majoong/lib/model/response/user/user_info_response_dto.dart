import 'package:json_annotation/json_annotation.dart';

part 'user_info_response_dto.g.dart';

@JsonSerializable()
class UserInfoResponseDto {
  final int userId;
  final String phoneNumber;
  final String nickname;
  final String profileImage;
  final int alarmCount;

  UserInfoResponseDto({
    required this.userId,
    required this.phoneNumber,
    required this.nickname,
    required this.profileImage,
    required this.alarmCount,
  });

  factory UserInfoResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserInfoResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoResponseDtoToJson(this);
}
