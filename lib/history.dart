import 'package:KRadio/globalSettings.dart';
import 'package:KRadio/historyData.dart';
import 'package:flutter/material.dart';

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
          );
        },
      ),
    );
  }
}
