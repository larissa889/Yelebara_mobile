import 'package:flutter/material.dart';
import 'package:yelebara_mobile/screens/WelcomePage.dart';

void main() {
  runApp(const YelebaraApp());
}

class YelebaraApp extends StatelessWidget {
  const YelebaraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yelebara Pressing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Poppins',
      ),
      home: WelcomePage(),
    );
  }
}