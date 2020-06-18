import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:tflite/tflite.dart';

class Classify extends StatefulWidget {
  @override
  _ClassifyState createState() => _ClassifyState();
}

class _ClassifyState extends State<Classify> with TickerProviderStateMixin {
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
  String _selected;

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
        model: "assets/tflite/vegs.tflite",
        labels: "assets/tflite/vegs.txt",
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

    await classify(image);

    FileImage(image)
        .resolve(ImageConfiguration())
        .addListener((ImageStreamListener((ImageInfo info, bool _) {
          setState(() {
            _imageWidth = info.image.width.toDouble();
            _imageHeight = info.image.height.toDouble();
          });
        })));

    setState(() {
      _image = image;
      _busy = false;
    });

    _setLoading(false);
  }

  classify(File image) async {
    var recognitions = await Tflite.runModelOnImage(
        path: image.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: false // defaults to true
        );
    setState(() {
      _recognitions = recognitions;
    });
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
              Image.file(image),
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
                      child: RadioListTile<String>(
                          activeColor: Theme.of(context).primaryColor,
                          groupValue: _selected,
                          value: _recognitions[index]['label'],
                          onChanged: (String value) {
                            if (_selected == value) {
                              setState(() {
                                _selected = null;
                              });
                            } else {
                              setState(() {
                                _selected = value;
                              });
                            }
                          },
                          secondary: Image.asset('assets/images/detect.png',
                              width: 40, color: Colors.grey),
                          title: Text(_recognitions[index]['label'],
                              style: TextStyle(fontSize: 16.0)),
                          subtitle: Text(
                              '${(_recognitions[index]["confidence"] * 100).toStringAsFixed(0)}%')));
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
                onPressed: () async {
                  Map<String, int> ingredients = {};
                  if (_selected == null) {
                    bool submit = await showDialog(
                      context: this.context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text('No Ingredient Selected'),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: Text('No',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor)),
                              ),
                              FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: Text('Yes',
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor))),
                            ],
                            content: Text(
                                'You did not select any ingredient. Are you sure you want to submit?'));
                      },
                    );
                    if (submit) {
                      Navigator.pop(context, _ingredients);
                    }
                  } else {
                    ingredients[_selected] = 1;
                    setState(() {
                      _ingredients = ingredients;
                    });
                    Navigator.pop(context, _ingredients);
                  }
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
            title: Text('Classify Ingredient'),
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
//      return Container();
    }
  }
}
