import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tensorflow_gbk/pages/pages.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tensorflow Demo',
      theme: ThemeData(
        accentColor: Colors.orange,
        primarySwatch: Colors.orange,
        buttonColor: Colors.orange,
      ),
      home: HomePage(),
    );
  }
}
