import 'dart:io';
import 'dart:ui';

import 'package:KRadio/historyData.dart';
import 'package:KRadio/savedData.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:KRadio/globalSettings.dart';
import 'package:flutter/services.dart';
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
    return PopScope(
      onPopInvoked: (bool didPop) {
        if (didPop) {
          ScaffoldMessenger.of(context).clearMaterialBanners();
        }
      },
      child: Scaffold(
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
              SwitchListTile.adaptive(
                  title: Text('App bar title'),
                  subtitle: Text('Show the station title on the app bar.'),
                  value: GlobalSettings.appBarTitle,
                  onChanged: (value) {
                    setState(() {
                      GlobalSettings.appBarTitle = value;
                    });
                    GlobalSettings.saveSettings();
                  }),
              Divider(),
              Visibility(
                visible: Platform.isAndroid,
                  child: Column(
                children: [
                  SwitchListTile.adaptive(
                      title: Text('Status bar background'),
                      subtitle: Text(
                          "Darken the status bar, can help when icons aren't visible."),
                      value: GlobalSettings.statusBarBackground,
                      onChanged: (value) {
                        setState(() {
                          GlobalSettings.statusBarBackground = value;
                          if (GlobalSettings.statusBarBackground) {
                            SystemChrome.setSystemUIOverlayStyle(
                              const SystemUiOverlayStyle(
                                systemStatusBarContrastEnforced: true,
                              ),
                            );
                          } else {
                            SystemChrome.setSystemUIOverlayStyle(
                              const SystemUiOverlayStyle(
                                systemStatusBarContrastEnforced: false,
                              ),
                            );
                          }
                        });
                        GlobalSettings.saveSettings();
                      }),
                  Divider(),
                ],
              )),
              SwitchListTile.adaptive(
                  title: Text('Notify internet loss'),
                  subtitle:
                      Text('Notify when internet connection is not available.'),
                  value: GlobalSettings.notifyInternetLoss,
                  onChanged: (value) {
                    setState(() {
                      GlobalSettings.notifyInternetLoss = value;
                    });
                    GlobalSettings.saveSettings();
                  }),
              Divider(),
              SwitchListTile.adaptive(
                  title: Text('Stop player on output disconnect'),
                  subtitle: Text(
                      'When disconnecting an audio output like bluetooth speaker or headphones etc, the radio player will stop.'),
                  value: GlobalSettings.stopPlayerOnDeviceDisconnect,
                  onChanged: (value) {
                    setState(() {
                      GlobalSettings.stopPlayerOnDeviceDisconnect = value;
                    });
                    GlobalSettings.saveSettings();
                  }),
              Divider(),
              SwitchListTile.adaptive(
                  title: Text('Show upcoming song'),
                  subtitle: Text('Displays upcoming song information.'),
                  value: GlobalSettings.showNextSong,
                  onChanged: (value) {
                    setState(() {
                      GlobalSettings.showNextSong = value;
                    });
                    GlobalSettings.saveSettings();
                  }),
              Divider(),
              SwitchListTile.adaptive(
                  title: Text('Show song run time'),
                  subtitle: Text("Display song's run time information."),
                  value: GlobalSettings.showRunTime,
                  onChanged: (value) {
                    setState(() {
                      GlobalSettings.showRunTime = value;
                    });
                    GlobalSettings.saveSettings();
                  }),
              Divider(),
              SwitchListTile.adaptive(
                  title: Text('Show progress bar'),
                  subtitle: Text("Display song's run time progress bar."),
                  value: GlobalSettings.showProgressBar,
                  onChanged: (value) {
                    setState(() {
                      GlobalSettings.showProgressBar = value;
                    });
                    GlobalSettings.saveSettings();
                  }),
              Divider(),
              Padding(
                padding: EdgeInsets.all(6.0),
                child: Center(
                  child: Text(
                    'Data',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              ListTile(
                title: Text('Delete listening history'),
                subtitle: Text(
                  'WARNING, this will delete listening history.',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showMaterialBanner(
                    MaterialBanner(
                      content: Text(
                        'Are you sure you want to delete the listening history?',
                        style: TextStyle(color: Colors.red),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            HistoryData.history = [];
                            GlobalSettings.saveSettings();
                            ScaffoldMessenger.of(context)
                                .clearMaterialBanners();
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Deleted listening history.'),
                              ),
                            );
                          },
                          child: Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .clearMaterialBanners();
                          },
                          child: Text('No'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('Delete saved songs'),
                subtitle: Text(
                  'WARNING, this will delete all saved songs.',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showMaterialBanner(
                    MaterialBanner(
                      content: Text(
                        'Are you sure you want to delete all saved songs?',
                        style: TextStyle(color: Colors.red),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            SavedData.saved = [];
                            GlobalSettings.saveSettings();
                            ScaffoldMessenger.of(context)
                                .clearMaterialBanners();
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Deleted all saved songs from the application.'),
                              ),
                            );
                          },
                          child: Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .clearMaterialBanners();
                          },
                          child: Text('No'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('Delete local data'),
                subtitle: Text(
                  'WARNING, this will delete all local data.',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showMaterialBanner(
                    MaterialBanner(
                      content: Text(
                        'Are you sure you want to delete all local data?',
                        style: TextStyle(color: Colors.red),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.clear();
                            GlobalSettings.loadSettings();
                            ScaffoldMessenger.of(context)
                                .clearMaterialBanners();
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Deleted all local data, please restart your application.'),
                              ),
                            );
                          },
                          child: Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .clearMaterialBanners();
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
      ),
    );
  }
}
