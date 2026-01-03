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
  final bool isAvailable;
  final String categoryId;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
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
      isAvailable: isAvailable ?? this.isAvailable,
      categoryId: categoryId,
    );
  }
}
