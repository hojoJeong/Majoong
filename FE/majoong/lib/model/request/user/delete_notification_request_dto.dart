import 'package:json_annotation/json_annotation.dart';

part 'delete_notification_request_dto.g.dart';

@JsonSerializable()
class DeleteNotificationRequestDto {
  final String notificationId;

  DeleteNotificationRequestDto({required this.notificationId});

  Map<String, dynamic> toJson() => _$DeleteNotificationRequestDtoToJson(this);
}