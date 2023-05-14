import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:location/location.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/layout/loading_layout.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/map/route_info_response_dto.dart';
import 'package:majoong/viewmodel/on_going/cur_address_provider.dart';
import 'package:majoong/viewmodel/search/route_point_provider.dart';
import 'package:majoong/viewmodel/share_loaction/share_location_provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../common/const/app_key.dart';
import '../../common/const/colors.dart';
import '../../model/request/map/get_facility_request_dto.dart';
import '../../model/response/base_response.dart';
import '../../model/response/map/location_point_response_dto.dart';
import '../../viewmodel/main/review_dialog_provider.dart';
import '../../viewmodel/search/search_facility_provider.dart';
import '../../viewmodel/search/search_marker_provider.dart';
import '../../viewmodel/search/search_route_provider.dart';
import 'package:http/http.dart' as http;

class OnGoingScreen extends ConsumerStatefulWidget {
  final RouteInfoResponseDto route;
  const OnGoingScreen({Key? key, required this.route}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnGoingState(selectedRoute: route);
}

class _OnGoingState extends ConsumerState<OnGoingScreen> {
  final RouteInfoResponseDto selectedRoute;
  late GoogleMapController mapController;
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _locationData;
  Set<Polyline> route = {};
  List<Marker> marker = [];

  _OnGoingState({required this.selectedRoute});

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
    final routePoint = ref.read(routePointProvider);
    final startLat = routePoint.startLat;
    final startLng = routePoint.startLng;
    final endLat = routePoint.endLat;
    final endLng = routePoint.endLng;
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
    ref.read(searchCenterPositionProvider.notifier).update((state) =>
        GetFacilityRequestDto(
            centerLng: _locationData!.longitude!,
            centerLat: _locationData!.latitude!,
            radius: 1000));
    ref.read(searchFacilityProvider.notifier).getFacility();
    setState(() {});
  }

  late StreamSubscription<LocationData> locationSubscription;

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

  Future<String?> getAddress(double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$GOOGLE_MAP_KEY&language=ko';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body);
      final results = decodedJson['results'] as List<dynamic>;
      final formattedAddresses = results
          .map((result) => result['formatted_address'] as String)
          .toList();
      logger.d('현재 위치 : $formattedAddresses');
      return formattedAddresses[0].replaceAll('대한민국', '');
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shareLocationState = ref.watch(shareLocationProvider);
    final facilityInfo = ref.watch(searchFacilityProvider.notifier);
    final markerInfo = ref.watch(searchMarkerProvider.notifier);
    final chipInfo = ref.watch(searchChipProvider.notifier);
    final cameraMovedInfo = ref.watch(searchCameraMovedProvider);
    final curAddress = ref.watch(curAddressProvider);
    String endTime = "";
    logger.d('amqp share locationstate : $shareLocationState');

    logger
        .d('ongoing : $_locationData, $shareLocationState');

    if (_locationData != null &&
        shareLocationState is BaseResponse<bool>) {
      endTime = DateFormat('hh:mm').format(
          DateTime.now().add(Duration(minutes: selectedRoute.time)));
      logger.d('도착시간 : $endTime');
      makePolyline(
        selectedRoute.point
      );
      makeMarkers(markerInfo.state);

      Timer.periodic(Duration(seconds: 1), (timer) async {
        final curLocation = await Location.instance.getLocation();
        final lat = curLocation.latitude!;
        final lng = curLocation.longitude!;
        logger.d('amqp cur location : $lat, $lng');
        final address = await getAddress(lat, lng) ?? "";
        ref.read(curAddressProvider.notifier).update((state) => address);
        logger.d('현재 위치 : $curAddress');
        ref.read(shareLocationProvider.notifier).sendLocation(lat, lng);
      });

      return Scaffold(
        body: _locationData != null
            ? Builder(builder: (context) {
                return SafeArea(
                  child: Stack(alignment: Alignment.topCenter, children: [
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      markers: markerInfo.state,
                      polylines: route,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_locationData!.latitude!,
                            _locationData!.longitude!),
                        zoom: 15.7,
                      ),
                      onCameraMove: (CameraPosition position) {
                        final lat = position.target.latitude;
                        final lng = position.target.longitude;
                        final centerLat = lat;
                        final centerLng = lng;
                        ref
                            .read(searchCenterPositionProvider.notifier)
                            .update((state) {
                          return state = GetFacilityRequestDto(
                            centerLat: centerLat,
                            centerLng: centerLng,
                            radius: 1000,
                          );
                        });
                        ref
                            .read(searchCameraMovedProvider.notifier)
                            .update((state) => true);
                      },
                      myLocationEnabled: true,
                    ),
                    ref.read(searchFacilityProvider.notifier).state
                            is BaseResponseLoading
                        ? loadingWidget()
                        : Container(),
                    Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
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
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 14,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '현재위치 : $curAddress',
                              style: TextStyle(
                                  fontSize: BASE_TITLE_FONT_SIZE,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '$endTime 도착 예정',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        )),
                    Positioned(
                      top: MediaQuery.of(context).size.height / 12,
                      left: MediaQuery.of(context).size.width / 50,
                      right: MediaQuery.of(context).size.width / 50,
                      child: Container(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (String choice in _choices)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
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
                      top: MediaQuery.of(context).size.height / 7,
                      child: GestureDetector(
                        onTap: () async {
                          facilityInfo.getFacility();
                          ref
                              .read(searchCameraMovedProvider.notifier)
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
                  ]),
                );
              })
            : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '잠시만 기다려주세요 :)',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
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
    } else {
      return LoadingLayout();
    }
  }
}
