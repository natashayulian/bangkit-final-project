import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whatscookin/view/classify.dart';
import 'package:whatscookin/view/detect.dart';
import 'package:whatscookin/view/ingredients_list.dart';
import 'package:whatscookin/view/select_method.dart';
import 'package:whatscookin/view/welcome_screen.dart';

void main() {
  //prevent rotation https://stackoverflow.com/questions/49418332/flutter-how-to-prevent-device-orientation-changes-and-force-portrait
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'What\'s Cookin?',
        home: WelcomeScreen(),
        theme: ThemeData(
            primaryColor: Color(0xfffdb15d), accentColor: Colors.black45),
        routes: {
          '/classify': (context) => Classify(),
          '/detect': (context) => Detect(),
          '/ingredients-list': (context) => IngredientsList(),
          '/select-method': (context) => SelectMethod(),
//          '/recipes-list': (context) => RecipesList(),
//          '/recipe-screen': (context) => RecipeScreen(),
        }));
  });
}
