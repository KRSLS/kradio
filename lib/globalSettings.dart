import 'package:KRadio/kstream.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettings {
  //Player Settings
  static int radioListIndex = 1;
  static bool appBarTitle = true;
  static bool statusBarBackground = false;
  static bool showRunTime = true;
  static bool showProgressBar = true;
  static double bgOpacityMin = 0.0;
  static double bgOpacityMax = 0.7;
  static double bgOpacity = 0.4;
  static double controllerBGOpacityMin = 0.0;
  static double controllerBGOpacityMax = 1.0;
  static double controllerBGOpacity = 0.3;
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
  static bool border = true;
  static double borderRadiusMin = 0.0;
  static double borderRadiusMax = 40.0;
  static double borderRadius = 20.0;

  static void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    radioListIndex = await prefs.getInt('radioListIndex')!;
    statusBarBackground = await prefs.getBool('statusBarBackground')!;
    appBarTitle = await prefs.getBool('appBarTitle')!;
    showRunTime = await prefs.getBool('showRunTime')!;
    showProgressBar = await prefs.getBool('showProgressBar')!;
    bgOpacityMin = await prefs.getDouble('bgOpacityMin')!;
    bgOpacityMax = await prefs.getDouble('bgOpacityMax')!;
    bgOpacity = await prefs.getDouble('bgOpacity')!;
    controllerBGOpacityMin = await prefs.getDouble('controllerBGOpacityMin')!;
    controllerBGOpacityMax = await prefs.getDouble('controllerBGOpacityMax')!;
    controllerBGOpacity = await prefs.getDouble('controllerBGOpacity')!;
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
    border = await prefs.getBool('border')!;
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
    prefs.setBool('statusBarBackground', statusBarBackground);
    prefs.setBool('appBarTitle', appBarTitle);
    prefs.setBool('showRunTime', showRunTime);
    prefs.setBool('showProgressBar', showProgressBar);
    prefs.setDouble('bgOpacityMin', bgOpacityMin);
    prefs.setDouble('bgOpacityMax', bgOpacityMax);
    prefs.setDouble('bgOpacity', bgOpacity);
    prefs.setDouble('controllerBGOpacityMin', controllerBGOpacityMin);
    prefs.setDouble('controllerBGOpacityMax', controllerBGOpacityMax);
    prefs.setDouble('controllerBGOpacity', controllerBGOpacity);
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
    prefs.setBool('border', border);
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
