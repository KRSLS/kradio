import 'package:flutter/material.dart';
import 'package:kradio/globalSettings.dart';
import 'package:kradio/home.dart';
import 'package:kradio/kstream.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //since this is the first page load the global settings
    GlobalSettings().loadSettings();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KRadio'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              'Pick a radio stream to start!',
              style: TextStyle(fontSize: 18),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: kstream.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return Home(startWithStation: index);
                      }));
                    },
                    title: Text(kstream[index].title),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
