import 'package:KRadio/globalSettings.dart';
import 'package:KRadio/historyData.dart';
import 'package:KRadio/savedData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Saved extends StatefulWidget {
  const Saved({super.key});

  @override
  State<Saved> createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved songs'),
        actions: [
          IconButton(
              tooltip: 'Delete saved songs',
              onPressed: () {
                setState(() {
                  SavedData.saved = [];
                });
                GlobalSettings.saveSettings();
              },
              icon: Icon(Icons.delete_outline_rounded)),
        ],
      ),
      body: ListView.builder(
        itemCount: SavedData.saved.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(SavedData.saved[index].songTitle),
            onTap: () {
              HapticFeedback.lightImpact();
              Clipboard.setData(
                  ClipboardData(text: SavedData.saved[index].songTitle));
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
                            SavedData.saved.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Song delete from history.',
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
