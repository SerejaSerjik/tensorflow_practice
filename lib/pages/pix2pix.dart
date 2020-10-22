import 'package:flutter/material.dart';

class Pix2PixPage extends StatefulWidget {
  @override
  _Pix2PixPageState createState() => _Pix2PixPageState();
}

class _Pix2PixPageState extends State<Pix2PixPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Pix2Pix",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(),
    );
  }
}
