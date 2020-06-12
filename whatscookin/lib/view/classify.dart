import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'dart:io';

class Classify extends StatefulWidget {
  @override
  _ClassifyState createState() => _ClassifyState();
}

const String ssd = "SSD MobileNet";
const String yolo = "Tiny YOLOv2";

class _ClassifyState extends State<Classify> with TickerProviderStateMixin{

  String _model = ssd;
  File _image;

  double _imageWidth;
  double _imageHeight;
  bool _busy = false;

  List _recognitions;
  ImagePicker _picker = ImagePicker();

  AnimationController _controller;
  static const List<IconData> icons = const [ Icons.camera_alt, Icons.image ];

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
      String res;
      if (_model == yolo) {
        res = await Tflite.loadModel(
          model: "assets/tflite/yolov2_tiny.tflite",
          labels: "assets/tflite/yolov2_tiny.txt",
        );
      } else {
        res = await Tflite.loadModel(
          model: "assets/tflite/ssd_mobilenet.tflite",
          labels: "assets/tflite/ssd_mobilenet.txt",
        );
      }
    } on PlatformException {
      print("Failed to load the model");
    }
  }

  selectFromImagePicker({bool fromCamera}) async {

    PickedFile pickedFile = fromCamera ? await _picker.getImage(source: ImageSource.camera) : await _picker.getImage(source: ImageSource.gallery);
    var image = File(pickedFile.path);
    if (image == null) return;
    setState(() {
      _busy = true;
    });
    predictImage(image);
  }

  predictImage(File image) async {
    if (image == null) return;

    if (_model == yolo) {
      await yolov2Tiny(image);
    } else {
      await ssdMobileNet(image);
    }

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
  }

  yolov2Tiny(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
        path: image.path,
        model: "YOLO",
        threshold: 0.3,
        imageMean: 0.0,
        imageStd: 255.0,
        numResultsPerClass: 1);

    setState(() {
      _recognitions = recognitions;
    });
  }

  ssdMobileNet(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
        path: image.path, numResultsPerClass: 1);
    setState(() {
      _recognitions = recognitions;
    });
  }

  List<Widget> renderBoxes(Size screen) {
    if (_recognitions == null) return [];
    if (_imageWidth == null || _imageHeight == null) return [];

    Map<String, String> listIngredientValue;
    double factorX = screen.width;
    double factorY = _imageHeight / _imageWidth * screen.width;

    Color blue = Colors.red;

    return _recognitions.map((re) {
      if ((re["confidenceInClass"] * 100) > 50){
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
      } else {
        return Container();
      }


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

    if (_busy) {
      stackChildren.add(Center(
        child: CircularProgressIndicator(),
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              child: Stack(
                children: stackChildren,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: FlatButton(
                    onPressed: (){

                    },
                    child: Text('Change')
                ),
              ),
              Expanded(
                child: FlatButton(
                    onPressed: (){
                      Map<String, int> ingredients = {};
                      _recognitions.forEach((element) {
                        if (ingredients.containsKey(element)) {
                          ingredients[element['detectedClass']]++;
                        }
                        else {
                          ingredients[element['detectedClass']] = 1;
                        }
                      });
                      Navigator.pop(context, ingredients);
                    },
                    child: Text('Accept')
                ),
              ),

            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_backspace,
              color: Colors.grey,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text('Detect Ingredients',
              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: new List.generate(icons.length, (int index) {
            Widget child = new Container(
              height: 70.0,
              width: 56.0,
              alignment: FractionalOffset.topCenter,
              child: new ScaleTransition(
                scale: new CurvedAnimation(
                  parent: _controller,
                  curve: new Interval(
                      0.0,
                      1.0 - index / icons.length / 2.0,
                      curve: Curves.easeOut
                  ),
                ),
                child: new FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Colors.grey,
                    mini: true,
                    child: new Icon(icons[index], color: Colors.black),
                    onPressed: () => icons[index] == Icons.camera_alt ? selectFromImagePicker(fromCamera: true) : selectFromImagePicker(fromCamera: false)
                ),
              ),
            );
            return child;
          }).toList()..add(
            new FloatingActionButton(
              heroTag: null,
              child: new AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget child) {
                  return new Transform(
                    transform: new Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                    alignment: FractionalOffset.center,
                    child: new Icon(_controller.isDismissed ? Icons.add : Icons.close),
                  );
                },
              ),
              onPressed: () {
                if (_controller.isDismissed) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              },
            ),
          ),
        ),
        body: _content(_image)
    );
  }

  _content(File image) {
    if(image == null) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.image,
                size: 100.0,
              ),
            ),
            Center(child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  'No Image',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                  )
              ),
            )),
            Center(child: Text('Image you pick will appear here.'))
          ]
      );
    } else {
      return _imagePreview(image);
    }
  }
}
