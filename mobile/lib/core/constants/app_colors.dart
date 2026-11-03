import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF059669); // Forest / Emerald green
  static const Color primaryLight = Color(0xFFE1F5EC);
  static const Color primaryDark = Color(0xFF047857);
  static const Color accent = Color(0xFF10B981);

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Category Colors (from GreenCart assets)
  static const Color catVegetables = Color(0xFFFEF6DA);
  static const Color catFruits = Color(0xFFFEE0E0);
  static const Color catDrinks = Color(0xFFF0F5DE);
  static const Color catInstant = Color(0xFFE1F5EC);
  static const Color catDairy = Color(0xFFFEE6CD);
  static const Color catBakery = Color(0xFFE0F6FE);
  static const Color catGrains = Color(0xFFF1E3F9);

  // Order Status Colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusProcessing = Color(0xFF3B82F6);
  static const Color statusShipped = Color(0xFF8B5CF6);
  static const Color statusDelivered = Color(0xFF10B981);

  // Feedback Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return catVegetables;
      case 'fruits':
        return catFruits;
      case 'drinks':
        return catDrinks;
      case 'instant':
        return catInstant;
      case 'dairy':
        return catDairy;
      case 'bakery':
        return catBakery;
      case 'grains':
        return catGrains;
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'processing':
        return statusProcessing;
      case 'shipped':
        return statusShipped;
      case 'delivered':
        return statusDelivered;
      default:
        return textSecondary;
    }
  }
}

