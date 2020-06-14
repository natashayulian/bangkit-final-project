import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:whatscookin/model/recipe_info.dart';
import 'package:whatscookin/services/api_service.dart';

class RecipeScreen extends StatefulWidget {
  final RecipeInfo _recipeInfo;
  RecipeScreen(this._recipeInfo);

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  dynamic _data;
  RecipeInfo _recipeInfo =
      RecipeInfo(title: 'wow', sourceUrl: 'www.google.com');

  @override
  Widget build(BuildContext context) {
    _data = ModalRoute.of(context).settings.arguments;
    loadRecipe(_data);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget._recipeInfo.title),
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
      body: WebView(
        initialUrl: widget._recipeInfo.sourceUrl,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }

  loadRecipe(id) async {
//    RecipeInfo recipeInfo = await APIService.instance.fetchRecipe(id);
    await APIService.instance.fetchRecipe(id);
//    setState(() {
//      _recipeInfo = recipeInfo;
//    });
  }
}
