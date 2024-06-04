import 'dart:ui';
import 'package:KRadio/savedData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class Saved extends StatefulWidget {
  const Saved({super.key});

  @override
  State<Saved> createState() => _SavedState();
}

class _SavedState extends State<Saved> {
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
          title: const Text('Saved songs'),
          actions: const [],
        ),
        body: ListView.builder(
          itemCount: SavedData.saved.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(SavedData.saved[index].songTitle),
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return ListView(
                        shrinkWrap: true,
                        children: [
                          const Padding(
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
                            leading: const Icon(Icons.headset_rounded),
                            title: Text(
                              SavedData.saved[index].songTitle,
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.open_in_browser_rounded),
                            title: const Text('Open with YouTube'),
                            subtitle:
                                const Text('Search for the song on YouTube'),
                            onTap: () async {
                              final searchFor =
                                  SavedData.saved[index].songTitle;
                              final Uri url = Uri.parse(
                                  'https://www.youtube.com/results?search_query=$searchFor');
                              await launchUrl(url);
                            },
                            trailing:
                                const Icon(Icons.keyboard_arrow_right_rounded),
                          ),
                          ListTile(
                            leading: const Icon(Icons.copy_rounded),
                            title: const Text('Copy'),
                            subtitle: const Text('Copy the song'),
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: SavedData.saved[index].songTitle,
                                ),
                              );
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.delete_rounded),
                            title: const Text('Delete'),
                            subtitle: const Text('Delete song from saved'),
                            onTap: () {
                              setState(() {
                                SavedData.saved.removeAt(index);
                              });
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      );
                    });
              },
            ).animate().fadeIn();
          },
        ),
      ),
    );
  }
}
