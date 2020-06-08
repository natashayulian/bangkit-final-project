import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whatscookin/view/select_method.dart';

void main() {
  //prevent rotation https://stackoverflow.com/questions/49418332/flutter-how-to-prevent-device-orientation-changes-and-force-portrait
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'What\'s Cookin?',
        initialRoute: '/',
        theme: ThemeData(
            fontFamily: 'NunitoSans', scaffoldBackgroundColor: Colors.white),
        routes: {
          '/': (context) => SelectMethod(),
        }));
  });
}
