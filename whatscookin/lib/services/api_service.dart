import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:whatscookin/model/recipe.dart';
import 'package:whatscookin/model/recipe_info.dart';

class APIService {

  APIService._instantiate();

  static final APIService instance = APIService._instantiate();

  static String _baseUrl = 'api.spoonacular.com';
  static const String API_KEY = '92a019e67e3c4b4c85edc82fad2f13af';

  // Recipe All
  Future<List<Recipe>> fetchAllRecipe(data) async {
    String params = "";
    for(var i = 0; i < data.length; i++){
      if (i!=0) {
        params += ',${data[i]}';
        continue;
      }
      params += data[i];
    }

    Map<String, String> parameters = {
      'ingredients': params,
      'apiKey': API_KEY,
    };

    Uri uri = Uri.parse('https://api.spoonacular.com/recipes/findByIngredients?apiKey=${API_KEY}&ingredients=${params}');

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };


    try {
      var response = await http.get(uri, headers: headers);
      List<dynamic> body = json.decode(response.body);
      return body.map((recipe) => Recipe.fromMap(recipe)).toList();
    } catch (err) {
      print('Cannot get recipes');
      throw err.toString();
    }
  }

  // Recipe Info
  Future<RecipeInfo> fetchRecipe(int id) async {
    Map<String, String> parameters = {
      'includeNutrition': 'false',
      'apiKey': API_KEY,
    };
    Uri uri = Uri.parse('https://api.spoonacular.com/recipes/$id/information?apiKey=${API_KEY}&includeNutrition=false');
    print(uri);
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    var response = await http.get(uri, headers: headers);
    Map<String, dynamic> body = json.decode(response.body);
    return RecipeInfo.fromMap(body);

//    try {
//      var response = await http.get(uri, headers: headers);
//      Map<String, dynamic> data = json.decode(response.body);
//      Recipe recipe = Recipe.fromMap(data);
//      return recipe;
//    } catch (err) {
//      throw err.toString();
//    }
  }
}