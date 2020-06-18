import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:tflite/tflite.dart';

class Detect extends StatefulWidget {
  @override
  _DetectState createState() => _DetectState();
}

class _DetectState extends State<Detect> with TickerProviderStateMixin {
  File _image;
  String _imageDisplay;

  double _imageWidth;
  double _imageHeight;
  bool _busy = false;
  double _containerHeight = 0;

  List _recognitions;
  ImagePicker _picker = ImagePicker();

  AnimationController _controller;
  static const List<IconData> icons = const [Icons.camera_alt, Icons.image];

  Map<String, int> _ingredients = {};

  bool _isLoading = false;

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _busy = true;

    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
    });

    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  loadModel() async {
    Tflite.close();
    try {
      String res = await Tflite.loadModel(
        model: "assets/tflite/ssd_mobilenet.tflite",
        labels: "assets/tflite/ssd_mobilenet.txt",
      );
    } on PlatformException {
      print("Failed to load the model");
    }
  }

  selectFromImagePicker({bool fromCamera}) async {
    PickedFile pickedFile = fromCamera
        ? await _picker.getImage(source: ImageSource.camera)
        : await _picker.getImage(source: ImageSource.gallery);
    var image = File(pickedFile.path);
    if (image == null) return;
    setState(() {
      _busy = true;
    });
    predictImage(image);
  }

  predictImage(File image) async {
    if (image == null) return;

    _setLoading(true);

    await detect(image);

    FileImage(image)
        .resolve(ImageConfiguration())
        .addListener((ImageStreamListener((ImageInfo info, bool _) {
          setState(() {
            _imageWidth = info.image.width.toDouble();
            _imageHeight = info.image.height.toDouble();
          });
        })));

    Map<String, int> ingredients = {};
    _recognitions.forEach((element) {
      if (ingredients.containsKey(element['class'])) {
        ingredients[element['class']]++;
      } else {
        ingredients[element['class']] = 1;
      }
    });

    setState(() {
      _image = image;
      _ingredients = ingredients;
      _busy = false;
    });

    _setLoading(false);
  }

  detect(File image) async {
    Dio dio = new Dio();

    FormData formDataDetections = FormData.fromMap({
      "images": await MultipartFile.fromFile(image.path, filename: "upload.jpg")
    });
    FormData formDataImage = FormData.fromMap({
      "images": await MultipartFile.fromFile(image.path, filename: "upload.jpg")
    });
    var detectionResponse = await dio.post('http://34.87.9.180/detections',
        data: formDataDetections);
    var imageResponse =
        await dio.post('http://34.87.9.180/image', data: formDataImage);

    var recognitions = detectionResponse.data['response'][0]['detections'];
    setState(() {
      _recognitions = recognitions;
      _imageDisplay = imageResponse.toString();
    });
  }

  Image imageFromBase64String(String base64String) {
    return Image.memory(base64Decode(base64String));
  }

  _imagePreview(File image) {
    _controller.reverse();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 7,
          child: ListView(
            children: <Widget>[
              imageFromBase64String(_imageDisplay),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Detected Ingredients',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _recognitions.length,
                itemBuilder: (context, index) {
                  return Card(
                      child: ListTile(
                          leading: Image.asset('assets/images/detect.png',
                              width: 40, color: Colors.grey),
                          title: Text(_recognitions[index]['class'],
                              style: TextStyle(fontSize: 16.0)),
                          trailing: Text(
                              '${(_recognitions[index]["confidence"]).toStringAsFixed(0)}%')));
                },
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0)),
                onPressed: () {
                  Navigator.pop(context, _ingredients);
                },
                child: Text('Submit', style: TextStyle(color: Colors.white))),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      progressIndicator:
          SpinKitWanderingCubes(color: Theme.of(context).primaryColor),
      child: Scaffold(
          appBar: AppBar(
            title: Text('Detect Ingredients'),
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.image, color: Theme.of(context).primaryColor),
                onPressed: () {
                  selectFromImagePicker(fromCamera: false);
                },
              ),
              IconButton(
                icon: Icon(Icons.camera_alt,
                    color: Theme.of(context).primaryColor),
                onPressed: () {
                  selectFromImagePicker(fromCamera: true);
                },
              ),
            ],
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: _content(_image)),
    );
  }

  _content(File image) {
    if (image == null) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.image, size: 100.0, color: Colors.grey),
            ),
            Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('No Image',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
            )),
            Center(
              child: Text('Image you pick will appear here.',
                  style: TextStyle(color: Colors.grey)),
            )
          ]);
    } else {
      return _imagePreview(image);
    }
  }
}
