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
import 'package:majoong/viewmodel/search/search_facility_provider.dart';
import 'package:majoong/viewmodel/search/search_marker_provider.dart';
import 'package:majoong/viewmodel/search/search_route_point_provider.dart';
import 'package:majoong/viewmodel/search/route_point_provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../common/const/colors.dart';
import '../../common/util/logger.dart';
import '../../model/request/map/get_facility_request_dto.dart';
import '../../model/response/base_response.dart';
import '../../viewmodel/main/facility_provider.dart';
import '../../viewmodel/main/marker_provider.dart';
import '../../viewmodel/main/review_dialog_provider.dart';
import '../../viewmodel/main/user_info_provider.dart';

class ResultSearchPlacesScreen extends ConsumerStatefulWidget {
  final String keyword;

  ResultSearchPlacesScreen({Key? key, required this.keyword}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ResultSearchPlacesState(keyword: keyword);
}

class _ResultSearchPlacesState extends ConsumerState<ResultSearchPlacesScreen> {
  final String keyword;
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  _ResultSearchPlacesState({required this.keyword});

  late GoogleMapController mapController;
  Location location = Location();
  LocationData? _locationData;
  final panelController = PanelController();
  double panelPosition = 0.5;
  List<Marker> marker = [];

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
    ref.read(facilityProvider.notifier).getFacility(context);
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
                                  valueChanged: (newState) {},
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
                                              routePoint.endLocationName ==
                                                  '') {
                                            showToast(
                                                context: context,
                                                '도착지를 입력해주세요');
                                            Navigator.pop(context);
                                          } else if (routePoint
                                                      .startLocationName !=
                                                  '' &&
                                              routePoint.endLocationName !=
                                                  '') {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SelectRouteScreen()));
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
                                              .addEndPoint(
                                                  place.locationName,
                                                  place.lat,
                                                  place.lng,
                                                  _locationData!.latitude ?? -1,
                                                  _locationData!.longitude ??
                                                      -1);
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SelectRouteScreen()));
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

  makeMarkers(List<SearchPlacesModel> places) async {
    final markerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(50, 50)),
      'res/icon_place_location.png',
    );

    marker.clear();
    for (var place in places) {
      final placeMarker = Marker(
          markerId: MarkerId('startPoint'),
          position: LatLng(place.lat, place.lng),
          icon: markerIcon);
      marker.add(placeMarker);
    }
    logger.d(
        '마커 생성 - 크기 : ${marker.length}, start : ${marker[marker.length - 2]}, end : ${marker[marker.length - 1]}');
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchRoutePointProvider);
    final routePointState = ref.watch(routePointProvider);

    if (searchState is BaseResponseLoading) {
      ref.read(searchRoutePointProvider.notifier).getResultSearch(keyword);
      return Container(color: Colors.grey, child: LoadingLayout());
    } else if (searchState is BaseResponse<List<SearchPlacesModel>> &&
        _locationData != null) {
      logger.d(
          '검색 결과 화면 : ${routePointState.startLocationName}, ${routePointState.endLocationName}');
      makeMarkers(searchState.data ?? []);
      return Scaffold(
        body: SlidingUpPanel(
          controller: panelController,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          minHeight: MediaQuery.of(context).size.height * 0.3,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
                        borderRadius: BorderRadius.all(Radius.circular(12.0))),
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
                  markers: Set.from(marker),
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
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            );
          }),
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
