import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:location/location.dart';
import 'package:majoong/common/const/app_key.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/request/map/get_facility_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/user_info_response_dto.dart';
import 'package:majoong/viewmodel/main/facility_provider.dart';
import 'package:majoong/viewmodel/main/marker_provider.dart';
import 'package:majoong/viewmodel/main/review_dialog_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../viewmodel/main/user_info_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late GoogleMapController mapController;

  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _locationData;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
    location.onLocationChanged.listen((event) {
      setState(() {
        _locationData = event;
        final currentLocation = ref.read(currentLocationProvider);
        currentLocation[0] = event.latitude!;
        currentLocation[1] = event.longitude!;
      });
    });
  }
  Future<String?> getAddress() async{
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${ref.read(currentLocationProvider)[0]},${ref.read(currentLocationProvider)[1]}&key=$GOOGLE_MAP_KEY&language=ko';
    final response = await http.get(Uri.parse(url));
    if(response.statusCode == 200){
      final decodedJson = jsonDecode(response.body);
      final results = decodedJson['results'] as List<dynamic>;
      final formattedAddresses = results.map((result) => result['formatted_address'] as String).toList();
      return formattedAddresses[0].replaceAll('대한민국', '');
    }else{
      return null;
    }
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

  Widget drawerMenu({title: String}) {
    return Container(
      alignment: Alignment.centerLeft,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 18,
      child: GestureDetector(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
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


  @override
  Widget build(BuildContext context) {
    final userInfo = ref.watch(userInfoProvider.notifier).state;
    final facilityInfo = ref.watch(facilityProvider.notifier);
    final markerInfo = ref.watch(markerProvider.notifier);
    final chipInfo = ref.watch(chipProvider.notifier);
    final reviewDialogInfo = ref.watch(reviewDialogProvider.notifier);
    final cameraMovedInfo = ref.watch(cameraMovedProvider);

    return Scaffold(
      drawer: Drawer(
        width: MediaQuery.of(context).size.width / 1.5,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: IconButton(
                  alignment: Alignment.topRight,
                  icon: Icon(Icons.notifications_none_rounded),
                  onPressed: () {},
                ),
              ),
              userInfo is BaseResponseLoading
                  ? Container()
                  : Container(
                      width: MediaQuery.of(context).size.width / 2.5,
                      height: MediaQuery.of(context).size.width / 2.5,
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(
                            (userInfo as BaseResponse<UserInfoResponseDto>)
                                .data!
                                .profileImage!),
                        radius: 100, // 동그란 영역의 반지름
                      ),
                    ),
              SizedBox(
                height: 10,
              ),
              Text(
                userInfo is BaseResponse<UserInfoResponseDto>
                    ? (userInfo as BaseResponse<UserInfoResponseDto>)
                            .data
                            ?.nickname ??
                        ''
                    : '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                userInfo is BaseResponse<UserInfoResponseDto>
                    ? (userInfo as BaseResponse<UserInfoResponseDto>)
                            .data
                            ?.phoneNumber ??
                        ''
                    : '',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                thickness: 1,
              ),
              drawerMenu(title: '즐겨찾기'),
              drawerMenu(title: '친구 관리'),
              drawerMenu(title: '녹화기록'),
              drawerMenu(title: '회원정보 수정'),
              drawerMenu(title: 'PIN 변경'),
              drawerMenu(title: '알림 설정'),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () {
                        print('tab!!!!!!!');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('로그아웃'),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.logout),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: _locationData != null
          ? Builder(builder: (context) {
              return SafeArea(
                child: Stack(alignment: Alignment.topCenter, children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    markers: markerInfo.state,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                          _locationData!.latitude!, _locationData!.longitude!),
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
                  ref.read(facilityProvider.notifier).state
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            ref.read(userInfoProvider.notifier).getUserInfo();
                            Scaffold.of(context).openDrawer();
                          },
                          icon: const Icon(Icons.menu),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Navigator.pushNamed(context, '/search');
                            },
                            child: const Text(
                              '도착지를 입력해주세요',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width / 4,
                    bottom: MediaQuery.of(context).size.height / 7,
                    child: GestureDetector(
                      onTap: () async{
                        final address = await getAddress();
                        if(address != null) reviewDialogInfo.setAddress(address);
                        reviewDialogInfo.setCurrentLocation();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return Dialog(
                                  backgroundColor: PRIMARY_COLOR,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            30,
                                        vertical:
                                            5,),
                                    child: Container(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[

                                          SizedBox(height: 10),
                                          const Text(
                                            '현재 위치에 대해서 평가해주세요',
                                            style:
                                                TextStyle(color: Colors.white,
                                                fontWeight: FontWeight.bold,),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            reviewDialogInfo.state.address,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          RatingBar.builder(
                                            initialRating: 0,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            itemCount: 5,
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onRatingUpdate: (rating) {
                                              reviewDialogInfo
                                                  .setScore(rating.toInt());
                                            },
                                          ),
                                          SizedBox(height: 10),
                                          createToggleButton(true, setState),
                                          SizedBox(height: 4),
                                          createToggleButton(false, setState),
                                          SizedBox(height: 2),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '사진과 함께 등록할까요?',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  //TODO 사진 촬영
                                                },
                                                child: Text(
                                                  '촬영하기',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      decoration: TextDecoration
                                                          .underline),
                                                ),
                                              ),
                                              Icon(
                                                Icons.camera_alt_outlined,
                                                color: Colors.white,
                                                size: 10,
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 15),
                                          TextField(
                                            onChanged: (content){
                                              reviewDialogInfo.setContent(content);
                                            },
                                            maxLength: 50, // 글자 제한 설정
                                            maxLines: 6, // 멀티라인 설정
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                            ),
                                            decoration: InputDecoration(
                                              counterStyle: TextStyle(
                                                color: Colors.white,
                                              ),
                                              contentPadding: EdgeInsets.all(4),
                                              hintText: '의견을 남겨주세요', // 힌트 설정
                                              filled: true, // 배경색 적용
                                              fillColor: Colors.white, // 배경색 설정
                                              border: OutlineInputBorder( // 외곽선 설정
                                                borderSide: BorderSide.none, // 외곽선 없음
                                                borderRadius: BorderRadius.circular(10), // 둥근 모서리 설정
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            color: Colors.white,
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              //TODO: 리뷰 등록 API 호출

                                              reviewDialogInfo.clearData();
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              '리뷰 등록',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
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
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.height / 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFF77469C),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '+ 현재위치 리뷰 작성',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
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
                            onPressed: () {
                              logger.d('Tab!');
                              canLaunchUrl(
                                      Uri(scheme: 'tel', path: '010-2638-5713'))
                                  .then((value) => launchUrl(Uri(
                                      scheme: 'tel', path: '010-2638-5713')));
                            },
                          ),
                          bottomComponent(
                            image: AssetImage('res/body_cam.png'),
                            text: '바디캠',
                            onPressed: () {},
                          ),
                          bottomComponent(
                            image: AssetImage('res/whistle.png'),
                            text: '호루라기',
                            onPressed: () async {
                              AudioCache player = AudioCache();
                              player.play('whistle.mp3');
                              logger.d('whistle!!');
                            },
                          ),
                          bottomComponent(
                            image: AssetImage('res/report.png'),
                            text: '비상신고',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  )
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
  }

  Widget createToggleButton(isBright, setState) {
    final reviewDialogInfo = ref.read(reviewDialogProvider.notifier);
    List<Widget> _lighting = [
      Text(
        '어두워요',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      Text(
        '밝아요',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];
    List<Widget> _crowded = [
      Text(
        '인적이 드물어요',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      Text(
        '사람이 많아요',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];
    return ToggleButtons(
      borderWidth: 2,
      children: isBright ? _lighting : _crowded,
      isSelected: isBright
          ? [!reviewDialogInfo.state.isBright, reviewDialogInfo.state.isBright]
          : [
              !reviewDialogInfo.state.isCrowded,
              reviewDialogInfo.state.isCrowded
            ],
      selectedBorderColor: SECOND_PRIMARY_COLOR,
      borderRadius: BorderRadius.circular(10),
      selectedColor: Colors.white,
      borderColor: SECOND_PRIMARY_COLOR,
      fillColor: SECOND_PRIMARY_COLOR,
      constraints: const BoxConstraints(
        minHeight: 40.0,
        minWidth: 120,
      ),
      onPressed: (int index) {
        setState(() {
          if (isBright)
            reviewDialogInfo.toggleBright();
          else
            reviewDialogInfo.toggleCrowded();
        });
      },
    );
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
}
