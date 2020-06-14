import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tflite/tflite.dart';

class Detect extends StatefulWidget {
  @override
  _DetectState createState() => _DetectState();
}

const String ssd = "SSD MobileNet";

class _DetectState extends State<Detect> with TickerProviderStateMixin {
  String _model = ssd;
  File _image;

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

    await ssdMobileNet(image);

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
      if (ingredients.containsKey(element['detectedClass'])) {
        ingredients[element['detectedClass']]++;
      } else {
        ingredients[element['detectedClass']] = 1;
      }
    });

    setState(() {
      _image = image;
      _ingredients = ingredients;
      _busy = false;
    });

    _setLoading(false);
  }

  ssdMobileNet(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
        path: image.path, numResultsPerClass: 5);
    setState(() {
      _recognitions = recognitions;
    });
  }

  List<Widget> renderBoxes(Size screen) {
    if (_recognitions == null) return [];
    if (_imageWidth == null || _imageHeight == null) return [];

    _setLoading(true);
    double factorX = screen.width;
    double factorY = _imageHeight / _imageWidth * screen.width;

    setState(() {
      _containerHeight = factorY;
    });

    Color blue = Theme.of(context).primaryColor;

    _setLoading(false);

    return _recognitions.map((re) {
      return Positioned(
        left: re["rect"]["x"] * factorX,
        top: re["rect"]["y"] * factorY,
        width: re["rect"]["w"] * factorX,
        height: re["rect"]["h"] * factorY,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
            color: blue,
            width: 3,
          )),
          child: Text(
            "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = blue,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      );
    }).toList();
  }

  _imagePreview(File image) {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      child: Image.file(image),
    ));

    stackChildren.addAll(renderBoxes(size));

    _controller.reverse();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 7,
          child: ListView(
            children: <Widget>[
              _checkIfImageReady(stackChildren),
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
                          title: Text(_recognitions[index]['detectedClass'],
                              style: TextStyle(fontSize: 16.0)),
                          trailing: Text(
                              '${(_recognitions[index]["confidenceInClass"] * 100).toStringAsFixed(0)}%')));
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

  _checkIfImageReady(List stackChildren) {
    if (_containerHeight != 0) {
      return SizedBox(
          height: _containerHeight,
          child: Stack(
            children: stackChildren,
          ));
    } else {
      return SpinKitWanderingCubes(color: Theme.of(context).primaryColor);
    }
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

  void _showDialog(String ingredient) async {
    await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return NumberPickerDialog.integer(
            minValue: 0,
            maxValue: 100,
            title: new Text(ingredient),
            initialIntegerValue: _ingredients[ingredient],
          );
        }).then((value) {
      if (value != null) {
        if (value == 0) {
          setState(() => _ingredients.remove(ingredient));
        } else if (value > 100) {
          setState(() => _ingredients[ingredient] = 100);
        } else if (value < 0) {
          setState(() => _ingredients[ingredient] = 0);
        } else {
          setState(() => _ingredients[ingredient] = value);
        }
      }
    });
  }
}
