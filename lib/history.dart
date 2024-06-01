import 'dart:ui';

import 'package:KRadio/globalSettings.dart';
import 'package:KRadio/historyData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
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
          title: Text('History'),
          actions: [],
        ),
        body: ListView.builder(
          itemCount: HistoryData.history.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(HistoryData.history[index].songTitle),
              subtitle: Text('Station: ' + HistoryData.history[index].station),
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'Song properties',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.headset_rounded),
                              title: Text(
                                HistoryData.history[index].songTitle,
                              ),
                              subtitle:
                                  Text(HistoryData.history[index].station),
                            ),
                            ListTile(
                              leading: Icon(Icons.open_in_browser_rounded),
                              title: Text('Open with YouTube'),
                              subtitle: Text('Search for the song on YouTube'),
                              onTap: () async {
                                final searchFor =
                                    HistoryData.history[index].songTitle;
                                final Uri url = Uri.parse(
                                    'https://www.youtube.com/results?search_query=$searchFor');
                                await launchUrl(url);
                              },
                              trailing:
                                  Icon(Icons.keyboard_arrow_right_rounded),
                            ),
                            ListTile(
                              leading: Icon(Icons.copy_rounded),
                              title: Text('Copy'),
                              subtitle: Text('Copy the song'),
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: HistoryData.history[index].songTitle,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.delete_rounded),
                              title: Text('Delete'),
                              subtitle: Text('Delete song from history'),
                              onTap: () {
                                setState(() {
                                  HistoryData.history.removeAt(index);
                                });
                                Navigator.pop(context);
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      );
                    });
              },
            );
          },
        ),
      ),
    );
  }
}
