import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:majoong/common/layout/loading_layout.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/map/location_point_response_dto.dart';
import 'package:majoong/viewmodel/share_loaction/share_location_provider.dart';

import '../../common/const/colors.dart';
import '../../common/util/logger.dart';

class GuardianScreen extends ConsumerStatefulWidget {
  final int friendId;
  const GuardianScreen({Key? key, required this.friendId}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GuardianState();
}

class _GuardianState extends ConsumerState<GuardianScreen> {
  late GoogleMapController mapController;
  Set<Polyline> route = {};
  List<Marker> marker = [];

  makePolyline(List<LocationPointResponseDto> selectedRoutePoints) {
    final List<LatLng> selectedRoutePointList = selectedRoutePoints.map((e) {
      return LatLng(e.lat, e.lng);
    }).toList();

    route.clear();
    route.add(Polyline(
        polylineId: PolylineId('seleted_route'),
        visible: true,
        points: selectedRoutePointList,
        color: SECOND_PRIMARY_COLOR,
        width: 8));
  }

  makeMarkers(Set<Marker> facilities) async {

    final startMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(50, 50)),
      'res/icon_start_3.png',
    );
    final endMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        size: Size(50, 50),
      ),
      'res/icon_end_3.png',
    );
    final startPoint = Marker(
        markerId: MarkerId('startPoint'),
        // position: LatLng(startLat, startLng),
        icon: startMarkerIcon);
    final endPoint = Marker(
        markerId: MarkerId('endPoint'),
        // position: LatLng(endLat, endLng),
        icon: endMarkerIcon);

    marker.clear();
    marker.addAll(facilities);
    marker.add(startPoint);
    marker.add(endPoint);

    logger.d(
        '마커 생성 - 크기 : ${marker.length}, start : ${marker[marker.length - 2]}, end : ${marker[marker.length - 1]}');
  }


  @override
  Widget build(BuildContext context) {
    final shareLocationState = ref.watch(shareLocationProvider);

    if(shareLocationState is BaseResponse<bool>){
      ref.read(shareLocationProvider.notifier).receiveLocation();
    }
    if(shareLocationState is BaseResponse<LocationPointResponseDto>){
      return Scaffold(
        body: Center(child: Text('${shareLocationState.data!.lat}, ${shareLocationState.data!.lng}'),),
      );
    }
    else {
      return LoadingLayout();
    }

  }

}
