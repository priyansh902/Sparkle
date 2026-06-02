import 'package:flutter/material.dart';

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  Color get surface => theme.colorScheme.surface;
  Color get onSurface => theme.colorScheme.onSurface;
  Color get background => theme.scaffoldBackgroundColor;
  Color get border => theme.dividerColor;
  Color get cardColor => theme.cardColor;
  
  // Dynamic colors based on theme
  Color get adaptiveWhite => isDarkMode ? Colors.grey[900]! : Colors.white;
  Color get adaptiveGrey50 => isDarkMode ? Colors.grey[900]! : Colors.grey[50]!;
  Color get adaptiveGrey100 => isDarkMode ? Colors.grey[800]! : Colors.grey[100]!;
  Color get adaptiveGrey200 => isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;
  Color get adaptiveGrey600 => isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
  Color get adaptiveGrey700 => isDarkMode ? Colors.grey[300]! : Colors.grey[700]!;
  Color get adaptiveText => isDarkMode ? Colors.white : Colors.black87;
  Color get adaptiveSubtext => isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
}