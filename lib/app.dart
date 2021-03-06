import 'package:flipart/screens/create_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarBrightness: Brightness.light),
    );

    return MaterialApp(
      title: 'FlipArt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CreateAnimationScreen(),
    );
  }
}
