import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volume_controller/volume_controller.dart';

final audioProvider =
    StateNotifierProvider<AudioNotifier, AssetsAudioPlayer>((ref) {
  return AudioNotifier();
});

class AudioNotifier extends StateNotifier<AssetsAudioPlayer> {
  final volumeController = VolumeController();
  bool isPlaying = false;
  double volume = 0.0;

  AudioNotifier() : super(AssetsAudioPlayer.newPlayer()) {
    getVolume();
  }

  getVolume() async {
    volumeController.showSystemUI = false;
    volume = await volumeController.getVolume();
  }

  play() async {
    isPlaying = true;
    volumeController.setVolume(1.0);
    await state.open(
      Audio("assets/whistle.mp3"),
      loopMode: LoopMode.single, //반복 여부 (LoopMode.none : 없음)
      autoStart: false, //자동 시작 여부
      showNotification: false, //스마트폰 알림 창에 띄울지 여부
    );
    state.play();
  }

  playOneShot() async {
    isPlaying = true;
    volumeController.setVolume(1.0);
    await state.open(
      Audio("assets/whistle.mp3"),
      loopMode: LoopMode.none,
      autoStart: false,
      showNotification: true,
    );
    state.play();
  }

  stop() {
    isPlaying = false;
    volumeController.setVolume(volume);
    state.stop();
  }

  setVolume(double volume) {
    state.setVolume(volume);
  }
}
