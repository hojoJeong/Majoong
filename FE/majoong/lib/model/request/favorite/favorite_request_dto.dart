import 'package:json_annotation/json_annotation.dart';

part 'favorite_request_dto.g.dart';

@JsonSerializable()
class FavoriteRequestDto {
  final String address;
  final String locationName;

  FavoriteRequestDto({required this.address, required this.locationName});

  Map<String, dynamic> toJson() => _$FavoriteRequestDtoToJson(this);
}
