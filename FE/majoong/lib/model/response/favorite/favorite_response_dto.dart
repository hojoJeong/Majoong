import 'package:json_annotation/json_annotation.dart';

part 'favorite_response_dto.g.dart';

@JsonSerializable()
class FavoriteResponseDto {
  final int favoriteId;
  final String locationName;
  final String address;

  FavoriteResponseDto(
      {required this.favoriteId,
      required this.locationName,
      required this.address});

  factory FavoriteResponseDto.fromJson(Map<String, dynamic> json) => _$FavoriteResponseDtoFromJson(json);
}
