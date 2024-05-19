import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kradio/kstream.dart';
import 'package:kradio/playerScreen.dart';

import 'package:radio_player/radio_player.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.startWithStation});

  final int startWithStation;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  RadioPlayer radioPlayer = RadioPlayer();
  bool isPlaying = false;
  List<String>? metadata;
  String currentStreamTitle = '';

  List<KStream> kstream = [
    KStream(
      title: 'KISS 60s',
      url: 'https://netradio.live24.gr/kiss-web-classic',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/60s/AirPlayNext.xml',
      urlImage:
          'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExODc1c3FqdGRlMjQyYXgwYXJrYWpzdjZpdzYxOWZudHE1d3NoM3VmZiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/gjgWQA5QBuBmUZahOP/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      title: 'KISS 70s',
      url: 'https://netradio.live24.gr/kiss-web-70s',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/70s/AirPlayNext.xml',
      urlImage:
          'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExODc1c3FqdGRlMjQyYXgwYXJrYWpzdjZpdzYxOWZudHE1d3NoM3VmZiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/gjgWQA5QBuBmUZahOP/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      title: 'KISS 80s',
      url: 'https://netradio.live24.gr/kiss-web-80s',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/80s/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      title: 'KISS 90s',
      url: 'https://netradio.live24.gr/kiss-web-90s',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/90s/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      title: 'KISS 00s',
      url: 'https://netradio.live24.gr/kiss-web-oos',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/00s/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      title: 'KISS DISCO',
      url: 'https://netradio.live24.gr/actionfm',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/Disco/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      title: 'KISS LATIN',
      url: 'https://netradio.live24.gr/kiss-web-latin1',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/Latin/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      title: 'KISS CHILL',
      url: 'https://netradio.live24.gr/kiss-web-lounge',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/Chill/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      title: 'KISS BALLADS',
      url: 'https://netradio.live24.gr/kiss-web-balads',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/Ballads/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      title: 'KISS XMAS',
      url: 'https://netradio.live24.gr/kiss-web-xmas',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/KissMas/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      title: 'KISS JAZZ',
      url: 'https://netradio.live24.gr/kiss-web-jazz',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/Jazz/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      title: 'REBEL',
      url: 'https://netradio.live24.gr/rebel1052',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/Rebel/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      title: 'NRG',
      url: 'https://netradio.live24.gr/kiss-web-nrg',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/NRG/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      title: 'CAVIAR',
      description: 'OOOOOOHhhhh babyyyy',
      url: 'https://netradio.live24.gr/kiss-web-rock',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/Caviar/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      title: 'HOT',
      description: 'Amazing, dev loves this.',
      url: 'https://netradio.live24.gr/hotfm',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/HotFM/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
  ];

  final headsetPlugin = HeadsetEvent();
  HeadsetState? headsetState;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    // TODO: implement initState
    super.initState();

    checkForInternet();

    initRadioPlayer();

    loadNextSongInformation();

    changeRadioStation(widget.startWithStation);

    currentStreamTitle = kstream[currentStationIndex].title;

    ///Request Permissions (Required for Android 12)
    headsetPlugin.requestPermission();

    /// if headset is plugged
    headsetPlugin.getCurrentState.then((_val) {
      setState(() {
        headsetState = _val;
      });
    });

    /// Detect the moment headset is plugged or unplugged
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
    radioPlayer.stateStream.listen((value) {
      setState(() {
        isPlaying = value;
        showNextSong = isPlaying;
      });
    });

    radioPlayer.metadataStream.listen((value) {
      setState(() {
        metadata = value;
      });
    });
  }

  int currentStationIndex = 0;
  void changeRadioStation(int index) async {
    setState(() {
      currentStationIndex = index;
    });
    await radioPlayer.stop();
    await radioPlayer.setChannel(
      title: kstream[index].title,
      url: kstream[index].url,
      imagePath: kstream[index].urlImage,
    );
    await radioPlayer.play();
  }

  void previousStation() {
    if (currentStationIndex - 1 < 0) {
      changeRadioStation(kstream.length - 1);
    } else
      changeRadioStation(currentStationIndex - 1);
  }

  void nextStation() {
    if (currentStationIndex + 1 > kstream.length - 1) {
      changeRadioStation(0);
    } else
      changeRadioStation(currentStationIndex + 1);
  }

  bool showNextSong = false;
  String nextSong = '';
  String nextArtist = '';

  String previousSong = '';
  String previousArtist = '';

  void checkForInternet() async {
    final listener =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          // The internet is now connected
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
          // The internet is now disconnected
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

  void loadNextSongInformation() async {
    //3 seconds
    Timer.periodic(Duration(milliseconds: 3000), (timer) async {
      //Next
      final urlNext = Uri.parse(kstream[currentStationIndex].urlNext);
      final requestNext = await HttpClient().getUrl(urlNext);
      final responseNext = await requestNext.close();
      await responseNext
          .transform(utf8.decoder)
          .toXmlEvents()
          .normalizeEvents()
          .forEach((event) => nextArtist = event.toString());

      setState(() {
        //Song
        var tempNextSong = XmlDocument.parse(nextArtist);
        nextSong = tempNextSong.findAllElements('Song').toString();
        nextSong = nextSong.substring(14, nextSong.indexOf(">") - 1);
        //Arist
        var tempNextArtist = XmlDocument.parse(nextArtist);
        nextArtist = tempNextArtist.findAllElements('Artist').toString();
        nextArtist = nextArtist.substring(15, nextArtist.indexOf("ID") - 2);

        //change current title for the appbar
        currentStreamTitle = kstream[currentStationIndex].title;
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
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu_outlined),
            );
          },
        ),
        title: Text(currentStreamTitle),
      ),
      drawer: Drawer(
        child: Padding(
          padding: EdgeInsets.all(6.0),
          child: SafeArea(
            child: Column(
              children: [
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () {},
                  title: Text(
                    'Settings',
                    style: TextStyle(fontSize: 18),
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
              kstream[currentStationIndex].urlImage.toString(),
            ),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Center(
                  //   child: Text(
                  //     kstream[currentStationIndex].title,
                  //     style: TextStyle(fontSize: 24),
                  //   ),
                  // ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 30.0),
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            child: Material(
                              elevation: 50,
                              shadowColor: Color.fromARGB(255, 145, 57, 183),
                              // shadowColor: Colors.purple,
                              borderRadius: BorderRadius.circular(20),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  fit: BoxFit.cover,
                                  kstream[currentStationIndex]
                                      .urlImage
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
                                // maxLines: 1,
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
                                // maxLines: 1,
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
                                  // maxLines: 1,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Color.fromARGB(30, 0, 0, 0)
                          : Color.fromARGB(30, 255, 255, 255),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                kstream[currentStationIndex].isFavorite =
                                    !kstream[currentStationIndex].isFavorite;
                              });
                            },
                            icon: Icon(
                              kstream[currentStationIndex].isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline_rounded,
                              size: 38,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              previousStation();
                            },
                            icon: Icon(
                              Icons.arrow_circle_left_rounded,
                              size: 52,
                            ),
                          ),
                          IconButton(
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
                            onPressed: () {
                              nextStation();
                            },
                            icon: Icon(
                              Icons.arrow_circle_right_rounded,
                              size: 52,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      return Padding(
                                        padding: EdgeInsets.all(6.0),
                                        child: Column(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(6.0),
                                                child: Text(
                                                  'Radio List',
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                )),
                                            Divider(),
                                            Expanded(
                                              child: ListView.builder(
                                                  itemCount: kstream.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return ListTile(
                                                      leading: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        child: Image.network(
                                                          fit: BoxFit.fitWidth,
                                                          kstream[index]
                                                              .urlImage
                                                              .toString(),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        changeRadioStation(
                                                            index);
                                                        Navigator.pop(context);
                                                      },
                                                      title: Text(
                                                          kstream[index].title),
                                                      subtitle: kstream[index]
                                                                  .description !=
                                                              null
                                                          ? Text(kstream[index]
                                                              .description!)
                                                          : Text('TBA'),
                                                      trailing: IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            kstream[currentStationIndex]
                                                                    .isFavorite =
                                                                !kstream[
                                                                        currentStationIndex]
                                                                    .isFavorite;
                                                          });
                                                        },
                                                        icon: Icon(kstream[
                                                                    index]
                                                                .isFavorite
                                                            ? Icons
                                                                .favorite_rounded
                                                            : Icons
                                                                .favorite_outline_rounded),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                                  });
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
