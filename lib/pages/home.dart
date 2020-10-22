import 'package:flutter/material.dart';
import 'package:tensorflow_gbk/pages/pages.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tensorflow Lite",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset("assets/images/logo.png"),
              _buildRaisedButton(
                context,
                text: "Image Classification",
                routeWidget: ClassificationPage(),
              ),
              _buildRaisedButton(
                context,
                text: "Image Detection",
                routeWidget: DetectionPage(),
              ),
              _buildRaisedButton(
                context,
                text: "Pix2Pix",
                routeWidget: Pix2PixPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  RaisedButton _buildRaisedButton(BuildContext context,
      {String text, Widget routeWidget}) {
    return RaisedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => routeWidget,
          ),
        );
      },
      child: Container(
        width: 200,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
