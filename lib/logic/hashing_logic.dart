import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:fast_base58/fast_base58.dart';
import 'package:cryptography/cryptography.dart' as crypto_pkg;
import '../constants.dart';

/// Data class using [Uint8List] for sensitive data to allow memory wiping.
class HashParams {
  final Uint8List userText;
  final HashAlgorithm algorithm;
  final Uint8List salt;
  final int argon2Iterations;
  final int argon2Memory;
  final int argon2Parallelism;
  final int pbkdf2Iterations;

  HashParams({
    required this.userText,
    required this.algorithm,
    required this.salt,
    required this.argon2Iterations,
    required this.argon2Memory,
    required this.argon2Parallelism,
    required this.pbkdf2Iterations,
  });

  /// Explicitly wipes sensitive byte arrays from memory.
  void wipe() {
    userText.fillRange(0, userText.length, 0);
    salt.fillRange(0, salt.length, 0);
  }
}

/// Core logic for cryptographic hashing with memory-hardening patterns.
class HashingLogic {
  
  /// Computes the hash and wipes the input parameters immediately after use.
  static Future<Uint8List> hashInput(HashParams params) async {
    try {
      final Uint8List result;
      switch (params.algorithm) {
        case HashAlgorithm.sha256:
          result = Uint8List.fromList(sha256.convert(params.userText).bytes);
          break;
        case HashAlgorithm.sha384:
          result = Uint8List.fromList(sha384.convert(params.userText).bytes);
          break;
        case HashAlgorithm.sha512:
          result = Uint8List.fromList(sha512.convert(params.userText).bytes);
          break;
        case HashAlgorithm.argon2id:
          if (params.salt.length < AppConstants.minSaltLength) {
            throw Exception("Salt must be at least ${AppConstants.minSaltLength} characters.");
          }
          final kdf = crypto_pkg.Argon2id(
            iterations: params.argon2Iterations,
            memory: params.argon2Memory,
            parallelism: params.argon2Parallelism,
            hashLength: 32,
          );
          final secretKey = crypto_pkg.SecretKey(params.userText);
          final key = await kdf.deriveKey(secretKey: secretKey, nonce: params.salt);
          result = Uint8List.fromList(await key.extractBytes());
          break;
        case HashAlgorithm.pbkdf2:
          if (params.salt.length < AppConstants.minSaltLength) {
            throw Exception("Salt must be at least ${AppConstants.minSaltLength} characters.");
          }
          final kdf = crypto_pkg.Pbkdf2(
            macAlgorithm: crypto_pkg.Hmac.sha256(),
            iterations: params.pbkdf2Iterations,
            bits: 256,
          );
          final secretKey = crypto_pkg.SecretKey(params.userText);
          final key = await kdf.deriveKey(secretKey: secretKey, nonce: params.salt);
          result = Uint8List.fromList(await key.extractBytes());
          break;
      }
      return result;
    } finally {
      // Memory Hardening: Wipe sensitive inputs in the worker isolate
      params.wipe();
    }
  }

  static String formatBytes(Uint8List bytes, NumberSystem numSystem) {
    switch (numSystem) {
      case NumberSystem.hex: return hex.encode(bytes);
      case NumberSystem.base64: return base64.encode(bytes);
      case NumberSystem.base58: return Base58Encode(bytes);
    }
  }

  static String truncateOutput(String text, double outputDigits) {
    int digits = outputDigits.round();
    if (digits == 0 || text.length <= digits) return text;
    return text.substring(0, digits);
  }

  static double calculateEntropy(String text, NumberSystem numSystem) {
    if (text.isEmpty || text == 'Output will appear here' || text.startsWith('Error')) return 0;
    int poolSize = (numSystem == NumberSystem.hex) ? 16 : (numSystem == NumberSystem.base64 ? 64 : 58);
    return text.length * (log(poolSize) / log(2));
  }
}
