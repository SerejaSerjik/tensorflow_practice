import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class PoseNetPage extends StatefulWidget {
  @override
  _PoseNetPageState createState() => _PoseNetPageState();
}

class _PoseNetPageState extends State<PoseNetPage> {
  File _image;
  List _recognitions = [];
  final picker = ImagePicker();
  bool _isLoading = false;
  double _imageWidth;
  double _imageHeight;

  @override
  void initState() {
    super.initState();
    _isLoading = true;

    loadModel().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future loadModel() async {
    Tflite.close();
    String res;
    try {
      res = await Tflite.loadModel(
        model: "assets/tflite/posenet_mv1_075_float_from_checkpoints.tflite",
      );
      print("loadModel res: $res");
    } catch (e) {
      print("Failed to load a model");
    }
  }

  Future predict(File image) async {
    print("predict is running");

    List recognitions;
    try {
      recognitions = await Tflite.runPoseNetOnImage(
        path: image.path,
        numResults: 2,
      );
    } catch (e) {
      print("Error while recognizing image");
    }

    print("predict recognitions: $recognitions");

    new FileImage(image)
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageHeight = info.image.height.toDouble();
        _imageWidth = info.image.width.toDouble();
      });
    }));

    setState(() {
      _recognitions = recognitions;
    });
  }

  selectFromGallery() async {
    var pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() {
      _isLoading = true;
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
      _isLoading = false;
    });
    await predict(_image);
  }

  List<Widget> renderKeypoints(Size screen) {
    if (_recognitions == null) return [];
    if (_imageHeight == null || _imageWidth == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageWidth * screen.width;

    var lists = <Widget>[];
    _recognitions.forEach((re) {
      var color = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
          .withOpacity(1.0);
      var list = re["keypoints"].values.map<Widget>((k) {
        return Positioned(
          left: k["x"] * factorX - 6,
          top: k["y"] * factorY - 6,
          width: 100,
          height: 12,
          child: Text(
            "● ${k["part"]}",
            style: TextStyle(
              color: color,
              fontSize: 12.0,
            ),
          ),
        );
      }).toList();

      lists..addAll(list);
    });

    return lists;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    List<Widget> stackChildren = [];

    stackChildren.add(
      _image == null
          ? Center(child: Text("Upload image to recognize objects on it"))
          : Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: Image.file(
                _image,
                fit: BoxFit.fitWidth,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.topCenter,
              ),
            ),
    );

    stackChildren.addAll(renderKeypoints(size));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Tflite.close();
            Navigator.of(context).pop();
          },
        ),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Pose Detection",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: stackChildren,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(
          Icons.image,
          color: Colors.white,
        ),
        tooltip: "Pick image from Gallery",
        onPressed: () {
          selectFromGallery();
        },
      ),
    );
  }
}
