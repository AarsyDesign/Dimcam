import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/empty_state.dart';
import '../../core/widgets/common/feature_header.dart';
import '../../core/widgets/common/kawaii_badge.dart';
import '../../core/widgets/common/primary_button.dart';
import '../../data/models/product.dart';
import '../../data/models/transaction.dart';
import '../../providers/hpp_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/transaction_provider.dart';
import 'transaction_detail_screen.dart';
import 'transaction_form_screen.dart';

class PenjualanScreen extends StatefulWidget {
  const PenjualanScreen({super.key});

  @override
  State<PenjualanScreen> createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Product? _selectedProduct;
  int _hpp = 0;
  bool _quickOpen = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final provider = context.read<TransactionProvider>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      provider.loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<TransactionProvider>().setQuery(query);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<TransactionProvider>().clearQuery();
  }

  void _addTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
    ).then((_) {
      if (mounted) {
        context.read<TransactionProvider>().refresh();
      }
    });
  }

  void _viewDetail(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TransactionDetailScreen(transaction: transaction)),
    ).then((_) {
      if (mounted) {
        context.read<TransactionProvider>().refresh();
      }
    });
  }

  void _onProductChanged(Product? product) async {
    if (product == null) return;
    setState(() {
      _selectedProduct = product;
      _priceController.text = product.sellingPrice.toString();
    });
    final hppProvider = context.read<HppProvider>();
    await hppProvider.load(product.id);
    setState(() {
      _hpp = hppProvider.hppOf(product.id);
    });
  }

  void _toggleQuick() {
    setState(() {
      _quickOpen = !_quickOpen;
      if (!_quickOpen) _resetQuick();
    });
  }

  void _resetQuick() {
    _selectedProduct = null;
    _qtyController.clear();
    _priceController.clear();
    _hpp = 0;
  }

  Future<void> _saveQuick() async {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk')),
      );
      return;
    }
    final qtyT = _qtyController.text;
    final priceT = _priceController.text;
    if (qtyT.isEmpty || priceT.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi jumlah dan harga')),
      );
      return;
    }
    final qty = int.tryParse(qtyT) ?? 0;
    final price = int.tryParse(priceT) ?? 0;
    if (qty <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah dan harga harus lebih dari 0')),
      );
      return;
    }

    final tx = Transaction(
      id: 0,
      productId: _selectedProduct!.id,
      productName: _selectedProduct!.name,
      productEmoji: _selectedProduct!.emoji,
      quantity: qty,
      unitPrice: price,
      hppPerUnit: _hpp,
      dateTime: DateTime.now(),
    );

    try {
      await context.read<TransactionProvider>().add(tx);
      _toggleQuick();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedProduct!.emoji} ${_selectedProduct!.name} x$qty — ${Format.rupiah(qty * price)}'),
            backgroundColor: AppColors.mintDeep,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }

  int get _total {
    final qty = int.tryParse(_qtyController.text) ?? 0;
    final price = int.tryParse(_priceController.text) ?? 0;
    return qty * price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          FeatureHeader(
            title: 'Penjualan',
            subtitle: 'Kelola transaksi penjualan',
            icon: Icons.sell_rounded,
            onAction: _addTransaction,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppDimens.lg, AppDimens.lg, AppDimens.lg, 0),
            child: _SearchBar(
              controller: _searchController,
              onChanged: _onSearch,
              onClear: _clearSearch,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppDimens.lg, AppDimens.sm, AppDimens.lg, 0),
            child: _QuickSaleToggle(onToggle: _toggleQuick, isOpen: _quickOpen),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _QuickSaleCard(
              key: ValueKey(_quickOpen),
              selectedProduct: _selectedProduct,
              qtyController: _qtyController,
              priceController: _priceController,
              total: _total,
              onProductChanged: _onProductChanged,
              onSave: _saveQuick,
            ),
            crossFadeState: _quickOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.pinkAccent),
                  );
                }

                final today = provider.today;
                final hasToday = today.isNotEmpty;

                if (provider.items.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: provider.query.isEmpty ? 'Belum ada transaksi' : 'Transaksi tidak ditemukan',
                    subtitle: provider.query.isEmpty
                        ? 'Catat penjualan cepat di atas'
                        : 'Coba kata kunci lain',
                  );
                }

                return RefreshIndicator(
                  color: AppColors.pinkAccent,
                  onRefresh: () => provider.refresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(AppDimens.lg, 0, AppDimens.lg, AppDimens.xxxl),
                    itemCount: provider.items.length + (hasToday ? 1 : 0) + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (hasToday && index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimens.md),
                          child: _TodayCard(today: today),
                        );
                      }
                      int i = hasToday ? index - 1 : index;
                      if (i >= provider.items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(AppDimens.lg),
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.pinkAccent),
                          ),
                        );
                      }
                      final tx = provider.items[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimens.md),
                        child: _TransactionCard(
                          transaction: tx,
                          onTap: () => _viewDetail(tx),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickSaleToggle extends StatelessWidget {
  const _QuickSaleToggle({required this.onToggle, required this.isOpen});

  final VoidCallback onToggle;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg, vertical: AppDimens.sm),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: isOpen ? AppColors.pinkAccent : AppColors.pinkSoft),
        ),
        child: Row(
          children: [
            Icon(
              isOpen ? Icons.expand_less_rounded : Icons.add_circle_rounded,
              color: AppColors.pinkAccent,
              size: 20,
            ),
            const SizedBox(width: AppDimens.sm),
            Text(
              isOpen ? 'Tutup input cepat' : 'Input Penjualan Cepat',
              style: AppTextStyles.bodyBold.copyWith(color: AppColors.pinkDeep, fontSize: 13),
            ),
            const Spacer(),
            Icon(
              isOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: AppColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickSaleCard extends StatelessWidget {
  const _QuickSaleCard({
    super.key,
    required this.selectedProduct,
    required this.qtyController,
    required this.priceController,
    required this.total,
    required this.onProductChanged,
    required this.onSave,
  });

  final Product? selectedProduct;
  final TextEditingController qtyController;
  final TextEditingController priceController;
  final int total;
  final ValueChanged<Product?> onProductChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.lg, AppDimens.sm, AppDimens.lg, 0),
      child: AppCard(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.pinkLight, AppColors.ivory],
        ),
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sell_rounded, color: AppColors.pinkDeep, size: 18),
                const SizedBox(width: AppDimens.sm),
                Text('Transaksi Baru', style: AppTextStyles.h3.copyWith(fontSize: 15)),
              ],
            ),
            const SizedBox(height: AppDimens.md),
            Consumer<ProductProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const SizedBox(
                    height: 48,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                return DropdownButtonFormField<Product>(
                  initialValue: selectedProduct,
                  decoration: const InputDecoration(
                    hintText: 'Pilih produk',
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  isExpanded: true,
                  items: provider.items.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Row(
                        children: [
                          Text(p.emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${p.name} — ${Format.rupiah(p.sellingPrice)}',
                              style: AppTextStyles.bodyBold.copyWith(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: onProductChanged,
                );
              },
            ),
            const SizedBox(height: AppDimens.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: qtyController,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah',
                      hintText: '0',
                      prefixIcon: Icon(Icons.shopping_cart_rounded, size: 18),
                      suffixText: 'pcs',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      hintText: '0',
                      prefixIcon: Icon(Icons.payments_rounded, size: 18),
                      prefixText: 'Rp ',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            if (total > 0) ...[
              const SizedBox(height: AppDimens.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Total: ', style: AppTextStyles.caption),
                  Text(
                    Format.rupiah(total),
                    style: AppTextStyles.h3.copyWith(color: AppColors.pinkDeep, fontSize: 15),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppDimens.md),
            PrimaryButton(
              label: 'Simpan Penjualan',
              icon: Icons.check_rounded,
              onPressed: selectedProduct != null ? onSave : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.today});

  final List<Transaction> today;

  @override
  Widget build(BuildContext context) {
    final totalSales = today.fold<int>(0, (s, t) => s + t.totalPrice);
    final totalProfit = today.fold<int>(0, (s, t) => s + t.profit);
    final totalQty = today.fold<int>(0, (s, t) => s + t.quantity);
    final profitPositive = totalProfit >= 0;

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
              const Icon(Icons.today_rounded, color: AppColors.pinkDeep, size: 18),
              const SizedBox(width: AppDimens.sm),
              Text('Penjualan Hari Ini', style: AppTextStyles.h3.copyWith(fontSize: 14)),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.receipt_long_rounded, color: AppColors.pinkAccent, size: 22),
                    const SizedBox(height: 4),
                    Text(Format.rupiahShort(totalSales), style: AppTextStyles.h3.copyWith(color: AppColors.pinkDeep, fontSize: 15)),
                    Text('Total', style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.pinkSoft),
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.shopping_cart_rounded, color: AppColors.pinkAccent, size: 22),
                    const SizedBox(height: 4),
                    Text('$totalQty', style: AppTextStyles.h3.copyWith(color: AppColors.pinkDeep, fontSize: 15)),
                    Text('Terjual', style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.pinkSoft),
              Expanded(
                child: Column(
                  children: [
                    Icon(
                      profitPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: profitPositive ? AppColors.mintDeep : AppColors.coral,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(Format.rupiahShort(totalProfit), style: AppTextStyles.h3.copyWith(color: profitPositive ? AppColors.mintDeep : AppColors.coral, fontSize: 15)),
                    Text('Laba', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Cari produk atau catatan...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: onClear,
              )
            : null,
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.transaction,
    required this.onTap,
  });

  final Transaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(transaction.dateTime);
    final profit = transaction.profit;
    final profitPositive = profit >= 0;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: AppColors.pinkGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    transaction.productEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.productName, style: AppTextStyles.h3.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      '${transaction.quantity} × ${Format.rupiah(transaction.unitPrice)}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Format.rupiah(transaction.totalPrice),
                    style: AppTextStyles.h3.copyWith(color: AppColors.pinkDeep, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        profitPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        size: 14,
                        color: profitPositive ? AppColors.mintDeep : AppColors.coral,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        Format.rupiah(profit.abs()),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: profitPositive ? AppColors.mintDeep : AppColors.coral,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          const Divider(height: 1),
          const SizedBox(height: AppDimens.sm),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                Format.dateTime(transaction.dateTime),
                style: AppTextStyles.caption,
              ),
              const Spacer(),
              if (isToday) const KawaiiBadge(label: 'Hari ini', variant: BadgeVariant.pink),
            ],
          ),
          if (transaction.note != null && transaction.note!.isNotEmpty) ...[
            const SizedBox(height: AppDimens.sm),
            Row(
              children: [
                const Icon(Icons.note_rounded, size: 14, color: AppColors.pinkAccent),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    transaction.note!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.pinkDeep,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
