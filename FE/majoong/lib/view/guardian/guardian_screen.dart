import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:location/location.dart';
import 'package:majoong/common/layout/loading_layout.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/map/accept_share_route_response_dto.dart';
import 'package:majoong/model/response/map/location_point_response_dto.dart';
import 'package:majoong/viewmodel/notification/accept_share_provider.dart';
import 'package:majoong/viewmodel/share_loaction/share_location_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/const/app_key.dart';
import '../../common/const/colors.dart';
import '../../common/const/key_value.dart';
import '../../common/const/size_value.dart';
import '../../common/util/logger.dart';
import '../../model/request/map/get_facility_request_dto.dart';
import '../../model/request/user/ReportRequestDto.dart';
import '../../model/response/user/user_info_response_dto.dart';
import '../../service/local/secure_storage.dart';
import '../../service/remote/api/user/user_api_service.dart';
import '../../viewmodel/main/facility_provider.dart';
import '../../viewmodel/main/review_dialog_provider.dart';
import '../../viewmodel/main/user_info_provider.dart';
import '../../viewmodel/on_going/cur_address_provider.dart';
import '../../viewmodel/search/search_facility_provider.dart';
import '../../viewmodel/search/search_marker_provider.dart';

class GuardianScreen extends ConsumerStatefulWidget {
  const GuardianScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GuardianState();
}

class _GuardianState extends ConsumerState<GuardianScreen> {
  late GoogleMapController mapController;
  Set<Polyline> route = {};
  Set<Marker> marker = {};
  bool isReporting = false;
  String endTime = "";
  LocationData? _locationData;
  Location location = Location();
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

  makeMarkers(Set<Marker> facilities, double curLat, double curLng,
      double startLat, double startLng, double endLat, double endLng) async {
    final curPositionMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(50, 50)),
      'res/icon_user_position.png',
    );
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

    final curPoint = Marker(
        markerId: MarkerId('curPoint'),
        position: LatLng(curLat, curLng),
        icon: curPositionMarkerIcon);
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
    marker.add(curPoint);
    marker.add(startPoint);
    marker.add(endPoint);
  }

  Future<void> _getLocation() async {
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

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    final acceptShareState = ref.read(acceptShareProvider)
        as BaseResponse<AcceptShareRouteResponseDto>;
    _getLocation();
    endTime = DateFormat('hh:mm').format(DateTime.now()
        .add(Duration(minutes: acceptShareState.data!.path.time)));
    logger.d('도착시간 : $endTime');
    Future.delayed(Duration.zero, () {
      ref.read(shareLocationProvider.notifier).receiveLocation();
    });
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

  Widget bottomComponent(
      {image: AssetImage, text: String, onPressed: Function}) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image(
            width: MediaQuery.of(context).size.width / 10,
            height: MediaQuery.of(context).size.width / 10,
            image: image,
          ),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  reportDialog(setState) {
    int _count = 20;
    Timer timer;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              timer = Timer(Duration(seconds: 1), () {
                if (_count == 0) {
                  final user = ref.read(userInfoProvider.notifier).state
                      as BaseResponse<UserInfoResponseDto>;
                  final currentLocation =
                      ref.read(currentLocationProvider.notifier).state;
                  final request = ReportRequestDto(
                      '[Majoong]\n도움이 필요합니다.\n신고자 연락처: ${user.data?.phoneNumber ?? '알수없음'}\n위도: ${currentLocation[0]} 경도: ${currentLocation[1]}');
                  ref.read(userApiServiceProvider).sendPhone112(request);
                  isReporting = false;
                  Navigator.pop(context);
                } else {
                  setState(() {
                    _count--;
                  });
                }
              });
              return Dialog(
                insetPadding: EdgeInsets.all(20),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          '🚨 비상 신고 알림 🚨',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        Divider(
                          color: Colors.grey,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: _count.toString(),
                                  style: TextStyle(
                                    fontSize: 40.0,
                                  )),
                              TextSpan(
                                text: '초후\n 현재 위치와 함께\n 경찰에 문자 신고가 접수됩니다.',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          '현재위치: 경북 구미시 인의동',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        Text(
                          '취소하시려면 PIN번호를 입력하세요',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        VerificationCode(
                          isSecure: true,
                          autofocus: true,
                          clearAll: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '초기화',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  decoration: TextDecoration.underline,
                                  color: PRIMARY_COLOR),
                            ),
                          ),
                          underlineColor: Colors.black,
                          length: 4,
                          onCompleted: (String value) {
                            Future.delayed(Duration.zero, () async {
                              final pinNum = await ref
                                  .read(secureStorageProvider)
                                  .read(key: PIN_NUM);
                              logger.d(pinNum);
                              if (value == pinNum) {
                                showToast(
                                    context: this.context, '신고 접수가 취소되었습니다');
                                timer.cancel();
                                isReporting = false;
                                Navigator.pop(context);
                              } else {
                                setState(() {
                                  value = "";
                                  showToast(
                                      isHideKeyboard: true,
                                      context: this.context,
                                      'PIN번호가 틀렸습니다');
                                });
                              }
                            });
                          },
                          onEditing: (bool value) {
                            Future.delayed(Duration.zero, () {});
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final acceptShareState = ref.read(acceptShareProvider);
    final shareLocationState = ref.watch(shareLocationProvider);
    final facilityInfo = ref.watch(searchFacilityProvider.notifier);
    final markerInfo = ref.watch(searchMarkerProvider.notifier);
    final chipInfo = ref.watch(searchChipProvider.notifier);
    final cameraMovedInfo = ref.watch(searchCameraMovedProvider);

    if (shareLocationState is BaseResponse<LocationPointResponseDto> &&
        acceptShareState is BaseResponse<AcceptShareRouteResponseDto>) {
      final curLat = shareLocationState.data!.lat;
      final curLng = shareLocationState.data!.lng;
      final startLat = acceptShareState.data!.path.point[0].lat;
      final startLng = acceptShareState.data!.path.point[0].lng;
      final endLat = acceptShareState
          .data!.path.point[acceptShareState.data!.path.point.length - 1].lat;
      final endLng = acceptShareState
          .data!.path.point[acceptShareState.data!.path.point.length - 1].lng;
      final userName = acceptShareState.data!.nickname;
      final userPhoneNumber = acceptShareState.data!.phoneNumber;
      final curAddress =
          ref.read(curAddressProvider.notifier).getAddress(curLat, curLng);

      makeMarkers(
          markerInfo.state, curLat, curLng, startLat, startLng, endLat, endLng);
      makePolyline(acceptShareState.data!.path.point);

      return Scaffold(
        body: Center(child: Builder(builder: (context) {
          return SafeArea(
            child: Stack(alignment: Alignment.topCenter, children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                markers: marker,
                polylines: route,
                initialCameraPosition: CameraPosition(
                  target: LatLng(curLat, curLng),
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
                myLocationEnabled: false,
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
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '$userName님의 현재위치\n$curAddress',
                        textAlign: TextAlign.center,
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
                top: MediaQuery.of(context).size.height / 10,
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
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                height: MediaQuery.of(context).size.height / 8,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height / 8,
                  decoration: BoxDecoration(
                    color: PRIMARY_COLOR,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      bottomComponent(
                        image: AssetImage('res/call.png'),
                        text: '통화',
                        onPressed: () {
                          logger.d('Tab!');
                          canLaunchUrl(
                                  Uri(scheme: 'tel', path: '010-2638-5713'))
                              .then((value) => launchUrl(
                                  Uri(scheme: 'tel', path: '010-2638-5713')));
                        },
                      ),
                      bottomComponent(
                        image: AssetImage('res/report.png'),
                        text: '비상신고',
                        onPressed: () {
                          reportDialog(setState);
                        },
                      ),
                    ],
                  ),
                ),
              )
            ]),
          );
        })),
      );
    } else {
      return LoadingLayout();
    }
  }
}