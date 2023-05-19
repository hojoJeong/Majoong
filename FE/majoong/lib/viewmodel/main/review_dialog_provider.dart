import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:majoong/model/request/review/write_review_request_dto.dart';

final currentLocationProvider = StateProvider((ref) {
  return [0.0, 0.0];
});

final reviewDialogProvider =
    StateNotifierProvider<ReviewDialogNotifier, WriteReviewRequestDto>((ref) {
  final currentLocation = ref.watch(currentLocationProvider);
  return ReviewDialogNotifier(currentLocation);
});

class ReviewDialogNotifier extends StateNotifier<WriteReviewRequestDto> {
  final currentLocation;

  ReviewDialogNotifier(this.currentLocation)
      : super(WriteReviewRequestDto(0, 0, '', 0, false, false, null, '')) {}

  toggleBright() {
    state.isBright = !state.isBright;
  }

  toggleCrowded() {
    state.isCrowded = !state.isCrowded;
  }

  setScore(int score) {
    state.score = score;
  }

  setCurrentLocation() {
    state.lat = currentLocation[0];
    state.lng = currentLocation[1];
  }

  setContent(String content) {
    state.content = content;
  }

  setAddress(String address) {
    state.address = address;
  }

  setPicture(File file) {
    state.reviewImage = file;
  }

  clearData() {
    state = WriteReviewRequestDto(0, 0, '', 0, false, false, null, '');
  }
}
