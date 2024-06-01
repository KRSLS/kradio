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
        title: Text('Covers'),
        actions: [
          IconButton(
            onPressed: () {
              TextEditingController controller = TextEditingController();
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Add a cover'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: [
                            Text("Image/Gif URL"),
                            TextField(
                              controller: controller,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text('Cancel'),
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
            icon: Icon(Icons.add),
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
                            return Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
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
                                    leading: Icon(Icons.route_rounded),
                                    title: Text('Use'),
                                    subtitle: Text(
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
                                    leading: Icon(Icons.copy_rounded),
                                    title: Text('Copy'),
                                    subtitle: Text('Copy the url'),
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete_rounded),
                                    title: Text('Delete'),
                                    subtitle: Text('Delete cover'),
                                    onTap: () {
                                      setState(() {
                                        Cover.covers.removeAt(index);
                                      });
                                      GlobalSettings.saveSettings();
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
                    child: Image.network(
                      fit: BoxFit.cover,
                      Cover.covers[index].coverUrl,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator());
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
