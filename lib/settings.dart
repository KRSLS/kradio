import 'package:flutter/material.dart';
import 'package:kradio/globalSettings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GlobalSettings().loadSettings();
  }
  bool t = true;
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
                value: GlobalSettings.showNextSong,
                onChanged: (value) {
                  setState(() {
                    GlobalSettings.showNextSong = value!;
                  });
                  GlobalSettings().saveSettings();
                }),
            CheckboxListTile(
                title: Text('Stop player if audio output is disconnected'),
                value: GlobalSettings.stopPlayerOnDeviceDisconnect,
                onChanged: (value) {
                  setState(() {
                    GlobalSettings.stopPlayerOnDeviceDisconnect = value!;
                  });
                  GlobalSettings().saveSettings();
                }),
          ],
        ),
      ),
    );
  }
}
