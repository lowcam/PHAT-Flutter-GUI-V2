import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:fast_base58/fast_base58.dart';
import 'package:cryptography/cryptography.dart' as crypto_pkg;

class HashingLogic {
  static Future<String> hashInput({
    required String userText,
    required String? algorithm,
    String salt = '',
    int argon2Iterations = 3,
    int argon2Memory = 65536,
    int argon2Parallelism = 4,
    int pbkdf2Iterations = 100000,
  }) async {
    try {
      var bytes = utf8.encode(userText);
      var saltBytes = utf8.encode(salt);

      if (algorithm == '256') {
        return sha256.convert(bytes).toString();
      } else if (algorithm == '384') {
        return sha384.convert(bytes).toString();
      } else if (algorithm == '512') {
        return sha512.convert(bytes).toString();
      } else if (algorithm == 'Argon2id') {
        final kdf = crypto_pkg.Argon2id(
          iterations: argon2Iterations,
          memory: argon2Memory,
          parallelism: argon2Parallelism,
          hashLength: 32,
        );
        final secretKey = crypto_pkg.SecretKey(bytes);
        final key = await kdf.deriveKey(
          secretKey: secretKey,
          nonce: saltBytes,
        );
        final keyBytes = await key.extractBytes();
        return hex.encode(keyBytes);
      } else if (algorithm == 'PBKDF2') {
        final kdf = crypto_pkg.Pbkdf2(
          macAlgorithm: crypto_pkg.Hmac.sha256(),
          iterations: pbkdf2Iterations,
          bits: 256,
        );
        final secretKey = crypto_pkg.SecretKey(bytes);
        final key = await kdf.deriveKey(
          secretKey: secretKey,
          nonce: saltBytes,
        );
        final keyBytes = await key.extractBytes();
        return hex.encode(keyBytes);
      }
      return "Error: Unknown algorithm";
    } catch (e) {
      return "Error: Unable to hash input. $e";
    }
  }

  static String numberSystemConvert(String? userNumSys, String convHashText) {
    try {
      if (convHashText.startsWith("Error")) return convHashText;
      List<int> bytes = hex.decode(convHashText);
      if (userNumSys == 'Hex') {
        return convHashText;
      } else if (userNumSys == 'Base64') {
        return base64.encode(bytes);
      } else {
        return Base58Encode(bytes);
      }
    } catch (e) {
      return "Error: Number system conversion failed.";
    }
  }

  static String finalOutputText(String convertedText, double outputDigits) {
    try {
      if (convertedText.startsWith("Error")) return convertedText;
      int outputDigitsInt = outputDigits.round();
      if (outputDigitsInt == 0) {
        return convertedText;
      } else {
        int stringLength = convertedText.length;
        if (stringLength <= outputDigitsInt) {
          return convertedText;
        } else {
          return convertedText.substring(0, outputDigitsInt);
        }
      }
    } catch (e) {
      return convertedText;
    }
  }

  static double calculateEntropy(String text, String? numSystem) {
    if (text.isEmpty || text == 'Output will appear here' || text.startsWith("Error")) return 0;

    int poolSize = 0;
    if (numSystem == 'Hex') {
      poolSize = 16;
    } else if (numSystem == 'Base64') {
      poolSize = 64;
    } else if (numSystem == 'Base58') {
      poolSize = 58;
    } else {
      poolSize = 16;
    }

    return text.length * (log(poolSize) / log(2));
  }
}
