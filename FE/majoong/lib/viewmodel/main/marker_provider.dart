import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../common/util/logger.dart';

final markerProvider =
    StateNotifierProvider<MarkerNotifier, Set<Marker>>((ref) {
  return MarkerNotifier(chipNotifier: ref.watch(chipProvider.notifier as AlwaysAliveProviderListenable<ChipNotifier>));
});

class MarkerNotifier extends StateNotifier<Set<Marker>> {
  MarkerNotifier({required this.chipNotifier}) : super(Set()) {}
  final cctvMarkerSet = Set<Marker>();
  final policeMarkerSet = Set<Marker>();
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

  addAllMarker(Set<Marker> markers) {
    state.addAll(markers);
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

final chipProvider = StateNotifierProvider.autoDispose<ChipNotifier, Set<String>>((ref) {
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
