import 'package:json_annotation/json_annotation.dart';

part 'get_facility_response_dto.g.dart';

@JsonSerializable()
class GetFacilityResponseDto {
  final List<CCTV>? cctv;
  final List<Police>? police;
  final List<Lamp>? lamp;
  final List<Store>? store;
  final List<Bell>? bell;
  final List<SafeRoad>? safeRoad;
  final List<DangerZone>? dangerZone;
  final List<Review>? review;

  GetFacilityResponseDto(this.cctv, this.police, this.lamp, this.bell,
      this.safeRoad, this.dangerZone, this.review, this.store);

  factory GetFacilityResponseDto.fromJson(Map<String, dynamic> json) =>
      _$GetFacilityResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GetFacilityResponseDtoToJson(this);
}

@JsonSerializable()
class CCTV {
  final int cctvId;
  final double lng;
  final double lat;
  final String address;

  CCTV(this.cctvId, this.lng, this.lat, this.address);

  factory CCTV.fromJson(Map<String, dynamic> json) => _$CCTVFromJson(json);

  Map<String, dynamic> toJson() => _$CCTVToJson(this);
}

@JsonSerializable()
class Police {
  final int policeId;
  final double lng;
  final double lat;
  final String address;

  Police(this.policeId, this.lng, this.lat, this.address);

  factory Police.fromJson(Map<String, dynamic> json) => _$PoliceFromJson(json);

  Map<String, dynamic> toJson() => _$PoliceToJson(this);
}

@JsonSerializable()
class Lamp {
  final int lampId;
  final double lng;
  final double lat;
  final String address;

  Lamp(this.lampId, this.lng, this.lat, this.address);

  factory Lamp.fromJson(Map<String, dynamic> json) => _$LampFromJson(json);

  Map<String, dynamic> toJson() => _$LampToJson(this);
}

@JsonSerializable()
class Bell {
  final int bellId;
  final double lng;
  final double lat;
  final String address;

  Bell(this.bellId, this.lng, this.lat, this.address);

  factory Bell.fromJson(Map<String, dynamic> json) => _$BellFromJson(json);

  Map<String, dynamic> toJson() => _$BellToJson(this);
}

@JsonSerializable()
class Store {
  final int storeId;
  final double lng;
  final double lat;
  final String address;

  Store(this.storeId, this.lng, this.lat, this.address);

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

  Map<String, dynamic> toJson() => _$StoreToJson(this);
}

@JsonSerializable()
class SafeRoad {
  final int safeRoadId;

  SafeRoad(this.safeRoadId);

  factory SafeRoad.fromJson(Map<String, dynamic> json) =>
      _$SafeRoadFromJson(json);

  Map<String, dynamic> toJson() => _$SafeRoadToJson(this);
}

@JsonSerializable()
class DangerZone {
  final int dangerZoneId;

  DangerZone(this.dangerZoneId);

  factory DangerZone.fromJson(Map<String, dynamic> json) =>
      _$DangerZoneFromJson(json);

  Map<String, dynamic> toJson() => _$DangerZoneToJson(this);
}

@JsonSerializable()
class Review {
  final int id;
  final double lng;
  final double lat;
  final String address;
  final int score;

  Review(this.id, this.lng, this.lat, this.address, this.score);

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
