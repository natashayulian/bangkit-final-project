import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:whatscookin/model/recipe.dart';
import 'package:whatscookin/model/recipe_info.dart';
import 'package:whatscookin/services/api_service.dart';
import 'package:whatscookin/view/recipe_screen.dart';

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
          title: Text('Recipes You Can Make'),
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
        body: _checkIfEmpty());
  }

  _checkIfEmpty() {
    if (widget._recipes.isEmpty) {
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
              child: Text('No Recipes',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
            )),
            Center(
                child: Text('Sorry. We could not find any recipes.',
                    style: TextStyle(color: Colors.grey)))
          ]);
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: StaggeredGridView.countBuilder(
            shrinkWrap: true,
            itemCount: widget._recipes.length,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 6),
            crossAxisCount: 2,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            itemBuilder: (context, index) {
              return new GestureDetector(
                child: new Card(
                  elevation: 2.0,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        child:
                            Image.network('${widget._recipes[index].imageUrl}'),
                      ),
                      new Align(
                        child: new Container(
                          padding: const EdgeInsets.all(6.0),
                          child: new Text('${widget._recipes[index].title}',
                              style: new TextStyle(
                                  color: Colors.black, height: 1.5)),
                          width: double.infinity,
                        ),
                        alignment: Alignment.bottomCenter,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.favorite,
                              color: Theme.of(context).primaryColor,
                              size: 15,
                            ),
                            SizedBox(width: 6),
                            Text(widget._recipes[index].likes.toString(),
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                onTap: () async {
                  RecipeInfo recipeInfo = await APIService.instance
                      .fetchRecipe(widget._recipes[index].id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeScreen(recipeInfo),
                    ),
                  );
                },
              );
            },
            staggeredTileBuilder: (int index) {
              return StaggeredTile.fit(1);
            }),
      );
    }
  }
}
