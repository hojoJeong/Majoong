import 'package:json_annotation/json_annotation.dart';

part 'pin_number_request_dto.g.dart';

@JsonSerializable()
class PinNumberRequestDto {
  final String pinNumber;

  PinNumberRequestDto({required this.pinNumber});

  Map<String, dynamic> toJson() => _$PinNumberRequestDtoToJson(this);
}
