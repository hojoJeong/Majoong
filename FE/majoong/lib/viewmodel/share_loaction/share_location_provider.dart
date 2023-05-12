

import "package:dart_amqp/dart_amqp.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:majoong/common/const/key_value.dart';
import 'package:majoong/common/const/path.dart';
import 'package:majoong/common/util/logger.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/map/location_point_response_dto.dart';
import 'package:majoong/service/local/secure_storage.dart';

final shareLocationProvider =
StateNotifierProvider<ShareLocationStateNotifier, BaseResponseState>((ref) {
  final secureStorage = ref.read(secureStorageProvider);
  final notifier = ShareLocationStateNotifier(secureStorage: secureStorage);
  return notifier;
});

class ShareLocationStateNotifier extends StateNotifier<BaseResponseState> {
  final FlutterSecureStorage secureStorage;

  ShareLocationStateNotifier({required this.secureStorage})
      : super(BaseResponseLoading());

  late ConnectionSettings amqpSetting;
  late Client amqpClient;
  late Channel amqpChannel;
  late Exchange amqpExchange;
  late Queue amqpQueue;
  late dynamic amqpConsumer;
  double lat = 0;
  double lng = 0;
  String userId = "";

  initChannel(bool isGuardian, int friendId) async {
    try {
      userId = (await secureStorage.read(key: USER_ID)).toString();
      amqpSetting = ConnectionSettings(
          host: RABBITMQ_HOST_URL,
          authProvider: PlainAuthenticator(RABBITMQ_ID, RABBITMQ_PW));

      amqpClient = Client(settings: amqpSetting);
      amqpChannel = await amqpClient.channel();

      if (isGuardian) {
        //보호자일 때
        logger.d('isGuardian : $isGuardian, friendId : $friendId');
        amqpQueue = await amqpChannel
            .queue('$RABBITMQ_QUEUE_NAME.$friendId', durable: true, arguments: {"x-message-ttl": 1000});
        amqpConsumer = await amqpQueue.consume(noAck: false);
      } else {
        logger.d('isGuardian : $isGuardian');
        amqpQueue = await amqpChannel
            .queue('$RABBITMQ_QUEUE_NAME.$userId',  durable: true,arguments: {"x-message-ttl": 1000});

        amqpExchange = await amqpChannel.exchange(
            RABBITMQ_EXCHANGE_NAME, ExchangeType.TOPIC,
            durable: true);
        await amqpQueue.bind(amqpExchange, userId.toString());
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
    amqpConsumer.listen((message) {
      final data =message.payloadAsString.split('/');
      lat = double.parse(data[0]);
      lng = double.parse(data[1]);
      locationSet.add(LocationPointResponseDto(lng: lng, lat: lat));
      if(setSize < locationSet.length){
        setSize = locationSet.length;
        state = BaseResponse(
            status: 200,
            message: '위치 정보 수신 성공',
            data: LocationPointResponseDto(lng: lng, lat: lat));
        print('receive message : $lat, $lng');
      }
    });
  }

  closeConnection() async {
    state = BaseResponseLoading();
    amqpChannel.close();
  }
}