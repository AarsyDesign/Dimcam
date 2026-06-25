import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/primary_button.dart';
import '../../data/models/customer.dart';
import '../../providers/customer_provider.dart';

class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({super.key, this.customer});

  final Customer? customer;

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _waController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  bool _loading = false;
  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.customer!;
      _nameController.text = c.name;
      _waController.text = c.whatsapp ?? '';
      _addressController.text = c.address ?? '';
      _noteController.text = c.note ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _waController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final customer = Customer(
      id: widget.customer?.id ?? 0,
      name: _nameController.text.trim(),
      whatsapp: _waController.text.trim().isEmpty ? null : _waController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      createdAt: widget.customer?.createdAt ?? DateTime.now(),
    );

    try {
      if (_isEditing) {
        await context.read<CustomerProvider>().update(customer);
      } else {
        await context.read<CustomerProvider>().add(customer);
      }
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Pelanggan berhasil diubah' : 'Pelanggan berhasil ditambahkan')),
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
          _isEditing ? 'Edit Pelanggan' : 'Pelanggan Baru',
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
                      Text('Identitas', style: AppTextStyles.h3),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Pelanggan',
                      hintText: 'Masukkan nama',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Masukkan nama' : null,
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
                  ),
                  const SizedBox(height: AppDimens.md),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat',
                      hintText: 'Masukkan alamat',
                      prefixIcon: Icon(Icons.location_on_rounded),
                    ),
                    maxLines: 2,
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
              label: _isEditing ? 'Simpan Perubahan' : 'Simpan Pelanggan',
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
