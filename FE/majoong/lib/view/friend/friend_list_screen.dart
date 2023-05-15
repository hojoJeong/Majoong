import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/layout/default_layout.dart';
import 'package:majoong/common/layout/loading_layout.dart';
import 'package:majoong/common/layout/loading_visibility_provider.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/friend_list_model.dart';
import 'package:majoong/model/response/user/friend_response_dto.dart';
import 'package:majoong/view/friend/friend_request_list_view.dart';
import 'package:majoong/view/friend/result_search_friend_dialog.dart';
import 'package:majoong/viewmodel/friend/friend_provider.dart';
import 'package:ndialog/ndialog.dart';

class FriendListScreen extends ConsumerWidget {
  const FriendListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchTextFieldController = TextEditingController();
    final friendState = ref.watch(friendProvider);
    final requestFriendState = ref.watch(requestFriendProvider);

    Future.delayed(Duration.zero, () {
      if (requestFriendState is BaseResponse) {
        if (requestFriendState.status == 200) {
          showToast(context: context, '요청이 완료되었습니다.');
        } else if (requestFriendState.status == 603) {
          showToast(context: context, '이미 친구입니다.');
        }
        ref.read(requestFriendProvider.notifier).refreshState();
        ref.read(loadingVisibilityProvider.notifier).update((state) => false);
      }
    });

    ref.listen(friendRequestListProvider, (previous, next) {
      ref.read(friendProvider.notifier).refreshFriendList();
    });
    ref.listen(guardianListProvider, (previous, next) {
      ref.read(friendProvider.notifier).refreshFriendList();
    });
    ref.listen(friendListProvider, (previous, next) {
      ref.read(friendProvider.notifier).refreshFriendList();
    });
    ref.listen(searchFriendProvider, (previous, response) {
      if ((response is BaseResponse && response.status == 200) ||
          (response is BaseResponse && response.status == 601)) {
        ref.read(loadingVisibilityProvider.notifier).update((state) => false);
        ResultSearchFriendDialog(
                friendInfo: response.data,
                isSuccess: response.status == 200 ? true : false)
            .showDialog(context, ref);
      }
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
                    controller: searchTextFieldController,
                    decoration: InputDecoration(
                        hintText: '전화번호로 친구 추가',
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            if (searchTextFieldController.text.isEmpty) {
                              showToast(context: context, '전화번호를 입력해주세요');
                            } else {
                              ref
                                  .read(loadingVisibilityProvider.notifier)
                                  .update((state) => true);
                              ref
                                  .read(searchFriendProvider.notifier)
                                  .searchFriend(searchTextFieldController.text);
                            }
                          },
                          child: Icon(
                            Icons.search,
                            color: POLICE_MARKER_COLOR,
                          ),
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
