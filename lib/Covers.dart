import 'dart:ui';

import 'package:KRadio/Cover.dart';
import 'package:KRadio/globalSettings.dart';
import 'package:KRadio/kstream.dart';
import 'package:flutter/material.dart';

class Covers extends StatefulWidget {
  const Covers({
    super.key,
    required this.currentStationIndex,
  });

  final int currentStationIndex;

  @override
  State<Covers> createState() => _CoversState();
}

class _CoversState extends State<Covers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text('Covers'),
        actions: [
          IconButton(
            onPressed: () {
              TextEditingController controller = TextEditingController();
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Add a cover'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: [
                            const Text("Image/Gif URL"),
                            TextField(
                              controller: controller,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Done'),
                          onPressed: () async {
                            setState(() {
                              Cover.covers.add(
                                Cover(
                                    id: Cover.covers.length + 1,
                                    coverUrl: controller.text),
                              );
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  });
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return GridView.builder(
              itemCount: Cover.covers.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: orientation == Orientation.portrait ? 2 : 4),
              itemBuilder: (context, index) {
                return AspectRatio(
                  aspectRatio: 1,
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ListView(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      'Cover properties',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.route_rounded),
                                  title: const Text('Use'),
                                  subtitle: const Text(
                                      'Use cover for the current station'),
                                  onTap: () {
                                    setState(() {
                                      KStream
                                              .streams[widget.currentStationIndex]
                                              .customUrlImage =
                                          Cover.covers[index].coverUrl;
                                    });
                                    GlobalSettings.saveSettings();
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.copy_rounded),
                                  title: const Text('Copy'),
                                  subtitle: const Text('Copy the url'),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete_rounded),
                                  title: const Text('Delete'),
                                  subtitle: const Text('Delete cover'),
                                  onTap: () {
                                    setState(() {
                                      Cover.covers.removeAt(index);
                                    });
                                    GlobalSettings.saveSettings();
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
                    child: Image.network(
                      fit: BoxFit.cover,
                      Cover.covers[index].coverUrl,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}
