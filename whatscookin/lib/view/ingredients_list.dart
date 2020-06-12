import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
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
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      progressIndicator: SpinKitWanderingCubes(color: Colors.red),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              'Ingredients You Have',
              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0.0,
          ),
        body: _content(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            dynamic result = await Navigator.pushNamed(context, '/select-method');
            print(result);
            try {
              setState(() {
                result.forEach((ingredient, quantity) {
                  if (_ingredients.containsKey(ingredient)) {
                    _ingredients[ingredient] += result[ingredient];
                  }
                  else {
                    _ingredients[ingredient] = result[ingredient];
                  }
                });
              });
            } catch (err){
              print(err);
            }
          },
          tooltip: 'Add Ingredients',
          child: Icon(Icons.add),
        )
      ),
    );
  }

  _content() {
    if(_ingredients.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.fastfood,
              size: 100.0,
            ),
          ),
          Center(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'No Ingredients',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold
              )
            ),
          )),
          Center(child: Text('Start adding ingredients by clicking the Add button.'))
        ]
      );
    } else {
      return ListView.builder(
        itemCount: _ingredients.length+1,
        itemBuilder: (context, index) {
          if (index==_ingredients.length){
            return FlatButton(
                onPressed: () async {
                  _setLoading(true);
                  List ingredientNames = _ingredients.keys.toList();
                  List<Recipe> recipes = await APIService.instance.fetchAllRecipe(ingredientNames);
                  _setLoading(false);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => RecipesList(
                        recipes
                    ),
                  ));
                },
                child: Text('Search Recipes')
            );
          }
          String key = _ingredients.keys.elementAt(index);
          return Card(
              child: ListTile(
                  onTap: () {},
                  title: Text(key),
                  trailing: Text(_ingredients[key].toString())
              )
          );
        },
      );
    }
  }
}
