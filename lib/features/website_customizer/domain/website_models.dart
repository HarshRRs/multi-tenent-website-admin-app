import 'package:flutter/material.dart';

class WebsiteConfig {
  final String headline;
  final String subheadline;
  final Color primaryColor;
  final String heroImageUrl;
  final String startButtonText;
  final double deliveryRadiusKm;

  WebsiteConfig({
    required this.headline,
    required this.subheadline,
    required this.primaryColor,
    required this.heroImageUrl,
    required this.startButtonText,
    this.deliveryRadiusKm = 10.0,
  });

  WebsiteConfig copyWith({
    String? headline,
    String? subheadline,
    Color? primaryColor,
    String? heroImageUrl,
    String? startButtonText,
    double? deliveryRadiusKm,
  }) {
    return WebsiteConfig(
      headline: headline ?? this.headline,
      subheadline: subheadline ?? this.subheadline,
      primaryColor: primaryColor ?? this.primaryColor,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      startButtonText: startButtonText ?? this.startButtonText,
      deliveryRadiusKm: deliveryRadiusKm ?? this.deliveryRadiusKm,
    );
  }

  factory WebsiteConfig.fromJson(Map<String, dynamic> json) {
    return WebsiteConfig(
      headline: json['headline'] ?? '',
      subheadline: json['subheadline'] ?? '',
      primaryColor: _colorFromHex(json['primaryColor']) ?? const Color(0xFFD97706),
      heroImageUrl: json['heroImageUrl'] ?? '',
      startButtonText: json['startButtonText'] ?? '',
      deliveryRadiusKm: (json['deliveryRadiusKm'] as num?)?.toDouble() ?? 10.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headline': headline,
      'subheadline': subheadline,
      'primaryColor': '#${primaryColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      'heroImageUrl': heroImageUrl,
      'startButtonText': startButtonText,
      'deliveryRadiusKm': deliveryRadiusKm,
    };
  }

  static Color? _colorFromHex(String? hexString) {
    if (hexString == null || hexString.isEmpty) return null;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return null;
    }
  }
}
