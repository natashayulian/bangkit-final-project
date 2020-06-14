class Recipe {
  final int id;
  final String title;
  final String imageUrl;
  final int likes;

  Recipe({
    this.id,
    this.title,
    this.imageUrl,
    this.likes,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      imageUrl: 'https://spoonacular.com/recipeImages/' +
          map['id'].toString() +
          '-240x150.' +
          map['imageType'],
      likes: map['likes'],
    );
  }
}
