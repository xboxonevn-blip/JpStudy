import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/services/backup_encryption.dart';

void main() {
  group('BackupEncryption', () {
    const passphrase = 'correct horse battery staple';
    const plaintext = '{"hello":"world","value":42,"nested":{"a":1,"b":[1,2]}}';

    test('encrypt + decrypt round-trips identical plaintext', () async {
      final block = await BackupEncryption.encrypt(plaintext, passphrase);
      final restored = await BackupEncryption.decrypt(block, passphrase);
      expect(restored, plaintext);
    });

    test('decrypt with wrong passphrase throws BackupDecryptionException',
        () async {
      final block = await BackupEncryption.encrypt(plaintext, passphrase);
      expect(
        () => BackupEncryption.decrypt(block, 'wrong-passphrase'),
        throwsA(isA<BackupDecryptionException>()),
      );
    });

    test('two encrypts of same plaintext produce different ciphertext',
        () async {
      final first = await BackupEncryption.encrypt(plaintext, passphrase);
      final second = await BackupEncryption.encrypt(plaintext, passphrase);
      expect(first['ciphertext'], isNot(second['ciphertext']));
      expect(first['nonce'], isNot(second['nonce']));
      expect(first['salt'], isNot(second['salt']));
    });

    test('metadata block carries all required identification fields',
        () async {
      final block = await BackupEncryption.encrypt(plaintext, passphrase);
      expect(block['algorithm'], BackupEncryption.algorithm);
      expect(block['kdf'], BackupEncryption.kdf);
      expect(block['iterations'], BackupEncryption.iterations);
      expect(block['salt'], isA<String>());
      expect(block['nonce'], isA<String>());
      expect(block['ciphertext'], isA<String>());
    });

    test('encrypt rejects empty passphrase', () async {
      expect(
        () => BackupEncryption.encrypt(plaintext, ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('decrypt with empty passphrase reports passphrase-required',
        () async {
      final block = await BackupEncryption.encrypt(plaintext, passphrase);
      try {
        await BackupEncryption.decrypt(block, '');
        fail('expected BackupDecryptionException');
      } on BackupDecryptionException catch (e) {
        expect(e.message, 'passphrase-required');
      }
    });

    test('tampered ciphertext fails authentication', () async {
      final block = await BackupEncryption.encrypt(plaintext, passphrase);
      final cipher = base64Decode(block['ciphertext'] as String);
      // Flip one byte in the middle of the ciphertext.
      cipher[cipher.length ~/ 2] ^= 0xFF;
      final tampered = {
        ...block,
        'ciphertext': base64Encode(cipher),
      };
      try {
        await BackupEncryption.decrypt(tampered, passphrase);
        fail('expected BackupDecryptionException');
      } on BackupDecryptionException catch (e) {
        expect(e.message, 'authentication-failed');
      }
    });

    test('missing salt field reports a structured error', () async {
      final block = await BackupEncryption.encrypt(plaintext, passphrase);
      final stripped = Map<String, dynamic>.from(block)..remove('salt');
      try {
        await BackupEncryption.decrypt(stripped, passphrase);
        fail('expected BackupDecryptionException');
      } on BackupDecryptionException catch (e) {
        expect(e.message, contains('missing-salt'));
      }
    });
  });
}
