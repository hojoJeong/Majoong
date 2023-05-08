import 'package:majoong/model/response/user/friend_response_dto.dart';

class FriendListModel {
  final List<FriendResponseDto> friendRequestList;
  final List<FriendResponseDto> guardianList;
  final List<FriendResponseDto> friendList;

  FriendListModel(
      {required this.friendRequestList,
      required this.guardianList,
      required this.friendList});
}
