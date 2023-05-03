import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/model/response/map/get_facility_response_dto.dart';
import 'package:majoong/service/remote/api/map/map_api_service.dart';

import '../../common/util/logger.dart';
import '../../model/request/map/get_facility_request_dto.dart';
import '../../model/response/base_response.dart';

final centerPositionProvider = StateProvider<GetFacilityRequestDto>((ref) {
  return GetFacilityRequestDto(centerLng: 0, centerLat: 0, radius: 0);
});

final facilityProvider = StateNotifierProvider((ref) {
  final mapService = ref.watch(mapApiServiceProvider);
  final facilityNotifier = FacilityNotifier(service: mapService);
  return facilityNotifier;
});

class FacilityNotifier extends StateNotifier<BaseResponseState> {
  final MapApiService service;

  FacilityNotifier({required this.service}) : super(BaseResponseLoading()) {}

  getFacility(GetFacilityRequestDto request) {
    logger.d('request: ${request.toJson()}');
    service.getFacility(request).then((value) {
      if (value is BaseResponse && value.data != null) {
        final response = value;
        state = response;
      }
    });
  }
}
