import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:location/location.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/map/route_info_response_dto.dart';
import 'package:majoong/model/response/map/search_route_response_dto.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/view/guardian/guardian_screen.dart';
import 'package:majoong/view/on_going/on_going_screen.dart';
import 'package:majoong/view/search/search_screen.dart';
import 'package:majoong/view/search/select_guardians_screen.dart';
import 'package:majoong/viewmodel/friend/friend_provider.dart';
import 'package:majoong/viewmodel/search/get_guardians_provider.dart';
import 'package:majoong/viewmodel/search/route_point_provider.dart';
import 'package:majoong/viewmodel/search/search_route_provider.dart';
import 'package:majoong/viewmodel/share_loaction/share_location_provider.dart';
import 'package:ndialog/ndialog.dart';

import '../../common/const/colors.dart';
import '../../model/request/map/get_facility_request_dto.dart';
import '../../model/request/map/share_route_request_dto.dart';
import '../../model/response/base_response.dart';
import '../../model/response/map/location_point_response_dto.dart';
import '../../model/response/user/friend_response_dto.dart';
import '../../viewmodel/main/facility_provider.dart';
import '../../viewmodel/main/marker_provider.dart';
import '../../viewmodel/main/review_dialog_provider.dart';

class SelectRouteScreen extends ConsumerStatefulWidget {
  const SelectRouteScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectRouteState();
}

class _SelectRouteState extends ConsumerState<SelectRouteScreen> {
  late GoogleMapController mapController;
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _locationData;
  bool selectShortest = false;
  bool selectRecommended = true;
  List<Polyline> route = [];
  List<Marker> marker = [];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    final currentLocation = ref.read(currentLocationProvider);
    currentLocation[0] = _locationData!.latitude!;
    currentLocation[1] = _locationData!.longitude!;
    logger.d(currentLocation.toString());
    ref.read(centerPositionProvider.notifier).update((state) =>
        GetFacilityRequestDto(
            centerLng: _locationData!.longitude!,
            centerLat: _locationData!.latitude!,
            radius: 1000));
    ref.read(facilityProvider.notifier).getFacility();
    setState(() {});
  }

  Widget loadingWidget() {
    return Positioned(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '잠시만 기다려주세요 :)',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white, size: 60)
          ],
        ),
      ),
    );
  }

  late StreamSubscription<LocationData> locationSubscription;

  @override
  void initState() {
    super.initState();
    _getLocation();
    locationSubscription = location.onLocationChanged.listen((event) {
      setState(() {
        _locationData = event;
        final currentLocation = ref.read(currentLocationProvider);
        currentLocation[0] = event.latitude!;
        currentLocation[1] = event.longitude!;
      });
    });
  }

  List<String> _choices = [
    'CCTV',
    '가로등',
    '안전 비상벨',
    '경찰서',
    '편의점',
    '여성 안심 귀갓길',
    '도로 리뷰',
    '위험 지역',
  ];

  makePolyline(
      List<LocationPointResponseDto> recommendedPoints,
      List<LocationPointResponseDto> shortestPoints,
      bool shortestSelected,
      bool recommendedSelected) {
    logger.d('경로 그리기 reco : $recommendedSelected, short : $shortestSelected');
    final List<LatLng> recommendedRouteList = recommendedPoints.map((e) {
      return LatLng(e.lat, e.lng);
    }).toList();

    final List<LatLng> shortestRouteList = shortestPoints.map((e) {
      return LatLng(e.lat, e.lng);
    }).toList();

    route.clear();
    if (recommendedSelected) {
      route.add(Polyline(
          polylineId: PolylineId('shortest'),
          visible: true,
          points: shortestRouteList,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          color: Colors.grey,
          width: 8));
      route.add(
        Polyline(
          polylineId: PolylineId('recommended'),
          visible: true,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          points: recommendedRouteList,
          color: POLICE_MARKER_COLOR,
          width: 8,
          zIndex: 1,
        ),
      );
    } else if (shortestSelected) {
      route.add(Polyline(
          polylineId: PolylineId('recommended'),
          visible: true,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          points: recommendedRouteList,
          color: Colors.grey,
          width: 8));

      route.add(Polyline(
        polylineId: PolylineId('shortest'),
        visible: true,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        points: shortestRouteList,
        color: SECOND_PRIMARY_COLOR,
        width: 8,
        zIndex: 1,
      ));
    }
    logger.d('경로 그리기 완료 : ${route[0].points.length}, ${route[1].points.length}');
  }

  makeMarkers(Set<Marker> facilities, double startLat, double startLng,
      double endLat, double endLng) async {
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
        position: LatLng(startLat, startLng),
        icon: startMarkerIcon);
    final endPoint = Marker(
        markerId: MarkerId('endPoint'),
        position: LatLng(endLat, endLng),
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
    final facilityInfo = ref.watch(facilityProvider.notifier);
    final markerInfo = ref.watch(markerProvider.notifier);
    final chipInfo = ref.watch(chipProvider.notifier);
    final cameraMovedInfo = ref.watch(cameraMovedProvider);
    final resultRoutePoint = ref.watch(routePointProvider);
    final searchRouteState = ref.watch(searchRouteProvider);

    if (resultRoutePoint.startLocationName != '' && resultRoutePoint.endLocationName != '' && searchRouteState is BaseResponseLoading && !ref.read(searchRouteProvider.notifier).checkGetRoot) {
      ref.read(searchRouteProvider.notifier).checkGetRoot = true;
      ref.read(searchRouteProvider.notifier).getRoute(
          resultRoutePoint.startLat,
          resultRoutePoint.startLng,
          resultRoutePoint.endLat,
          resultRoutePoint.endLng);
    }

    logger.d(
        '출발지 : ${resultRoutePoint.startLocationName} , ${resultRoutePoint.startLat}, 목적지 : ${resultRoutePoint.endLocationName}, ${resultRoutePoint.endLat}');
    if (_locationData != null &&
        searchRouteState is BaseResponse<SearchRouteResponseDto>) {
      final shortestPath = searchRouteState.data!.shortestPath.point;
      final initialLat = searchRouteState
          .data!.shortestPath.point[shortestPath.length ~/ 2].lat;
      final initialLng = searchRouteState
          .data!.shortestPath.point[shortestPath.length ~/ 2].lng;

      makePolyline(
          searchRouteState.data!.recommendedPath?.point ?? [],
          searchRouteState.data!.shortestPath.point ?? [],
          selectShortest,
          selectRecommended);
      makeMarkers(
          markerInfo.state,
          resultRoutePoint.startLat,
          resultRoutePoint.startLng,
          resultRoutePoint.endLat,
          resultRoutePoint.endLng);

      return Scaffold(
        body: Builder(builder: (context) {
          return SafeArea(
            child: Stack(alignment: Alignment.topCenter, children: [
              WillPopScope(child: Container(), onWillPop: () async {
                ref.read(routePointProvider.notifier).refreshState();
                return true;
              }),
              GoogleMap(
                polylines: Set.from(route),
                onMapCreated: _onMapCreated,
                markers: Set.from(marker),
                initialCameraPosition: CameraPosition(
                  target: LatLng(initialLat, initialLng),
                  zoom: 15.7,
                ),
                onCameraMove: (CameraPosition position) {
                  final lat = position.target.latitude;
                  final lng = position.target.longitude;
                  final centerLat = lat;
                  final centerLng = lng;
                  ref.read(centerPositionProvider.notifier).update((state) {
                    return state = GetFacilityRequestDto(
                      centerLat: centerLat,
                      centerLng: centerLng,
                      radius: 1000,
                    );
                  });
                  ref
                      .read(cameraMovedProvider.notifier)
                      .update((state) => true);
                },
                myLocationEnabled: true,
              ),
              ref.read(facilityProvider.notifier).state is BaseResponseLoading
                  ? loadingWidget()
                  : Container(),
              Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: FINE_MARKER_COLOR,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: (){
                                      ref.read(searchRouteProvider.notifier).refreshState();
                                      ref.read(routePointProvider.notifier).refreshStartPoint();
                                      Navigator.pop(context);
                                    },
                                    child: Container( //출발지
                                      height: MediaQuery.of(context).size.height *
                                          0.07,
                                      decoration: BoxDecoration(
                                          color: WHITE_SMOKE,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14),
                                          child: Text(
                                            resultRoutePoint.startLocationName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: BASE_TITLE_FONT_SIZE,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.place,
                                  color: FINE_MARKER_COLOR,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: (){
                                      ref.read(searchRouteProvider.notifier).refreshState();
                                      ref.read(routePointProvider.notifier).refreshEndPoint();
                                      Navigator.pop(context);
                                    },
                                    child: Container( //도착지
                                      height: MediaQuery.of(context).size.height *
                                          0.07,
                                      decoration: BoxDecoration(
                                          color: WHITE_SMOKE,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14),
                                          child: Text(
                                            resultRoutePoint.endLocationName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: BASE_TITLE_FONT_SIZE,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.more_vert,
                                color: Colors.grey,
                              ),
                              GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(searchRouteProvider.notifier)
                                        .getRoute(
                                          resultRoutePoint.endLat,
                                          resultRoutePoint.endLng,
                                          resultRoutePoint.startLat,
                                          resultRoutePoint.startLng,
                                        );
                                    ref
                                        .read(routePointProvider.notifier)
                                        .changePoint();
                                  },
                                  child: Icon(
                                    Icons.swap_vert,
                                    color: Colors.black54,
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
              Positioned(
                top: MediaQuery.of(context).size.height / 5,
                left: MediaQuery.of(context).size.width / 50,
                right: MediaQuery.of(context).size.width / 50,
                child: Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (String choice in _choices)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ChoiceChip(
                              backgroundColor: Colors.grey,
                              label: Text(
                                choice,
                                style: TextStyle(color: Colors.white),
                              ),
                              selectedColor: PRIMARY_COLOR,
                              selected: chipInfo.state.contains(choice),
                              onSelected: (bool selected) {
                                chipInfo.toggleChip(choice);
                                markerInfo.renderMarker();
                                setState(() {});
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height / 3.8,
                child: GestureDetector(
                  onTap: () async {
                    facilityInfo.getFacility();
                    ref
                        .read(cameraMovedProvider.notifier)
                        .update((state) => false);
                  },
                  child: cameraMovedInfo
                      ? Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height / 25,
                          width: MediaQuery.of(context).size.width / 3,
                          child: Text(
                            '현재 위치에서 검색',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectRecommended = true;
                                selectShortest = false;
                              });
                            },
                            child: selectRouteButton(
                                '추천 경로',
                                searchRouteState.data!.recommendedPath?.time ??
                                    0,
                                searchRouteState
                                        .data!.recommendedPath?.distance ??
                                    0,
                                selectRecommended,
                                searchRouteState.data!.recommendedPath),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectRecommended = false;
                                selectShortest = true;
                              });
                            },
                            child: selectRouteButton(
                                '최단 경로',
                                searchRouteState.data!.shortestPath.time ?? 0,
                                searchRouteState.data!.shortestPath.distance ??
                                    0,
                                selectShortest,
                                searchRouteState.data!.shortestPath),
                          ),
                        ],
                      ),
                    ),
                  ))
            ]),
          );
        }),
      );
    } else {
      return Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withOpacity(0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '잠시만 기다려주세요 :)',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.white, size: 60)
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    locationSubscription.cancel();
  }
  Widget selectRouteButton(String title, int time, int distance, bool selected,
      RouteInfoResponseDto? path) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected
                  ? (title == '추천 경로'
                      ? POLICE_MARKER_COLOR
                      : SECOND_PRIMARY_COLOR)
                  : Colors.grey,
              width: 1)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? (title == '추천 경로'
                            ? POLICE_MARKER_COLOR
                            : SECOND_PRIMARY_COLOR)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: selected
                      ? () {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (_) => SelectGuardiansScreen(
                                    path: path!,
                                  )));
                        }
                      : null,
                  child: Image(
                    image: selected
                        ? (title == '추천 경로'
                            ? AssetImage(
                                'res/icon_search_route_selected_recommended.png')
                            : AssetImage('res/icon_search_route_selected_shortest.png'))
                        : AssetImage('res/icon_search_route_unselected.png'),
                    width: 50,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$time분',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: selected
                          ? (title == '추천 경로'
                              ? POLICE_MARKER_COLOR
                              : SECOND_PRIMARY_COLOR)
                          : Colors.grey),
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  '${distance}m',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
