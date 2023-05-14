import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/component/signle_button_widget.dart';
import 'package:majoong/common/layout/default_layout.dart';
import 'package:majoong/common/layout/loading_layout.dart';
import 'package:majoong/model/request/map/share_route_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/viewmodel/search/get_guardians_provider.dart';
import 'package:majoong/viewmodel/search/selected_guardian_provider.dart';

import '../../common/const/size_value.dart';
import '../../common/util/logger.dart';
import '../../model/response/map/route_info_response_dto.dart';
import '../../model/response/user/friend_response_dto.dart';
import '../../viewmodel/share_loaction/share_location_provider.dart';
import '../on_going/on_going_screen.dart';

class SelectGuardiansScreen extends ConsumerStatefulWidget {
  final RouteInfoResponseDto path;
  SelectGuardiansScreen({super.key, required this.path});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SelectGuardiansState(path: path);
}

class _SelectGuardiansState extends ConsumerState<SelectGuardiansScreen>{
  final RouteInfoResponseDto path;
  _SelectGuardiansState({required this.path});
  @override
  Widget build(BuildContext context) {
    final selectGuardianState = ref.watch(selectedGuardianProvider);
    final guardianListState = ref.watch(getGuardianListProvider);
    final shareLocationState = ref.watch(shareLocationProvider);

    if (shareLocationState is BaseResponse) {
      logger.d('이동 준비 완료 : ${shareLocationState.message}');
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => OnGoingScreen(route: path,)));
      });
    }

    if (guardianListState is BaseResponse<List<FriendResponseDto>>) {
      return DefaultLayout(
          title: '보호자 선택',
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                guardianListView(ref, context, guardianListState.data ?? []),
                SingleButtonWidget(
                    content: '경로 탐색',
                    onPressed: () {
                      ref.read(shareLocationProvider.notifier).requestShare(
                          ShareRouteRequestDto(
                              userId: ref
                                  .read(getGuardianListProvider.notifier)
                                  .userId,
                              guardians: selectGuardianState,
                              path: path));
                      ref
                          .read(shareLocationProvider.notifier)
                          .initChannel(false, -1);
                    })
              ],
            ),
          ));
    } else {
      return LoadingLayout();
    }
  }

  Widget guardianListView(WidgetRef ref,
      BuildContext context, List<FriendResponseDto> guardianList) {
    if (guardianList.isEmpty) {
      return Text('등록된 보호자가 없습니다.\n친구목록에서 보호자를 등록해주세요.');
    } else {
      bool checked = false;
      return Expanded(
        child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final guardian = guardianList[index];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(guardian.profileImage),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guardian.nickname,
                        style: TextStyle(
                            fontSize: BASE_TITLE_FONT_SIZE,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        guardian.phoneNumber,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                  Spacer(),
                  Checkbox(
                      value: ref.read(selectedGuardianProvider.notifier).guardianList.contains(guardian.userId),
                      onChanged: (bool? checked) {
                        setState(() {
                          ref.read(selectedGuardianProvider.notifier).editGuardian(guardian.userId);
                        });
                      })
                ],
              );
            },
            separatorBuilder: (context, index) => Divider(
              thickness: 1,
            ),
            itemCount: guardianList.length),
      );
    }
  }

}