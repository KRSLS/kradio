import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettings {
  static bool showNextSong = true;
  static bool stopPlayerOnDeviceDisconnect = true;


  //Player Settings
  static double bgOpacityMin = 0.0;
  static double bgOpacityMax = 0.5;
  static double bgOpacity = 0.4;
  static bool playerButtonsBG = true;
  static double playerBGBlurMin = 1.0;
  static double playerBGBlurMax = 40.0;
  static double playerBGBlurValue = 10.0;

  void loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('showNextSong', showNextSong);
    await prefs.setBool(
        'stopPlayerOnDeviceDisconnect', stopPlayerOnDeviceDisconnect);
  }

  void saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    showNextSong = await prefs.getBool('showNextSong')!
        ? await prefs.getBool('showNextSong')!
        : true;
    stopPlayerOnDeviceDisconnect =
        await prefs.getBool('stopPlayerOnDeviceDisconnect')!
            ? await prefs.getBool('stopPlayerOnDeviceDisconnect')!
            : true;
  }
}
