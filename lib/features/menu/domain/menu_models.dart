class MenuCategory {
  final String id;
  final String name;

  MenuCategory({required this.id, required this.name});
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> images;
  final bool isAvailable;
  final String categoryId;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.images = const [],
    required this.isAvailable,
    required this.categoryId,
  });

  MenuItem copyWith({bool? isAvailable}) {
    return MenuItem(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      images: images,
      isAvailable: isAvailable ?? this.isAvailable,
      categoryId: categoryId,
    );
  }
}
