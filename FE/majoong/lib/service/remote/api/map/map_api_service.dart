import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/model/request/map/get_facility_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/map/get_facility_response_dto.dart';
import 'package:majoong/service/remote/dio/dio_provider.dart';
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/http.dart';

import '../../../../common/const/path.dart';

part 'map_api_service.g.dart';

final mapApiServiceProvider = Provider<MapApiService>((ref) {
  final dio = ref.watch(dioProvider);
  final mapApiService = MapApiService(dio);
  return mapApiService;
});

@RestApi(baseUrl: BASE_URL)
abstract class MapApiService {
  factory MapApiService(Dio dio, {String baseUrl}) = _MapApiService;

  @Headers({AUTHORIZATION: AUTH})
  @POST('map/facility')
  Future<BaseResponse<GetFacilityResponseDto>> getFacility(
      @Body() GetFacilityRequestDto request);
}
