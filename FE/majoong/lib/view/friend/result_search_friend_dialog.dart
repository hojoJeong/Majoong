import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/layout/loading_visibility_provider.dart';
import 'package:majoong/model/response/user/friend_response_dto.dart';
import 'package:majoong/viewmodel/friend/friend_provider.dart';
import 'package:ndialog/ndialog.dart';

class ResultSearchFriendDialog extends ConsumerWidget {
  final FriendResponseDto? friendInfo;
  final bool isSuccess;

  const ResultSearchFriendDialog(
      {Key? key, required this.friendInfo, required this.isSuccess})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NAlertDialog(
      dialogStyle: DialogStyle(titleDivider: true),
      title: Text('친구 검색'),
      content: Column(
        children: [
          Visibility(visible: !isSuccess, child: Text('검색 결과가 없습니다.')),
          Visibility(
            visible: isSuccess,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(friendInfo!.profileImage),
                  ),
                  Text(friendInfo!.nickname),
                  Text(friendInfo!.phoneNumber)
                ],
              ))
        ],
      ),
      actions: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '닫기',
              style: TextStyle(color: Colors.white),
            )),
        Visibility(
          visible: isSuccess,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: POLICE_MARKER_COLOR),
              onPressed: () {
                ref
                    .read(requestFriendProvider.notifier)
                    .requestFriend(friendInfo!.userId);
                ref
                    .read(loadingVisibilityProvider.notifier)
                    .update((state) => true);
                Navigator.pop(context);
              },
              child: const Text(
                '친구 요청',
                style: TextStyle(color: Colors.white),
              )),
        ),
      ],
    );
    ;
  }
}
