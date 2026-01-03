import 'package:flutter/material.dart';

class WebsiteConfig {
  final String headline;
  final String subheadline;
  final Color primaryColor;
  final String heroImageUrl;
  final String startButtonText;

  WebsiteConfig({
    required this.headline,
    required this.subheadline,
    required this.primaryColor,
    required this.heroImageUrl,
    required this.startButtonText,
  });

  WebsiteConfig copyWith({
    String? headline,
    String? subheadline,
    Color? primaryColor,
    String? heroImageUrl,
    String? startButtonText,
  }) {
    return WebsiteConfig(
      headline: headline ?? this.headline,
      subheadline: subheadline ?? this.subheadline,
      primaryColor: primaryColor ?? this.primaryColor,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      startButtonText: startButtonText ?? this.startButtonText,
    );
  }
}
