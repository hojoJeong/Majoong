import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/component/signle_button_widget.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/layout/loading_visibility_provider.dart';
import 'package:majoong/model/response/user/friend_response_dto.dart';
import 'package:majoong/viewmodel/friend/friend_provider.dart';
import 'package:ndialog/ndialog.dart';

class ResultSearchFriendDialog {
  final FriendResponseDto? friendInfo;
  final bool isSuccess;

  const ResultSearchFriendDialog(
      {required this.friendInfo, required this.isSuccess})
      : super();

  showDialog(BuildContext context, WidgetRef ref) {
    NAlertDialog(
      dialogStyle: DialogStyle(titleDivider: true),
      title: Text('친구 검색'),
      content: !isSuccess ? Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text('검색 결과가 없습니다.', textAlign: TextAlign.center,),
      )) :  SizedBox(
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            SizedBox(height: 20,),
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(friendInfo!.profileImage),
            ),
            Text(friendInfo!.nickname),
            Text(friendInfo!.phoneNumber)
          ],
        ),
      ),
      actions: [
        !isSuccess ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleButtonWidget(content: '닫기', onPressed: (){
            Navigator.pop(context);
          }),
        ) : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '닫기',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
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
            ),
          ],
        )
      ],
    ).show(context);

  }
}
