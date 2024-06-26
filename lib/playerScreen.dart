import 'dart:ui';

import 'package:flutter/material.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            const Center(
              child: Text('KISS HOT'),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 52.0),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    'https://assets2.razerzone.com/images/pnx.assets/57c2af30b5d9a2b699b3e896b788e00f/headset-landingpg-500x500-blacksharkv2pro2023.jpg',
                  ),
                ),
              ),
            ),
            const Center(
              child: Text('SONG NAME'),
            ),
            const Center(
              child: Text('SONG ARTIST'),
            ),
            Center(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
