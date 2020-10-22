import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ClassificationPage extends StatefulWidget {
  @override
  _ClassificationPageState createState() => _ClassificationPageState();
}

class _ClassificationPageState extends State<ClassificationPage> {
  File _image;
  List _recognitions = [];
  bool _isLoading = false;
  final picker = ImagePicker();
  PanelController _panelController = new PanelController();

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

    List recognitions;
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
      _recognitions = recognitions;
    });

    _panelController.open();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        controller: _panelController,
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
              child: GestureDetector(
                onTap: () {
                  _panelController.isPanelOpen
                      ? _panelController.close()
                      : _panelController.open();
                },
                child: Icon(
                  Icons.arrow_drop_up,
                  color: Colors.orange,
                ),
              ),
            ),
            _recognitions.length != 0
                ? Padding(
                    padding: const EdgeInsets.only(left: 15, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          "Object: " + _recognitions[0]['label'].split(',')[0],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Confidence: " +
                              _recognitions[0]['confidence'].toStringAsFixed(3),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 60, 5),
                    child: Text(
                      "No match objects in current model. Please try another model.",
                      textAlign: TextAlign.center,
                    ),
                  ),
          ],
        ),
        body: Scaffold(
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
              "Image Classification",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: _image == null
                ? Center(
                    child: Text("Upload an image to classify it"),
                  )
                : _isLoading == true
                    ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.orange,
                        ),
                      )
                    : Image.file(
                        _image,
                        fit: BoxFit.fitWidth,
                        height: double.infinity,
                        width: double.infinity,
                        alignment: Alignment.topCenter,
                      ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(
          Icons.image,
          color: Colors.white,
        ),
        tooltip: "Pick image from Gallery",
        onPressed: () {
          _panelController.close();
          selectFromGallery();
        },
      ),
    );
  }
}
