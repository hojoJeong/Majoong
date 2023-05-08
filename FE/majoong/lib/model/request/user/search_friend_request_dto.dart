import 'package:json_annotation/json_annotation.dart';

part 'search_friend_request_dto.g.dart';

@JsonSerializable()
class SearchFriendRequestDto {
  final String phoneNumber;

  SearchFriendRequestDto({required this.phoneNumber});

  Map<String, dynamic> toJson() => _$SearchFriendRequestDtoToJson(this);
}
