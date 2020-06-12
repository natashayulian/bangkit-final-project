import 'package:flutter/material.dart';
import 'package:whatscookin/model/recipe.dart';
import 'package:whatscookin/model/recipe_info.dart';
import 'package:whatscookin/services/api_service.dart';
import 'package:whatscookin/view/recipe_screen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class RecipesList extends StatefulWidget {
  final List<Recipe> _recipes;
  RecipesList(this._recipes);

  @override
  _RecipesListState createState() => _RecipesListState();
}

class _RecipesListState extends State<RecipesList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Recipe List',
            style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StaggeredGridView.countBuilder(
          shrinkWrap: true,
          itemCount: widget._recipes.length,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16),
          crossAxisCount: 2,
          mainAxisSpacing: 2,
          itemBuilder: (context, index) {
            return new GestureDetector(
              child: new Card(
                elevation: 2.0,
                child: new Column(
                  children: <Widget>[
                    Container(
                        child: Image.network('${widget._recipes[index].imageUrl}'),
                    ),
                    new Align(
                      child: new Container(
                        padding: const EdgeInsets.all(6.0),
                        child: new Text('${widget._recipes[index].title}',
                            style: new TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0)),
                        color: Theme.of(context).accentColor,
                        width: double.infinity,
                      ),
                      alignment: Alignment.bottomCenter,
                    ),
                  ],
                ),
              ),
              onTap: () async {
                RecipeInfo recipeInfo = await APIService.instance.fetchRecipe(widget._recipes[index].id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecipeScreen(
                        recipeInfo
                    ),
                  ),
                );
              },
            );
          },
          staggeredTileBuilder: (int index) {
            return  StaggeredTile.fit(1);
          }
        ),
      )
    );
  }

}

