import 'dart:ui';

import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
        title: Text('Profile'),
      ),
      body: ListView(
        children: [
          SizedBox(height: 30,),
          Container(
            height: 100,
            child: CircleAvatar(
              child: Icon(
                Icons.person_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
