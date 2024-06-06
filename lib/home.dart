import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:KRadio/Cover.dart';
import 'package:KRadio/Covers.dart';
import 'package:KRadio/historyData.dart';
import 'package:KRadio/history.dart';
import 'package:KRadio/saved.dart';
import 'package:KRadio/savedData.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:KRadio/globalSettings.dart';
import 'package:KRadio/kstream.dart';
import 'package:KRadio/settings.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:radio_player/radio_player.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

import 'Secure.dart';

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
  bool playerStarted = false;

  final headsetPlugin = HeadsetEvent();
  HeadsetState? headsetState;

  int currentStationIndex = 0;

  String currentSongArtist = '';
  String currentSongTitle = '';
  String currentSong = '';

  bool showNextSong = false;

  String nextSong = '';
  String songRuntime = '';
  DateTime songStartTime = DateTime.now();
  DateTime songEndTime = DateTime.now();
  double runetimePercentage = 0.0;
  String elapsedTimeString = '';

  String previousSong = '';
  String previousArtist = '';

  bool enableSleepTimer = false;
  double sleepTimer = 60.0;
  double maxSleepTimer = 120;
  DateTime sleepTimerDT = DateTime.now();
  Timer? timer;

  bool showLike = false;

  bool swipeNext = false;
  bool swipePrevious = false;

  //Spotify
  String? spotifyToken;
  String? spotifyCoverUrl;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    super.initState();

    //load global settings
    GlobalSettings.loadSettings();

    //check for internet listener
    checkForInternet();

    //initialize radio player
    initRadioPlayer();

    //load currents song information
    loadCurrentSongInformation();

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
    headsetPlugin.getCurrentState.then((val) {
      setState(() {
        headsetState = val;
      });
    });

    //listen for changes to audio output
    headsetPlugin.setListener((val) {
      setState(() {
        headsetState = val;
        if (headsetState == HeadsetState.DISCONNECT) {
          if (GlobalSettings.stopPlayerOnDeviceDisconnect) {
            radioPlayer.stop();
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Audio output device disconnected, stopped playing.'),
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
    super.dispose();
  }

  Future<void> fetchToken() async {
    String clientId = Secure.spotifyClientId;
    String clientSecret = Secure.spotifyClientSecret;
    String credentials =
        Base64Encoder().convert(utf8.encode("$clientId:$clientSecret"));
    String authorizationHeader = "Basic $credentials";
    Map<String, String> headers = {"Authorization": authorizationHeader};
    Map<String, String> body = {"grant_type": "client_credentials"};

    try {
      final url = Uri.parse("https://accounts.spotify.com/api/token");
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data["access_token"];
        print("Access Token: $accessToken");
        setState(() {
          spotifyToken = accessToken;
        });
      } else {
        throw Exception("Error: ${response.statusCode}");
      }
    } on Exception catch (e) {
      print("Error fetching access token: $e");
    }
  }

  Future<void> fetchCoverImage(
      String searchFor, String songTitle, String songArtist) async {
    // search with filters, results are much better
    final url = Uri.parse(
        "https://api.spotify.com/v1/search?q=$searchFor%2520track%3$songTitle%2520artist%3$songArtist&type=track");
    // this is without filters, and might return wrong covers
    // final url = Uri.parse(
    //     "https://api.spotify.com/v1/search?q=$searchFor&type=track");
    final headers = {"Authorization": "Bearer $spotifyToken"};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tracks = data["tracks"]["items"] as List;

        if (tracks.isNotEmpty) {
          setState(() {
            spotifyCoverUrl = tracks[0]["album"]["images"][0]["url"];
          });
        } else
          print("Tracks is empty");
      } else {
        fetchToken();
        throw Exception("Error: ${response.statusCode}");
      }
    } on Exception catch (e) {
      print("Error fetching search results: $e");
    }
  }

  Future<void> fetchRandomGif(bool setTag) async {
    String apiKey = Platform.isAndroid ? Secure.giphyAndroid : Secure.giphyIOS;
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
                title: const Text('Search with a tag'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      const Text(
                          "If it doesn't work then the API reached the limit for today. Sorry :("),
                      TextField(
                        controller: controller,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
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
    } else {
      tag = 'loop';
    }

    if (cancel != true) {
      final url = Uri.parse(
          "https://api.giphy.com/v1/gifs/random?api_key=$apiKey&tag=$tag");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            KStream.streams[currentStationIndex].customUrlImage =
                'https://i.giphy.com/${data['data']['id']}.webp';
          });
          GlobalSettings.saveSettings();
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('API limit reached.')));
      }
    }
  }

  void initRadioPlayer() async {
    //set a listener for the radio player
    //this will change the isPlaying bool if the radio stops or starts
    radioPlayer.stateStream.listen((value) {
      setState(() {
        isPlaying = value;
        showNextSong = isPlaying;
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
    if (playerStarted) await radioPlayer.stop();
    if (!playerStarted) playerStarted = true;
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
    } else {
      changeRadioStation(false, currentStationIndex - 1);
    }
  }

  //go the next station
  void nextStation() {
    //handle out of range index
    if (currentStationIndex + 1 > KStream.streams.length - 1) {
      changeRadioStation(false, 0);
    } else {
      changeRadioStation(false, currentStationIndex + 1);
    }
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
              content: const Text('Connected to the internet.'),
              actions: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).clearMaterialBanners();
                  },
                  child: const Text('Okay'),
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
                content: const Text('Not connected to the internet.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).clearMaterialBanners();
                    },
                    child: const Text('Okay'),
                  ),
                ],
              ),
            );
          }
          break;
      }
    });
  }

  //this handles currents song information from xml
  void loadCurrentSongInformation() async {
    //Fetch album image every 3 seconds //will change
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (GlobalSettings.useSongsCover) {
        fetchCoverImage(currentSongTitle + currentSongArtist, currentSongTitle,
            currentSongArtist);
      }
    });
    String tempCurrentArtist = '';
    String tempCurrentSong = '';
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      String url = KStream.streams[currentStationIndex].urlOnAir;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final tempTitle =
            document.findAllElements('Song').first.attributes.first.value;
        final tempArtist =
            document.findAllElements('Artist').first.attributes.first.value;

        setState(() {
          currentSongTitle = tempTitle;
          currentSongArtist = tempArtist;
        });
      }
    });
  }

  //this handles the next song information from xml
  void loadNextSongInformation() async {
    String tempCurrentSong = '';
    Timer.periodic(const Duration(seconds: 1), (timer) async {
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
          if (tempCurrentSong != currentSongTitle) {
            tempCurrentSong = currentSongTitle;
            HistoryData.history.add(HistoryData(
                id: HistoryData.history.length + 1,
                songTitle: '$currentSongTitle - $currentSongArtist',
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

    String minElapsed = '';
    String secElapsed = '';
    if (elapsedTime.inMinutes.remainder(60) < 10) {
      minElapsed = '0${elapsedTime.inMinutes.remainder(60)}';
    } else if (elapsedTime.inMinutes.remainder(60) > 10) {
      minElapsed = elapsedTime.inMinutes.remainder(60).toString();
    }

    if (elapsedTime.inSeconds.remainder(60) < 10) {
      secElapsed = '0${elapsedTime.inSeconds.remainder(60)}';
    } else if (elapsedTime.inSeconds.remainder(60) > 10) {
      secElapsed = elapsedTime.inSeconds.remainder(60).toString();
    }

    setState(() {
      elapsedTimeString = '$minElapsed:$secElapsed';
    });

    //clamp 0 to 1 for the percentage
    return math.min((elapsedTime.inSeconds / totalDuration.inSeconds), 1.0);
  }

  //handle sleep timer
  void sleep() {
    //start a timer with the time that the user selects
    timer = Timer(Duration(minutes: sleepTimer.toInt()), () async {
      //only run the code bellow if the option is still enabled
      if (enableSleepTimer) {
        await radioPlayer.stop();
        setState(() {
          enableSleepTimer = false;
        });
      }
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

  void saveSong() {
    bool add = true;

    // check if theres another song saved with the same name
    for (var i = 0; i < SavedData.saved.length; i++) {
      // if there is not the allow the save
      if (SavedData.saved[i].songTitle !=
          "$currentSongTitle - $currentSongArtist") {
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
            songTitle: "$currentSongTitle - $currentSongArtist"));
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Song saved.')));
      GlobalSettings.saveSettings();
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Song exists.')));
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
                    splashBorderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.list_alt_rounded),
                      ),
                      Tab(
                        icon: Icon(Icons.favorite_rounded),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(children: [
                      //Radio list
                      ListView.builder(
                          itemCount: KStream.streams.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                changeRadioStation(false, index);
                                Navigator.pop(context);
                              },
                              title: Text(
                                  'Station: ${KStream.streams[index].title}'),
                              subtitle: KStream.streams[index].description !=
                                      null
                                  ? Text(KStream.streams[index].description!)
                                  : const Text('TBA'),
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
                            ).animate().fadeIn();
                          }),
                      //Favorite radio list
                      favorites.isEmpty
                          ? const Center(
                              child: Text(
                                'Nothing found. 💔',
                                style: TextStyle(fontSize: 20),
                              ),
                            ).animate().fadeIn()
                          : ListView.builder(
                              itemCount: favorites.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  onTap: () {
                                    changeRadioStation(true, index);
                                    Navigator.pop(context);
                                  },
                                  title: Text(
                                      'Station: ${favorites[index].title}'),
                                  subtitle: favorites[index].description != null
                                      ? Text(favorites[index].description!)
                                      : const Text('TBA'),
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
                                ).animate().fadeIn();
                              }),
                    ]),
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
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Center(
                      child: Text(
                        'Station Properties',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.headset_rounded),
                    title: Text(
                      'Listening to: ${KStream.streams[currentStationIndex].title}',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.share_rounded),
                    title: const Text('Share'),
                    subtitle: const Text('Share the vibe'),
                    onTap: () async {
                      Navigator.pop(context);
                      await Share.share(
                          KStream.streams[currentStationIndex].url);
                    },
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  ),
                  ListTile(
                    leading: const Icon(Icons.open_in_browser_rounded),
                    title: const Text('Open with YouTube'),
                    subtitle: const Text('Search for the song on YouTube'),
                    onTap: () async {
                      final searchFor =
                          '"$currentSongTitle - $currentSongArtist")';
                      final Uri url = Uri.parse(
                          'https://www.youtube.com/results?search_query=$searchFor');
                      await launchUrl(url);
                    },
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  ),
                  ListTile(
                    leading: const Icon(Icons.save_alt_rounded),
                    title: const Text('Save song'),
                    subtitle: const Text('Always remember the vibe.'),
                    onTap: () {
                      saveSong();
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(enableSleepTimer
                        ? Icons.mode_night_rounded
                        : Icons.mode_night_outlined),
                    title: const Text('Sleep timer'),
                    subtitle: const Text('Stop the player after some time'),
                    onTap: () {
                      modalSleepTimer();
                    },
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  ),
                  ListTile(
                    leading: const Icon(Icons.image_outlined),
                    title: const Text('Cover'),
                    subtitle: const Text('See all cover options'),
                    onTap: () {
                      modalCoverOptions();
                    },
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  ),
                  ListTile(
                    leading: const Icon(Icons.copy_rounded),
                    title: const Text('Copy'),
                    subtitle: const Text("Copy song's information"),
                    onTap: () {
                      modalCopyOptions();
                    },
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  ),
                ],
              ),
            );
          });
        });
  }

  void modalCoverOptions() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Center(
                      child: Text(
                        'Cover Options',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.image_outlined),
                    title: const Text('Custom cover'),
                    subtitle: const Text("Change current's station cover url"),
                    onTap: () {
                      changeImageAlertDialog();
                    },
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  ),
                  ListTile(
                    leading: const Icon(Icons.copy_rounded),
                    title: const Text('Copy cover'),
                    subtitle: const Text("Get the url from the cover"),
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(
                            text: KStream
                                .streams[currentStationIndex].customUrlImage
                                .toString()),
                      );
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
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
                    leading: const Icon(Icons.image_search_rounded),
                    title: const Text('Random cover'),
                    subtitle: const Text("Try holding me"),
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
                    leading: const Icon(Icons.save_outlined),
                    title: const Text('Save cover'),
                    subtitle: const Text("Save cover for later use"),
                    onTap: () {
                      setState(() {
                        bool add = true;

                        // check if theres another song saved with the same name
                        for (var i = 0; i < Cover.covers.length; i++) {
                          // if there is not the allow the save
                          if (Cover.covers[i].coverUrl !=
                              KStream
                                  .streams[currentStationIndex].customUrlImage
                                  .toString()) {
                            add = true;
                          } else {
                            // if there is then don't allow and break the loop
                            add = false;
                            break;
                          }
                        }

                        if (add) {
                          setState(() {
                            Cover.covers.add(
                              Cover(
                                id: Cover.covers.length + 1,
                                coverUrl: KStream
                                    .streams[currentStationIndex].customUrlImage
                                    .toString(),
                              ),
                            );
                          });
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cover saved.')));
                          GlobalSettings.saveSettings();
                        } else {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cover exists.')));
                        }
                        Navigator.pop(context);
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.restore_outlined),
                    title: const Text('Reset cover'),
                    subtitle: const Text('Revert covert to original'),
                    onTap: () {
                      setState(() {
                        KStream.streams[currentStationIndex].customUrlImage =
                            KStream.streams[currentStationIndex].urlImage;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          });
        });
  }

  void modalCopyOptions() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Center(
                      child: Text(
                        'Copy Options',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.copy_rounded),
                    title: const Text('Copy current song'),
                    subtitle: const Text('Copies the current song'),
                    onTap: () {
                      Clipboard.setData(ClipboardData(
                          text: "$currentSongTitle - $currentSongArtist"));
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
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
                    leading: const Icon(Icons.copy_all_rounded),
                    title: const Text('Copy next song'),
                    subtitle: const Text('Copies the next song'),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: nextSong));
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
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
              title: const Text('Custom background'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    const Text('Image/gif URL'),
                    const Text(
                        'Please note that the higher the quality of the image the longer it will take to load.'),
                    TextField(
                      controller: controller,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
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
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Center(
                      child: Text(
                        'Sleep Timer',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  CheckboxListTile(
                      title: const Text('Enable'),
                      subtitle: const Text(
                          'This will stop the player after some time.'),
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
                        label: '${sleepTimer.round()} min',
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
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    double coverHeight = MediaQuery.of(context).size.width / 1.1;
    double coverWidth = MediaQuery.of(context).size.width / 1.1;

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
              icon: const Icon(Icons.menu_rounded),
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
                          child: const Text('Change')),
                      TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .clearMaterialBanners();
                          },
                          child: const Text('Okay'))
                    ]));
              },
              icon: Icon(enableSleepTimer
                  ? Icons.mode_night_rounded
                  : Icons.mode_night_outlined),
            ).animate().fadeIn(),
          ),
          IconButton(
            tooltip: 'Properties',
            onPressed: () {
              modalPlayerProperties();
            },
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    // ListTile(
                    //   onTap: () {
                    //     Navigator.push(context,
                    //         MaterialPageRoute(builder: (context) {
                    //       return Profile();
                    //     }));
                    //   },
                    //   title: Text('Profile'),
                    //   leading: Icon(Icons.person_rounded),
                    // ),
                    ListTile(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const History();
                        }));
                      },
                      title: const Text('History'),
                      leading: const Icon(Icons.history_rounded),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const Saved();
                        }));
                      },
                      title: const Text('Saved'),
                      leading: const Icon(Icons.save_alt_outlined),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Covers(
                            currentStationIndex: currentStationIndex,
                          );
                        }));
                      },
                      title: const Text('Covers'),
                      leading: const Icon(Icons.image_outlined),
                    ),
                  ],
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const Settings();
                    }));
                  },
                  title: const Text(
                    'Settings',
                  ),
                  leading: const Icon(Icons.settings_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onDoubleTap: () {
          setState(() {
            showLike = true;
          });
          saveSong();
          Future.delayed(const Duration(milliseconds: 900), () {
            setState(() {
              showLike = false;
            });
          });
        },
        onHorizontalDragUpdate: (details) {
          double sens = 8.0;

          if (details.delta.dx > sens) {
            swipeNext = true;
            swipePrevious = false;
          } else if (details.delta.dx < sens) {
            swipeNext = false;
            swipePrevious = true;
          }
        },
        onHorizontalDragEnd: (details) {
          if (GlobalSettings.swipe) {
            if (swipeNext) {
              nextStation();
              swipeNext = false;
              swipePrevious = false;
            }

            if (swipePrevious) {
              previousStation();
              swipeNext = false;
              swipePrevious = false;
            }
          }
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  opacity: .5,
                  image: NetworkImage(
                    //cache image sometime
                    GlobalSettings.useSongsCover
                        ? spotifyCoverUrl.toString()
                        : KStream.streams[currentStationIndex].customUrlImage
                            .toString(),
                  ),
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    return orientation == Orientation.portrait
                        ? SafeArea(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                playerCover(coverHeight, coverWidth),
                                playerInformation(),
                                playerController(),
                              ],
                            ),
                          )
                        : SafeArea(
                            child: GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 1.45,
                              children: [
                                playerCover(coverHeight, coverWidth),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    playerInformation(),
                                    playerController(),
                                  ],
                                ),
                              ],
                            ),
                          );
                  },
                ),
              ),
            ),
            Visibility(
              visible: showLike,
              child: Center(
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 250,
                )
                    .animate()
                    .shimmer()
                    .shake(
                        duration: Duration(
                      milliseconds: 300,
                    ))
                    .fadeIn(
                      duration: Duration(
                        milliseconds: 300,
                      ),
                    )
                    .fadeOut(
                      delay: const Duration(milliseconds: 600),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget playerCover(double coverHeight, double coverWidth) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 40,
          child: Container(
            height: coverHeight,
            width: coverWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: GlobalSettings.useSongsCover
                    ? spotifyCoverUrl.toString()
                    : KStream.streams[currentStationIndex].customUrlImage
                        .toString(),
                placeholder: (context, url) {
                  return Center(child: CircularProgressIndicator.adaptive());
                },
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget playerInformation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$currentSongTitle - $currentSongArtist',
              overflow: TextOverflow.fade,
              maxLines: 2,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Visibility(
              visible: GlobalSettings.showNextSong,
              child: Text(
                'Next: $nextSong',
                style: const TextStyle(
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget playerController() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Visibility(
            visible: GlobalSettings.showProgressBar,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                backgroundColor: const Color.fromRGBO(255, 255, 255, 0.2),
                minHeight: 4,
                borderRadius: BorderRadius.circular(12),
                value: runetimePercentage,
              ),
            ),
          ),
          Visibility(
            visible: GlobalSettings.showProgressBar,
            child: const SizedBox(
              height: 10,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: GlobalSettings.showRunTime,
                  child: Text(
                    textAlign: TextAlign.center,
                    elapsedTimeString,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.fade,
                  ),
                ),
                Visibility(
                  visible: GlobalSettings.showRunTime,
                  child: Text(
                    textAlign: TextAlign.center,
                    songRuntime,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: GlobalSettings.showRunTime,
            child: const SizedBox(
              height: 10,
            ),
          ),
          //add padding if the users wants to
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                  tooltip: 'Favorite',
                  onPressed: () {
                    setState(() {
                      KStream.streams[currentStationIndex].isFavorite =
                          !KStream.streams[currentStationIndex].isFavorite;
                    });
                    GlobalSettings.saveSettings();
                  },
                  icon: Icon(
                    KStream.streams[currentStationIndex].isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_outline_rounded,
                    size: 30,
                  ),
                ),
                IconButton(
                  tooltip: 'Previous',
                  onPressed: () {
                    previousStation();
                  },
                  icon: const Icon(
                    Icons.arrow_circle_left_rounded,
                    size: 40,
                  ),
                ),
                IconButton(
                  tooltip: isPlaying ? 'Stop' : 'Play',
                  onPressed: () async {
                    isPlaying
                        ? await radioPlayer.pause()
                        : await radioPlayer.play();
                  },
                  icon: Icon(
                    !isPlaying
                        ? Icons.play_circle_rounded
                        : Icons.pause_circle_rounded,
                    size: 56,
                  ),
                ),
                IconButton(
                  tooltip: 'Next',
                  onPressed: () {
                    nextStation();
                  },
                  icon: const Icon(
                    Icons.arrow_circle_right_rounded,
                    size: 40,
                  ),
                ),
                IconButton(
                  tooltip: 'Radio List',
                  onPressed: () {
                    modalRadioList();
                  },
                  icon: const Icon(
                    Icons.list_alt_rounded,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
