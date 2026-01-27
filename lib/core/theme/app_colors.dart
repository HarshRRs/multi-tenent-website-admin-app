import 'package:flutter/material.dart';

/// 2026 Design System - Color Palette
/// Following the 60-30-10 rule for a premium, warm business app
class AppColors {
  // ==================== ELITE PALETTE ====================
  
  /// Base - Alabaster Mist: Ultra-refined warm white for backgrounds
  static const Color alabasterMist = Color(0xFFFBFBFA);
  static const Color cloudDancer = alabasterMist; // Legacy mapping
  
  /// Depth - Midnight Onyx: Deep luxury contrast
  static const Color midnightOnyx = Color(0xFF0C0E12);
  
  /// Primary - Liquid Amber: Warm, sophisticated action color
  static const Color liquidAmber = Color(0xFFE67E22);
  static const Color burntTerracotta = liquidAmber; // Legacy mapping
  
  /// Accent - Electric Rose: Vibrant luxury highlight
  static const Color electricRose = Color(0xFFFF2D55);
  static const Color wildRose = electricRose; // Legacy mapping
  
  /// Surface - Pure Glass
  static const Color glassSurface = Colors.white;
  
  /// Text - Deep Ink
  static const Color deepInk = Color(0xFF101417);
  
  /// Borders - Ethereal Border
  static const Color etherealBorder = Color(0xFFEEEEEE);
  static const Color softBorder = etherealBorder; // Legacy mapping
  
  // ==================== SEMANTIC & FUNCTIONAL ====================
  
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);
  
  static final Color cardShadow = Colors.black.withOpacity(0.06);
  static final Color haloGlow = liquidAmber.withOpacity(0.15);
}
