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
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        actions: [
          IconButton(
              tooltip: 'Delete history',
              onPressed: () {
                ScaffoldMessenger.of(context).clearMaterialBanners();
                ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
                    content:
                        Text('Are you sure you want to delete the history?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            HistoryData.history = [];
                            ScaffoldMessenger.of(context)
                                .clearMaterialBanners();
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Deleted history.')));
                          });

                          GlobalSettings.saveSettings();
                        },
                        child: Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).clearMaterialBanners();
                        },
                        child: Text('No'),
                      ),
                    ]));
              },
              icon: Icon(Icons.delete_outline_rounded)),
        ],
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                            title: Text(
                              HistoryData.history[index].songTitle,
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.open_in_browser_rounded),
                            title: Text('Open with YouTube'),
                            onTap: () async {
                              final searchFor =
                                  HistoryData.history[index].songTitle;
                              final Uri url = Uri.parse(
                                  'https://www.youtube.com/results?search_query=$searchFor');
                              await launchUrl(url);
                            },
                            trailing: Icon(Icons.keyboard_arrow_right_rounded),
                          ),
                          ListTile(
                            leading: Icon(Icons.copy_rounded),
                            title: Text('Copy'),
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
    );
  }
}
