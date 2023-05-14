import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/video/get_recordings_response_dto.dart';
import 'package:majoong/model/response/video/start_video_response_dto.dart';
import '../../service/remote/api/video/video_api_service.dart';

final videoProvider = StateNotifierProvider<VideoStateNotifier, BaseResponseState>((ref) {
  final videoService = ref.read(videoApiServiceProvider);
  final notifier = VideoStateNotifier(videoService: videoService);
  return notifier;
});

class VideoStateNotifier extends StateNotifier<BaseResponseState>{
  final VideoApiService videoService;
  late StartVideoResponseDto sessionInfo ;
  VideoStateNotifier({required this.videoService}): super(BaseResponse(status: 200, message: 'message', data: null));

  getRecordings() async {
    state = BaseResponseLoading();
    final BaseResponse<List<GetRecordingResponseDto>> response = await videoService.getRecordings();
    if(response.status == 200){
      state = response;
    }
  }

  startVideo() async {
    state = BaseResponseLoading();
    final BaseResponse<StartVideoResponseDto> response = await videoService.startVideo();
    if(response.status == 200){
      sessionInfo = response.data!;
      state = response;
    }
  }

  stopVideo() async {
    state = BaseResponseLoading();
    final BaseResponse response = await videoService.stopVideo(sessionInfo.sessionId, sessionInfo.connectionId);
    if(response.status == 200){
      state = response;
    }
  }
}