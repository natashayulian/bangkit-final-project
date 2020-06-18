import 'package:flutter/material.dart';

List items = [
  {
    "header": "What's Cookin'?",
    "description":
        "This app is made as part of Bangkit Academy's final project (Group BDG3-C)",
    "image": "assets/images/logobg.png"
  },
  {
    "header": "Classify",
    "description": "Run your image on the ingredient classifier model",
    "image": "assets/images/classifybg.png"
  },
  {
    "header": "Detect",
    "description": "Detect ingredients in your uploaded image.",
    "image": "assets/images/detectbg.png"
  },
  {
    "header": "Type In",
    "description": "Type in additional ingredients you have in your pantry",
    "image": "assets/images/typebg.png"
  },
  {
    "header": "Search recipes",
    "description":
        "Search recipes you can make using the ingredients available",
    "image": "assets/images/listbg.png"
  }
];

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<Widget> slides = items
      .map((item) => Container(
          padding: EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: <Widget>[
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Image.asset(
                  item['image'],
                  fit: BoxFit.fitWidth,
                  width: 220.0,
                  alignment: Alignment.bottomCenter,
                ),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 64.0, 0, 0),
                        child: Text(item['header'],
                            style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0XFF3F3D56),
                                height: 2.0)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                        child: Text(
                          item['description'],
                          style: TextStyle(
                              color: Colors.grey,
                              letterSpacing: 1.2,
                              fontSize: 16.0,
                              height: 1.3),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )))
      .toList();

  List<Widget> indicator() => List<Widget>.generate(
      slides.length,
      (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 3.0),
            height: 10.0,
            width: 10.0,
            decoration: BoxDecoration(
                color: currentPage.round() == index
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.0)),
          ));

  double currentPage = 0.0;
  final _pageViewController = new PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            PageView.builder(
              controller: _pageViewController,
              itemCount: slides.length,
              itemBuilder: (BuildContext context, int index) {
                _pageViewController.addListener(() {
                  setState(() {
                    currentPage = _pageViewController.page;
                  });
                });
                return slides[index];
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(top: 70.0),
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: currentPage.round() != slides.length - 1
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: indicator(),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: RaisedButton(
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0)),
                              onPressed: () async {
                                Navigator.pushReplacementNamed(
                                    context, '/ingredients-list');
                              },
                              child: Text('Start Cookin\'',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ))),
                        ),
                      ),
              ),
              //  ),
            ),
            currentPage.round() == slides.length - 1
                ? Container()
                : Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: FlatButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/ingredients-list');
                          },
                          child: Text('SKIP',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor))),
                    )) // )
          ],
        ),
      ),
    );
  }
}
