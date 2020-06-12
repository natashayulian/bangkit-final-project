class Recipe {
  final int id;
  final String title;
  final String imageUrl;

  Recipe({
    this.id,
    this.title,
    this.imageUrl,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      imageUrl: 'https://spoonacular.com/recipeImages/' + map['id'].toString() + '-240x150.' + map['imageType'],
    );
  }
}