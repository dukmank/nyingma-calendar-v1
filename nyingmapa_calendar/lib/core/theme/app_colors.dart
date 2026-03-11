

import 'package:flutter/material.dart';

/// Centralized color system.
/// UI team can safely adjust visual style here without touching feature files.
class AppColors {
  // ===== Base =====
  static const Color backgroundPrimary = Color(0xFF121212);
  static const Color backgroundCard = Color(0xFF1E1E1E);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;

  // ===== Brand =====
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentMaroon = Color(0xFF6A1B1A);

  // ===== Astrology Status =====
  static const Color auspicious = Color(0xFF1B5E20);      // dark green
  static const Color inauspicious = Color(0xFF7F0000);    // dark red
  static const Color caution = Color(0xFFE65100);         // deep orange
  static const Color direction = Color(0xFF37474F);       // blue grey
  static const Color neutral = Color(0xFF424242);         // dark grey
  static const Color unknown = Color(0xFF303030);

  // ===== Badge =====
  static const Color highlight = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFC62828);

  // ===== Dividers =====
  static const Color divider = Color(0xFF2A2A2A);
}