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
  SystemChrome.setPreferredOrientations([
    // DeviceOrientation.portraitUp,
  ]);
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 249, 253, 255),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        listTileTheme: ListTileThemeData(
          iconColor: Color(0xDD1c1c1c),
          textColor: Color(0xDD1c1c1c),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xDD1c1c1c)),
        primaryIconTheme: IconThemeData(color: Color(0xDD1c1c1c)),
        progressIndicatorTheme:
            ProgressIndicatorThemeData(color: Color(0xDD1c1c1c)),
        appBarTheme: AppBarTheme(surfaceTintColor: Colors.transparent),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 249, 253, 255),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        listTileTheme: ListTileThemeData(
          iconColor: Colors.white,
          textColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        primaryIconTheme: IconThemeData(color: Colors.white),
        progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.white),
        appBarTheme: AppBarTheme(surfaceTintColor: Colors.transparent),
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}
