import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// AES-256-GCM at-rest encryption for backup envelopes.
///
/// Plaintext is encrypted with a key derived from the user's passphrase via
/// PBKDF2-HMAC-SHA-256 (200_000 iterations). The output metadata block
/// embeds salt, nonce, and authenticated ciphertext so a future decrypt only
/// needs the same passphrase.
class BackupEncryption {
  const BackupEncryption._();

  static const algorithm = 'aes-256-gcm';
  static const kdf = 'pbkdf2-sha256';
  static const iterations = 200000;
  static const _saltBytes = 16;

  /// Encrypts [plaintextJson] under a key derived from [passphrase].
  /// Returns the encryption metadata block to embed under the
  /// envelope's `encryption` key. Throws [ArgumentError] if [passphrase]
  /// is empty.
  static Future<Map<String, dynamic>> encrypt(
    String plaintextJson,
    String passphrase,
  ) async {
    if (passphrase.isEmpty) {
      throw ArgumentError.value(passphrase, 'passphrase', 'must not be empty');
    }

    final salt = _randomBytes(_saltBytes);
    final secretKey = await _deriveKey(passphrase, salt);
    final cipher = AesGcm.with256bits();
    final nonce = cipher.newNonce();
    final plaintextBytes = utf8.encode(plaintextJson);
    final secretBox = await cipher.encrypt(
      plaintextBytes,
      secretKey: secretKey,
      nonce: nonce,
    );

    final cipherWithMac = Uint8List.fromList(
      [...secretBox.cipherText, ...secretBox.mac.bytes],
    );

    return {
      'algorithm': algorithm,
      'kdf': kdf,
      'iterations': iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
      'ciphertext': base64Encode(cipherWithMac),
    };
  }

  /// Decrypts the [block] produced by [encrypt] back to the original JSON
  /// string. Throws [BackupDecryptionException] if [passphrase] is wrong,
  /// the ciphertext was tampered with, or required fields are missing.
  static Future<String> decrypt(
    Map<String, dynamic> block,
    String passphrase,
  ) async {
    if (passphrase.isEmpty) {
      throw BackupDecryptionException('passphrase-required');
    }

    final salt = _decodeBase64Field(block, 'salt');
    final nonce = _decodeBase64Field(block, 'nonce');
    final cipherWithMac = _decodeBase64Field(block, 'ciphertext');
    if (cipherWithMac.length < 16) {
      throw BackupDecryptionException('ciphertext-too-short');
    }
    final cipherText = cipherWithMac.sublist(0, cipherWithMac.length - 16);
    final macBytes = cipherWithMac.sublist(cipherWithMac.length - 16);

    final secretKey = await _deriveKey(passphrase, salt);
    final cipher = AesGcm.with256bits();

    try {
      final plaintextBytes = await cipher.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes)),
        secretKey: secretKey,
      );
      return utf8.decode(plaintextBytes);
    } on SecretBoxAuthenticationError {
      throw BackupDecryptionException('authentication-failed');
    }
  }

  static Future<SecretKey> _deriveKey(
    String passphrase,
    List<int> salt,
  ) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );
  }

  static List<int> _decodeBase64Field(
    Map<String, dynamic> block,
    String key,
  ) {
    final raw = block[key];
    if (raw is! String || raw.isEmpty) {
      throw BackupDecryptionException('missing-$key');
    }
    try {
      return base64Decode(raw);
    } on FormatException {
      throw BackupDecryptionException('invalid-$key');
    }
  }

  static List<int> _randomBytes(int length) {
    // AesGcm.newNonce uses a CSPRNG; reuse cipher's secure source for salts.
    final cipher = AesGcm.with256bits();
    final filler = <int>[];
    while (filler.length < length) {
      filler.addAll(cipher.newNonce());
    }
    return filler.sublist(0, length);
  }
}

class BackupDecryptionException implements Exception {
  BackupDecryptionException(this.message);

  final String message;

  @override
  String toString() => 'BackupDecryptionException($message)';
}
