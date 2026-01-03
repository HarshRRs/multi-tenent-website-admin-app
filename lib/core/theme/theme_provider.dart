import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple boolean provider: true = dark, false = light
final isDarkModeProvider = StateProvider<bool>((ref) => false);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final isDark = ref.watch(isDarkModeProvider);
  return isDark ? ThemeMode.dark : ThemeMode.light;
});
