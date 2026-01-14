import 'package:flutter/material.dart';

class IconMapper {
  static Color getColorForLang(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
        return const Color(0xFF00B4AB); // Dart Teal
      case 'python':
        return const Color(0xFF3572A5); // Python Blue
      case 'javascript':
      case 'js':
        return const Color(0xFFF1E05A); // JS Yellow
      case 'html':
        return const Color(0xFFE34C26); // HTML Orange
      case 'css':
        return const Color(0xFF563D7C); // CSS Purple
      case 'java':
        return const Color(0xFFB07219); // Java Brown
      case 'c++':
        return const Color(0xFFF34B7D); // C++ Pink
      default:
        return Colors.white; // Fallback
    }
  }
}