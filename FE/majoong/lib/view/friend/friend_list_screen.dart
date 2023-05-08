import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/layout/default_layout.dart';
import 'package:majoong/common/layout/loading_layout.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/friend_list_model.dart';
import 'package:majoong/model/response/user/friend_response_dto.dart';
import 'package:majoong/view/friend/friend_request_list_view.dart';
import 'package:majoong/viewmodel/friend/friend_provider.dart';

class FriendListScreen extends ConsumerWidget {
  const FriendListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendState = ref.watch(friendProvider);
    ref.listen(friendRequestListProvider, (previous, next) {
      ref.read(friendProvider.notifier).refreshFriendList();
    });
    ref.listen(guardianListProvider, (previous, next) {
      ref.read(friendProvider.notifier).refreshFriendList();
    });
    ref.listen(friendListProvider, (previous, next) {
      ref.read(friendProvider.notifier).refreshFriendList();
    });

    if (friendState is BaseResponse<FriendListModel>) {
      return DefaultLayout(
          title: '친구 목록',
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextField(
                    decoration: InputDecoration(
                        hintText: '전화번호로 친구 추가',
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        suffixIcon: Icon(
                          Icons.search,
                          color: POLICE_MARKER_COLOR,
                        )),
                  ),
                  SizedBox(
                    height: BASE_MARGIN_CONTENTS_TO_CONTENTS,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                      ),
                      Text('친구요청'),
                    ],
                  ),
                  FriendRequestListView(
                    isGuardian: false,
                    isRequest: true,
                    list: friendState.data?.friendRequestList ?? [],
                  ),
                  SizedBox(
                    height: BASE_MARGIN_CONTENTS_TO_CONTENTS,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.people_alt,
                      ),
                      Text('보호자'),
                    ],
                  ),
                  FriendRequestListView(
                    isGuardian: true,
                    isRequest: false,
                    list: friendState.data?.guardianList ?? [],
                  ),
                  SizedBox(
                    height: BASE_MARGIN_CONTENTS_TO_CONTENTS,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                      ),
                      Text('친구 목록'),
                    ],
                  ),
                  FriendRequestListView(
                    isGuardian: false,
                    isRequest: false,
                    list: friendState.data?.friendList ?? [],
                  ),
                  SizedBox(
                    height: 40,
                  )
                ],
              ),
            ),
          ));
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey,
        ),
        child: LoadingLayout(),
      );
    }
  }
}
