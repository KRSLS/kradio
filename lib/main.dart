import 'package:flutter/material.dart';
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
          seedColor: const Color.fromARGB(255, 249, 253, 255),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        listTileTheme: ListTileThemeData(
          iconColor: const Color(0xDD1c1c1c),
          textColor: const Color(0xDD1c1c1c),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xDD1c1c1c)),
        primaryIconTheme: const IconThemeData(color: Color(0xDD1c1c1c)),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: Color(0xDD1c1c1c)),
        appBarTheme: const AppBarTheme(surfaceTintColor: Colors.transparent),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 249, 253, 255),
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
        iconTheme: const IconThemeData(color: Colors.white),
        primaryIconTheme: const IconThemeData(color: Colors.white),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: Colors.white),
        appBarTheme: const AppBarTheme(surfaceTintColor: Colors.transparent),
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}
