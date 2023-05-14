import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/const/path.dart';
import 'package:majoong/model/response/video/get_recordings_response_dto.dart';
import 'package:majoong/model/response/video/start_video_response_dto.dart';
import 'package:retrofit/http.dart';

import '../../../../common/const/key_value.dart';
import '../../../../model/response/base_response.dart';
import '../../dio/dio_provider.dart';

part 'video_api_service.g.dart';

final videoApiServiceProvider = Provider<VideoApiService>((ref) {
  final dio = ref.watch(dioProvider);
  final videoApiService = VideoApiService(dio);
  return videoApiService;
});
@RestApi(baseUrl: BASE_URL)
abstract class VideoApiService{
  factory VideoApiService(Dio dio, {String baseUrl}) = _VideoApiService;

  @Headers({AUTHORIZATION: AUTH})
  @POST('video/start')
  Future<BaseResponse<StartVideoResponseDto>> startVideo();

  @Headers({AUTHORIZATION: AUTH})
  @GET('video/recordings')
  Future<BaseResponse<List<GetRecordingResponseDto>>> getRecordings();
  
  @Headers({AUTHORIZATION: AUTH})
  @DELETE('video/stop/{sessionId}/{connectionId}')
  Future<BaseResponse> stopVideo(@Path('sessionId') String sessionId, @Path('connectionId') String connectionId);

  @Headers({AUTHORIZATION: AUTH})
  @DELETE('video/recordings/{recordingId}')
  Future<BaseResponse> deleteRecording(@Path('recordingId') String recordingId);

}