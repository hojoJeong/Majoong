import 'dart:async';

import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:location/location.dart';
import 'package:majoong/common/component/signle_button_widget.dart';
import 'package:majoong/common/const/size_value.dart';
import 'package:majoong/common/layout/loading_layout.dart';
import 'package:majoong/model/response/map/search_places_model.dart';
import 'package:majoong/view/search/select_route_screen.dart';
import 'package:majoong/viewmodel/search/search_route_point_provider.dart';
import 'package:majoong/viewmodel/search/route_point_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../common/const/colors.dart';
import '../../common/util/logger.dart';
import '../../model/request/map/get_facility_request_dto.dart';
import '../../model/response/base_response.dart';
import '../../viewmodel/main/facility_provider.dart';
import '../../viewmodel/main/marker_provider.dart';
import '../../viewmodel/main/review_dialog_provider.dart';
import '../../viewmodel/main/user_info_provider.dart';

class ResponseSearchPlacesScreen extends ConsumerStatefulWidget {
  final String keyword;

  ResponseSearchPlacesScreen({Key? key, required this.keyword})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ResponseSearchPlacesState(keyword: keyword);
}

class _ResponseSearchPlacesState
    extends ConsumerState<ResponseSearchPlacesScreen> {
  final String keyword;

  _ResponseSearchPlacesState({required this.keyword});

  late GoogleMapController mapController;
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _locationData;

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

  final panelController = PanelController();
  double panelPosition = 0.8;
  late StreamSubscription<LocationData> locationSubscription;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      panelController.animatePanelToPosition(panelPosition);
    });
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

  Widget placesListView(List<SearchPlacesModel> list) {
    if (list.isEmpty) {
      return Text('검색 결과가 없습니다.');
    } else {
      return Expanded(
        child: ListView.separated(
            itemBuilder: (context, index) {
              final place = list[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: SizedBox(
                  height: MediaQuery.of(context).size.width * 0.3,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image(
                        image: NetworkImage(place.image),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.width * 0.3,
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    place.locationName,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                        fontSize: BASE_TITLE_FONT_SIZE,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                StarButton(
                                  iconSize: 30,
                                  valueChanged: (newState) {
                                    // if (newState) {
                                    //   ref
                                    //       .read(searchProvider.notifier)
                                    //       .setFavoritePlace(place.address,
                                    //           place.locationName);
                                    // } else {
                                    //   ///화면 리빌드 되는 오류 수정되면 즐겨찾기 수정할 때마다 화면 리빌드 할 수 있고(지금은 is BaseResponseLoading 일 때만 리스트 불러오게 해놨음) 그러면 즐겨찾기 추가 후 다시 삭제 가능
                                    //   ref
                                    //       .read(searchProvider.notifier)
                                    //       .deleteFavoritePlace(
                                    //           place.favoriteId);
                                    // }
                                  },
                                  isStarred: place.isFavorite,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              place.address.substring(5),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: GAINSBORO),
                                        onPressed: () {
                                          ref
                                              .read(routePointProvider.notifier)
                                              .addStartPoint(place.locationName,
                                                  place.lat, place.lng);

                                          final routePoint =
                                              ref.read(routePointProvider);
                                          if (routePoint.startLocationName !=
                                                  '' &&
                                              routePoint.endLocationName !=
                                                  '') {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        ResultSearchRouteScreen()));
                                          } else {
                                            Navigator.pop(context);
                                            showToast(
                                                context: context,
                                                '도착지를 지정해주세요');
                                          }
                                        },
                                        child: Text(
                                          '출발',
                                          style: TextStyle(color: Colors.white),
                                        ))),
                                SizedBox(
                                  width: 6,
                                ),
                                Expanded(
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                POLICE_MARKER_COLOR),
                                        onPressed: () {
                                          ref
                                              .read(routePointProvider.notifier)
                                              .addEndPoint(place.locationName,
                                                  place.lat, place.lng);

                                          final routePoint =
                                              ref.read(routePointProvider);
                                          if (routePoint.startLocationName !=
                                                  '' &&
                                              routePoint.endLocationName !=
                                                  '') {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        ResultSearchRouteScreen()));
                                          } else {
                                            Navigator.pop(context);
                                            showToast(
                                                context: context,
                                                '출발지를 지정해주세요');
                                          }
                                        },
                                        child: Text(
                                          '도착',
                                          style: TextStyle(color: Colors.white),
                                        )))
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) =>
                Padding(padding: EdgeInsets.symmetric(vertical: 16)),
            itemCount: list.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      if (panelController.isPanelAnimating) {
        panelPosition = panelController.panelPosition;
      }
    });

    final facilityInfo = ref.watch(facilityProvider.notifier);
    final markerInfo = ref.watch(markerProvider.notifier);
    final chipInfo = ref.watch(chipProvider.notifier);
    final cameraMovedInfo = ref.watch(cameraMovedProvider);
    final searchState = ref.watch(searchRoutePointProvider);

    if (searchState is BaseResponseLoading) {
      ref.read(searchRoutePointProvider.notifier).getResultSearch(keyword);
      return LoadingLayout();
    } else if (searchState is BaseResponse<List<SearchPlacesModel>>) {
      return Scaffold(
        body: _locationData != null
            ? SlidingUpPanel(
                controller: panelController,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                panel: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 40),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: 5,
                          decoration: BoxDecoration(
                              color: Colors.grey[500],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0))),
                        ),
                      ),
                      placesListView(searchState.data ?? [])
                    ],
                  ),
                ),
                body: Builder(builder: (context) {
                  return SafeArea(
                    child: Stack(alignment: Alignment.topCenter, children: [
                      GoogleMap(
                        onMapCreated: _onMapCreated,
                        markers: markerInfo.state,
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
                              .read(centerPositionProvider.notifier)
                              .update((state) {
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
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  keyword,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                                .read(cameraMovedProvider.notifier)
                                .update((state) => false);
                          },
                          child: cameraMovedInfo
                              ? Container(
                                  alignment: Alignment.center,
                                  height:
                                      MediaQuery.of(context).size.height / 25,
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Text(
                                    '현재 위치에서 검색',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                }),
              )
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
    locationSubscription.cancel();
  }
}
