import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/util/logger.dart';

class FriendItemWidget extends ConsumerWidget {
  final bool isRequest;
  final String profileImage;
  final String nickname;
  final String phoneNumber;
  final bool isGuardian;

  const FriendItemWidget(
      {Key? key,
      required this.isRequest,
      required this.profileImage,
      required this.nickname,
      required this.phoneNumber,
      required this.isGuardian})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Slidable(
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context){
              //TODO 삭제 API 호출
            },
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Icons.delete,
          ),
          SlidableAction(
            onPressed: (context){
              //TODO 수락 or 보호자 등록 API 호출
            },
            backgroundColor: POLICE_MARKER_COLOR,
            foregroundColor: Colors.white,
            icon: isRequest ? Icons.person_add_rounded : Icons.people_alt,
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
          SizedBox(width: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(nickname, style: TextStyle(
              fontSize: BASE_TITLE_FONT_SIZE,
              fontWeight: FontWeight.bold
            ),), Text(phoneNumber, style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),)],
          ),
          Spacer(),
          Visibility(visible: isRequest, child: Icon(Icons.person_add_rounded))
        ],
      ),
    );
  }
}
