import 'package:KRadio/globalSettings.dart';
import 'package:KRadio/historyData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
                setState(() {
                  HistoryData.history = [];
                });
                GlobalSettings.saveSettings();
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
              HapticFeedback.lightImpact();
              Clipboard.setData(
                  ClipboardData(text: HistoryData.history[index].songTitle));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Song copied.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
            onLongPress: () {
              ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
                  content: Text('Delete song from history?'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            HistoryData.history.removeAt(index);
                          });
                          GlobalSettings.saveSettings();
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Song deleted from history.',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                          ScaffoldMessenger.of(context).clearMaterialBanners();
                        },
                        child: Text('Yes')),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).clearMaterialBanners();
                      },
                      child: Text('No'),
                    ),
                  ]));
            },
          );
        },
      ),
    );
  }
}
