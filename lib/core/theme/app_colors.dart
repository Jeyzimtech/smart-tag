import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color lightBlue = Color(0xFFEAF2FF);
  static const Color softBlue = Color(0xFFD6E4FF);
  static const Color primaryBlue = Color(0xFF4F7DFF);
  static const Color deepBlue = Color(0xFF1E3A8A);
  
  // Accents
  static const Color dotAccent = Color.fromRGBO(79, 125, 255, 0.15);
  static const Color glassBorder = Color.fromRGBO(255, 255, 255, 0.5);
  
  // Functional Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color textPrimary = deepBlue;
  static const Color textSecondary = Color(0xFF64748B);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
