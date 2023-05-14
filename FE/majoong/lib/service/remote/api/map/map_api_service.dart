import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/model/request/map/get_facility_request_dto.dart';
import 'package:majoong/model/request/map/search_route_request_dto.dart';
import 'package:majoong/model/request/map/share_route_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/map/accept_share_route_response_dto.dart';
import 'package:majoong/model/response/map/get_facility_response_dto.dart';
import 'package:majoong/model/response/map/search_route_response_dto.dart';
import 'package:majoong/service/remote/dio/dio_provider.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

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

  @Headers({
    AUTHORIZATION: AUTH,
    'Content-Type': 'multipart/form-data; boundary=----WebKitFormBoundary12345'
  })
  @POST('map/review')
  @MultiPart()
  Future<BaseResponse> postReview(
      @Part(name: 'reviewImage', contentType: 'multipart/form-data')
          FormData formData,
      @Body()
          Map<String, dynamic> data);

  @Headers({AUTHORIZATION: AUTH})
  @POST('map/path')
  Future<BaseResponse<SearchRouteResponseDto>> getRoute(@Body() SearchRouteRequestDto request);

  @Headers({AUTHORIZATION: AUTH})
  @POST('map/share')
  Future<BaseResponse> shareRoute(@Body() ShareRouteRequestDto request);

  @Headers({AUTHORIZATION: AUTH})
  @GET('map/share/{userId}')
  Future<BaseResponse<AcceptShareRouteResponseDto>> acceptShareRoute(@Path('userId') int userId);

}
