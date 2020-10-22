import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class DetectionPage extends StatefulWidget {
  @override
  _DetectionPageState createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  File _image;
  List _recognitions = [];
  bool _isLoading = false;
  double _imageWidth;
  double _imageHeight;
  final picker = ImagePicker();

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
        model: "assets/tflite/ssd_mobilenet_v1_1_metadata_1.tflite",
        labels: "assets/tflite/ssd_mobilenet.txt",
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
      recognitions = await Tflite.detectObjectOnImage(
        path: image.path,
        numResultsPerClass: 1,
      );
    } catch (e) {
      print("Error while recognizing image");
    }

    print("predict recognitions: $recognitions");

    FileImage(image).resolve(ImageConfiguration()).addListener(
          (ImageStreamListener(
            (ImageInfo info, bool _) {
              setState(() {
                _imageWidth = info.image.width.toDouble();
                _imageHeight = info.image.height.toDouble();
              });
            },
          )),
        );

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

  List<Widget> renderBoxes(Size screen) {
    if (_recognitions == null) return [];
    if (_imageWidth == null || _imageHeight == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageHeight * screen.width;

    return _recognitions.map((re) {
      if ((re["confidenceInClass"] * 100) > 35) {
        return Positioned(
          left: re["rect"]["x"] * factorX,
          top: re["rect"]["y"] * factorY,
          width: re["rect"]["w"] * factorX,
          height: re["rect"]["h"] * factorY,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
                width: 3,
              ),
            ),
            child: Text(
              "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                background: Paint()..color = Colors.red,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        );
      } else {
        return Container();
      }
    }).toList();
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

    stackChildren.addAll(renderBoxes(size));

    if (_isLoading) {
      stackChildren.add(Center(
        child: CircularProgressIndicator(),
      ));
    }

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
          "Image Detection",
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
