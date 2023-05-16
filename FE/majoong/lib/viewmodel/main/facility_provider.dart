import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:majoong/common/const/colors.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/model/response/map/get_facility_response_dto.dart';
import 'package:majoong/service/remote/api/map/map_api_service.dart';
import 'package:majoong/service/remote/dio/dio_provider.dart';
import 'package:majoong/viewmodel/main/marker_provider.dart';
import 'package:majoong/viewmodel/main/review_dialog_provider.dart';

import '../../common/util/logger.dart';
import '../../model/request/map/get_facility_request_dto.dart';
import '../../model/response/base_response.dart';
import '../../model/response/map/get_review_response_dto.dart';

// 시설물 조회 api RequestDto
final centerPositionProvider = StateProvider<GetFacilityRequestDto>((ref) {
  return GetFacilityRequestDto(centerLng: 0, centerLat: 0, radius: 0);
});

final cameraMovedProvider = StateProvider<bool>((ref) {
  return false;
});

final facilityProvider =
    StateNotifierProvider<FacilityNotifier, BaseResponseState>((ref) {
  final mapService = ref.watch(mapApiServiceProvider);
  final markerInfo =
      ref.watch(markerProvider.notifier as AlwaysAliveProviderListenable);
  final chipInfo = ref.watch(chipProvider.notifier);
  final reviewDialogInfo = ref.watch(reviewDialogProvider.notifier);
  final centerPositionInfo = ref.watch(centerPositionProvider.notifier);
  final polyLineInfo =
      ref.watch(polyLineProvider.notifier as AlwaysAliveProviderListenable);
  final polygonInfo =
      ref.watch(polygonProvider.notifier as AlwaysAliveProviderListenable);

  final dio = ref.watch(dioProvider);
  final facilityNotifier = FacilityNotifier(
    dio,
    service: mapService,
    markerNotifier: markerInfo,
    chipNotifier: chipInfo,
    centerPositionNotifier: centerPositionInfo,
    reviewDialogNotifier: reviewDialogInfo,
    polyLineNotifier: polyLineInfo,
    polygonNotifier: polygonInfo,
  );
  return facilityNotifier;
});

class FacilityNotifier extends StateNotifier<BaseResponseState> {
  final MapApiService service;
  final MarkerNotifier markerNotifier;
  final ChipNotifier chipNotifier;
  final PolyLineNotifier polyLineNotifier;
  final PolygonNotifier polygonNotifier;
  final StateNotifier centerPositionNotifier;
  final ReviewDialogNotifier reviewDialogNotifier;
  final Dio dio;

  FacilityNotifier(this.dio,
      {required this.service,
      required this.markerNotifier,
      required this.polyLineNotifier,
      required this.polygonNotifier,
      required this.chipNotifier,
      required this.centerPositionNotifier,
      required this.reviewDialogNotifier})
      : super(BaseResponseLoading()) {}

  getFacility(context) async {
    state = BaseResponseLoading();
    final request = centerPositionNotifier.state;
    final BaseResponse<GetFacilityResponseDto> response =
        await service.getFacility(request);
    if (response.status == 200) {
      state = response;
      final cctvList = response.data?.cctv ?? [];
      final policeList = response.data?.police ?? [];
      final lampList = response.data?.lamp ?? [];
      final storeList = response.data?.store ?? [];
      final bellList = response.data?.bell ?? [];
      final reviewList = response.data?.review ?? [];

      final cctvIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), 'res/cctv.png');

      for (var cctv in cctvList) {
        markerNotifier.addCctvMarker(Marker(
          markerId: MarkerId(cctv.cctvId.toString()),
          position: LatLng(cctv.lat, cctv.lng),
          icon: cctvIcon,
          infoWindow: InfoWindow(title: cctv.address),
        ));
      }

      final policeIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), 'res/police.png');
      for (var police in policeList) {
        markerNotifier.addPoliceMarker(Marker(
          markerId: MarkerId(police.policeId.toString()),
          position: LatLng(police.lat, police.lng),
          icon: policeIcon,
          infoWindow: InfoWindow(title: police.address),
        ));
      }

      final lampIcon = await getCustomMarkerIcon();
      logger.d(lampList.length);
      for (var lamp in lampList) {
        markerNotifier.addLampMarker(Marker(
          markerId: MarkerId(lamp.lampId.toString()),
          position: LatLng(lamp.lat, lamp.lng),
          icon: lampIcon,
        ));
      }

      final bellIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), 'res/bell.png');
      for (var bell in bellList) {
        markerNotifier.addBellMarker(Marker(
          markerId: MarkerId(bell.bellId.toString()),
          position: LatLng(bell.lat, bell.lng),
          icon: bellIcon,
          infoWindow: InfoWindow(title: bell.address),
        ));
      }

      final storeIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), 'res/store.png');
      for (var store in storeList) {
        markerNotifier.addStoreMarker(Marker(
          markerId: MarkerId(store.storeId.toString()),
          position: LatLng(store.lat, store.lng),
          icon: storeIcon,
          infoWindow: InfoWindow(title: store.address),
        ));
      }

      final goodReviewIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), 'res/good.png');
      final badReviewIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), 'res/bad.png');
      final sosoReviewIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), 'res/soso.png');
      for (var review in reviewList) {
        BitmapDescriptor icon;
        if (review.score <= 2) {
          icon = badReviewIcon;
        } else if (review.score == 3) {
          icon = sosoReviewIcon;
        } else {
          icon = goodReviewIcon;
        }

        markerNotifier.addReviewMarker(
          Marker(
            markerId: MarkerId(review.reviewId.toString()),
            position: LatLng(review.lat, review.lng),
            icon: icon,
            infoWindow: InfoWindow(title: review.address),
            onTap: () async {
              final response = await service.getReview(review.reviewId);
              if (response.status == 200) {
                response.data as GetReviewResponseDto;
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
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    child: Text(
                                      '리뷰 정보',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  response.data!.reviewImage == null
                                      ? Container()
                                      : CachedNetworkImage(
                                          imageUrl: response.data!.reviewImage!,
                                          placeholder: (context, url) =>
                                              LoadingAnimationWidget
                                                  .staggeredDotsWave(
                                                      color: Colors.white,
                                                      size: 60),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: Text(
                                      response.data!.address,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          response.data!.crowded
                                              ? Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF469C5E),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  child: Text(
                                                    '사람이 많아요',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          response.data!.bright
                                              ? Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFFFBA6A),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  child: Text(
                                                    '밝아요',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: PRIMARY_COLOR,
                                          border:
                                              Border.all(color: Colors.yellow),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 2, horizontal: 4),
                                        child: Text(
                                          '⭐ x ${response.data!.score}',
                                          style:
                                              TextStyle(color: Colors.yellow),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: Text(
                                      response.data!.content,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
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
              } else {
                showToast(context: context, '리뷰를 불러오는데 실패했습니다.');
              }
            },
          ),
        );
      }
      if (response.data?.safeRoad?.length != 0) {
        for (int i = 0; i < response.data!.safeRoad!.length; i++) {
          final road = response.data!.safeRoad![i];
          final polyLine = Polyline(
            polylineId: PolylineId('safeRoad$i'),
            points: [],
            color: Colors.green.withOpacity(0.5),
            endCap: Cap.roundCap,
            startCap: Cap.roundCap,
            width: 5,
          );
          for (var point in road.point) {
            polyLine.points.add(LatLng(point.lat, point.lng));
          }
          polyLineNotifier.addSafeRoad(polyLine);
        }
      }

      if (response.data?.riskRoad?.length != 0) {
        for (int i = 0; i < response.data!.riskRoad!.length; i++) {
          final road = response.data!.riskRoad![i];
          final polygon = Polygon(
            polygonId: PolygonId('riskRoad$i'),
            points: [],
            strokeWidth: 2,
            strokeColor: Colors.red.withOpacity(0.5),
            fillColor: Colors.red.withOpacity(0.5),
          );
          for (var point in road.point) {
            polygon.points.add(LatLng(point.lat, point.lng));
          }
          polygonNotifier.addRiskRoad(polygon);
        }
      }
      polygonNotifier.renderPolygon();
      polyLineNotifier.renderLine();
      markerNotifier.renderMarker();
    }
  }

  postReview() async {
    final request = reviewDialogNotifier.state;
    logger.d(request.reviewImage?.path.toString());

    final formData = FormData.fromMap({
      'lng': request.lng.toString(),
      'lat': request.lat.toString(),
      'content': request.content,
      'score': request.score.toString(),
      'isBright': request.isBright.toString(),
      'isCrowded': request.isCrowded.toString(),
      'address': request.address,
      'reviewImage': request.reviewImage != null
          ? await MultipartFile.fromFile(request.reviewImage!.path,
              filename: null)
          : null,
    });

    dio.options.headers.addAll({AUTHORIZATION: AUTH});
    final response =
        await dio.post('https://majoong4u.com/api/map/review', data: formData);
    logger.d(response);
  }

  Future<BitmapDescriptor> getCustomMarkerIcon() async {
    final Size imageSize = Size(30, 30);
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Paint paint = Paint()
      ..color = Colors.yellow.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(imageSize.width / 2, imageSize.height / 2),
      imageSize.width / 2,
      paint,
    );

    final img = await pictureRecorder.endRecording().toImage(
          imageSize.width.toInt(),
          imageSize.height.toInt(),
        );
    final data = await img.toByteData(format: ImageByteFormat.png);
    final bytes = data?.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(bytes!);
  }
}
