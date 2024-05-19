import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(0.0),
        child: Column(
          children: [
            Center(
              child: Text('KISS HOT'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 52.0),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    'https://assets2.razerzone.com/images/pnx.assets/57c2af30b5d9a2b699b3e896b788e00f/headset-landingpg-500x500-blacksharkv2pro2023.jpg',
                  ),
                ),
              ),
            ),
            Center(
              child: Text('SONG NAME'),
            ),
            Center(
              child: Text('SONG ARTIST'),
            ),
            Center(
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.play_arrow_outlined),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
