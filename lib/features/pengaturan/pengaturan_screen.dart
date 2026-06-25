import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/services/backup_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/feature_header.dart';
import '../../core/widgets/common/icon_bubble.dart';
import '../../core/widgets/common/kawaii_badge.dart';
import '../../core/widgets/common/primary_button.dart';
import '../../providers/theme_provider.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  List<BackupInfo> _backups = [];
  bool _loading = true;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _loading = true);
    final backups = await BackupService.listBackups();
    if (mounted) {
      setState(() {
        _backups = backups;
        _loading = false;
      });
    }
  }

  Future<void> _backup() async {
    setState(() => _processing = true);
    try {
      final path = await BackupService.exportBackup();
      await BackupService.shareBackup(path);
      await _loadBackups();
      if (mounted) _showSnackBar('Backup berhasil dibuat & dibagikan');
    } catch (e) {
      if (mounted) _showSnackBar('Gagal backup: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _restoreFromLocal(BackupInfo backup) async {
    final confirm = await _showConfirm(
      'Restore Data',
      'Database akan dikembalikan ke kondisi ${DateFormat('d MMM yyyy HH:mm', 'id_ID').format(backup.dateTime)}. Data saat ini akan hilang. Lanjutkan?',
    );
    if (confirm != true) return;

    setState(() => _processing = true);
    try {
      await BackupService.restoreFromFile(backup.path);
      if (mounted) {
        _showSnackBar('Restore berhasil');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PengaturanScreen()),
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('Gagal restore: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _restoreFromExternal() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) return;

    final filePath = result.files.single.path!;
    if (!filePath.endsWith('.db')) {
      _showSnackBar('Pilih file database (.db)');
      return;
    }

    final confirm = await _showConfirm(
      'Restore dari File External',
      'Database akan diganti dengan file yang dipilih. Data saat ini akan hilang. Lanjutkan?',
    );
    if (confirm != true) return;

    setState(() => _processing = true);
    try {
      await BackupService.restoreFromExternal(filePath);
      if (mounted) {
        _showSnackBar('Restore berhasil');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PengaturanScreen()),
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('Gagal restore: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _deleteBackup(BackupInfo backup) async {
    final confirm = await _showConfirm(
      'Hapus Backup',
      'Hapus backup ${backup.name}?',
    );
    if (confirm != true) return;

    await BackupService.deleteBackup(backup.path);
    await _loadBackups();
    if (mounted) _showSnackBar('Backup berhasil dihapus');
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<bool?> _showConfirm(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusXl)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppColors.coral),
            const SizedBox(width: AppDimens.sm),
            Expanded(child: Text(title, style: AppTextStyles.h3)),
          ],
        ),
        content: Text(message, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkDeep),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          const FeatureHeader(
            title: 'Pengaturan',
            subtitle: 'Backup & restore database',
            icon: Icons.settings_rounded,
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.pinkAccent,
              onRefresh: _loadBackups,
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.lg),
                children: [
                  _BackupActions(
                    processing: _processing,
                    onBackup: _backup,
                    onRestoreExternal: _restoreFromExternal,
                  ),
                  const SizedBox(height: AppDimens.lg),
                  _BackupList(
                    backups: _backups,
                    loading: _loading,
                    processing: _processing,
                    onRestore: _restoreFromLocal,
                    onDelete: _deleteBackup,
                  ),
                  const SizedBox(height: AppDimens.lg),
                  _ThemeCard(),
                  const SizedBox(height: AppDimens.lg),
                  _AppInfoCard(),
                  const SizedBox(height: AppDimens.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackupActions extends StatelessWidget {
  const _BackupActions({
    required this.processing,
    required this.onBackup,
    required this.onRestoreExternal,
  });

  final bool processing;
  final VoidCallback onBackup;
  final VoidCallback onRestoreExternal;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBubble(
                icon: Icons.backup_rounded,
                color: AppColors.mint,
                iconColor: AppColors.mintDeep,
              ),
              const SizedBox(width: AppDimens.sm),
              Text('Backup & Restore', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          Text(
            'Backup menyimpan seluruh data aplikasi ke file database. '
            'Gunakan restore untuk mengembalikan data dari backup.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppDimens.lg),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Backup Sekarang',
                  onPressed: processing ? null : onBackup,
                  icon: Icons.backup_rounded,
                  gradient: const LinearGradient(
                    colors: [AppColors.mintDeep, AppColors.mint],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: processing ? null : onRestoreExternal,
                  icon: const Icon(Icons.restore_rounded),
                  label: const Text('Restore dari File'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.pinkDeep,
                    side: const BorderSide(color: AppColors.pinkAccent),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackupList extends StatelessWidget {
  const _BackupList({
    required this.backups,
    required this.loading,
    required this.processing,
    required this.onRestore,
    required this.onDelete,
  });

  final List<BackupInfo> backups;
  final bool loading;
  final bool processing;
  final void Function(BackupInfo) onRestore;
  final void Function(BackupInfo) onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBubble(
                icon: Icons.history_rounded,
                color: AppColors.lavender,
                iconColor: AppColors.pinkDeep,
              ),
              const SizedBox(width: AppDimens.sm),
              Text('Riwayat Backup', style: AppTextStyles.h3),
              const Spacer(),
              KawaiiBadge(
                label: '${backups.length} file',
                variant: BadgeVariant.pink,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimens.xl),
                child: CircularProgressIndicator(color: AppColors.pinkAccent),
              ),
            )
          else if (backups.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppDimens.xl),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.backup_rounded, size: 48, color: AppColors.textMuted.withValues(alpha: 0.4)),
                    const SizedBox(height: AppDimens.md),
                    Text('Belum ada backup', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                    Text('Tap "Backup Sekarang" untuk membuat backup pertama', style: AppTextStyles.caption),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: backups.length,
              separatorBuilder: (_, __) => const Divider(height: AppDimens.lg),
              itemBuilder: (context, index) {
                final backup = backups[index];
                return _BackupItem(
                  backup: backup,
                  processing: processing,
                  onRestore: () => onRestore(backup),
                  onDelete: () => onDelete(backup),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _BackupItem extends StatelessWidget {
  const _BackupItem({
    required this.backup,
    required this.processing,
    required this.onRestore,
    required this.onDelete,
  });

  final BackupInfo backup;
  final bool processing;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.mint.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
          child: const Icon(Icons.backup_rounded, color: AppColors.mintDeep, size: 22),
        ),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(backup.name, style: AppTextStyles.bodyBold, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(
                '${backup.sizeLabel} • ${DateFormat('d MMM yyyy HH:mm', 'id_ID').format(backup.dateTime)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.restore_rounded, color: AppColors.mintDeep),
          onPressed: processing ? null : onRestore,
          tooltip: 'Restore',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.coral),
          onPressed: onDelete,
          tooltip: 'Hapus',
        ),
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBubble(
                icon: Icons.palette_rounded,
                color: AppColors.lavender,
                iconColor: AppColors.pinkDeep,
              ),
              const SizedBox(width: AppDimens.sm),
              Text('Tampilan', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDark ? 'Mode Gelap' : 'Mode Terang',
                    style: AppTextStyles.bodyBold,
                  ),
                  Text(
                    'Sesuaikan tampilan aplikasi',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              Switch.adaptive(
                value: isDark,
                onChanged: (_) => themeProvider.toggle(),
                activeTrackColor: AppColors.pinkAccent,
                inactiveTrackColor: null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBubble(
                icon: Icons.info_outline_rounded,
                color: AppColors.coral,
                iconColor: AppColors.white,
              ),
              const SizedBox(width: AppDimens.sm),
              Text('Tentang Aplikasi', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          const _InfoRow(label: 'Nama Aplikasi', value: 'Dimsumia Manager'),
          const SizedBox(height: AppDimens.md),
          const _InfoRow(label: 'Versi', value: '1.0.0'),
          const SizedBox(height: AppDimens.md),
          const _InfoRow(label: 'Database', value: 'SQLite'),
          const SizedBox(height: AppDimens.md),
          Text(
            'Dimsumia Manager membantu Anda mengelola usaha dimsum dengan mudah — '
            'dari pencatatan penjualan, produksi, stok bahan, hingga laporan keuangan.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(value, style: AppTextStyles.bodyBold),
      ],
    );
  }
}
