import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/database/database_helper.dart';

class BackupInfo {
  BackupInfo({
    required this.path,
    required this.name,
    required this.size,
    required this.dateTime,
  });

  final String path;
  final String name;
  final int size;
  final DateTime dateTime;

  String get sizeLabel {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class BackupService {
  BackupService._();

  static final DatabaseHelper _db = DatabaseHelper.instance;

  /// Lokasi folder backups di dokumen aplikasi.
  static Future<Directory> _getBackupDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'backups'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Path file database asli.
  static Future<String> getDbPath() async {
    final dbDir = await getDatabasesPath();
    return p.join(dbDir, 'dimsumia.db');
  }

  /// Export database ke folder backups + share.
  static Future<String> exportBackup() async {
    final dbPath = await getDbPath();
    final backupDir = await _getBackupDir();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final backupName = 'dimsumia_backup_$timestamp.db';
    final backupPath = p.join(backupDir.path, backupName);

    // Tutup database dulu agar konsisten
    await _db.close();
    try {
      await File(dbPath).copy(backupPath);
    } finally {
      // Buka kembali database
      await _db.database;
    }

    return backupPath;
  }

  /// Share file backup via share sheet.
  static Future<void> shareBackup(String filePath) async {
    final file = XFile(filePath);
    await Share.shareXFiles([file], subject: 'Backup Dimsumia Manager');
  }

  /// Daftar backup lokal.
  static Future<List<BackupInfo>> listBackups() async {
    final backupDir = await _getBackupDir();
    final files = await backupDir.list().toList();
    final backups = <BackupInfo>[];

    for (final entity in files) {
      if (entity is File && entity.path.endsWith('.db')) {
        final stat = await entity.stat();
        backups.add(BackupInfo(
          path: entity.path,
          name: p.basename(entity.path),
          size: stat.size,
          dateTime: stat.modified,
        ));
      }
    }

    backups.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return backups;
  }

  /// Hapus file backup.
  static Future<void> deleteBackup(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Restore database dari file backup.
  static Future<void> restoreFromFile(String backupPath) async {
    final dbPath = await getDbPath();
    await _db.close();
    try {
      await File(backupPath).copy(dbPath);
    } finally {
      await _db.reopen();
    }
  }

  /// Restore dari file yang dipilih user (external).
  static Future<void> restoreFromExternal(String sourcePath) async {
    final dbPath = await getDbPath();
    await _db.close();
    try {
      await File(sourcePath).copy(dbPath);
    } finally {
      await _db.reopen();
    }
  }
}
