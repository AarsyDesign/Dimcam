import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/kawaii_badge.dart';
import '../../core/widgets/common/primary_button.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/bahan.dart';

class AdjustmentFormScreen extends StatefulWidget {
  const AdjustmentFormScreen({super.key, required this.bahan});

  final Bahan bahan;

  @override
  State<AdjustmentFormScreen> createState() => _AdjustmentFormScreenState();
}

class _AdjustmentFormScreenState extends State<AdjustmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isAddition = true;
  bool _loading = false;

  @override
  void dispose() {
    _qtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final qty = double.parse(_qtyController.text);
    final delta = _isAddition ? qty : -qty;
    final note = _noteController.text.trim().isEmpty
        ? (_isAddition ? 'Penambahan manual' : 'Pengurangan manual')
        : _noteController.text.trim();

    try {
      await DatabaseHelper.instance.adjustStock(
        widget.bahan.id,
        widget.bahan.name,
        delta,
        note,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stok berhasil disesuaikan')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bahan = widget.bahan;
    final qty = double.tryParse(_qtyController.text) ?? 0.0;
    final delta = _isAddition ? qty : -qty;
    final double newStock = (bahan.stock + delta).clamp(0.0, double.infinity).toDouble();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.pinkAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Penyesuaian Stok',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.lg),
          children: [
            _BahanInfo(bahan: bahan),
            const SizedBox(height: AppDimens.lg),
            _TypeSelector(
              isAddition: _isAddition,
              onChanged: (value) => setState(() => _isAddition = value),
            ),
            const SizedBox(height: AppDimens.lg),
            _QuantityInput(
              controller: _qtyController,
              unit: bahan.unit,
              isAddition: _isAddition,
            ),
            const SizedBox(height: AppDimens.lg),
            _NoteInput(controller: _noteController),
            const SizedBox(height: AppDimens.lg),
            _SummaryCard(
              bahan: bahan,
              delta: delta,
              newStock: newStock.toDouble(),
            ),
            const SizedBox(height: AppDimens.xxl),
            PrimaryButton(
              label: 'Simpan Penyesuaian',
              onPressed: _loading ? null : _save,
              icon: Icons.check_rounded,
            ),
            const SizedBox(height: AppDimens.xxxl),
          ],
        ),
      ),
    );
  }
}

class _BahanInfo extends StatelessWidget {
  const _BahanInfo({required this.bahan});
  final Bahan bahan;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.pinkLight, AppColors.ivory],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: AppColors.pinkGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(bahan.emoji ?? '📦', style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bahan.name, style: AppTextStyles.h3),
                const SizedBox(height: 2),
                Text(
                  'Stok: ${bahan.stock.toStringAsFixed(bahan.stock % 1 == 0 ? 0 : 1)} ${bahan.unit}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({
    required this.isAddition,
    required this.onChanged,
  });

  final bool isAddition;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows_rounded, color: AppColors.pinkAccent),
              const SizedBox(width: AppDimens.sm),
              Text('Jenis Penyesuaian', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              Expanded(
                child: _TypeButton(
                  icon: Icons.add_circle_rounded,
                  label: 'Tambah',
                  color: AppColors.mintDeep,
                  selected: isAddition,
                  onTap: () => onChanged(true),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: _TypeButton(
                  icon: Icons.remove_circle_rounded,
                  label: 'Kurang',
                  color: AppColors.coral,
                  selected: !isAddition,
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.lg),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : AppColors.pinkSoft,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: selected ? color : AppColors.pinkSoft,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : AppColors.textMuted, size: 32),
            const SizedBox(height: AppDimens.xs),
            Text(
              label,
              style: AppTextStyles.bodyBold.copyWith(
                color: selected ? color : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityInput extends StatelessWidget {
  const _QuantityInput({
    required this.controller,
    required this.unit,
    required this.isAddition,
  });

  final TextEditingController controller;
  final String unit;
  final bool isAddition;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAddition ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded,
                color: isAddition ? AppColors.mintDeep : AppColors.coral,
              ),
              const SizedBox(width: AppDimens.sm),
              Text('Jumlah', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Jumlah ${isAddition ? 'penambahan' : 'pengurangan'}',
              hintText: 'Masukkan jumlah',
              prefixIcon: Icon(
                isAddition ? Icons.add_rounded : Icons.remove_rounded,
                color: isAddition ? AppColors.mintDeep : AppColors.coral,
              ),
              suffixText: unit,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return 'Masukkan jumlah';
              final qty = double.tryParse(value);
              if (qty == null || qty <= 0) return 'Jumlah harus lebih dari 0';
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _NoteInput extends StatelessWidget {
  const _NoteInput({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.note_rounded, color: AppColors.pinkAccent),
              const SizedBox(width: AppDimens.sm),
              Text('Catatan', style: AppTextStyles.h3),
              const Spacer(),
              const KawaiiBadge(label: 'Opsional', variant: BadgeVariant.lavender),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Alasan penyesuaian (opsional)',
              prefixIcon: Icon(Icons.edit_rounded),
            ),
            maxLines: 3,
            maxLength: 200,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.bahan,
    required this.delta,
    required this.newStock,
  });

  final Bahan bahan;
  final double delta;
  final double newStock;

  @override
  Widget build(BuildContext context) {
    final isAddition = delta >= 0;
    final color = isAddition ? AppColors.mintDeep : AppColors.coral;

    return AppCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.pinkLight, AppColors.ivory],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: AppColors.pinkDeep),
              const SizedBox(width: AppDimens.sm),
              Text('Ringkasan', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          _SummaryRow(
            label: 'Stok Saat Ini',
            value: '${bahan.stock.toStringAsFixed(bahan.stock % 1 == 0 ? 0 : 1)} ${bahan.unit}',
          ),
          const SizedBox(height: AppDimens.sm),
          _SummaryRow(
            label: 'Penyesuaian',
            value: '${isAddition ? '+' : ''}${delta.toStringAsFixed(delta.abs() % 1 == 0 ? 0 : 1)} ${bahan.unit}',
            valueColor: color,
          ),
          const SizedBox(height: AppDimens.sm),
          const Divider(),
          const SizedBox(height: AppDimens.sm),
          _SummaryRow(
            label: 'Stok Setelah Penyesuaian',
            value: '${newStock.toStringAsFixed(newStock % 1 == 0 ? 0 : 1)} ${bahan.unit}',
            bold: true,
            valueColor: AppColors.pinkDeep,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: bold ? AppTextStyles.bodyBold : AppTextStyles.body),
        Text(
          value,
          style: (bold ? AppTextStyles.bodyBold : AppTextStyles.body).copyWith(color: valueColor),
        ),
      ],
    );
  }
}
