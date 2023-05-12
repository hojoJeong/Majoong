import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../common/util/logger.dart';

final markerProvider =
    StateNotifierProvider.autoDispose<MarkerNotifier, Set<Marker>>((ref) {
  return MarkerNotifier(chipNotifier: ref.watch(chipProvider.notifier));
});

class MarkerNotifier extends StateNotifier<Set<Marker>> {
  MarkerNotifier({required this.chipNotifier}) : super(Set()) {}
  final cctvMarkerSet = Set();
  final policeMarkerSet = Set();
  final lampMarkerSet = Set();
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
