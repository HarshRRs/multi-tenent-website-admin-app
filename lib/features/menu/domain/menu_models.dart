class MenuCategory {
  final String id;
  final String name;

  MenuCategory({required this.id, required this.name});

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Modifier {
  final String id;
  final String name;
  final double extraPrice;

  Modifier({required this.id, required this.name, required this.extraPrice});

  factory Modifier.fromJson(Map<String, dynamic> json) {
    return Modifier(
      id: json['id'],
      name: json['name'],
      extraPrice: (json['extraPrice'] as num).toDouble(),
    );
  }
}

class ModifierGroup {
  final String id;
  final String name;
  final int minSelect;
  final int maxSelect;
  final List<Modifier> modifiers;

  ModifierGroup({
    required this.id,
    required this.name,
    required this.minSelect,
    required this.maxSelect,
    required this.modifiers,
  });

  factory ModifierGroup.fromJson(Map<String, dynamic> json) {
    return ModifierGroup(
      id: json['id'],
      name: json['name'],
      minSelect: json['minSelect'] ?? 0,
      maxSelect: json['maxSelect'] ?? 1,
      modifiers: (json['modifiers'] as List?)
              ?.map((m) => Modifier.fromJson(m))
              .toList() ??
          [],
    );
  }
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
  final List<ModifierGroup> modifierGroups;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.images = const [],
    required this.isAvailable,
    required this.categoryId,
    this.modifierGroups = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      isAvailable: json['isAvailable'] ?? true,
      categoryId: json['categoryId'],
      modifierGroups: (json['modifierGroups'] as List?)
              ?.map((m) => ModifierGroup.fromJson(m))
              .toList() ??
          [],
    );
  }

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
      modifierGroups: modifierGroups,
    );
  }
}
