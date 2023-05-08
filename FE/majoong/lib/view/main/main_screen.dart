import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:location/location.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/model/request/map/get_facility_request_dto.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/user/user_info_response_dto.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/view/edit/edit_pin_number_screen.dart';
import 'package:majoong/view/edit/edit_user_info_screen.dart';
import 'package:majoong/view/favorite/favorite_screen.dart';
import 'package:majoong/view/friend/friend_list_screen.dart';
import 'package:majoong/view/login/login_screen.dart';
import 'package:majoong/view/notification/notification_screen.dart';
import 'package:majoong/view/search/search_screen.dart';
import 'package:majoong/viewmodel/main/facility_provider.dart';
import 'package:majoong/viewmodel/main/marker_provider.dart';

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
        ref.read(centerPositionProvider.notifier).update((state) =>
            GetFacilityRequestDto(
                centerLng: _locationData!.longitude!,
                centerLat: _locationData!.latitude!,
                radius: 1000));
      });
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
    return Column(
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
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => NotificationScreen()));
                  },
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
              GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => FavoriteScreen()));
                  },
                  child: drawerMenu(title: '즐겨찾기')),
              GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => FriendListScreen()));
                  },
                  child: drawerMenu(title: '친구 관리')),
              drawerMenu(title: '녹화기록'),
              GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => EditUserInfoScreen()));
                  },
                  child: drawerMenu(title: '회원정보 수정')),
              GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => EditPinNumberScreen()));
                  },
                  child: drawerMenu(title: 'PIN 변경')),
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
                      child: GestureDetector(
                        onTap: (){
                          showToast(context: context, '로그아웃 되었습니다.');
                          ref.read(secureStorageProvider).deleteAll();
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchScreen()));
                            },
                            child: const Text(
                              '도착지를 입력해주세요',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width / 4,
                    bottom: MediaQuery.of(context).size.height / 7,
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
                            onPressed: () {},
                          ),
                          bottomComponent(
                            image: AssetImage('res/body_cam.png'),
                            text: '바디캠',
                            onPressed: () {},
                          ),
                          bottomComponent(
                            image: AssetImage('res/whistle.png'),
                            text: '호루라기',
                            onPressed: () {},
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
