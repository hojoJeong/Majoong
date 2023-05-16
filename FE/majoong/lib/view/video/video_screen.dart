import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/layout/default_layout.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/video/get_recordings_response_dto.dart';
import 'package:majoong/viewmodel/video/videoProvider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                        child: GestureDetector(
                          onTap: () async {
                            final url = videoInfo.data![index].recordingUrl;
                            await canLaunch(url)
                                ? await launch(url)
                                : throw 'Could not launch $url';
                          },
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
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(
                                            builder: (context, setState) {
                                          return AlertDialog(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            content: Text('정말로 삭제하시겠습니까?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('취소')),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    ref
                                                        .read(videoProvider
                                                            .notifier)
                                                        .deleteRecording(
                                                            '${videoInfo.data![index].recordingId}');
                                                  },
                                                  child: Text('삭제')),
                                            ],
                                          );
                                        });
                                      });
                                },
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
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(
                                            builder: (context, setState) {
                                          return AlertDialog(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      '영상이 갤러리에 저장됩니다.\n\n저장하시겠습니까?'),
                                                  Text(
                                                    '(WI-FI 사용 권장))',
                                                    style: TextStyle(
                                                        color: PRIMARY_COLOR,
                                                        fontSize: 12),
                                                  )
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('취소')),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    GallerySaver.saveVideo(
                                                        videoInfo.data![index]
                                                            .recordingUrl);
                                                  },
                                                  child: Text('저장')),
                                            ],
                                          );
                                        });
                                      });
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
