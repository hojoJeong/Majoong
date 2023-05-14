import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


final searchMarkerProvider =
    StateNotifierProvider.autoDispose<SearchMarkerNotifier, Set<Marker>>((ref) {
  return SearchMarkerNotifier(
      chipNotifier: ref.watch(searchChipProvider.notifier
          as AlwaysAliveProviderListenable<SearchChipNotifier>));
});

class SearchMarkerNotifier extends StateNotifier<Set<Marker>> {
  SearchMarkerNotifier({required this.chipNotifier}) : super(Set()) {}
  final cctvMarkerSet = Set<Marker>();
  final policeMarkerSet = Set<Marker>();
  final lampMarkerSet = Set();
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

final searchChipProvider =
    StateNotifierProvider.autoDispose<SearchChipNotifier, Set<String>>((ref) {
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
