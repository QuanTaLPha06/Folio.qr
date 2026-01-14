import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConstants {
  static const Color scaffoldBg = Color(0xFF0F0F13); // Very dark background
  static const Color cardColor = Color(0xFF1C1C23); // Slightly lighter for cards
  static const Color accentColor = Color(0xFFFFB703); // The orange/yellow from image
  static const Color textColor = Colors.white;
  static const Color secondaryText = Colors.grey;

  static TextStyle titleStyle = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static TextStyle subtitleStyle = GoogleFonts.poppins(
    fontSize: 16,
    color: secondaryText,
  );

  static TextStyle bioStyle = GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.white70,
  );
}