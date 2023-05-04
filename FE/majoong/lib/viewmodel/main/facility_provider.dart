import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:majoong/model/response/map/get_facility_response_dto.dart';
import 'package:majoong/service/remote/api/map/map_api_service.dart';
import 'package:majoong/viewmodel/main/marker_provider.dart';

import '../../common/util/logger.dart';
import '../../model/request/map/get_facility_request_dto.dart';
import '../../model/response/base_response.dart';

final centerPositionProvider = StateProvider<GetFacilityRequestDto>((ref) {
  return GetFacilityRequestDto(centerLng: 0, centerLat: 0, radius: 0);
});

final facilityProvider =
    StateNotifierProvider<FacilityNotifier, BaseResponseState>((ref) {
  final mapService = ref.watch(mapApiServiceProvider);
  final markerInfo = ref.watch(markerProvider.notifier);
  final facilityNotifier =
      FacilityNotifier(service: mapService, markerNotifier: markerInfo);
  return facilityNotifier;
});

class FacilityNotifier extends StateNotifier<BaseResponseState> {
  final MapApiService service;
  final MarkerNotifier markerNotifier;

  FacilityNotifier({required this.service, required this.markerNotifier})
      : super(BaseResponseLoading());

  getFacility(GetFacilityRequestDto request) async {
    logger.d('request: ${request.toJson()}');
    final BaseResponse<GetFacilityResponseDto> response =
        await service.getFacility(request);
    if (response.status == 200) {
      state = response;
      final cctvList = response.data?.cctv ?? [];
      final policeList = response.data?.police ?? [];
      final lampList = response.data?.lamp ?? [];
      final cctvIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), 'res/cctv.png');
      for (var cctv in cctvList) {
        markerNotifier.addMarker(
          Marker(
            markerId: MarkerId(cctv.cctvId.toString()),
            position: LatLng(cctv.lat, cctv.lng),
            icon: cctvIcon,
            visible: false,
            infoWindow: InfoWindow(title: cctv.address),
          ),
        );
      }
      final policeIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), 'res/police.png');
      for (var police in policeList) {
        markerNotifier.addMarker(
          Marker(
            markerId: MarkerId(police.policeId.toString()),
            position: LatLng(police.lat, police.lng),
            visible: false,
            icon: policeIcon,
            infoWindow: InfoWindow(title: police.address),
          ),
        );
      }
      logger.d(markerNotifier.state.first.toString());
    }
  }
}
