import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/primary_button.dart';
import '../../data/models/product.dart';
import '../../providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();

  String _category = 'Dimsum';
  bool _loading = false;
  bool get _isEditing => widget.product != null;

  static const _categories = ['Dimsum', 'Lumpia', 'Siomay', 'Bakso', 'Cilok', 'Minuman', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.product!;
      _nameController.text = p.name;
      _emojiController.text = p.emoji;
      _priceController.text = p.sellingPrice.toString();
      _unitController.text = p.unit;
      _category = p.category;
    } else {
      _emojiController.text = '🥟';
      _unitController.text = 'pcs';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final product = Product(
      id: widget.product?.id ?? 0,
      name: _nameController.text.trim(),
      emoji: _emojiController.text.trim().isEmpty ? '🥟' : _emojiController.text.trim(),
      category: _category,
      sellingPrice: int.tryParse(_priceController.text) ?? 0,
      unit: _unitController.text.trim().isEmpty ? 'pcs' : _unitController.text.trim(),
    );

    try {
      final provider = context.read<ProductProvider>();
      if (_isEditing) {
        await provider.update(product);
      } else {
        await provider.add(product);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.coral),
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
          _isEditing ? 'Edit Produk' : 'Produk Baru',
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
                      const Icon(Icons.shopping_bag_rounded, color: AppColors.pinkAccent),
                      const SizedBox(width: AppDimens.sm),
                      Text('Data Produk', style: AppTextStyles.h3),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama Produk', prefixIcon: Icon(Icons.label_rounded)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Masukkan nama produk' : null,
                  ),
                  const SizedBox(height: AppDimens.md),
                  TextFormField(
                    controller: _emojiController,
                    decoration: const InputDecoration(labelText: 'Emoji', prefixIcon: Icon(Icons.emoji_emotions_rounded)),
                    maxLength: 2,
                  ),
                  const SizedBox(height: AppDimens.md),
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(labelText: 'Kategori', prefixIcon: Icon(Icons.category_rounded)),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _category = v ?? 'Dimsum'),
                  ),
                  const SizedBox(height: AppDimens.md),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Harga Jual',
                      prefixIcon: Icon(Icons.money_rounded),
                      suffixText: 'Rp',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Masukkan harga';
                      final n = int.tryParse(v);
                      if (n == null || n <= 0) return 'Harga harus > 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimens.md),
                  TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(labelText: 'Satuan', prefixIcon: Icon(Icons.inventory_rounded)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.xxl),
            PrimaryButton(
              label: _isEditing ? 'Simpan Perubahan' : 'Tambah Produk',
              onPressed: _loading ? null : _save,
              icon: Icons.check_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
