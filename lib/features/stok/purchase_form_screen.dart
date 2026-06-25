import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart' as fmt;
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/primary_button.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/bahan.dart';
import '../../providers/bahan_provider.dart';

class PurchaseFormScreen extends StatefulWidget {
  const PurchaseFormScreen({super.key});

  @override
  State<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends State<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _noteController = TextEditingController();

  Bahan? _selectedBahan;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _loading = false;

  @override
  void dispose() {
    _qtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.pinkAccent,
              onPrimary: AppColors.white,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.pinkAccent,
              onPrimary: AppColors.white,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBahan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih bahan terlebih dahulu')),
      );
      return;
    }

    setState(() => _loading = true);

    final qty = double.parse(_qtyController.text);
    final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    try {
      await DatabaseHelper.instance.purchaseBahan(
        _selectedBahan!.id,
        _selectedBahan!.name,
        qty,
        note,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembelian berhasil dicatat')),
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
          'Pembelian Bahan',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.lg),
          children: [
            _BahanSelector(
              selectedBahan: _selectedBahan,
              onChanged: (bahan) => setState(() => _selectedBahan = bahan),
            ),
            const SizedBox(height: AppDimens.lg),
            _DateTimeSelector(
              date: _selectedDate,
              time: _selectedTime,
              onDateTap: _selectDate,
              onTimeTap: _selectTime,
            ),
            const SizedBox(height: AppDimens.lg),
            _QuantityInput(
              controller: _qtyController,
              unit: _selectedBahan?.unit ?? 'unit',
            ),
            const SizedBox(height: AppDimens.lg),
            _NoteInput(controller: _noteController),
            if (_selectedBahan != null) ...[
              const SizedBox(height: AppDimens.lg),
              _SummaryCard(
                bahan: _selectedBahan!,
                qty: double.tryParse(_qtyController.text) ?? 0,
              ),
            ],
            const SizedBox(height: AppDimens.xxl),
            PrimaryButton(
              label: 'Simpan Pembelian',
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

class _BahanSelector extends StatelessWidget {
  const _BahanSelector({
    required this.selectedBahan,
    required this.onChanged,
  });

  final Bahan? selectedBahan;
  final ValueChanged<Bahan?> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_rounded, color: AppColors.pinkAccent),
              const SizedBox(width: AppDimens.sm),
              Text('Bahan', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Consumer<BahanProvider>(
            builder: (context, provider, _) {
              if (provider.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              return DropdownButtonFormField<Bahan>(
                initialValue: selectedBahan,
                decoration: const InputDecoration(
                  hintText: 'Pilih bahan',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                items: provider.items.map((bahan) {
                  return DropdownMenuItem(
                    value: bahan,
                    child: Row(
                      children: [
                        Text(bahan.emoji ?? '📦', style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(bahan.name, style: AppTextStyles.bodyBold),
                              Text(
                                'Stok: ${bahan.stock.toStringAsFixed(0)} ${bahan.unit}',
                                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                validator: (value) => value == null ? 'Pilih bahan' : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DateTimeSelector extends StatelessWidget {
  const _DateTimeSelector({
    required this.date,
    required this.time,
    required this.onDateTap,
    required this.onTimeTap,
  });

  final DateTime date;
  final TimeOfDay time;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_rounded, color: AppColors.pinkAccent),
              const SizedBox(width: AppDimens.sm),
              Text('Tanggal & Waktu', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: onDateTap,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    child: Text(
                      DateFormat('d MMM yyyy', 'id_ID').format(date),
                      style: AppTextStyles.body,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              Expanded(
                child: InkWell(
                  onTap: onTimeTap,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.access_time_rounded),
                    ),
                    child: Text(
                      time.format(context),
                      style: AppTextStyles.body,
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

class _QuantityInput extends StatelessWidget {
  const _QuantityInput({
    required this.controller,
    required this.unit,
  });

  final TextEditingController controller;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.add_circle_outline_rounded, color: AppColors.pinkAccent),
              const SizedBox(width: AppDimens.sm),
              Text('Jumlah Pembelian', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Jumlah',
              hintText: 'Masukkan jumlah pembelian',
              prefixIcon: const Icon(Icons.shopping_cart_rounded),
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
            ],
          ),
          const SizedBox(height: AppDimens.md),
          TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Tambahkan catatan (opsional)',
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
    required this.qty,
  });

  final Bahan bahan;
  final double qty;

  @override
  Widget build(BuildContext context) {
    final totalCost = (bahan.buyPrice * qty).round();
    final newStock = bahan.stock + qty;

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
            label: 'Pembelian',
            value: '+${qty.toStringAsFixed(qty % 1 == 0 ? 0 : 1)} ${bahan.unit}',
            valueColor: AppColors.mintDeep,
          ),
          const SizedBox(height: AppDimens.sm),
          const Divider(),
          const SizedBox(height: AppDimens.sm),
          _SummaryRow(
            label: 'Stok Setelah Pembelian',
            value: '${newStock.toStringAsFixed(newStock % 1 == 0 ? 0 : 1)} ${bahan.unit}',
            bold: true,
            valueColor: AppColors.pinkDeep,
          ),
          const SizedBox(height: AppDimens.lg),
          Container(
            padding: const EdgeInsets.all(AppDimens.md),
            decoration: BoxDecoration(
              color: AppColors.pinkSoft,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Estimasi Biaya', style: AppTextStyles.bodyBold),
                Text(
                  fmt.Format.rupiah(totalCost),
                  style: AppTextStyles.h3.copyWith(color: AppColors.pinkDeep),
                ),
              ],
            ),
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
