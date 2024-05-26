import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:KRadio/globalSettings.dart';
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
            CheckboxListTile(
                title: Text('Stop player on output disconnect'),
                subtitle: Text(
                    'When disconnecting an audio output like bluetooth speaker or headphones etc, the radio player will stop.'),
                value: GlobalSettings.stopPlayerOnDeviceDisconnect,
                onChanged: (value) {
                  setState(() {
                    GlobalSettings.stopPlayerOnDeviceDisconnect = value!;
                  });
                  GlobalSettings.saveSettings();
                }),
            Divider(),
            CheckboxListTile(
                title: Text('Show upcoming song'),
                subtitle: Text('Displays upcoming song information.'),
                value: GlobalSettings.showNextSong,
                onChanged: (value) {
                  setState(() {
                    GlobalSettings.showNextSong = value!;
                  });
                  GlobalSettings.saveSettings();
                }),
            Divider(),
            ListTile(
              title: Text('Background image opacity'),
              trailing: Text(GlobalSettings.bgOpacity.toStringAsFixed(2) + ''),
            ),
            Slider(
              min: GlobalSettings.bgOpacityMin,
              max: GlobalSettings.bgOpacityMax,
              value: GlobalSettings.bgOpacity,
              divisions: 50,
              label: GlobalSettings.bgOpacity.toStringAsFixed(2),
              onChanged: (value) {
                setState(() {
                  GlobalSettings.bgOpacity = value;
                });
                GlobalSettings.saveSettings();
              },
            ),
            Divider(),
            ListTile(
              title: Text('Background blur amount'),
              trailing:
                  Text(GlobalSettings.playerBGBlur.toInt().toString() + 'px'),
            ),
            Slider(
              min: GlobalSettings.playerBGBlurMin,
              max: GlobalSettings.playerBGBlurMax,
              value: GlobalSettings.playerBGBlur,
              divisions: GlobalSettings.playerBGBlurMax.toInt(),
              label: GlobalSettings.playerBGBlur.round().toString() + 'px',
              onChanged: (value) {
                setState(() {
                  GlobalSettings.playerBGBlur = value;
                });
                GlobalSettings.saveSettings();
              },
            ),
            CheckboxListTile(
                title: Text('Controller background'),
                value: GlobalSettings.playerButtonsBG,
                onChanged: (value) {
                  setState(() {
                    GlobalSettings.playerButtonsBG = value!;
                  });
                  GlobalSettings.saveSettings();
                }),
            Divider(),
            ListTile(
              title: Text('Delete local stored data'),
              subtitle: Text(
                'WARNING, this will delete all local stored data.',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showMaterialBanner(
                  MaterialBanner(
                    content: Text(
                      'Are you sure you want to delete all local stored data?',
                      style: TextStyle(color: Colors.red),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.clear();
                          GlobalSettings.loadSettings();
                          ScaffoldMessenger.of(context).clearMaterialBanners();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Deleted all local stored data, please restart your application.'),
                            ),
                          );
                        },
                        child: Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).clearMaterialBanners();
                        },
                        child: Text('No'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
