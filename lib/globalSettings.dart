import 'package:KRadio/Cover.dart';
import 'package:KRadio/historyData.dart';
import 'package:KRadio/kstream.dart';
import 'package:KRadio/savedData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettings {
  //Player Settings
  static int radioListIndex = 1;
  static bool appBarTitle = true;
  static bool statusBarBackground = false;
  static bool showRunTime = true;
  static bool showProgressBar = true;
  static double bgOpacityMin = 0.0;
  static double bgOpacityMax = 1;
  static double bgOpacity = 0.4;
  static double controllerBGOpacityMin = 0.0;
  static double controllerBGOpacityMax = 1.0;
  static double controllerBGOpacity = 0.3;
  static bool playerButtonsBG = true;
  static double playerBGBlurMin = 0;
  static double playerBGBlurMax = 80.0;
  static double playerBGBlur = 10.0;
  static double controllerBGBlurMin = 0;
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

    int historySongLength = prefs.getInt('historySongLength')!;
    //get history
    for (var i = 0; i < historySongLength; i++) {
      HistoryData.history.add(
        HistoryData(
          id: prefs.getInt('historySongID$i')!,
          songTitle: prefs.getString('historySongTitle$i')!,
          station: prefs.getString('historySongStation$i')!,
        ),
      );
    }

    int savedSongLength = prefs.getInt('savedSongLength')!;
    //get saved
    for (var i = 0; i < savedSongLength; i++) {
      SavedData.saved.add(
        SavedData(
          id: prefs.getInt('savedSongID$i')!,
          songTitle: prefs.getString('savedSongTitle$i')!,
        ),
      );
    }

    int savedCoversLength = prefs.getInt('savedCoversLength')!;
    //get saved covers
    for (var i = 0; i < savedCoversLength; i++) {
      Cover.covers.add(
        Cover(
          id: prefs.getInt('savedCoverID$i')!,
          coverUrl: prefs.getString('savedCover$i')!,
        ),
      );
    }

    // //save covers
    // prefs.setInt('savedCoversLength', Cover.covers.length);
    // for (var i = 0; i < Cover.covers.length; i++) {
    //   prefs.setInt('savedCoverID$i', i);
    //   prefs.setString('savedCover$i', Cover.covers[i].coverUrl);
    // }
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

    //save history
    prefs.setInt('historySongLength', HistoryData.history.length);
    for (var i = 0; i < HistoryData.history.length; i++) {
      prefs.setInt('historySongID$i', i);
      prefs.setString('historySongTitle$i', HistoryData.history[i].songTitle);
      prefs.setString('historySongStation$i', HistoryData.history[i].station);
    }

    //save saved
    prefs.setInt('savedSongLength', SavedData.saved.length);
    for (var i = 0; i < SavedData.saved.length; i++) {
      prefs.setInt('savedSongID$i', i);
      prefs.setString('savedSongTitle$i', SavedData.saved[i].songTitle);
    }

    //save covers
    prefs.setInt('savedCoversLength', Cover.covers.length);
    for (var i = 0; i < Cover.covers.length; i++) {
      prefs.setInt('savedCoverID$i', i);
      prefs.setString('savedCover$i', Cover.covers[i].coverUrl);
    }
  }
}
