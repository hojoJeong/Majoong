import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/viewmodel/friend/friend_provider.dart';

class FriendItemWidget extends ConsumerWidget {
  final bool isRequest;
  final String profileImage;
  final String nickname;
  final String phoneNumber;
  final bool isGuardian;
  final int friendId;

  const FriendItemWidget(
      {Key? key,
      required this.isRequest,
      required this.profileImage,
      required this.nickname,
      required this.phoneNumber,
      required this.isGuardian,
      required this.friendId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Slidable(
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              if (isRequest) {
                ref.read(friendRequestListProvider.notifier).denyFriend(friendId);
              } else if (isGuardian) {
                ref.read(guardianListProvider.notifier).editGuardian(friendId);
              } else {
                ref.read(friendListProvider.notifier).deleteFriend(friendId);
              }
            },
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Icons.delete,
          ),
          Visibility(
            visible: !isRequest,
            child: SlidableAction(
              onPressed: (context) {
                ref.read(guardianListProvider.notifier).editGuardian(friendId);
              },
              backgroundColor: POLICE_MARKER_COLOR,
              foregroundColor: Colors.white,
              icon: isGuardian ? Icons.group_off : Icons.people_alt,
            ),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(profileImage),
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nickname,
                style: TextStyle(
                    fontSize: BASE_TITLE_FONT_SIZE,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                phoneNumber,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
              )
            ],
          ),
          Spacer(),
          Visibility(
              visible: isRequest,
              child: GestureDetector(
                  onTap: () {
                    ref
                        .read(friendRequestListProvider.notifier)
                        .acceptFriend(friendId);
                  },
                  child: Icon(Icons.person_add_rounded)))
        ],
      ),
    );
  }
}
