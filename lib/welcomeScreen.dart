import 'package:flutter/material.dart';
import 'package:kradio/globalSettings.dart';
import 'package:kradio/home.dart';
import 'package:kradio/kstream.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('KRadio'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.network(
                  'https://docs.flutter.dev/cookbook'
                  '/img-files/effects/split-check/Avatar1.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(
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
