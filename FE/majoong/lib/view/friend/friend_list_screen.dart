import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/layout/default_layout.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/friend_response_dto.dart';
import 'package:majoong/view/friend/friend_item_widget.dart';

class FriendListScreen extends ConsumerWidget {
  const FriendListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Row(
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                    ),
                    Text('친구요청'),
                  ],
                ),
                friendRequestListView(ref, context, true, false),
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
                friendRequestListView(ref, context, false, true),
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
                friendRequestListView(ref, context, false, true),
              ],
            ),
          ),
        ));
  }

  Widget friendRequestListView(
      WidgetRef ref, BuildContext context, bool isRequest, bool isGuardian) {
    // final friendRequestListState = ref.read(friendRequestProvider);
    final friendRequestListState =
        BaseResponse(status: 200, message: "", data: [
      FriendResponseDto(
          userId: 1,
          phoneNumber: "01092424723",
          nickname: "정호조",
          profileImage:
              "https://k.kakaocdn.net/dn/bkklEp/btryRtPG1qK/LKRumD2OP1rzeQSrLfulF0/img_640x640.jpg"),
          FriendResponseDto(
              userId: 1,
              phoneNumber: "01092424723",
              nickname: "정호조",
              profileImage:
              "https://k.kakaocdn.net/dn/bkklEp/btryRtPG1qK/LKRumD2OP1rzeQSrLfulF0/img_640x640.jpg"),
          FriendResponseDto(
              userId: 1,
              phoneNumber: "01092424723",
              nickname: "정호조",
              profileImage:
              "https://k.kakaocdn.net/dn/bkklEp/btryRtPG1qK/LKRumD2OP1rzeQSrLfulF0/img_640x640.jpg"),
          FriendResponseDto(
              userId: 1,
              phoneNumber: "01092424723",
              nickname: "정호조",
              profileImage:
              "https://k.kakaocdn.net/dn/bkklEp/btryRtPG1qK/LKRumD2OP1rzeQSrLfulF0/img_640x640.jpg"),
    ]);
    if (friendRequestListState is BaseResponse<List<FriendResponseDto>> &&
        friendRequestListState.status == 200 &&
        friendRequestListState.data!.isNotEmpty) {
      return ListView.separated(
        primary: false,
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 10),
          itemBuilder: (context, index) {
            final data = friendRequestListState.data![index];
            return FriendItemWidget(
              isRequest: isRequest,
              profileImage: data.profileImage,
              nickname: data.nickname,
              phoneNumber: data.phoneNumber,
              isGuardian: isGuardian,
            );
          },
          separatorBuilder: (context, index) => const Divider(
                thickness: 1,
              ),
          itemCount: friendRequestListState.data!.length);
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(
            vertical: BASE_MARGIN_CONTENTS_TO_CONTENTS),
        child: Text('목록이 없습니다.'),
      );
    }
  }
}
