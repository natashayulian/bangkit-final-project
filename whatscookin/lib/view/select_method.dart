import 'package:flutter/material.dart';

class SelectMethod extends StatefulWidget {
  @override
  _SelectMethodState createState() => _SelectMethodState();
}

class _SelectMethodState extends State<SelectMethod> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              'Select Input Method',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: Container(
          padding: EdgeInsets.all(32.0),
          child: _buttons(),
        )
    );
  }

  _buttons() {
    return Column(
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
                    dynamic result = await Navigator.pushNamed(context, '/classify');
                    Navigator.pop(context, result);
                  },
                  child: Container(
                      child: Align(
                        alignment: Alignment(0, 0.9),
                        child: Text('Classify Ingredient',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                      ),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Theme.of(context).primaryColor, Theme.of(context).accentColor]),
                        image: DecorationImage(
                          image: AssetImage("assets/images/classify.png"),
                          fit: BoxFit.cover,
                        ),
                      )),
                ),
              ),
              SizedBox(width: 6.0),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () async {
                    dynamic result = await Navigator.pushNamed(context, '/detect');
                    Navigator.pop(context, result);
                  },
                  child: Container(
                      child: Align(
                        alignment: Alignment(0, 0.9),
                        child: Text('Detect Ingredients',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                      ),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Theme.of(context).primaryColor, Theme.of(context).accentColor]),
                        image: DecorationImage(
                          image: AssetImage("assets/images/detect.png"),
                          fit: BoxFit.cover,
                        ),
                      )),
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 6.0),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {},
            child: Container(
                child: Align(
                  alignment: Alignment(0, 0.9),
                  child: Text('Type in Ingredients',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                ),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Theme.of(context).primaryColor, Theme.of(context).accentColor]),
                  image: DecorationImage(
                    image: AssetImage("assets/images/type.png"),
                    fit: BoxFit.cover,
                  ),
                )),
          ),
        ),
      ],
    );
  }
}
