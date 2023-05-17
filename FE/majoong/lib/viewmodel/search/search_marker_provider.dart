import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final searchMarkerProvider =
StateNotifierProvider<SearchMarkerNotifier, Set<Marker>>((ref) {
  return SearchMarkerNotifier(chipNotifier: ref.watch(searchChipProvider.notifier));
});
final searchPolyLineProvider = StateNotifierProvider.autoDispose<SearchPolyLineNotifier,
    Map<PolylineId, Polyline>>((ref) {
  final chipInfo = ref.watch(searchChipProvider.notifier);
  return SearchPolyLineNotifier(chipNotifier: chipInfo);
});

final searchPolygonProvider =
StateNotifierProvider.autoDispose<SearchPolygonNotifier, Set<Polygon>>((ref) {
  final chipInfo = ref.watch(searchChipProvider.notifier);
  return SearchPolygonNotifier(chipNotifier: chipInfo);
});

class SearchPolygonNotifier extends StateNotifier<Set<Polygon>> {
  final SearchChipNotifier chipNotifier;
  final riskRoad = Set<Polygon>();

  SearchPolygonNotifier({required this.chipNotifier}) : super({});

  renderPolygon() {
    state.clear();
    if (chipNotifier.state.contains('위험 지역')) {
      state.addAll(riskRoad);
    }
  }

  addRiskRoad(Polygon polygon) {
    riskRoad.add(polygon);
  }
}

class SearchPolyLineNotifier extends StateNotifier<Map<PolylineId, Polyline>> {
  final SearchChipNotifier chipNotifier;
  final safeRaod = Map<PolylineId, Polyline>();

  SearchPolyLineNotifier({required this.chipNotifier}) : super({}) {}

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

class SearchMarkerNotifier extends StateNotifier<Set<Marker>> {
  SearchMarkerNotifier({required this.chipNotifier}) : super(Set()) {}
  final cctvMarkerSet = Set();
  final policeMarkerSet = Set();
  final lampMarkerSet = Set();
  final storeMarkerSet = Set();
  final bellMarkerSet = Set();
  final reviewMarkerSet = Set();

  final SearchChipNotifier chipNotifier;

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

final searchChipProvider = StateNotifierProvider<SearchChipNotifier, Set<String>>((ref) {
  return SearchChipNotifier();
});

class SearchChipNotifier extends StateNotifier<Set<String>> {
  SearchChipNotifier() : super(Set()) {}

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
