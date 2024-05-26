import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettings {
  static bool showNextSong = true;
  static bool stopPlayerOnDeviceDisconnect = true;

  static double playerBGBlurValue = 2.0;

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
