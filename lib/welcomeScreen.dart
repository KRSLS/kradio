import 'package:flutter/material.dart';
import 'package:KRadio/home.dart';
import 'package:KRadio/kstream.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('KRadio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text(
              'Pick a radio stream to start!',
              style: TextStyle(fontSize: 18),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: KStream.streams.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return Home(startWithStation: index);
                      }));
                    },
                    title: Text(KStream.streams[index].title),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
