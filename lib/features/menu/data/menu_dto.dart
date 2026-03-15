import 'package:event_bite/features/menu/domain/menu_models.dart';

// Categories
List<MenuCategory> categoriesFromJson(List<dynamic> json) {
  return json.map((e) => MenuCategory(
    id: e['id'] ?? '',
    name: e['name'] ?? '',
  )).toList();
}

Map<String, dynamic> categoryToJson(MenuCategory category) {
  return {
    'id': category.id,
    'name': category.name,
  };
}

// Products
List<MenuItem> menuItemsFromJson(List<dynamic> json) {
  return json.map((e) => menuItemFromJson(e)).toList();
}

MenuItem menuItemFromJson(Map<String, dynamic> json) {
  return MenuItem(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    imageUrl: json['imageUrl'] ?? '',
    isAvailable: json['isAvailable'] ?? true,
    categoryId: json['categoryId'] ?? '',
  );
}

Map<String, dynamic> menuItemToJson(MenuItem item) {
  return {
    'id': item.id,
    'name': item.name,
    'description': item.description,
    'price': item.price,
    'imageUrl': item.imageUrl,
    'isAvailable': item.isAvailable,
    'categoryId': item.categoryId,
  };
}
