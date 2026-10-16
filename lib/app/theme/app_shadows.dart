import 'package:flutter/material.dart';

/// Centralized Shadow styles for modern SaaS UI design
class AppShadows {
  AppShadows._();

  /// Subtle border drop shadow for cards and surfaces
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.04),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Standard card elevation
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.05),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.02),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  /// Elevated component shadow (modals, floating menus, popovers)
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.08),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.04),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Active or highlighted card glow
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color.fromRGBO(0, 119, 138, 0.15),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}
