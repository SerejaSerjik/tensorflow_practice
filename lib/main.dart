import 'package:flutter/material.dart';
import 'package:tensorflow_gbk/pages/pages.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tensorflow Demo',
      theme: ThemeData(),
      home: HomePage(),
    );
  }
}
