import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/kawaii_badge.dart';
import '../../core/widgets/common/primary_button.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/bahan.dart';
import '../../data/models/product.dart';
import '../../providers/bahan_provider.dart';
import '../../providers/production_provider.dart';
import '../../providers/product_provider.dart';

class ProductionFormScreen extends StatefulWidget {
  const ProductionFormScreen({super.key});

  @override
  State<ProductionFormScreen> createState() => _ProductionFormScreenState();
}

class _ProductionFormScreenState extends State<ProductionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _noteController = TextEditingController();

  Product? _selectedProduct;
  List<_BahanRequirement> _requirements = [];
  bool _loading = false;
  bool _loadingRequirements = false;
  int _totalCost = 0;

  @override
  void dispose() {
    _qtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _onProductChanged(Product? product) async {
    if (product == null) return;
    setState(() {
      _selectedProduct = product;
      _loadingRequirements = true;
    });

    await _loadRequirements(product.id);
  }

  Future<void> _loadRequirements(int productId) async {
    final db = DatabaseHelper.instance;
    final bahanProvider = context.read<BahanProvider>();
    final resep = await db.getResep(productId);
    final bahans = bahanProvider.items;

    final requirements = <_BahanRequirement>[];
    for (final r in resep) {
      final bahan = bahans.firstWhere((b) => b.id == r.bahanId, orElse: () => bahans.first);
      requirements.add(_BahanRequirement(
        bahan: bahan,
        qtyPerUnit: r.qtyUsed,
      ));
    }

    if (mounted) {
      setState(() {
        _requirements = requirements;
        _loadingRequirements = false;
      });
      _calculateCost();
    }
  }

  void _calculateCost() {
    final qty = int.tryParse(_qtyController.text) ?? 0;
    int cost = 0;
    for (final req in _requirements) {
      final needed = req.qtyPerUnit * qty;
      cost += (req.bahan.buyPrice * needed).round();
    }
    setState(() => _totalCost = cost);
  }

  Future<void> _checkAndSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      _showError('Pilih produk terlebih dahulu');
      return;
    }

    if (_requirements.isEmpty) {
      _showError('Produk ini belum memiliki resep');
      return;
    }

    final qty = int.parse(_qtyController.text);

    // Validasi stok
    final insufficient = <String>[];
    for (final req in _requirements) {
      final needed = req.qtyPerUnit * qty;
      if (req.bahan.stock < needed) {
        insufficient.add('${req.bahan.name} (butuh ${needed.toStringAsFixed(1)}, tersedia ${req.bahan.stock.toStringAsFixed(1)} ${req.bahan.unit})');
      }
    }

    if (insufficient.isNotEmpty) {
      _showInsufficientDialog(insufficient);
      return;
    }

    // Konfirmasi produksi
    final confirm = await _showConfirmDialog();
    if (confirm != true) return;

    setState(() => _loading = true);

    if (!mounted) return;

    try {
      await context.read<ProductionProvider>().process(
            _selectedProduct!.id,
            _selectedProduct!.name,
            _selectedProduct!.emoji,
            qty,
            _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          );

      // Refresh bahan provider
      if (mounted) {
        await context.read<BahanProvider>().refresh();
        if (!mounted) return;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produksi $qty ${_selectedProduct!.name} berhasil')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showError('Gagal memproses produksi: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.coral),
    );
  }

  void _showInsufficientDialog(List<String> items) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusXl)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppColors.coral),
            const SizedBox(width: AppDimens.sm),
            Text('Stok Tidak Cukup', style: AppTextStyles.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bahan berikut tidak mencukupi:',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppDimens.md),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: AppColors.coral)),
                      Expanded(
                        child: Text(item, style: AppTextStyles.bodySmall),
                      ),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusXl)),
        title: Row(
          children: [
            const Icon(Icons.factory_rounded, color: AppColors.pinkAccent),
            const SizedBox(width: AppDimens.sm),
            Text('Konfirmasi Produksi', style: AppTextStyles.h3),
          ],
        ),
        content: Text(
          'Stok bahan akan berkurang otomatis sesuai resep. Lanjutkan?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Proses'),
          ),
        ],
      ),
    );
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
          'Produksi Baru',
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
            _QuantityInput(
              controller: _qtyController,
              onChanged: (_) => _calculateCost(),
            ),
            const SizedBox(height: AppDimens.lg),
            _NoteInput(controller: _noteController),
            if (_selectedProduct != null && _requirements.isNotEmpty) ...[
              const SizedBox(height: AppDimens.lg),
              _RequirementsCard(
                requirements: _requirements,
                qty: int.tryParse(_qtyController.text) ?? 1,
                loading: _loadingRequirements,
              ),
              const SizedBox(height: AppDimens.lg),
              _SummaryCard(
                totalCost: _totalCost,
                qty: int.tryParse(_qtyController.text) ?? 0,
              ),
            ],
            const SizedBox(height: AppDimens.xxl),
            PrimaryButton(
              label: 'Proses Produksi',
              onPressed: _loading ? null : _checkAndSubmit,
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
              const Icon(Icons.shopping_bag_rounded, color: AppColors.coral),
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
  const _QuantityInput({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

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
            onChanged: onChanged,
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
              const Icon(Icons.note_rounded, color: AppColors.coral),
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

class _RequirementsCard extends StatelessWidget {
  const _RequirementsCard({
    required this.requirements,
    required this.qty,
    required this.loading,
  });

  final List<_BahanRequirement> requirements;
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
              Text('Kebutuhan Bahan', style: AppTextStyles.h3),
              const Spacer(),
              KawaiiBadge(
                label: '${requirements.length} bahan',
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requirements.length,
              separatorBuilder: (_, __) => const Divider(height: AppDimens.lg),
              itemBuilder: (context, index) {
                final req = requirements[index];
                final needed = req.qtyPerUnit * qty;
                final sufficient = req.bahan.stock >= needed;

                return Row(
                  children: [
                    Text(req.bahan.emoji ?? '📦', style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: AppDimens.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(req.bahan.name, style: AppTextStyles.bodyBold),
                          Text(
                            'Stok: ${req.bahan.stock.toStringAsFixed(req.bahan.stock % 1 == 0 ? 0 : 1)} ${req.bahan.unit}',
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
                          style: AppTextStyles.bodyBold.copyWith(color: AppColors.coral),
                        ),
                        Text(req.bahan.unit, style: AppTextStyles.caption),
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
                    'Stok bahan akan berkurang otomatis',
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
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalCost,
    required this.qty,
  });

  final int totalCost;
  final int qty;

  @override
  Widget build(BuildContext context) {
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
              Text('Ringkasan Biaya', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jumlah Produksi', style: AppTextStyles.body),
              Text('$qty pcs', style: AppTextStyles.bodyBold),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          const Divider(),
          const SizedBox(height: AppDimens.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Biaya Bahan', style: AppTextStyles.h3.copyWith(fontSize: 16)),
              Text(
                Format.rupiah(totalCost),
                style: AppTextStyles.h3.copyWith(color: AppColors.pinkDeep, fontSize: 16),
              ),
            ],
          ),
          if (qty > 0) ...[
            const SizedBox(height: AppDimens.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Biaya per Unit', style: AppTextStyles.caption),
                Text(
                  Format.rupiah((totalCost / qty).round()),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BahanRequirement {
  const _BahanRequirement({
    required this.bahan,
    required this.qtyPerUnit,
  });

  final Bahan bahan;
  final double qtyPerUnit;
}
