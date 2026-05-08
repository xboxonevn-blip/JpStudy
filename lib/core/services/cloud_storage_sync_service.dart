import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart';

import 'backup_sync_service.dart';

enum CloudStorageUploadDecision { uploaded, notSignedIn, writeFailed }

enum CloudStorageDownloadDecision {
  apply,
  skipOlder,
  invalidChecksum,
  invalidFormat,
  notSignedIn,
  noRemoteFile,
  readFailed,
  requiresPassphrase,
  decryptionFailed,
}

class CloudStorageUploadResult {
  const CloudStorageUploadResult({required this.decision, this.path});

  final CloudStorageUploadDecision decision;
  final String? path;
}

class CloudStorageDownloadResult {
  const CloudStorageDownloadResult({
    required this.decision,
    this.payload,
    this.remoteExportedAt,
  });

  final CloudStorageDownloadDecision decision;
  final Map<String, dynamic>? payload;
  final DateTime? remoteExportedAt;
}

/// Reads and writes the current user's encrypted backup envelope to Firebase
/// Storage at `users/{uid}/backup.json`. Storage Security Rules ensure no
/// other user can access this path.
///
/// The payload format is the same envelope produced by [BackupSyncService] so
/// the file-based and cloud-based sync flows stay interchangeable.
class CloudStorageSyncService {
  CloudStorageSyncService({
    fb_auth.FirebaseAuth? firebaseAuth,
    FirebaseStorage? firebaseStorage,
  }) : _auth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
       _storage = firebaseStorage ?? FirebaseStorage.instance;

  final fb_auth.FirebaseAuth _auth;
  final FirebaseStorage _storage;

  static const _backupFileName = 'backup.json';

  String? _backupPathForCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return 'users/${user.uid}/$_backupFileName';
  }

  Future<CloudStorageUploadResult> uploadEnvelope(
    Map<String, dynamic> envelope,
  ) async {
    final path = _backupPathForCurrentUser();
    if (path == null) {
      return const CloudStorageUploadResult(
        decision: CloudStorageUploadDecision.notSignedIn,
      );
    }
    try {
      final ref = _storage.ref(path);
      final bytes = Uint8List.fromList(utf8.encode(jsonEncode(envelope)));
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'application/json'),
      );
      return CloudStorageUploadResult(
        decision: CloudStorageUploadDecision.uploaded,
        path: path,
      );
    } catch (_) {
      return CloudStorageUploadResult(
        decision: CloudStorageUploadDecision.writeFailed,
        path: path,
      );
    }
  }

  Future<CloudStorageDownloadResult> prepareDownload({
    String? passphrase,
  }) async {
    final path = _backupPathForCurrentUser();
    if (path == null) {
      return const CloudStorageDownloadResult(
        decision: CloudStorageDownloadDecision.notSignedIn,
      );
    }

    final Uint8List? bytes;
    try {
      bytes = await _storage.ref(path).getData();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return const CloudStorageDownloadResult(
          decision: CloudStorageDownloadDecision.noRemoteFile,
        );
      }
      return const CloudStorageDownloadResult(
        decision: CloudStorageDownloadDecision.readFailed,
      );
    } catch (_) {
      return const CloudStorageDownloadResult(
        decision: CloudStorageDownloadDecision.readFailed,
      );
    }

    if (bytes == null) {
      return const CloudStorageDownloadResult(
        decision: CloudStorageDownloadDecision.noRemoteFile,
      );
    }

    final Map<String, dynamic> rawEnvelope;
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map) {
        return const CloudStorageDownloadResult(
          decision: CloudStorageDownloadDecision.invalidFormat,
        );
      }
      rawEnvelope = Map<String, dynamic>.from(decoded);
    } catch (_) {
      return const CloudStorageDownloadResult(
        decision: CloudStorageDownloadDecision.invalidFormat,
      );
    }

    Map<String, dynamic> envelope;
    if (BackupSyncService.isEnvelopeEncrypted(rawEnvelope)) {
      if (passphrase == null || passphrase.isEmpty) {
        return CloudStorageDownloadResult(
          decision: CloudStorageDownloadDecision.requiresPassphrase,
          remoteExportedAt: BackupSyncService.parseExportedAt(rawEnvelope),
        );
      }
      try {
        envelope = await BackupSyncService.tryDecryptEnvelope(
          rawEnvelope,
          passphrase,
        );
      } catch (_) {
        return const CloudStorageDownloadResult(
          decision: CloudStorageDownloadDecision.decryptionFailed,
        );
      }
    } else {
      envelope = rawEnvelope;
    }

    final plan = await BackupSyncService.prepareImport(envelope);
    final mapped = switch (plan.decision) {
      BackupImportDecision.apply => CloudStorageDownloadDecision.apply,
      BackupImportDecision.skipOlder => CloudStorageDownloadDecision.skipOlder,
      BackupImportDecision.invalidChecksum =>
        CloudStorageDownloadDecision.invalidChecksum,
    };
    return CloudStorageDownloadResult(
      decision: mapped,
      payload: plan.payload,
      remoteExportedAt: plan.incomingExportedAt,
    );
  }
}
