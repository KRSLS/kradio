class KStream {
  String title;
  String url;
  String urlNext;
  String? description;
  String? urlImage;
  bool isFavorite;

  KStream({
    required this.title,
    required this.url,
    required this.urlNext,
    this.description,
    this.urlImage,
    required this.isFavorite,
  });
}
