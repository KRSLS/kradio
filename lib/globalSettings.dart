import 'package:KRadio/kstream.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettings {
  //Player Settings
  static int radioListIndex = 1;
  static bool appBarTitle = true;
  static double bgOpacityMin = 0.0;
  static double bgOpacityMax = 0.7;
  static double bgOpacity = 0.4;
  static bool playerButtonsBG = true;
  static double playerBGBlurMin = 0.0;
  static double playerBGBlurMax = 80.0;
  static double playerBGBlur = 10.0;
  static double controllerBGBlurMin = 0.0;
  static double controllerBGBlurMax = 80.0;
  static double controllerBGBlur = 10.0;
  static bool notifyInternetLoss = true;
  static bool showNextSong = true;
  static bool stopPlayerOnDeviceDisconnect = true;
  static double borderRadiusMin = 0.0;
  static double borderRadiusMax = 40.0;
  static double borderRadius = 20.0;

  static void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    radioListIndex = await prefs.getInt('radioListIndex')!;
    appBarTitle = await prefs.getBool('appBarTitle')!;
    bgOpacityMin = await prefs.getDouble('bgOpacityMin')!;
    bgOpacityMax = await prefs.getDouble('bgOpacityMax')!;
    bgOpacity = await prefs.getDouble('bgOpacity')!;
    playerButtonsBG = await prefs.getBool('playerButtonsBG')!;
    playerBGBlurMin = await prefs.getDouble('playerBGBlurMin')!;
    playerBGBlurMax = await prefs.getDouble('playerBGBlurMax')!;
    playerBGBlur = await prefs.getDouble('playerBGBlur')!;
    controllerBGBlurMin = await prefs.getDouble('controllerBGBlurMin')!;
    controllerBGBlurMax = await prefs.getDouble('controllerBGBlurMax')!;
    controllerBGBlur = await prefs.getDouble('controllerBGBlur')!;
    notifyInternetLoss = await prefs.getBool('notifyInternetLoss')!;
    showNextSong = await prefs.getBool('showNextSong')!;
    stopPlayerOnDeviceDisconnect =
        await prefs.getBool('stopPlayerOnDeviceDisconnect')!;
    borderRadius = await prefs.getDouble('borderRadius')!;

    //get custom image url
    for (var i = 0; i < KStream.streams.length; i++) {
      KStream.streams[i].customUrlImage = await prefs.getString(
        KStream.streams[i].title,
      )!;
    }

    //get station isFavorite status
    for (var i = 0; i < KStream.streams.length; i++) {
      KStream.streams[i].isFavorite = await prefs.getBool(
        KStream.streams[i].title + 'isFavorite',
      )!;
    }
  }

  static void saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('radioListIndex', radioListIndex);
    prefs.setBool('appBarTitle', appBarTitle);
    prefs.setDouble('bgOpacityMin', bgOpacityMin);
    prefs.setDouble('bgOpacityMax', bgOpacityMax);
    prefs.setDouble('bgOpacity', bgOpacity);
    prefs.setBool('playerButtonsBG', playerButtonsBG);
    prefs.setDouble('playerBGBlurMin', playerBGBlurMin);
    prefs.setDouble('playerBGBlurMax', playerBGBlurMax);
    prefs.setDouble('playerBGBlur', playerBGBlur);
    prefs.setDouble('controllerBGBlurMin', controllerBGBlurMin);
    prefs.setDouble('controllerBGBlurMax', controllerBGBlurMax);
    prefs.setDouble('controllerBGBlur', controllerBGBlur);
    prefs.setBool('notifyInternetLoss', notifyInternetLoss);
    prefs.setBool('showNextSong', showNextSong);
    prefs.setBool('stopPlayerOnDeviceDisconnect', stopPlayerOnDeviceDisconnect);
    prefs.setDouble('borderRadius', borderRadius);

    //save custom image url
    for (var i = 0; i < KStream.streams.length; i++) {
      prefs.setString(
        KStream.streams[i].title,
        KStream.streams[i].customUrlImage.toString(),
      );
    }
    //save station isFavorite status
    for (var i = 0; i < KStream.streams.length; i++) {
      prefs.setBool(
        KStream.streams[i].title + 'isFavorite',
        KStream.streams[i].isFavorite,
      );
    }
  }
}
