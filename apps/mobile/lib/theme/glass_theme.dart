import 'package:flutter/material.dart';
import 'dart:ui';

class GlassTheme {
  static ThemeData getTheme({required Color seedColor}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white.withOpacity(0.15),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static BoxDecoration glassDecoration({
    BorderRadius? borderRadius,
    Color? color,
  }) {
    return BoxDecoration(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      color: color?.withOpacity(0.15) ?? Colors.white.withOpacity(0.15),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: -5,
        ),
      ],
    );
  }

  static Widget glassContainer({
    required Widget child,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    Color? color,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: glassDecoration(
            borderRadius: borderRadius,
            color: color,
          ),
          child: child,
        ),
      ),
    );
  }
}