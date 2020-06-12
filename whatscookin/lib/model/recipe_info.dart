class RecipeInfo {
  final String title;
  final String sourceUrl;

  RecipeInfo({
    this.title,
    this.sourceUrl,
  });

  factory RecipeInfo.fromMap(Map<String, dynamic> map) {
    return RecipeInfo(
      title: map['title'],
      sourceUrl: map['sourceUrl'],
    );
  }
}