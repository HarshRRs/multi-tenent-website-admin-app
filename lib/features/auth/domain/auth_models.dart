class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String businessType;
  final String address; 
  final bool isStoreOpen;
  final String? slug;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.address = '',
    this.businessType = 'restaurant',
    this.isStoreOpen = true,
    this.slug,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'manager',
      address: json['address'] ?? '',
      businessType: json['businessType'] ?? 'restaurant',
      isStoreOpen: json['isStoreOpen'] ?? true,
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'address': address,
      'businessType': businessType,
      'isStoreOpen': isStoreOpen,
      'slug': slug,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? address,
    String? businessType,
    bool? isStoreOpen,
    String? slug,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      address: address ?? this.address,
      businessType: businessType ?? this.businessType,
      isStoreOpen: isStoreOpen ?? this.isStoreOpen,
      slug: slug ?? this.slug,
    );
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
