import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:whatscookin/model/recipe.dart';
import 'package:whatscookin/services/api_service.dart';
import 'package:whatscookin/view/recipes_list.dart';

class IngredientsList extends StatefulWidget {
  @override
  _IngredientsListState createState() => _IngredientsListState();
}

class _IngredientsListState extends State<IngredientsList> {
  Map<String, int> _ingredients = {};
  bool _isLoading = false;

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      progressIndicator:
          SpinKitWanderingCubes(color: Theme.of(context).primaryColor),
      child: Scaffold(
          appBar: AppBar(
            title: Text('Your Ingredients'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.clear_all,
                    color: Theme.of(context).primaryColor),
                onPressed: () async {
                  dynamic result = await showDialog(
                      child: new AlertDialog(
                        content: Text('Delete all ingredients?'),
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
                                      color: Theme.of(context).primaryColor))),
                        ],
                      ),
                      context: context);
                  if (result) {
                    setState(() {
                      _ingredients.clear();
                    });
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
                onPressed: () async {
                  dynamic result =
                      await Navigator.pushNamed(context, '/select-method');
                  try {
                    setState(() {
                      result.forEach((ingredient, quantity) {
                        if (_ingredients.containsKey(ingredient)) {
                          _ingredients[ingredient] += result[ingredient];
                        } else {
                          _ingredients[ingredient] = result[ingredient];
                        }
                      });
                    });
                  } catch (err) {
                    print(err);
                  }
                },
              )
            ],
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: _content()),
    );
  }

  _content() {
    if (_ingredients.isEmpty) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.fastfood, size: 100.0, color: Colors.grey),
            ),
            Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('No Ingredients',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
            )),
            Center(
                child: Text(
                    'Start adding ingredients by clicking the Add button.',
                    style: TextStyle(color: Colors.grey)))
          ]);
    } else {
      return Stack(
        children: <Widget>[
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 7,
                  child: ListView.builder(
                    itemCount: _ingredients.length,
                    itemBuilder: (context, index) {
                      String key = _ingredients.keys.elementAt(index);
                      return Card(
                          child: ListTile(
                              leading: Image.asset('assets/images/detect.png',
                                  width: 40, color: Colors.grey),
                              title:
                                  Text(key, style: TextStyle(fontSize: 16.0)),
                              subtitle: Text(_ingredients[key].toString()),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _showDialog(key);
                                      }),
                                  IconButton(
                                      icon: Icon(Icons.delete_outline,
                                          color:
                                              Theme.of(context).primaryColor),
                                      onPressed: () {
                                        setState(
                                            () => _ingredients.remove(key));
                                      }),
                                ],
                              )));
                    },
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
                          _setLoading(true);
                          List ingredientNames = _ingredients.keys.toList();
                          List<Recipe> recipes = await APIService.instance
                              .fetchAllRecipe(ingredientNames);
                          _setLoading(false);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipesList(recipes),
                              ));
                        },
                        child: Text('Search Recipes',
                            style: TextStyle(
                              color: Colors.white,
                            ))),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  void _showDialog(String ingredient) async {
    await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return NumberPickerDialog.integer(
            minValue: 0,
            maxValue: 100,
            cancelWidget: Text('Cancel'),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset('assets/images/detect.png',
                    width: 40, color: Colors.grey),
                SizedBox(width: 16),
                Text(ingredient)
              ],
            ),
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
