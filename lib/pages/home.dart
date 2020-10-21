import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File _image;
  var _recognitions;
  bool _isLoading = false;
  final picker = ImagePicker();

  Future loadModel() async {
    Tflite.close();
    String res;
    try {
      res = await Tflite.loadModel(
        model: "assets/tflite/mobilenet.tflite",
        labels: "assets/tflite/labels.txt",
      );
      print("loadModel res: $res");
    } catch (e) {
      print("Failed to load a model");
    }
  }

  Future predict(File image) async {
    print("predict is running");
    var recognitions;
    try {
      recognitions = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        threshold: 0.2,
        numResults: 3,
      );
    } catch (e) {
      print("Error while recognizing image");
    }

    print("predict recognitions: $recognitions");

    setState(() {
      _isLoading = false;
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
    });
    await predict(_image);
  }

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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SlidingUpPanel(
        minHeight: 30,
        maxHeight: 100,
        boxShadow: [
          BoxShadow(
              color: Colors.orange.withOpacity(.5),
              blurRadius: 3,
              spreadRadius: 1)
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        panel: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 5,
            ),
            Center(
              child: Icon(
                Icons.arrow_drop_up,
                color: Colors.orange,
              ),
            ),
            _recognitions != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 15, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text("Object: " + _recognitions[0]['label']),
                        Text(
                          "Confidence: " +
                              _recognitions[0]['confidence'].toStringAsFixed(3),
                        ),
                      ],
                    ),
                  )
                : SizedBox(height: 40),
          ],
        ),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: _image == null
                  ? Center(
                      child: Text("Upload an image to recognize objects"),
                    )
                  : _isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.orange,
                          ),
                        )
                      : Image.file(
                          _image,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                          alignment: Alignment.center,
                        ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 35, left: 15, bottom: 10),
              height: 70,
              color: Colors.black.withOpacity(.4),
              child: SvgPicture.asset(
                "assets/images/logo.svg",
                alignment: Alignment.centerLeft,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(
          Icons.image,
        ),
        tooltip: "Pick image from Gallery",
        onPressed: selectFromGallery,
      ),
    );
  }
}
