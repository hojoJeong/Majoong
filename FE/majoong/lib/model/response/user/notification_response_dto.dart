import 'package:json_annotation/json_annotation.dart';

part 'notification_response_dto.g.dart';
@JsonSerializable()
class NotificationResponseDto {
  final String notificationId;
  final int userId;
  final String profileImage;
  final String nickname;
  final String phoneNumber;
  final int type;

  NotificationResponseDto(
      {required this.notificationId,
      required this.userId,
      required this.profileImage,
      required this.nickname,
      required this.phoneNumber,
      required this.type});

  factory NotificationResponseDto.fromJson(Map<String, dynamic> json) => _$NotificationResponseDtoFromJson(json);
}
