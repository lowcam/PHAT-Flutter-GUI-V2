import 'package:flutter/material.dart';

/// Supported hashing algorithms for the application.
enum HashAlgorithm {
  sha256('SHA-256'),
  sha384('SHA-384'),
  sha512('SHA-512'),
  argon2id('Argon2id'),
  pbkdf2('PBKDF2');

  /// The user-facing label for the algorithm.
  final String label;
  const HashAlgorithm(this.label);

  /// Helper to find an enum value from a string label.
  static HashAlgorithm fromLabel(String label) {
    return HashAlgorithm.values.firstWhere((e) => e.label == label || label.contains(e.label));
  }
}

/// Supported output encoding/number systems.
enum NumberSystem {
  hex('Hex'),
  base64('Base64'),
  base58('Base58');

  /// The user-facing label for the number system.
  final String label;
  const NumberSystem(this.label);

  /// Helper to find an enum value from a string label.
  static NumberSystem fromLabel(String label) {
    return NumberSystem.values.firstWhere((e) => e.label == label);
  }
}

/// Global constants and theme values used throughout the app.
class AppConstants {
  static const String appTitle = 'PHAT CALC';
  static const String version = '2026.07.02';
  static const String copyright = 'Copyright (C) 2026 Lorne Cammack';
  
  // App Theme Colors (Dark)
  static const Color scaffoldBgColor = Color(0xFF121212);
  static const Color cardColor = Color(0xFF333333);
  static const Color primaryAccent = Colors.blueAccent;
  
  // App Theme Colors (Light)
  static const Color lightScaffoldBgColor = Color(0xFFF5F5F5);
  static const Color lightCardColor = Colors.white;
  
  // Argon2id Default Parameters
  static const int argon2Iterations = 3;
  static const int argon2Memory = 65536; // 64MB in KB
  static const int argon2Parallelism = 4;
  
  // PBKDF2 Default Parameters
  /// 600,000 is the current OWASP recommendation for PBKDF2-HMAC-SHA256.
  static const int pbkdf2Iterations = 600000;
  
  /// Minimum recommended salt length for security.
  static const int minSaltLength = 8;
}
