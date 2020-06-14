import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SelectMethod extends StatefulWidget {
  @override
  _SelectMethodState createState() => _SelectMethodState();
}

class _SelectMethodState extends State<SelectMethod> {
  String _text;
  TextEditingController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final PreferredSizeWidget appBar = AppBar(
      title: Text('Home'),
    );

    double width = mediaQuery.size.width;
    double height = mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top;

    return Scaffold(
        appBar: AppBar(
          title: Text('Select Input Method'),
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(child: _buttons(width, height)));
  }

  _buttons(double width, double height) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () async {
                      dynamic result =
                          await Navigator.pushNamed(context, '/classify');
                      if (result != null) {
                        Navigator.pop(context, result);
                        Fluttertoast.showToast(
                            msg: 'Ingredients added successfully.');
                      }
                    },
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('assets/images/classify.png', width: 75),
                          SizedBox(height: 6),
                          Text('Classify',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                              )),
                          SizedBox(height: 3),
                          Text('Run your image on the Ingredient Classifier',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              )),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 0.1,
                              blurRadius: 0.5,
                              offset:
                                  Offset(3, 3), // changes position of shadow
                            )
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                    ),
                  ),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () async {
                      dynamic result =
                          await Navigator.pushNamed(context, '/detect');
                      if (result != null) {
                        Navigator.pop(context, result);
                        Fluttertoast.showToast(
                            msg: 'Ingredients added successfully.');
                      }
                    },
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('assets/images/detect.png', width: 75),
                          SizedBox(height: 6),
                          Text('Detect',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                              )),
                          SizedBox(height: 3),
                          Text('Run your image on the Ingredient Detector',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              )),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 0.1,
                              blurRadius: 0.5,
                              offset:
                                  Offset(3, 3), // changes position of shadow
                            )
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.0),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () async {
                dynamic result = await showDialog(
                    child: new AlertDialog(
                      content: new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          new TextField(
                            autofocus: true,
                            decoration:
                                new InputDecoration(hintText: "New Ingredient"),
                            controller: _controller,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new RaisedButton(
                              color: Theme.of(context).primaryColor,
                              child: new Text("Submit",
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () {
                                Map<String, int> ingredients = {};
                                ingredients[_controller.text] = 1;
                                Navigator.pop(context, ingredients);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    context: context);
                if (result != null) {
                  Navigator.pop(context, result);
                  Fluttertoast.showToast(
                      msg: 'Ingredients added successfully.');
                }
              },
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/images/type.png', width: 50),
                    SizedBox(height: 6),
                    Text('Type In',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                        )),
                    Text('Ingredient',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                        )),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0.1,
                        blurRadius: 0.5,
                        offset: Offset(3, 3), // changes position of shadow
                      )
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(5))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
