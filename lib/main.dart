import 'package:flutter/material.dart';
import 'package:KRadio/globalSettings.dart';
import 'package:KRadio/home.dart';
import 'package:flutter/services.dart';
import 'package:KRadio/welcomeScreen.dart';

void main() {
  runApp(const MyApp());
  // make navigation bar transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KRadio',
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        listTileTheme: ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        progressIndicatorTheme:
            ProgressIndicatorThemeData(color: Color(0xDD1c1c1c)),
        iconTheme: IconThemeData(color: Color(0xDD1c1c1c)),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        listTileTheme: ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.white),
        // iconTheme: IconThemeData(color: Colors.white),
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}
