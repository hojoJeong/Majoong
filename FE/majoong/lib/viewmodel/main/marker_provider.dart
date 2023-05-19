import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:majoong/common/util/logger.dart';

final markerProvider =
    StateNotifierProvider<MarkerNotifier, Set<Marker>>((ref) {
  return MarkerNotifier(chipNotifier: ref.watch(chipProvider.notifier));
});
final polyLineProvider = StateNotifierProvider.autoDispose<PolyLineNotifier,
    Map<PolylineId, Polyline>>((ref) {
  final chipInfo = ref.watch(chipProvider.notifier);
  return PolyLineNotifier(chipNotifier: chipInfo);
});

final polygonProvider =
    StateNotifierProvider.autoDispose<PolygonNotifier, Set<Polygon>>((ref) {
  final chipInfo = ref.watch(chipProvider.notifier);
  return PolygonNotifier(chipNotifier: chipInfo);
});

class PolygonNotifier extends StateNotifier<Set<Polygon>> {
  final ChipNotifier chipNotifier;
  final riskRoad = Set<Polygon>();

  PolygonNotifier({required this.chipNotifier}) : super({});

  renderPolygon() {
    state.clear();
    if (chipNotifier.state.contains('위험 지역')) {
      logger.d('폴리곤 : ${riskRoad.length}');
      state.addAll(riskRoad);
    }
  }

  addRiskRoad(Polygon polygon) {
    riskRoad.add(polygon);
  }
}

class PolyLineNotifier extends StateNotifier<Map<PolylineId, Polyline>> {
  final ChipNotifier chipNotifier;
  final safeRaod = Map<PolylineId, Polyline>();

  PolyLineNotifier({required this.chipNotifier}) : super({}) {}

  renderLine() {
    state.clear();
    if (chipNotifier.state.contains('여성 안심 귀갓길')) {
      state.addAll(safeRaod);
    }
  }

  addSafeRoad(Polyline polyLine) {
    safeRaod[polyLine.polylineId] = polyLine;
  }
}

class MarkerNotifier extends StateNotifier<Set<Marker>> {
  MarkerNotifier({required this.chipNotifier}) : super(Set()) {}
  final cctvMarkerSet = Set();
  final policeMarkerSet = Set();
  final lampMarkerSet = Set();
  final storeMarkerSet = Set();
  final bellMarkerSet = Set();
  final reviewMarkerSet = Set();

  final ChipNotifier chipNotifier;

  renderMarker() {
    state.clear();
    final chips = chipNotifier.state;
    if (chips.contains('CCTV')) {
      addAllMarker(cctvMarkerSet);
    }
    if (chips.contains('경찰서')) {
      addAllMarker(policeMarkerSet);
    }
    if (chips.contains('가로등')) {
      addAllMarker(lampMarkerSet);
    }
    if (chips.contains('편의점')) {
      addAllMarker(storeMarkerSet);
    }
    if (chips.contains('안전 비상벨')) {
      addAllMarker(bellMarkerSet);
    }
    if (chips.contains('도로 리뷰')) {
      addAllMarker(reviewMarkerSet);
    }
  }

  addAllMarker(Set markers) {
    for (var marker in markers) {
      state.add(marker);
    }
  }

  clearMarker() {
    state.clear();
  }

  addCctvMarker(marker) {
    cctvMarkerSet.add(marker);
  }

  addPoliceMarker(marker) {
    policeMarkerSet.add(marker);
  }

  addLampMarker(marker) {
    lampMarkerSet.add(marker);
  }

  addBellMarker(marker) {
    bellMarkerSet.add(marker);
  }

  addStoreMarker(marker) {
    storeMarkerSet.add(marker);
  }

  addReviewMarker(marker) {
    reviewMarkerSet.add(marker);
  }
}

final chipProvider = StateNotifierProvider<ChipNotifier, Set<String>>((ref) {
  return ChipNotifier();
});

class ChipNotifier extends StateNotifier<Set<String>> {
  ChipNotifier() : super(Set()) {}

  toggleChip(chip) {
    if (state.contains(chip)) {
      state.remove(chip);
    } else {
      state.add(chip);
    }
  }

  addChip(chip) {
    state.add(chip);
  }

  removeChip(chip) {
    state.remove(chip);
  }

  clearChip() {
    state.clear();
  }
}
