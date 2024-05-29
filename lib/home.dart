import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:KRadio/Cover.dart';
import 'package:KRadio/Covers.dart';
import 'package:KRadio/historyData.dart';
import 'package:KRadio/history.dart';
import 'package:KRadio/profile.dart';
import 'package:KRadio/saved.dart';
import 'package:KRadio/savedData.dart';
import 'package:KRadio/secure/secure.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:KRadio/globalSettings.dart';
import 'package:KRadio/kstream.dart';
import 'package:KRadio/playerScreen.dart';
import 'package:KRadio/settings.dart';
import 'package:KRadio/welcomeScreen.dart';

import 'package:radio_player/radio_player.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.startWithStation,
  });

  final int startWithStation;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  RadioPlayer radioPlayer = RadioPlayer();
  bool isPlaying = false;
  List<String>? metadata;

  final headsetPlugin = HeadsetEvent();
  HeadsetState? headsetState;

  int currentStationIndex = 0;

  bool showNextSong = false;
  String nextSong = '';
  String songRuntime = '';
  DateTime songStartTime = DateTime.now();
  DateTime songEndTime = DateTime.now();
  double runetimePercentage = 0.0;

  String previousSong = '';
  String previousArtist = '';

  bool enableSleepTimer = false;
  double sleepTimer = 60.0;
  double maxSleepTimer = 120;
  DateTime sleepTimerDT = DateTime.now();
  Timer? timer;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    // TODO: implement initState
    super.initState();

    //load global settings
    GlobalSettings.loadSettings();

    //check for internet listener
    checkForInternet();

    //initialize radio player
    initRadioPlayer();

    //load the next song information
    loadNextSongInformation();

    //get currents song information, startTime, endTime and
    //calculate the difference as a percentage, clamped 0 to 1
    getCurrentSongRuntime();

    //start radio with the users selected radio station
    //passed from the previous screen
    changeRadioStation(false, widget.startWithStation);

    //set the csi to the data passed from previous screen
    currentStationIndex = widget.startWithStation;

    //request permissions for the package
    headsetPlugin.requestPermission();

    //set the current state of audio output
    headsetPlugin.getCurrentState.then((_val) {
      setState(() {
        headsetState = _val;
      });
    });

    //listen for changes to audio output
    headsetPlugin.setListener((_val) {
      setState(() {
        headsetState = _val;
        if (this.headsetState == HeadsetState.DISCONNECT) {
          if (GlobalSettings.stopPlayerOnDeviceDisconnect) {
            radioPlayer.stop();
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Audio output device disconnected, stopped playing.'),
                action: SnackBarAction(
                  label: ('Okay'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                  },
                ),
              ),
            );
          }
        }
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> fetchRandomGif(bool setTag) async {
    final apiKey = Secure.giphyAndroidAPIKey;
    String tag = '';
    bool cancel = false;

    if (setTag) {
      TextEditingController controller = TextEditingController();
      await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text('Search with a tag'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      Text(
                          "If it doesn't work then the API reached the limit for today. Sorry :("),
                      TextField(
                        controller: controller,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      cancel = true;
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Done'),
                    onPressed: () async {
                      tag = controller.text.trim();
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    } else
      tag = 'loop';

    if (cancel != true) {
      final url = Uri.parse(
          "https://api.giphy.com/v1/gifs/random?api_key=$apiKey&tag=$tag");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          print(data['data']['id']);
          setState(() {
            KStream.streams[currentStationIndex].customUrlImage =
                'https://i.giphy.com/${data['data']['id']}.webp';
          });
          GlobalSettings.saveSettings();
        } else {
          print("Can't get a response from the api");
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('API limit reached.')));
      }
    }
  }

  void initRadioPlayer() {
    //set a listener for the radio player
    //this will change the isPlaying bool if the radio stops or starts
    radioPlayer.stateStream.listen((value) {
      setState(() {
        isPlaying = value;
        showNextSong = isPlaying;
      });
    });

    //set a listener to get metadata from the radio url (icy)
    radioPlayer.metadataStream.listen((value) {
      setState(() {
        metadata = value;
      });
    });
  }

  //change the current radio station with the provided index
  //index will be used for the radio list
  void changeRadioStation(bool isFavorite, int index) async {
    setState(() {
      //set the current station to the index
      //if its favorite then take the index of the favorite station class
      //easy fix
      if (isFavorite) {
        currentStationIndex = favorites[index].index!;
      } else {
        currentStationIndex = index;
      }
    });

    //it's important to wait for the player to stop and then change the channel
    //then start the player again
    await radioPlayer.stop();
    await radioPlayer.setChannel(
      title: KStream.streams[currentStationIndex].title,
      url: KStream.streams[currentStationIndex].url,
      imagePath: KStream.streams[currentStationIndex].customUrlImage,
    );

    await radioPlayer.play();
  }

  //go to previous station
  void previousStation() {
    //handle out of range index
    if (currentStationIndex - 1 < 0) {
      changeRadioStation(false, KStream.streams.length - 1);
    } else
      changeRadioStation(false, currentStationIndex - 1);
  }

  //go the next station
  void nextStation() {
    //handle out of range index
    if (currentStationIndex + 1 > KStream.streams.length - 1) {
      changeRadioStation(false, 0);
    } else
      changeRadioStation(false, currentStationIndex + 1);
  }

  //check for internet connection and provide info to the end user
  //this might help in situations when the user is wondering why the radio stop
  //wifi - data
  void checkForInternet() async {
    final listener =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          //if connected
          ScaffoldMessenger.of(context).clearMaterialBanners();
          if (GlobalSettings.notifyInternetLoss) {
            MaterialBanner(
              content: Text('Connected to the internet.'),
              actions: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).clearMaterialBanners();
                  },
                  child: Text('Okay'),
                ),
              ],
            );
          }
          break;
        case InternetStatus.disconnected:
          //if disconnected
          if (GlobalSettings.notifyInternetLoss) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showMaterialBanner(
              MaterialBanner(
                content: Text('Not connected to the internet.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).clearMaterialBanners();
                    },
                    child: Text('Okay'),
                  ),
                ],
              ),
            );
          }
          break;
      }
    });
  }

  //this handles the next song information from xml
  void loadNextSongInformation() async {
    String tempCurrentSong = '';
    Timer.periodic(Duration(seconds: 1), (timer) async {
      String url = KStream.streams[currentStationIndex].urlNext;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final tempNextSongInformation = document
            .findAllElements('Announcement')
            .first
            .attributes
            .first
            .value;

        setState(() {
          nextSong = tempNextSongInformation.toString();
          if (tempCurrentSong != metadata![1]) {
            tempCurrentSong = metadata![1];
            HistoryData.history.add(HistoryData(
                id: HistoryData.history.length + 1,
                songTitle: metadata![1] + ' - ' + metadata![0],
                station: KStream.streams[currentStationIndex].title));

            GlobalSettings.saveSettings();
          }
        });
      }
    });
  }

  void getCurrentSongRuntime() async {
    Timer timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      String url = KStream.streams[currentStationIndex].urlOnAir;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);

        String tempRuntime =
            document.findAllElements('Media').first.attributes.first.value;
        String tempEnd =
            document.findAllElements('Expire').first.attributes.first.value;

        String runtimeMinuteString = tempRuntime[0] + tempRuntime[1];
        int runtimeMinute = int.parse(runtimeMinuteString);
        String runtimeSecondString = tempRuntime[3] + tempRuntime[4];
        int runtimeSecond = int.parse(runtimeSecondString);

        DateTime endTime = DateTime.now();
        String endHourString = tempEnd[0] + tempEnd[1];
        int endHour = int.parse(endHourString);
        String endMinuteString = tempEnd[3] + tempEnd[4];
        int endMinute = int.parse(endMinuteString);
        String endSecondString = tempEnd[6] + tempEnd[7];
        int endSecond = int.parse(endSecondString);
        songEndTime = DateTime(endTime.year, endTime.month, endTime.day,
            endHour, endMinute, endSecond);

        setState(() {
          songRuntime = tempRuntime;
          songStartTime = songEndTime.subtract(
              Duration(minutes: runtimeMinute, seconds: runtimeSecond));
          runetimePercentage = calculatePercentage(songStartTime, songEndTime);
        });
      }
    });
  }

  //handle the percentage of the time elapsed
  double calculatePercentage(DateTime startTime, DateTime endTime) {
    //calculate the difference between 2 date times
    Duration totalDuration = endTime.difference(startTime);

    //dont divide by 0
    if (totalDuration.inSeconds == 0) return 0.0;

    DateTime now = DateTime.now();
    //calculate the differnece between now and a datetime
    Duration elapsedTime = now.difference(startTime);

    //clamp 0 to 1 for the percentage
    return math.min((elapsedTime.inSeconds / totalDuration.inSeconds), 1.0);
  }

  //handle sleep timer
  void sleep() {
    //start a timer with the time that the user selects
    timer = Timer(Duration(minutes: sleepTimer.toInt()), () async {
      //only run the code bellow if the option is still enabled
      if (enableSleepTimer) {
        print('Sleep timer execution.');
        await radioPlayer.stop();
        setState(() {
          enableSleepTimer = false;
        });
      } else
        print('Sleep timer execution but the options is not enabled.');
    });
  }

  List<KStream> favorites = [];

  void loadFavorites() {
    //clear the list before populating it
    favorites = [];
    //populate the list
    for (var i = 0; i < KStream.streams.length; i++) {
      if (KStream.streams[i].isFavorite) {
        favorites.add(KStream.streams[i]);
      }
    }
  }

  void modalRadioList() {
    loadFavorites();
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return DefaultTabController(
              initialIndex: GlobalSettings.radioListIndex,
              length: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    onTap: (value) {
                      GlobalSettings.radioListIndex = value;
                      GlobalSettings.saveSettings();
                    },
                    splashBorderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    tabs: [
                      Tab(
                        icon: Icon(Icons.list_alt_rounded),
                      ),
                      Tab(
                        icon: Icon(Icons.favorite_rounded),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      child: TabBarView(children: [
                        //Radio list
                        ListView.builder(
                            itemCount: KStream.streams.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      GlobalSettings.borderRadius),
                                  child: Image.network(
                                    fit: BoxFit.fitWidth,
                                    KStream.streams[index].customUrlImage
                                        .toString(),
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return CircularProgressIndicator();
                                    },
                                  ),
                                ),
                                onTap: () {
                                  changeRadioStation(false, index);
                                  Navigator.pop(context);
                                },
                                title: Text(KStream.streams[index].title),
                                subtitle: KStream.streams[index].description !=
                                        null
                                    ? Text(KStream.streams[index].description!)
                                    : Text('TBA'),
                                trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      KStream.streams[index].isFavorite =
                                          !KStream.streams[index].isFavorite;
                                    });
                                    loadFavorites();
                                    GlobalSettings.saveSettings();
                                  },
                                  icon: Icon(KStream.streams[index].isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_outline_rounded),
                                ),
                              );
                            }),
                        //Favorite radio list
                        favorites.isEmpty
                            ? Center(
                                child: Text(
                                  'Nothing found. 💔',
                                  style: TextStyle(fontSize: 20),
                                ),
                              )
                            : ListView.builder(
                                itemCount: favorites.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          GlobalSettings.borderRadius),
                                      child: Image.network(
                                        fit: BoxFit.fitWidth,
                                        favorites[index]
                                            .customUrlImage
                                            .toString(),
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return CircularProgressIndicator();
                                        },
                                      ),
                                    ),
                                    onTap: () {
                                      changeRadioStation(true, index);
                                      Navigator.pop(context);
                                    },
                                    title: Text(favorites[index].title),
                                    subtitle: favorites[index].description !=
                                            null
                                        ? Text(favorites[index].description!)
                                        : Text('TBA'),
                                    trailing: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          favorites[index].isFavorite = false;
                                        });
                                        loadFavorites();
                                        GlobalSettings.saveSettings();
                                      },
                                      icon: Icon(favorites[index].isFavorite
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_outline_rounded),
                                    ),
                                  );
                                }),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  void modalPlayerProperties() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Center(
                        child: Text(
                          'Station Properties',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.save_alt_rounded),
                      title: Text('Save song'),
                      subtitle: Text('Always remember the vibe.'),
                      onTap: () {
                        bool add = true;

                        // check if theres another song saved with the same name
                        for (var i = 0; i < SavedData.saved.length; i++) {
                          // if there is not the allow the save
                          if (SavedData.saved[i].songTitle !=
                              metadata![1] + " - " + metadata![0]) {
                            add = true;
                          } else {
                            // if there is then don't allow and break the loop
                            add = false;
                            break;
                          }
                        }

                        if (add) {
                          setState(() {
                            SavedData.saved.add(SavedData(
                                id: SavedData.saved.length + 1,
                                songTitle:
                                    metadata![1] + " - " + metadata![0]));
                          });
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Song saved.')));
                          GlobalSettings.saveSettings();
                        } else {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Song already saved.')));
                        }
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.open_in_browser_rounded),
                      title: Text('Open with YouTube'),
                      subtitle: Text('Search for the song on YouTube'),
                      onTap: () async {
                        final searchFor = metadata![1] + ' - ' + metadata![0];
                        final Uri url = Uri.parse(
                            'https://www.youtube.com/results?search_query=$searchFor');
                        await launchUrl(url);
                      },
                      trailing: Icon(Icons.keyboard_arrow_right_rounded),
                    ),
                    ListTile(
                      leading: Icon(Icons.share_rounded),
                      title: Text('Share'),
                      subtitle: Text('Share the vibe with someone'),
                      onTap: () async {
                        Navigator.pop(context);
                        await Share.share(
                            KStream.streams[currentStationIndex].url);
                      },
                    ),
                    ListTile(
                      leading: Icon(enableSleepTimer
                          ? Icons.mode_night_rounded
                          : Icons.mode_night_outlined),
                      title: Text('Sleep timer'),
                      subtitle: Text('Stop the player after some time'),
                      onTap: () {
                        modalSleepTimer();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.image_outlined),
                      title: Text('Custom cover'),
                      subtitle: Text("Change current's station cover url"),
                      onTap: () {
                        changeImageAlertDialog();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.image_search_rounded),
                      title: Text('Random cover'),
                      subtitle: Text("Try holding me"),
                      onTap: () {
                        fetchRandomGif(false);
                        Navigator.pop(context);
                      },
                      onLongPress: () async {
                        await fetchRandomGif(true);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.restore_outlined),
                      title: Text('Reset cover'),
                      subtitle: Text('Revert covert to original'),
                      onTap: () {
                        setState(() {
                          KStream.streams[currentStationIndex].customUrlImage =
                              KStream.streams[currentStationIndex].urlImage;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.copy_rounded),
                      title: Text('Copy cover'),
                      subtitle: Text("Get the url from the cover"),
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                              text: KStream
                                  .streams[currentStationIndex].customUrlImage
                                  .toString()),
                        );
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Copied.",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.copy_rounded),
                      title: Text('Copy current song'),
                      subtitle: Text('Copies the current song'),
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                            text: '${metadata?[0]} - ${metadata?[1]}'));
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Copied.',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.copy_all_rounded),
                      title: Text('Copy next song'),
                      subtitle: Text('Copies the next song'),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: '${nextSong}'));
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Copied.',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  void changeImageAlertDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Custom background'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text('Image/gif URL'),
                    Text(
                        'Please note that the higher the quality of the image the longer it will take to load.'),
                    TextField(
                      controller: controller,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Done'),
                  onPressed: () async {
                    setState(() {
                      if (!controller.text.contains('.mp4')) {
                        KStream.streams[currentStationIndex].customUrlImage =
                            controller.text;
                        Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Wrong format. Only images and gifs are allowed.')));
                      }
                    });
                    GlobalSettings.saveSettings();
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void modalSleepTimer() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text(
                        'Sleep timer',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    CheckboxListTile(
                        title: Text('Enable'),
                        subtitle:
                            Text('This will stop the player after some time.'),
                        value: enableSleepTimer,
                        onChanged: (value) {
                          setState(() {
                            enableSleepTimer = value!;

                            if (enableSleepTimer) {
                              sleep();
                              sleepTimerDT = DateTime.now()
                                  .add(Duration(minutes: sleepTimer.toInt()));
                            } else {
                              enableSleepTimer = false;
                              timer!.cancel();
                            }
                          });
                        }),
                    Visibility(
                        visible: enableSleepTimer,
                        child: Slider(
                          min: 0,
                          max: maxSleepTimer,
                          divisions: maxSleepTimer.toInt(),
                          label: sleepTimer.round().toString() + ' min',
                          value: sleepTimer,
                          onChanged: (value) {
                            timer!.cancel();
                            setState(() {
                              sleepTimer = value;
                              sleepTimerDT = DateTime.now()
                                  .add(Duration(minutes: sleepTimer.toInt()));
                            });
                          },
                          onChangeEnd: (value) {
                            //if the value at the end of the drag is 0
                            // then just disable the sleep feature
                            if (value == 0) {
                              setState(() {
                                enableSleepTimer = false;
                                timer!.cancel();
                              });
                            } else {
                              timer!.cancel;
                              sleep();
                            }
                          },
                        )),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (context) {
            return IconButton(
              tooltip: 'Drawer',
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu_rounded),
            );
          },
        ),
        title: Visibility(
          visible: GlobalSettings.appBarTitle,
          child: Text(
            KStream.streams[currentStationIndex].title,
          ),
        ),
        actions: [
          Visibility(
            visible: enableSleepTimer,
            child: IconButton(
              tooltip: 'Sleep Timer',
              onPressed: () {
                ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
                    content: Text(
                        'The player will stop at ${sleepTimerDT.hour}:${sleepTimerDT.minute}'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            modalSleepTimer();
                            ScaffoldMessenger.of(context)
                                .clearMaterialBanners();
                          },
                          child: Text('Change')),
                      TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .clearMaterialBanners();
                          },
                          child: Text('Okay'))
                    ]));
              },
              icon: Icon(enableSleepTimer
                  ? Icons.mode_night_rounded
                  : Icons.mode_night_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Properties',
            onPressed: () {
              modalPlayerProperties();
            },
            icon: Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      drawer: Drawer(
        child: Padding(
          padding: EdgeInsets.all(6.0),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Profile();
                        }));
                      },
                      title: Text('Profile'),
                      leading: Icon(Icons.person_rounded),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return History();
                        }));
                      },
                      title: Text('History'),
                      leading: Icon(Icons.history_rounded),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Saved();
                        }));
                      },
                      title: Text('Saved'),
                      leading: Icon(Icons.save_alt_outlined),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Covers();
                        }));
                      },
                      title: Text('Covers'),
                      leading: Icon(Icons.image_outlined),
                    ),
                  ],
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(GlobalSettings.borderRadius / 2),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Settings();
                    }));
                  },
                  title: Text(
                    'Settings',
                  ),
                  leading: Icon(Icons.settings_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            opacity: GlobalSettings.bgOpacity,
            image: NetworkImage(
              KStream.streams[currentStationIndex].customUrlImage.toString(),
            ),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: GlobalSettings.playerBGBlur,
              sigmaY: GlobalSettings.playerBGBlur),
          child: OrientationBuilder(
            builder: (context, orientation) {
              return GridView.count(
                physics: orientation == Orientation.portrait
                    ? NeverScrollableScrollPhysics()
                    : ClampingScrollPhysics(),
                childAspectRatio:
                    orientation == Orientation.portrait ? 1 : 1 / .65,
                crossAxisCount: orientation == Orientation.portrait ? 1 : 2,
                children: [
                  Padding(
                    padding: orientation == Orientation.portrait
                        ? EdgeInsets.symmetric(horizontal: 20, vertical: 20)
                        : EdgeInsets.symmetric(horizontal: 70, vertical: 0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(GlobalSettings.borderRadius),
                        border: Border.all(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.light
                                ? Color.fromARGB(255, 196, 196, 196)
                                : Color.fromARGB(255, 97, 97, 97),
                            width: 1,
                            style: GlobalSettings.border
                                ? BorderStyle.solid
                                : BorderStyle.none),
                      ),
                      child: Material(
                        elevation: 50,
                        borderRadius:
                            BorderRadius.circular(GlobalSettings.borderRadius),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              GlobalSettings.borderRadius),
                          child: Image.network(
                            fit: BoxFit.cover,
                            KStream.streams[currentStationIndex].customUrlImage
                                .toString(),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator());
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: orientation == Orientation.portrait
                        ? EdgeInsets.symmetric(horizontal: 20, vertical: 20)
                        : EdgeInsets.only(right: 50),
                    child: Column(
                      mainAxisAlignment: orientation == Orientation.portrait
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          children: [
                            Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                metadata?[0] ?? 'Loading...',
                                overflow: TextOverflow.fade,
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                            Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                metadata?[1] ?? 'Loading...',
                                overflow: TextOverflow.fade,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Visibility(
                              visible: GlobalSettings.showNextSong,
                              child: Center(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'Next: ${nextSong}',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Visibility(
                              visible: GlobalSettings.showRunTime,
                              child: Text(
                                textAlign: TextAlign.center,
                                songRuntime,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            Visibility(
                              visible: GlobalSettings.showRunTime,
                              child: SizedBox(
                                height: 10,
                              ),
                            ),
                            Visibility(
                              visible: GlobalSettings.showProgressBar,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: LinearProgressIndicator(
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  backgroundColor: Colors.transparent,
                                  minHeight: 4,
                                  borderRadius: BorderRadius.circular(
                                      GlobalSettings.borderRadius),
                                  value: runetimePercentage,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: GlobalSettings.showProgressBar,
                              child: SizedBox(
                                height: 10,
                              ),
                            ),
                            //add padding if the users wants to
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  GlobalSettings.borderRadius),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: GlobalSettings.controllerBGBlur,
                                    sigmaY: GlobalSettings.controllerBGBlur),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.light
                                            ? Color.fromARGB(255, 196, 196, 196)
                                            : Color.fromARGB(255, 97, 97, 97),
                                        width: 1,
                                        style: GlobalSettings.border
                                            ? BorderStyle.solid
                                            : BorderStyle.none),
                                    borderRadius: BorderRadius.circular(
                                        GlobalSettings.borderRadius),
                                    color: GlobalSettings.playerButtonsBG
                                        ? MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark
                                            ? Color.fromRGBO(
                                                0,
                                                0,
                                                0,
                                                GlobalSettings
                                                    .controllerBGOpacity)
                                            : Color.fromRGBO(
                                                255,
                                                255,
                                                255,
                                                GlobalSettings
                                                    .controllerBGOpacity)
                                        : Colors.transparent,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      IconButton(
                                        tooltip: 'Favorite',
                                        onPressed: () {
                                          setState(() {
                                            KStream.streams[currentStationIndex]
                                                    .isFavorite =
                                                !KStream
                                                    .streams[
                                                        currentStationIndex]
                                                    .isFavorite;
                                          });
                                          GlobalSettings.saveSettings();
                                        },
                                        icon: Icon(
                                          KStream.streams[currentStationIndex]
                                                  .isFavorite
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_outline_rounded,
                                          size: 38,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Previous',
                                        onPressed: () {
                                          previousStation();
                                        },
                                        icon: Icon(
                                          Icons.arrow_circle_left_rounded,
                                          size: 52,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: isPlaying ? 'Stop' : 'Play',
                                        onPressed: () {
                                          isPlaying
                                              ? radioPlayer.stop()
                                              : radioPlayer.play();
                                        },
                                        icon: Icon(
                                          !isPlaying
                                              ? Icons.play_circle_rounded
                                              : Icons.pause_circle_rounded,
                                          size: 86,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Next',
                                        onPressed: () {
                                          nextStation();
                                        },
                                        icon: Icon(
                                          Icons.arrow_circle_right_rounded,
                                          size: 52,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Radio List',
                                        onPressed: () {
                                          modalRadioList();
                                        },
                                        icon: Icon(
                                          Icons.list_alt_rounded,
                                          size: 38,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
