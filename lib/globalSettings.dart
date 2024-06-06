import 'package:KRadio/Cover.dart';
import 'package:KRadio/historyData.dart';
import 'package:KRadio/kstream.dart';
import 'package:KRadio/savedData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettings {
  //Player Settings
  static int radioListIndex = 1;
  static bool appBarTitle = true;
  static bool useSongsCover = false;
  static bool statusBarBackground = false;
  static bool showRunTime = true;
  static bool showProgressBar = true;
  static bool swipe = false;
  static bool notifyInternetLoss = true;
  static bool showNextSong = true;
  static bool stopPlayerOnDeviceDisconnect = true;

  static void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    radioListIndex = prefs.getInt('radioListIndex')!;
    statusBarBackground = prefs.getBool('statusBarBackground')!;
    appBarTitle = prefs.getBool('appBarTitle')!;
    useSongsCover = prefs.getBool('useSongsCover')!;
    showRunTime = prefs.getBool('showRunTime')!;
    showProgressBar = prefs.getBool('showProgressBar')!;
    swipe = prefs.getBool('swipe')!;
    notifyInternetLoss = prefs.getBool('notifyInternetLoss')!;
    showNextSong = prefs.getBool('showNextSong')!;
    stopPlayerOnDeviceDisconnect =
        prefs.getBool('stopPlayerOnDeviceDisconnect')!;

    //get custom image url
    for (var i = 0; i < KStream.streams.length; i++) {
      KStream.streams[i].customUrlImage = prefs.getString(
        KStream.streams[i].title,
      )!;
    }

    //get station isFavorite status
    for (var i = 0; i < KStream.streams.length; i++) {
      KStream.streams[i].isFavorite = prefs.getBool(
        '${KStream.streams[i].title}isFavorite',
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
  }

  static void saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('radioListIndex', radioListIndex);
    prefs.setBool('statusBarBackground', statusBarBackground);
    prefs.setBool('appBarTitle', appBarTitle);
    prefs.setBool('useSongsCover', useSongsCover);
    prefs.setBool('showRunTime', showRunTime);
    prefs.setBool('showProgressBar', showProgressBar);
    prefs.setBool('swipe', swipe);
    prefs.setBool('notifyInternetLoss', notifyInternetLoss);
    prefs.setBool('showNextSong', showNextSong);
    prefs.setBool('stopPlayerOnDeviceDisconnect', stopPlayerOnDeviceDisconnect);

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
        '${KStream.streams[i].title}isFavorite',
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
