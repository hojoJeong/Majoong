import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/friend_response_dto.dart';
import 'package:majoong/view/friend/friend_item_widget.dart';

class FriendRequestListView extends ConsumerWidget {
  final bool isRequest, isGuardian;
  final List<FriendResponseDto> list;

  const FriendRequestListView(
      {Key? key,
      required this.isGuardian,
      required this.isRequest,
      required this.list})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (list.isNotEmpty) {
      return ListView.separated(
          primary: false,
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 10),
          itemBuilder: (context, index) {
            final data = list[index];
            return FriendItemWidget(
              isRequest: isRequest,
              profileImage: data.profileImage,
              nickname: data.nickname,
              phoneNumber: data.phoneNumber,
              isGuardian: isGuardian,
              friendId: data.userId,
            );
          },
          separatorBuilder: (context, index) => const Divider(
                thickness: 1,
              ),
          itemCount: list.length);
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: BASE_PADDING),
        child: isRequest ? Text('받은 친구 요청이 없습니다.') : Text('목록이 없습니다.'),
      );
    }
  }
}
