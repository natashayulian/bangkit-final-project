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
    for (var i = 0; i < data.length; i++) {
      if (i != 0) {
        params += ',${data[i]}';
        continue;
      }
      params += data[i];
    }

    Map<String, String> parameters = {
      'ingredients': params,
      'apiKey': API_KEY,
    };

    Uri uri = Uri.parse(
        'https://api.spoonacular.com/recipes/findByIngredients?apiKey=${API_KEY}&number=20&ingredients=${params}');
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    try {
      var response = await http.get(uri, headers: headers);
      List<dynamic> body = json.decode(response.body);
      return body.map((recipe) => Recipe.fromMap(recipe)).toList();
    } catch (err) {
      throw err.toString();
    }
  }

  // Recipe Info
  Future<RecipeInfo> fetchRecipe(int id) async {
    Map<String, String> parameters = {
      'includeNutrition': 'false',
      'apiKey': API_KEY,
    };
    Uri uri = Uri.parse(
        'https://api.spoonacular.com/recipes/$id/information?apiKey=${API_KEY}&includeNutrition=false');
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    try {
      var response = await http.get(uri, headers: headers);
      Map<String, dynamic> body = json.decode(response.body);
      return RecipeInfo.fromMap(body);
    } catch (err) {
      throw err.toString();
    }
  }
}
