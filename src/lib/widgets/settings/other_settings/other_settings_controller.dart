import 'package:grob_aar/data/music_assets.dart';
import 'package:get/get.dart';

class OtherSettingsController extends GetxController {
  String? bgMusicPath = MusicAssets.list.keys.first;
  RxBool playMusic = true.obs;
  RxBool playCry = true.obs;
  RxBool showWreath = false.obs;

  onShowWreathChanged(bool value) {
    showWreath.value = !showWreath.value;
  }

  onCryChanged(bool value) {
    playCry.value = !playCry.value;
  }

  onMusicChanged(bool value) {
    playMusic.value = !playMusic.value;
  }
}
