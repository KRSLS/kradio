import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kradio/globalSettings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool panelPlayerOpen = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
            Padding(
              padding: EdgeInsets.all(6.0),
              child: Center(
                child: Text(
                  'Player',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            ListTile(
              title: Text('Background blur amount'),
              trailing: Text(
                  GlobalSettings.playerBGBlurValue.toInt().toString() + 'px'),
            ),
            Slider(
              min: GlobalSettings.playerBGBlurMin,
              max: GlobalSettings.playerBGBlurMax,
              value: GlobalSettings.playerBGBlurValue,
              divisions: GlobalSettings.playerBGBlurMax.toInt(),
              label: GlobalSettings.playerBGBlurValue.round().toString() + 'px',
              onChanged: (value) {
                setState(() {
                  GlobalSettings.playerBGBlurValue = value;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Controller background'),
                value: GlobalSettings.playerButtonsBG,
                onChanged: (value) {
                  setState(() {
                    GlobalSettings.playerButtonsBG = value!;
                  });
                })
          ],
        ),
      ),
    );
  }
}
