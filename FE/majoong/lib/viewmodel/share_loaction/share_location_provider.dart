import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import "package:dart_amqp/dart_amqp.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/common/const/path.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/map/location_point_response_dto.dart';
import 'package:majoong/service/local/secure_storage.dart';
import 'package:majoong/service/remote/api/map/map_api_service.dart';

import '../../common/const/app_key.dart';
import '../../model/request/map/share_route_request_dto.dart';

final shareLocationProvider =
    StateNotifierProvider<ShareLocationStateNotifier, BaseResponseState>((ref) {
  final secureStorage = ref.read(secureStorageProvider);
  final mapApi = ref.read(mapApiServiceProvider);
  final notifier =
      ShareLocationStateNotifier(secureStorage: secureStorage, mapApi: mapApi);
  return notifier;
});

class ShareLocationStateNotifier extends StateNotifier<BaseResponseState> {
  final FlutterSecureStorage secureStorage;
  final MapApiService mapApi;

  ShareLocationStateNotifier(
      {required this.secureStorage, required this.mapApi})
      : super(BaseResponseLoading());

  late ConnectionSettings amqpSetting;
  late Client amqpClient;
  late Channel amqpChannel;
  late Exchange amqpExchange;
  List<Queue> amqpQueue = [];
  late dynamic amqpConsumer;
  StreamSubscription? amqpSubscription;
  double lat = 0;
  double lng = 0;
  String userId = "";

  initChannel(bool isGuardian, int friendId, List<int> guardianList) async {
    try {
      userId = (await secureStorage.read(key: USER_ID)).toString();
      amqpSetting = ConnectionSettings(
          host: RABBITMQ_HOST_URL,
          authProvider: PlainAuthenticator(RABBITMQ_ID, RABBITMQ_PW));

      amqpClient = Client(settings: amqpSetting);
      amqpChannel = await amqpClient.channel();
      amqpExchange = await amqpChannel.exchange(
          RABBITMQ_EXCHANGE_NAME, ExchangeType.TOPIC,
          durable: true);

      if (isGuardian) {
        //보호자일 때
        logger.d('isGuardian : $isGuardian, friendId : $friendId');
        amqpQueue.add(await amqpChannel.queue('$RABBITMQ_QUEUE_NAME.$userId',
            durable: true, arguments: {"x-message-ttl": 1000}));
        amqpConsumer = await amqpQueue[0].consume();
        await amqpQueue[0].bind(amqpExchange, friendId.toString());
        // amqpConsumer.setRoutingKey(friendId.toString());
      } else {
        logger.d('isGuardian : $isGuardian');
        for(int i=0; i<guardianList.length; i++){
          amqpQueue.add(await amqpChannel.queue('$RABBITMQ_QUEUE_NAME.${guardianList[i]}',
              durable: true, arguments: {"x-message-ttl": 1000}));
          await amqpQueue[i].bind(amqpExchange, userId.toString());
        }
      }

      logger.d('success init AMQP');
      state =
          BaseResponse(status: 200, message: 'success init AMQP', data: true);
    } on Exception catch (err) {
      logger.d('fail init RabbitMQ : $err');
    }
  }

  /// 위도, 경도 좌표를 하나의 문자열로 병합하여 전송
  sendLocation(double lat, double lng) async {
    final location = '$lat/$lng';
    // final properties = MessageProperties();
    // properties.headers = <String, Object>{};
    // properties.headers!['expiration'] = '1000';
    amqpExchange.publish(location, userId);
    print('amqp send Location : $lat, $lng');
  }

  /// 위치정보 수신
  receiveLocation() {
    logger.d('수신 메소드 호출');
    Set<LocationPointResponseDto> locationSet = {};
    int setSize = 0;
    amqpConsumer.listen((message) async {
      final data = message.payloadAsString.split('/');
      lat = double.parse(data[0]);
      lng = double.parse(data[1]);
      String curAddress = "";
      if (lat != -1 && lng != -1) {
        curAddress = await getAddress(lat, lng) ?? "";
      }
      locationSet.add(LocationPointResponseDto(lng: lng, lat: lat));
      if (setSize < locationSet.length) {
        setSize = locationSet.length;
        state = BaseResponse(
            status: 200,
            message: curAddress,
            data: LocationPointResponseDto(lng: lng, lat: lat));
        print('receive message : $lat, $lng');
      }
    });
  }

  closeConnection() async {
    state = BaseResponseLoading();
    amqpChannel.close();
  }

  requestShare(ShareRouteRequestDto request) async {
    final response = await mapApi.shareRoute(request);
    logger.d('위치 공유 요청 : ${response.status}');
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
      logger.d('현재 좌표 : $lat, $lng');
      logger.d('현재 위치 : $formattedAddresses');
      return formattedAddresses[0].replaceAll('대한민국', '');
    } else {
      return null;
    }
  }
}
