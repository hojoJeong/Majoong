import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
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
      return DefaultLayout(title: '녹화 기록', body: Container());
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
