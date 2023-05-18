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
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/layout/loading_layout.dart';
import 'package:majoong/common/util/extensions.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/map/route_info_response_dto.dart';
import 'package:majoong/view/main/main_screen.dart';
import 'package:majoong/viewmodel/on_going/cancel_share_provider.dart';
import 'package:majoong/viewmodel/search/route_point_provider.dart';
import 'package:majoong/viewmodel/search/search_route_point_provider.dart';
import 'package:majoong/viewmodel/search/selected_guardian_provider.dart';
import 'package:majoong/viewmodel/share_loaction/share_location_provider.dart';
import 'package:openvidu_client/openvidu_client.dart';
import 'package:permission_handler/permission_handler.dart' hide PermissionStatus;
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/const/app_key.dart';
import '../../common/const/colors.dart';
import '../../common/const/key_value.dart';
import '../../common/const/path.dart';
import '../../model/request/map/get_facility_request_dto.dart';
import '../../model/request/user/ReportRequestDto.dart';
import '../../model/response/base_response.dart';
import '../../model/response/map/location_point_response_dto.dart';
import '../../model/response/user/friend_response_dto.dart';
import '../../model/response/user/user_info_response_dto.dart';
import '../../service/local/secure_storage.dart';
import '../../service/remote/api/user/user_api_service.dart';
import '../../service/remote/dio/dio_provider.dart';
import '../../viewmodel/friend/friend_provider.dart';
import '../../viewmodel/main/audio_provider.dart';
import '../../viewmodel/main/marker_provider.dart';
import '../../viewmodel/main/review_dialog_provider.dart';
import '../../viewmodel/main/user_info_provider.dart';
import '../../viewmodel/search/search_facility_provider.dart';
import '../../viewmodel/search/search_marker_provider.dart';
import '../../viewmodel/search/search_route_provider.dart';
import 'package:http/http.dart' as http;

import '../../viewmodel/video/videoProvider.dart';
import '../openvidu/media_stream_view.dart';

class OnGoingScreen extends ConsumerStatefulWidget {
  final RouteInfoResponseDto route;

  const OnGoingScreen({Key? key, required this.route}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnGoingState(selectedRoute: route);
}

class _OnGoingState extends ConsumerState<OnGoingScreen> {
  final RouteInfoResponseDto selectedRoute;
  late GoogleMapController mapController;
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late StreamSubscription<LocationData> locationSubscription;
  late Timer timer;
  late OpenViduClient _openvidu;
  LocationData? _locationData;
  Location location = Location();
  Set<Polyline> route = {};
  Set<Marker> marker = {};
  List<Marker> routePointMarker = [];
  String curAddress = "";
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
  int backBtnCnt = 0;
  LocalParticipant? localParticipant;
  bool isInside = false;
  bool isReporting = false;
  Map<String, RemoteParticipant> remoteParticipants = {};

  _OnGoingState({required this.selectedRoute});

  makePolyline(List<LocationPointResponseDto> selectedRoutePoints) {
    final List<LatLng> selectedRoutePointList = selectedRoutePoints.map((e) {
      return LatLng(e.lat, e.lng);
    }).toList();

    route.clear();
    route.add(Polyline(
        polylineId: PolylineId('seleted_route'),
        visible: true,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        points: selectedRoutePointList,
        color: SECOND_PRIMARY_COLOR,
        width: 8));
  }

  makeMarkers() async {
    final routePoint = ref.read(routePointProvider);
    final startLat = routePoint.startLat;
    final startLng = routePoint.startLng;
    final endLat = routePoint.endLat;
    final endLng = routePoint.endLng;

    logger.d('온고잉 출발 도착지 : ${routePoint.startLat}, ${routePoint.endLat}');
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
    routePointMarker.clear();
    routePointMarker.add(startPoint);
    routePointMarker.add(endPoint);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> initOpenVidu() async {
    _openvidu = OpenViduClient('${BASE_URL}openvidu');
    localParticipant =
    await _openvidu.startLocalPreview(context, StreamMode.backCamera);
    await localParticipant?.setVideoInput("1");
    final videoId = localParticipant?.stream?.getVideoTracks().toString();
    setState(() {});
  }

  void _listenSessionEvents() {
    _openvidu.on(OpenViduEvent.userJoined, (params) async {
      await _openvidu.subscribeRemoteStream(params["id"]);
    });
    _openvidu.on(OpenViduEvent.userPublished, (params) {
      _openvidu.subscribeRemoteStream(params["id"],
          video: params["videoActive"], audio: params["audioActive"]);
    });

    _openvidu.on(OpenViduEvent.addStream, (params) {
      remoteParticipants = {..._openvidu.participants};
      setState(() {});
    });

    _openvidu.on(OpenViduEvent.removeStream, (params) {
      remoteParticipants = {..._openvidu.participants};
      setState(() {});
    });

    _openvidu.on(OpenViduEvent.publishVideo, (params) {
      remoteParticipants = {..._openvidu.participants};
      setState(() {});
    });
    _openvidu.on(OpenViduEvent.publishAudio, (params) {
      remoteParticipants = {..._openvidu.participants};
      setState(() {});
    });
    _openvidu.on(OpenViduEvent.updatedLocal, (params) {
      localParticipant = params['localParticipant'];
      setState(() {});
    });
    _openvidu.on(OpenViduEvent.reciveMessage, (params) {
      context.showMessageRecivedDialog(params["data"] ?? '');
    });
    _openvidu.on(OpenViduEvent.userUnpublished, (params) {
      remoteParticipants = {..._openvidu.participants};
      setState(() {});
    });

    _openvidu.on(OpenViduEvent.error, (params) {
      context.showErrorDialog(params["error"]);
    });
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
    ref.read(searchFacilityProvider.notifier).getFacility(context);
    setState(() {});
  }

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
      return formattedAddresses[0].replaceAll('대한민국', '');
    } else {
      return null;
    }
  }

  Future<void> _onConnect() async {
    final dio = ref.read(dioProvider);
    final secureStorage = ref.read(secureStorageProvider);
    final nickname = await secureStorage.read(key: USER_ID);
    dio.options.baseUrl = 'https://majoong4u.com/openvidu/api';
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] =
        'Basic ${base64Encode(utf8.encode('OPENVIDUAPP:MY_SECRET'))}';
    localParticipant = await _openvidu.publishLocalStream(
        token: ref.read(videoProvider.notifier).sessionInfo!.connectionToken,
        userName: nickname ?? 'user');
    setState(() {
      isInside = true;
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
    Timer dialogTimer;
    ref.read(audioProvider.notifier).play();
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
              dialogTimer = Timer(Duration(seconds: 1), () {
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
                              if (value == pinNum) {
                                showToast(
                                    context: this.context, '신고 접수가 취소되었습니다');
                                dialogTimer.cancel();
                                ref.read(audioProvider.notifier).stop();
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

  guardianDialog(setState) {
    logger.d(ref.read(guardianListProvider.notifier).state);
    final guardians = ref.read(guardianListProvider.notifier).state
    as BaseResponse<List<FriendResponseDto>>;
    List<Widget> guardianWidget = List.generate(
      guardians.data?.length ?? 0,
          (index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage:
              Image.network(guardians.data?[index].profileImage ?? "")
                  .image,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(guardians.data?[index].nickname ?? ''),
                SizedBox(
                  height: 5,
                ),
                Text(
                  guardians.data?[index].phoneNumber ?? '',
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
            IconButton(
              onPressed: () {
                canLaunchUrl(Uri(
                    scheme: 'tel',
                    path: guardians.data?[index].phoneNumber ?? ''))
                    .then((value) => launchUrl(Uri(
                    scheme: 'tel',
                    path: guardians.data?[index].phoneNumber ?? '')));
              },
              icon: Icon(
                Icons.phone_in_talk_rounded,
                color: PRIMARY_COLOR,
              ),
            ),
          ],
        ),
      ),
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.all(60),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: Column(
                    children: [
                      Text(
                        '보호자 목록',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: guardianWidget,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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

  @override
  Widget build(BuildContext context) {
    final shareLocationState = ref.watch(shareLocationProvider);
    final facilityInfo = ref.watch(searchFacilityProvider.notifier);
    final markerInfo = ref.watch(searchMarkerProvider.notifier);
    final chipInfo = ref.watch(searchChipProvider.notifier);
    final cameraMovedInfo = ref.watch(searchCameraMovedProvider);
    final cancelShareState = ref.watch(cancelShareProvider);
    final polygonInfo = ref.watch(searchPolygonProvider.notifier);
    final polyLineInfo = ref.watch(searchPolyLineProvider.notifier);

    String endTime = "";
    logger.d('amqp share locationstate : $shareLocationState');

    logger.d('ongoing : $_locationData, $shareLocationState');

    logger.d('온고잉 마커 크기 : ${marker.length}');
    logger.d('온고잉 마커 인포 : ${markerInfo.state.length}');
    logger.d('온고잉 마커 출발 도착지 마커 크기 : ${routePointMarker.length}');

    marker.clear();
    marker.addAll(routePointMarker);
    marker.addAll(markerInfo.state);

    if (cancelShareState is BaseResponse) {
      Future.delayed(Duration.zero, () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
            (route) => false);
      });
    }
    if (_locationData != null && shareLocationState is BaseResponse<bool>) {
      endTime = DateFormat('hh:mm')
          .format(DateTime.now().add(Duration(minutes: selectedRoute.time)));
      logger.d('도착시간 : $endTime');
      makePolyline(selectedRoute.point);

      makeMarkers();

      timer = Timer(Duration(seconds: 1), () async {
        final curLocation = await Location.instance.getLocation();
        final lat = curLocation.latitude!;
        final lng = curLocation.longitude!;
        logger.d('amqp cur location : $lat, $lng');
        curAddress = await getAddress(lat, lng) ?? "";
        logger.d('curAddress 현재 위치 : $curAddress');
        ref.read(shareLocationProvider.notifier).sendLocation(lat, lng);
      });

      logger.d('curAddress : $curAddress');
      return Scaffold(
        body: _locationData != null
            ? Builder(builder: (context) {
                return SafeArea(
                  child: Stack(alignment: Alignment.topCenter, children: [
                    WillPopScope(
                      onWillPop: () async {
                        // 뒤로 가기 버튼 클릭 시 수행할 동작
                        if (backBtnCnt == 0) {
                          showToast(
                              context: context, '뒤로가기를 한 번 더 누르면 공유가 종료됩니다.');
                          backBtnCnt++;
                          return false;
                        }
                        if (backBtnCnt == 1) {
                          backBtnCnt = 0;
                          showToast(context: context, '공유가 종료되었습니다.');
                          timer.cancel();
                          ref.read(shareLocationProvider.notifier).dispose();
                          ref
                              .read(shareLocationProvider.notifier)
                              .sendLocation(-1, -1);
                          ref.read(cancelShareProvider.notifier).cancelShare();
                        }
                        return false; // true 반환 시 뒤로 가기 동작 수행, false 반환 시 동작 수행하지 않음
                      },
                      child: Container(),
                    ),
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      markers: marker,
                      polylines: route,
                      polygons: polygonInfo.state,
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
                                      polyLineInfo.renderLine();
                                      polygonInfo.renderPolygon();
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
                          facilityInfo.getFacility(context);
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
                    ref.read(videoProvider.notifier).state is BaseResponseLoading
                        ? loadingWidget()
                        : Container(),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      height: MediaQuery.of(context).size.height / 8,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
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
                              text: '보호자 통화',
                              onPressed: () async {
                                await ref
                                    .read(guardianListProvider.notifier)
                                    .getFriendList(1);
                                guardianDialog(setState);
                              },
                            ),
                            bottomComponent(
                              image: AssetImage('res/body_cam.png'),
                              text: '바디캠',
                              onPressed: () async {
                                var cameraStatus =
                                await Permission.camera.request();
                                if (!cameraStatus.isGranted) {
                                  showToast(context: context, '권한 사용을 허용 해주세요');
                                  openAppSettings();
                                  return;
                                }
                                var micStatus =
                                await Permission.microphone.request();
                                if (!micStatus.isGranted) {
                                  showToast(context: context, '권한 사용을 허용 해주세요');
                                  openAppSettings();
                                  return;
                                }
                                if (!isInside) {
                                  initOpenVidu();
                                  _listenSessionEvents();
                                  await ref
                                      .read(videoProvider.notifier)
                                      .startVideo();
                                  await _onConnect();

                                  isInside = true;
                                } else {
                                  isInside = false;
                                  localParticipant = null;
                                  await ref
                                      .read(videoProvider.notifier)
                                      .stopVideo();
                                  await _openvidu.disconnect();
                                }
                              },
                            ),
                            bottomComponent(
                              image: AssetImage('res/whistle.png'),
                              text: '호루라기',
                              onPressed: () async {
                                final audioInfo =
                                ref.read(audioProvider.notifier);
                                if (audioInfo.isPlaying) {
                                  audioInfo.stop();
                                } else {
                                  audioInfo.play();
                                }
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
                    ),
                    isInside
                        ? Positioned(
                      bottom: MediaQuery.of(context).size.height / 6,
                      left: MediaQuery.of(context).size.width / 20,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 4,
                        height: MediaQuery.of(context).size.height / 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.black,
                        ),
                        child: MediaStreamView(
                          borderRadius: BorderRadius.circular(15),
                          participant: localParticipant!,
                        ),
                      ),
                    )
                        : Container(),
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

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    locationSubscription.cancel();
    ref.read(routePointProvider.notifier).dispose();
    ref.read(searchRoutePointProvider.notifier).dispose();
    ref.read(selectGuardianProvider.notifier).dispose();
  }
}
