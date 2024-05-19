import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool showNextSong = true;
  bool stopPlayerOnDeviceDisconnect = true;
  bool sleepTimer = false;
  double sleepTimerValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(0),
        child: ListView(
          children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     Center(
            //       child: Text(
            //         'Player',
            //         style: TextStyle(fontSize: 18),
            //       ),
            //     ),
            //     Icon(Icons.headphones_rounded),
            //   ],
            // ),
            Center(
              child: Text('Nothing works yet, nothing will save.'),
            ),
            CheckboxListTile(
                title: Text('Show upcoming song'),
                value: showNextSong,
                onChanged: (value) {
                  setState(() {
                    showNextSong = value!;
                  });
                }),
            CheckboxListTile(
                title: Text('Stop player if audio output is disconnected'),
                value: stopPlayerOnDeviceDisconnect,
                onChanged: (value) {
                  setState(() {
                    stopPlayerOnDeviceDisconnect = value!;
                  });
                }),
          ],
        ),
      ),
    );
  }
}
