import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/layout/default_layout.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/video/get_recordings_response_dto.dart';
import 'package:majoong/viewmodel/video/videoProvider.dart';

import '../../common/layout/loading_layout.dart';
import '../../common/util/logger.dart';

class VideoScreen extends ConsumerWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoInfo = ref.watch(videoProvider);
    logger.d('videoscreen build');
    if (videoInfo is BaseResponse<List<GetRecordingResponseDto>>) {
      return DefaultLayout(
        title: '녹화 기록',
        body: ListView.builder(
          itemCount: videoInfo.data!.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.15,
                  decoration: BoxDecoration(),
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.height * 0.15,
                        height: MediaQuery.of(context).size.height * 0.15,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              videoInfo.data![index].thumbnailImageUrl ?? '',
                          placeholder: (context, url) =>
                              LoadingAnimationWidget.staggeredDotsWave(
                                  color: Colors.white, size: 60),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            videoInfo.data![index].createdAt,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            (videoInfo.data![index].duration / 60).toInt() > 0
                                ? "${(videoInfo.data![index].duration / 60).toInt()}분 ${videoInfo.data![index].duration % 60}초"
                                : "${videoInfo.data![index].duration % 60}초",
                            style: TextStyle(color: Colors.black38),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: Color(0xFFEFEFEF),
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Text(
                                      '삭제',
                                      style: TextStyle(color: Colors.black),
                                    )),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  showToast(context: context, '다운로드 시작');
                                  await GallerySaver.saveVideo(
                                      videoInfo.data![index].recordingUrl);
                                  showToast(context: context, '저장 되었습니다');
                                },
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: PRIMARY_COLOR,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Text(
                                      '저장',
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Divider(),
              ],
            );
          },
        ),
      );
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
