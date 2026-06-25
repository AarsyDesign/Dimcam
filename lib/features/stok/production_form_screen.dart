import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/kawaii_badge.dart';
import '../../core/widgets/common/primary_button.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/product.dart';
import '../../data/models/resep_item.dart';
import '../../providers/product_provider.dart';

class ProductionFormScreen extends StatefulWidget {
  const ProductionFormScreen({super.key});

  @override
  State<ProductionFormScreen> createState() => _ProductionFormScreenState();
}

class _ProductionFormScreenState extends State<ProductionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();

  Product? _selectedProduct;
  List<ResepItem> _resep = [];
  bool _loading = false;
  bool _loadingResep = false;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _onProductChanged(Product? product) async {
    if (product == null) return;
    setState(() {
      _selectedProduct = product;
      _loadingResep = true;
    });

    final resep = await DatabaseHelper.instance.getResep(product.id);
    if (mounted) {
      setState(() {
        _resep = resep;
        _loadingResep = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu')),
      );
      return;
    }

    if (_resep.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk ini belum memiliki resep')),
      );
      return;
    }

    setState(() => _loading = true);

    final qty = int.parse(_qtyController.text);

    try {
      await DatabaseHelper.instance.produceBahan(
        _selectedProduct!.id,
        _selectedProduct!.name,
        qty,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produksi $qty ${_selectedProduct!.name} berhasil')),
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
        backgroundColor: AppColors.coral,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Produksi',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.lg),
          children: [
            _ProductSelector(
              selectedProduct: _selectedProduct,
              onChanged: _onProductChanged,
            ),
            const SizedBox(height: AppDimens.lg),
            _QuantityInput(controller: _qtyController),
            if (_selectedProduct != null && _resep.isNotEmpty) ...[
              const SizedBox(height: AppDimens.lg),
              _ResepCard(
                resep: _resep,
                qty: int.tryParse(_qtyController.text) ?? 1,
                loading: _loadingResep,
              ),
            ],
            const SizedBox(height: AppDimens.xxl),
            PrimaryButton(
              label: 'Proses Produksi',
              onPressed: _loading ? null : _save,
              icon: Icons.factory_rounded,
              gradient: const LinearGradient(
                colors: [AppColors.coral, Color(0xFFE8557E)],
              ),
            ),
            const SizedBox(height: AppDimens.xxxl),
          ],
        ),
      ),
    );
  }
}

class _ProductSelector extends StatelessWidget {
  const _ProductSelector({
    required this.selectedProduct,
    required this.onChanged,
  });

  final Product? selectedProduct;
  final ValueChanged<Product?> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.factory_rounded, color: AppColors.coral),
              const SizedBox(width: AppDimens.sm),
              Text('Produk', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Consumer<ProductProvider>(
            builder: (context, provider, _) {
              if (provider.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              return DropdownButtonFormField<Product>(
                initialValue: selectedProduct,
                decoration: const InputDecoration(
                  hintText: 'Pilih produk yang akan diproduksi',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                items: provider.items.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Row(
                      children: [
                        Text(product.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(product.name, style: AppTextStyles.bodyBold),
                              Text(
                                product.category,
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
                validator: (value) => value == null ? 'Pilih produk' : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuantityInput extends StatelessWidget {
  const _QuantityInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.numbers_rounded, color: AppColors.coral),
              const SizedBox(width: AppDimens.sm),
              Text('Jumlah Produksi', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Jumlah',
              hintText: 'Masukkan jumlah produksi',
              prefixIcon: Icon(Icons.production_quantity_limits_rounded),
              suffixText: 'pcs',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) return 'Masukkan jumlah';
              final qty = int.tryParse(value);
              if (qty == null || qty <= 0) return 'Jumlah harus lebih dari 0';
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _ResepCard extends StatelessWidget {
  const _ResepCard({
    required this.resep,
    required this.qty,
    required this.loading,
  });

  final List<ResepItem> resep;
  final int qty;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_menu_rounded, color: AppColors.coral),
              const SizedBox(width: AppDimens.sm),
              Text('Bahan yang Dibutuhkan', style: AppTextStyles.h3),
              const Spacer(),
              KawaiiBadge(
                label: '${resep.length} bahan',
                variant: BadgeVariant.coral,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimens.xl),
                child: CircularProgressIndicator(color: AppColors.coral),
              ),
            )
          else
            FutureBuilder(
              future: _loadBahanDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimens.xl),
                      child: CircularProgressIndicator(color: AppColors.coral),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('Tidak ada data'));
                }

                final details = snapshot.data as List<_BahanDetail>;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: details.length,
                  separatorBuilder: (_, __) => const Divider(height: AppDimens.lg),
                  itemBuilder: (context, index) {
                    final detail = details[index];
                    final needed = detail.qtyPerUnit * qty;
                    final sufficient = detail.currentStock >= needed;

                    return Row(
                      children: [
                        Text(detail.emoji ?? '📦', style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(detail.name, style: AppTextStyles.bodyBold),
                              Text(
                                'Stok: ${detail.currentStock.toStringAsFixed(detail.currentStock % 1 == 0 ? 0 : 1)} ${detail.unit}',
                                style: AppTextStyles.caption.copyWith(
                                  color: sufficient ? AppColors.mintDeep : AppColors.coral,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '-${needed.toStringAsFixed(needed % 1 == 0 ? 0 : 1)}',
                              style: AppTextStyles.bodyBold.copyWith(
                                color: sufficient ? AppColors.coral : AppColors.coral,
                              ),
                            ),
                            Text(detail.unit, style: AppTextStyles.caption),
                          ],
                        ),
                        const SizedBox(width: AppDimens.sm),
                        Icon(
                          sufficient ? Icons.check_circle_rounded : Icons.warning_rounded,
                          color: sufficient ? AppColors.mintDeep : AppColors.coral,
                          size: 20,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          const SizedBox(height: AppDimens.md),
          Container(
            padding: const EdgeInsets.all(AppDimens.md),
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(color: AppColors.coral.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.coral, size: 20),
                const SizedBox(width: AppDimens.sm),
                Expanded(
                  child: Text(
                    'Stok bahan akan berkurang otomatis sesuai resep',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.coral),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<_BahanDetail>> _loadBahanDetails() async {
    final details = <_BahanDetail>[];
    final db = DatabaseHelper.instance;

    for (final r in resep) {
      final bahanRows = await (await db.database).query(
        'bahans',
        where: 'id = ?',
        whereArgs: [r.bahanId],
      );

      if (bahanRows.isNotEmpty) {
        final bahan = bahanRows.first;
        details.add(_BahanDetail(
          name: bahan['name'] as String,
          emoji: bahan['emoji'] as String?,
          unit: bahan['unit'] as String,
          qtyPerUnit: r.qtyUsed,
          currentStock: (bahan['stock'] as num).toDouble(),
        ));
      }
    }

    return details;
  }
}

class _BahanDetail {
  const _BahanDetail({
    required this.name,
    required this.emoji,
    required this.unit,
    required this.qtyPerUnit,
    required this.currentStock,
  });

  final String name;
  final String? emoji;
  final String unit;
  final double qtyPerUnit;
  final double currentStock;
}
