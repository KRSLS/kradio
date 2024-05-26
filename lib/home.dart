import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kradio/globalSettings.dart';
import 'package:kradio/kstream.dart';
import 'package:kradio/playerScreen.dart';
import 'package:kradio/settings.dart';
import 'package:kradio/welcomeScreen.dart';

import 'package:radio_player/radio_player.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:share_plus/share_plus.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

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
  String currentStreamTitle = '';

  final headsetPlugin = HeadsetEvent();
  HeadsetState? headsetState;

  int currentStationIndex = 0;

  bool showNextSong = false;
  String nextSong = '';
  String nextArtist = '';

  String previousSong = '';
  String previousArtist = '';

  bool enableSleepTimer = false;
  double sleepTimer = 60.0;
  double maxSleepTimer = 120;
  String sleepTimerTest = 'running';

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    // TODO: implement initState
    super.initState();

    //check for internet listener
    checkForInternet();

    //initialize radio player
    initRadioPlayer();

    //load the next song information
    //xml parsing //run every 5 seconds
    loadNextSongInformation();

    //start radio with the users selected radio station
    //passed from the previous screen
    changeRadioStation(widget.startWithStation);

    //set the csi to the data passed from previous screen
    currentStationIndex = widget.startWithStation;
    //set the app bar title to the current station title
    currentStreamTitle = KStream.streams[currentStationIndex].title;

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
          radioPlayer.stop();
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
      });
    });
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
  void changeRadioStation(int index) async {
    setState(() {
      //set the current station to the index
      currentStationIndex = index;
    });

    //it's important to wait for the player to stop and then change the channel
    //then start the player again
    await radioPlayer.stop();
    await radioPlayer.setChannel(
      title: KStream.streams[index].title,
      url: KStream.streams[index].url,
      imagePath: KStream.streams[index].urlImage,
    );
    await radioPlayer.play();
  }

  //go to previous station
  void previousStation() {
    //handle out of range index
    if (currentStationIndex - 1 < 0) {
      changeRadioStation(KStream.streams.length - 1);
    } else
      changeRadioStation(currentStationIndex - 1);
  }

  //go the next station
  void nextStation() {
    //handle out of range index
    if (currentStationIndex + 1 > KStream.streams.length - 1) {
      changeRadioStation(0);
    } else
      changeRadioStation(currentStationIndex + 1);
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
          break;
        case InternetStatus.disconnected:
          //if disconnected
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
          break;
      }
    });
  }

  //this handles the next song information from xml
  void loadNextSongInformation() async {
    //this function runes every 2 seconds
    Timer.periodic(Duration(milliseconds: 2000), (timer) async {
      //next
      final urlNext = Uri.parse(KStream.streams[currentStationIndex].urlNext);
      final requestNext = await HttpClient().getUrl(urlNext);
      final responseNext = await requestNext.close();
      await responseNext
          .transform(utf8.decoder)
          .toXmlEvents()
          .normalizeEvents()
          .forEach((event) => nextArtist = event.toString());

      setState(() {
        //song
        //parse the data from the url
        var tempNextSong = XmlDocument.parse(nextArtist);
        //find all elements that uses the name Song
        nextSong = tempNextSong.findAllElements('Song').toString();
        //cut the string 14 characters ahead until it finds the character ">"
        nextSong = nextSong.substring(14, nextSong.indexOf(">") - 1);
        //replace html code to text
        nextSong = nextSong.replaceAll("&amp;", '&');

        //arist
        var tempNextArtist = XmlDocument.parse(nextArtist);
        //find all elements that uses the name Song
        nextArtist = tempNextArtist.findAllElements('Artist').toString();
        //cut the string 14 characters ahead until it finds the character ">"
        nextArtist = nextArtist.substring(15, nextArtist.indexOf("ID") - 2);
        //replace html code to text
        nextArtist = nextArtist.replaceAll("&amp;", '&');

        //change current title for the appbar
        currentStreamTitle = KStream.streams[currentStationIndex].title;
      });
    });
  }

  //handle sleep timer
  void sleep() {
    //start a timer with the time that the user selects
    Timer t = Timer(Duration(minutes: sleepTimer.toInt()), () async {
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

  void modalRadioList() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text(
                        'Station List',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: KStream.streams.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  fit: BoxFit.fitWidth,
                                  KStream.streams[index].urlImage.toString(),
                                ),
                              ),
                              onTap: () {
                                changeRadioStation(index);
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
                                },
                                icon: Icon(KStream.streams[index].isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_outline_rounded),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
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
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text(
                        'Station Properties',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.share_rounded),
                      title: Text('Share'),
                      subtitle: Text('Share the vibes with someone.'),
                      onTap: () async {
                        await Share.share(
                            KStream.streams[currentStationIndex].url);
                      },
                    ),
                    ListTile(
                      leading: Icon(enableSleepTimer
                          ? Icons.mode_night_rounded
                          : Icons.mode_night_outlined),
                      title: Text('Sleep timer'),
                      subtitle: Text('Stop the player after some time.'),
                      onTap: () {
                        modalSleepTimer();
                      },
                    ),
                  ],
                ),
              ),
            );
          });
        });
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
                            setState(() {
                              sleepTimer = value;
                            });
                          },
                          onChangeEnd: (value) {
                            //if the value at the end of the drag is 0
                            // then just disable the sleep feature
                            if (value == 0) {
                              setState(() {
                                enableSleepTimer = false;
                              });
                            } else
                              sleep();
                          },
                        )),
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
        title: Text(currentStreamTitle),
        actions: [
          IconButton(
            tooltip: 'Sleep Timer',
            onPressed: () {
              modalSleepTimer();
            },
            icon: Icon(enableSleepTimer
                ? Icons.mode_night_rounded
                : Icons.mode_night_outlined),
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
                SizedBox(),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
                  trailing: Icon(Icons.settings_rounded),
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
            opacity: 0.4,
            image: NetworkImage(
              KStream.streams[currentStationIndex].urlImage.toString(),
            ),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: GlobalSettings.playerBGBlurValue,
              sigmaY: GlobalSettings.playerBGBlurValue),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 30.0),
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            height: 300,
                            child: Material(
                              elevation: 50,
                              shadowColor: Color.fromARGB(255, 145, 57, 183),
                              borderRadius: BorderRadius.circular(20),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  fit: BoxFit.cover,
                                  KStream.streams[currentStationIndex].urlImage
                                      .toString(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: GestureDetector(
                              onLongPress: () {
                                HapticFeedback.lightImpact();
                                Clipboard.setData(
                                    ClipboardData(text: '${metadata?[0]}'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Artist copied.',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                textAlign: TextAlign.center,
                                metadata?[0] ?? 'Loading...',
                                overflow: TextOverflow.fade,
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: GestureDetector(
                              onLongPress: () {
                                HapticFeedback.lightImpact();
                                Clipboard.setData(
                                    ClipboardData(text: '${metadata?[1]}'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Title copied.',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                textAlign: TextAlign.center,
                                metadata?[1] ?? 'Loading...',
                                overflow: TextOverflow.fade,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Visibility(
                            visible: showNextSong,
                            child: Center(
                              child: GestureDetector(
                                onLongPress: () {
                                  HapticFeedback.lightImpact();
                                  Clipboard.setData(ClipboardData(
                                      text: '${nextSong} - ${nextArtist}'));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Next song copied.',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'Next: ${nextSong} by ${nextArtist}',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: GlobalSettings.playerButtonsBG
                            ? MediaQuery.of(context).platformBrightness ==
                                    Brightness.light
                                ? Color.fromARGB(40, 0, 0, 0)
                                : Color.fromARGB(40, 255, 255, 255)
                            : Colors.transparent,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              tooltip: 'Favorite',
                              onPressed: () {
                                setState(() {
                                  KStream.streams[currentStationIndex]
                                          .isFavorite =
                                      !KStream.streams[currentStationIndex]
                                          .isFavorite;
                                });
                              },
                              icon: Icon(
                                KStream.streams[currentStationIndex].isFavorite
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
            ),
          ),
        ),
      ),
    );
  }
}
