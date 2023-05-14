// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_facility_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetFacilityResponseDto _$GetFacilityResponseDtoFromJson(
        Map<String, dynamic> json) =>
    GetFacilityResponseDto(
      (json['cctv'] as List<dynamic>?)
          ?.map((e) => CCTV.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['police'] as List<dynamic>?)
          ?.map((e) => Police.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['lamp'] as List<dynamic>?)
          ?.map((e) => Lamp.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['bell'] as List<dynamic>?)
          ?.map((e) => Bell.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['safeRoad'] as List<dynamic>?)
          ?.map((e) => SafeRoad.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['riskRoad'] as List<dynamic>?)
          ?.map((e) => SafeRoad.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['review'] as List<dynamic>?)
          ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['store'] as List<dynamic>?)
          ?.map((e) => Store.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetFacilityResponseDtoToJson(
        GetFacilityResponseDto instance) =>
    <String, dynamic>{
      'cctv': instance.cctv,
      'police': instance.police,
      'lamp': instance.lamp,
      'store': instance.store,
      'bell': instance.bell,
      'safeRoad': instance.safeRoad,
      'riskRoad': instance.riskRoad,
      'review': instance.review,
    };

CCTV _$CCTVFromJson(Map<String, dynamic> json) => CCTV(
      json['cctvId'] as int,
      (json['lng'] as num).toDouble(),
      (json['lat'] as num).toDouble(),
      json['address'] as String,
    );

Map<String, dynamic> _$CCTVToJson(CCTV instance) => <String, dynamic>{
      'cctvId': instance.cctvId,
      'lng': instance.lng,
      'lat': instance.lat,
      'address': instance.address,
    };

Police _$PoliceFromJson(Map<String, dynamic> json) => Police(
      json['policeId'] as int,
      (json['lng'] as num).toDouble(),
      (json['lat'] as num).toDouble(),
      json['address'] as String,
    );

Map<String, dynamic> _$PoliceToJson(Police instance) => <String, dynamic>{
      'policeId': instance.policeId,
      'lng': instance.lng,
      'lat': instance.lat,
      'address': instance.address,
    };

Lamp _$LampFromJson(Map<String, dynamic> json) => Lamp(
      json['lampId'] as int,
      (json['lng'] as num).toDouble(),
      (json['lat'] as num).toDouble(),
      json['address'] as String,
    );

Map<String, dynamic> _$LampToJson(Lamp instance) => <String, dynamic>{
      'lampId': instance.lampId,
      'lng': instance.lng,
      'lat': instance.lat,
      'address': instance.address,
    };

Bell _$BellFromJson(Map<String, dynamic> json) => Bell(
      json['bellId'] as int,
      (json['lng'] as num).toDouble(),
      (json['lat'] as num).toDouble(),
      json['address'] as String,
    );

Map<String, dynamic> _$BellToJson(Bell instance) => <String, dynamic>{
      'bellId': instance.bellId,
      'lng': instance.lng,
      'lat': instance.lat,
      'address': instance.address,
    };

Store _$StoreFromJson(Map<String, dynamic> json) => Store(
      json['storeId'] as int,
      (json['lng'] as num).toDouble(),
      (json['lat'] as num).toDouble(),
      json['address'] as String,
    );

Map<String, dynamic> _$StoreToJson(Store instance) => <String, dynamic>{
      'storeId': instance.storeId,
      'lng': instance.lng,
      'lat': instance.lat,
      'address': instance.address,
    };

SafeRoad _$SafeRoadFromJson(Map<String, dynamic> json) => SafeRoad(
      (json['point'] as List<dynamic>)
          .map((e) => Point.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SafeRoadToJson(SafeRoad instance) => <String, dynamic>{
      'point': instance.point,
    };

Point _$PointFromJson(Map<String, dynamic> json) => Point(
      (json['lng'] as num).toDouble(),
      (json['lat'] as num).toDouble(),
    );

Map<String, dynamic> _$PointToJson(Point instance) => <String, dynamic>{
      'lng': instance.lng,
      'lat': instance.lat,
    };

DangerZone _$DangerZoneFromJson(Map<String, dynamic> json) => DangerZone(
      json['dangerZoneId'] as int,
    );

Map<String, dynamic> _$DangerZoneToJson(DangerZone instance) =>
    <String, dynamic>{
      'dangerZoneId': instance.dangerZoneId,
    };

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      json['id'] as int,
      (json['lng'] as num).toDouble(),
      (json['lat'] as num).toDouble(),
      json['address'] as String,
      json['score'] as int,
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'id': instance.id,
      'lng': instance.lng,
      'lat': instance.lat,
      'address': instance.address,
      'score': instance.score,
    };
