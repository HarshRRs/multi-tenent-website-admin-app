import 'package:flutter/material.dart';

/// 2026 Design System - Color Palette
/// Following the 60-30-10 rule for a premium, warm business app
class AppColors {
  // ==================== 2026 COLOR PALETTE ====================
  
  /// Base (60%) - Cloud Dancer: Warm, airy white for all backgrounds
  /// Reduces eye strain and creates a premium feel
  static const Color cloudDancer = Color(0xFFF0EEE9);
  
  /// Primary (30%) - Burnt Terracotta: Main action color
  /// Used for buttons, active tabs, progress bars
  static const Color burntTerracotta = Color(0xFFE67E22);
  
  /// Accent (10%) - Wild Rose: Special highlights
  /// Used for notification dots, special tags, small accents
  static const Color wildRose = Color(0xFFD63384);
  
  /// Text - Deep Ink: Maximum legibility
  /// Used for all headlines and body text
  static const Color deepInk = Color(0xFF101417);
  
  /// Borders & Dividers - Soft Border
  /// Light gray for subtle separation
  static const Color softBorder = Color(0xFFE0E0E0);
  
  // ==================== LEGACY SUPPORT ====================
  
  /// Legacy gold color (now mapped to Burnt Terracotta for compatibility)
  static const Color gold = burntTerracotta;
  
  // ==================== SEMANTIC COLORS ====================
  
  /// Success - Green for positive actions
  static const Color success = Color(0xFF10B981);
  
  /// Error - Red for errors and warnings
  static const Color error = Color(0xFFEF4444);
  
  /// Info - Blue for informational messages
  static const Color info = Color(0xFF3B82F6);
  
  // ==================== LIGHT THEME ====================
  
  static const Color primaryLight = burntTerracotta;
  static const Color secondaryLight = wildRose;
  static const Color backgroundLight = cloudDancer;
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = deepInk;
  static const Color textSecondaryLight = Color(0xFF6B7280);
  
  // ==================== DARK THEME ====================
  
  static const Color primaryDark = burntTerracotta;
  static const Color secondaryDark = wildRose;
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  
  // ==================== SHADOW COLORS ====================
  
  /// Soft shadow for cards (4dp elevation)
  static final Color cardShadow = Colors.black.withOpacity(0.08);
  
  /// Button shadow (Burnt Terra cotta with opacity)
  static final Color buttonShadow = burntTerracotta.withOpacity(0.3);
}
