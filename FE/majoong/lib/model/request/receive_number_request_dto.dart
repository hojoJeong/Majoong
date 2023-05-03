import 'package:json_annotation/json_annotation.dart';

part 'receive_number_request_dto.g.dart';

@JsonSerializable()
class ReceiveNumberRequestDto {
  final String phoneNumber;

  ReceiveNumberRequestDto({required this.phoneNumber});

  factory ReceiveNumberRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ReceiveNumberRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ReceiveNumberRequestDtoToJson(this);
}