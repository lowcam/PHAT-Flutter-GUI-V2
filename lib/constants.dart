import 'package:flutter/material.dart';

class AppConstants {
  static const String appTitle = 'PHAT CALC';
  static const String version = '2026.04.23';
  static const String copyright = 'Copyright (C) 2026 Lorne Cammack';
  
  // Colors
  static const Color scaffoldBgColor = Color(0xFF121212);
  static const Color cardColor = Color(0xFF333333);
  static const Color primaryAccent = Colors.blueAccent;
  static const Color inputFillColor = Colors.black26;
  
  // Algorithm Options
  static const List<String> algorithmOptions = ['256', '384', '512', 'Argon2id', 'PBKDF2'];
  
  // System Options
  static const List<String> systemOptions = ['Hex', 'Base64', 'Base58'];

  // Default KDF Settings
  static const int argon2Iterations = 3;
  static const int argon2Memory = 65536; // 64MB in KB
  static const int argon2Parallelism = 4;
  
  static const int pbkdf2Iterations = 100000;
}
