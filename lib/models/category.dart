class Category {
  final String title;
  final String image;

  Category({
    required this.title,
    required this.image,
  });
}

final List<Category> categories = [
  Category(title: "Rosas", image: "assets/Rosas.png"),
  Category(title: "Lirios", image: "assets/Lirios.jpg"),
  Category(title: "Claveles", image: "assets/Clavel.jpg"),
];
