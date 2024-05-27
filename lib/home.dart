import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
  DateTime sleepTimerDT = DateTime.now();
  Timer? t;

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
          if (GlobalSettings.stopPlayerOnDeviceDisconnect) {
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
      imagePath: KStream.streams[index].customUrlImage,
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
    t = Timer(Duration(minutes: sleepTimer.toInt()), () async {
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
                children: [
                  TabBar(
                    onTap: (value) {
                      GlobalSettings.radioListIndex = value;
                      GlobalSettings.saveSettings();
                    },
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
                        ListView.builder(
                            itemCount: favorites.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      GlobalSettings.borderRadius),
                                  child: Image.network(
                                    fit: BoxFit.fitWidth,
                                    favorites[index].customUrlImage.toString(),
                                  ),
                                ),
                                onTap: () {
                                  changeRadioStation(index);
                                  Navigator.pop(context);
                                },
                                title: Text(favorites[index].title),
                                subtitle: favorites[index].description != null
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
                      leading: Icon(Icons.share_rounded),
                      title: Text('Share'),
                      subtitle: Text('Share the vibes with someone.'),
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
                      subtitle: Text('Stop the player after some time.'),
                      onTap: () {
                        modalSleepTimer();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.image_outlined),
                      title: Text('Custom image'),
                      subtitle: Text('Change currents station image/gif url.'),
                      onTap: () {
                        changeImageAlertDialog();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.image_search_rounded),
                      title: Text('Copy image'),
                      subtitle: Text('Copy the current station image/gif url.'),
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                              text:
                                  '${KStream.streams[currentStationIndex].customUrlImage}'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Station image/gif url copied.',
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
                      subtitle: Text(
                          'Copies the title and artist of the current song.'),
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                            text: '${metadata?[0]} - ${metadata?[1]}'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Current song copied.',
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
                      subtitle:
                          Text('Copies the title and artist of the next song.'),
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: '${nextSong} - ${nextArtist}'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Next song copied.',
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
                  child: Text('Revert'),
                  onPressed: () {
                    setState(() {
                      KStream.streams[currentStationIndex].customUrlImage =
                          KStream.streams[currentStationIndex].urlImage;
                    });
                    Navigator.pop(context);
                    GlobalSettings.saveSettings();
                  },
                ),
                TextButton(
                  child: const Text('Done'),
                  onPressed: () async {
                    setState(() {
                      KStream.streams[currentStationIndex].customUrlImage =
                          controller.text;
                      // GlobalSettings.saveSettings();
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
                              ScaffoldMessenger.of(context)
                                  .clearMaterialBanners();
                              t!.cancel();
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
                            t!.cancel();
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
                                ScaffoldMessenger.of(context)
                                    .clearMaterialBanners();
                                enableSleepTimer = false;
                                t!.cancel();
                              });
                            } else {
                              t!.cancel;
                              sleep();
                            }
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
            child: Text(currentStreamTitle)),
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
                SizedBox(),
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
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                        child: Container(
                          child: Material(
                            elevation: 40,
                            borderRadius: BorderRadius.circular(
                                GlobalSettings.borderRadius),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  GlobalSettings.borderRadius),
                              child: Image.network(
                                fit: BoxFit.cover,
                                KStream
                                    .streams[currentStationIndex].customUrlImage
                                    .toString(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Column(
                          mainAxisAlignment: orientation == Orientation.portrait
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Column(
                                children: [
                                  Center(
                                    child: GestureDetector(
                                      onLongPress: () {
                                        HapticFeedback.lightImpact();
                                        Clipboard.setData(ClipboardData(
                                            text: '${metadata?[0]}'));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
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
                                        Clipboard.setData(ClipboardData(
                                            text: '${metadata?[1]}'));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
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
                                    visible: GlobalSettings.showNextSong,
                                    child: Center(
                                      child: GestureDetector(
                                        onLongPress: () {
                                          HapticFeedback.lightImpact();
                                          Clipboard.setData(ClipboardData(
                                              text:
                                                  '${nextSong} - ${nextArtist}'));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
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
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      GlobalSettings.borderRadius),
                                  color: GlobalSettings.playerButtonsBG
                                      ? MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.light
                                          ? Color.fromARGB(40, 0, 0, 0)
                                          : Color.fromARGB(40, 255, 255, 255)
                                      : Colors.transparent,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
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
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
