import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/primary_button.dart';
import '../../data/models/debt.dart';
import '../../providers/debt_provider.dart';

class DebtFormScreen extends StatefulWidget {
  const DebtFormScreen({super.key, this.debt});

  final Debt? debt;

  @override
  State<DebtFormScreen> createState() => _DebtFormScreenState();
}

class _DebtFormScreenState extends State<DebtFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _waController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _loading = false;
  bool get _isEditing => widget.debt != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final d = widget.debt!;
      _nameController.text = d.customerName;
      _waController.text = d.whatsapp ?? '';
      _amountController.text = d.amount.toString();
      _noteController.text = d.note ?? '';
      _selectedDate = d.dateTime;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _waController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.pinkAccent,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final debt = Debt(
      id: widget.debt?.id ?? 0,
      customerName: _nameController.text.trim(),
      whatsapp: _waController.text.trim().isEmpty ? null : _waController.text.trim(),
      amount: int.parse(_amountController.text),
      dateTime: _selectedDate,
      status: widget.debt?.status ?? DebtStatus.unpaid,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    try {
      if (_isEditing) {
        await context.read<DebtProvider>().update(debt);
      } else {
        await context.read<DebtProvider>().add(debt);
      }
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Hutang berhasil diubah' : 'Hutang berhasil ditambahkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: AppColors.coral),
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
          _isEditing ? 'Edit Hutang' : 'Hutang Baru',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.lg),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_rounded, color: AppColors.pinkAccent),
                      const SizedBox(width: AppDimens.sm),
                      Text('Data Pelanggan', style: AppTextStyles.h3),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Pelanggan',
                      hintText: 'Masukkan nama pelanggan',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Masukkan nama pelanggan';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimens.md),
                  TextFormField(
                    controller: _waController,
                    decoration: const InputDecoration(
                      labelText: 'Nomor WhatsApp',
                      hintText: '08XXXXXXXXXX',
                      prefixIcon: Icon(Icons.phone_rounded),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payments_rounded, color: AppColors.pinkAccent),
                      const SizedBox(width: AppDimens.sm),
                      Text('Detail Hutang', style: AppTextStyles.h3),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Nominal Hutang',
                      hintText: 'Masukkan nominal',
                      prefixIcon: Icon(Icons.money_rounded),
                      suffixText: 'Rp',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Masukkan nominal';
                      final amount = int.tryParse(value);
                      if (amount == null || amount <= 0) return 'Nominal harus lebih dari 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimens.md),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal',
                        prefixIcon: Icon(Icons.calendar_today_rounded),
                      ),
                      child: Text(
                        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate),
                        style: AppTextStyles.bodyBold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            AppCard(
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
                  const SizedBox(height: AppDimens.lg),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: 'Tambahkan catatan (opsional)',
                      prefixIcon: Icon(Icons.edit_rounded),
                    ),
                    maxLines: 3,
                    maxLength: 200,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.xxl),
            PrimaryButton(
              label: _isEditing ? 'Simpan Perubahan' : 'Simpan Hutang',
              onPressed: _loading ? null : _save,
              icon: Icons.save_rounded,
            ),
            const SizedBox(height: AppDimens.xxxl),
          ],
        ),
      ),
    );
  }
}
