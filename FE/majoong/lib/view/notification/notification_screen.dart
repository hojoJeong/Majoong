import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/layout/default_layout.dart';
import 'package:majoong/common/layout/loading_layout.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/notification_response_dto.dart';
import 'package:majoong/view/friend/friend_list_screen.dart';
import 'package:majoong/view/guardian/guardian_screen.dart';
import 'package:majoong/viewmodel/notification/accept_share_provider.dart';
import 'package:majoong/viewmodel/notification/notification_provider.dart';

import '../../viewmodel/share_loaction/share_location_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationListState = ref.watch(notificationProvider);
    final acceptShareState = ref.watch(acceptShareProvider);
    final shareLocationState = ref.watch(shareLocationProvider);
    if (acceptShareState is BaseResponse &&
        shareLocationState is BaseResponse<bool>) {
      Future.delayed(Duration.zero, () {
        if (acceptShareState.status == 404) {
          showToast(context: context, '유효하지 않는 마중 요청입니다.');
        } else {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => GuardianScreen()));
        }
      });
    }

    if (notificationListState is BaseResponse<List<NotificationResponseDto>>) {
      return DefaultLayout(
          title: '알림',
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: notificationListState.data!.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Text('알림 목록이 없습니다.'),
                        )
                      : ListView.separated(
                          itemBuilder: (context, index) {
                            final notification =
                                notificationListState.data![index];
                            final notiType =
                                notification.type == 1 ? '친구' : '마중';
                            return Slidable(
                              key: ValueKey(notification.notificationId),
                              endActionPane: ActionPane(
                                motion: ScrollMotion(),
                                dismissible: DismissiblePane(
                                  onDismissed: () {
                                    ref
                                        .read(notificationProvider.notifier)
                                        .deleteNotification(
                                            notification.notificationId);
                                    showToast(context: context, '삭제 완료');
                                  },
                                ),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      ref
                                          .read(notificationProvider.notifier)
                                          .deleteNotification(
                                              notification.notificationId);
                                      showToast(context: context, '삭제완료');
                                    },
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                  )
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  if (notification.type == 1) {
                                    ref
                                        .read(notificationProvider.notifier)
                                        .deleteNotification(
                                            notification.notificationId);
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                FriendListScreen()));
                                  } else {
                                    ref
                                        .read(shareLocationProvider.notifier)
                                        .initChannel(true, notification.userId);
                                    ref
                                        .read(acceptShareProvider.notifier)
                                        .acceptShare(notification.userId);
                                  }
                                },
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(
                                          notification.profileImage),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Text.rich(
                                              TextSpan(children: <TextSpan>[
                                            TextSpan(
                                                text: notification.nickname,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        BASE_TITLE_FONT_SIZE)),
                                            TextSpan(
                                                text: '님이 $notiType을 요청했습니다.')
                                          ])),
                                        ),
                                        Visibility(
                                            visible: notification.type == 2,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child:
                                                  Text('클릭하시면 공유 화면으로 이동합니다.'),
                                            )),
                                        Text(notification.phoneNumber)
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => Divider(
                                thickness: 1,
                              ),
                          itemCount: notificationListState.data!.length),
                ),
              ],
            ),
          ));
    } else {
      return Container(color: Colors.grey, child: LoadingLayout());
    }
  }
}
