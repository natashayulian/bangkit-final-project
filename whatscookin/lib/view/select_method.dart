import 'package:flutter/material.dart';

class SelectMethod extends StatefulWidget {
  @override
  _SelectMethodState createState() => _SelectMethodState();
}

class _SelectMethodState extends State<SelectMethod> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xff0000000F), Color(0xffC2C2C2)]),
                image: DecorationImage(
                  image: AssetImage("assets/images/home-background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text('Welcome back',
                                    style: TextStyle(
                                        fontSize: 25.0, fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(height: 5.0),
                              Expanded(
                                child: Text(
                                    'Guest',
                                    style: TextStyle(
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red)),
                              )
                            ],
                          )),
                      Expanded(
                        flex: 7,
                        child: _buttons(),
                      )
                    ],
                  ),
                ),
              ),
            )));
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
                  onTap: () {
                    Navigator.pushNamed(context, '/create-meeting');
                  },
                  child: Container(
                      child: Align(
                        alignment: Alignment(0, 0.9),
                        child: Text('Create',
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
                            colors: [Color(0xffE83939), Color(0xff289FD0)]),
                        image: DecorationImage(
                          image: AssetImage("assets/images/create.png"),
                          fit: BoxFit.cover,
                        ),
                      )),
                ),
              ),
              SizedBox(width: 6.0),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/join-room');
                  },
                  child: Container(
                      child: Align(
                        alignment: Alignment(0, 0.9),
                        child: Text('Join',
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
                            colors: [Color(0xffE83939), Color(0xff289FD0)]),
                        image: DecorationImage(
                          image: AssetImage("assets/images/join.png"),
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
                  child: Text('Friends',
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
                      colors: [Color(0xffE83939), Color(0xff289FD0)]),
                  image: DecorationImage(
                    image: AssetImage("assets/images/friends.png"),
                    fit: BoxFit.cover,
                  ),
                )),
          ),
        ),
      ],
    );
  }
}
