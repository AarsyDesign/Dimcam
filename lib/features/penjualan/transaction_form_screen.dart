import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common/app_card.dart';
import '../../core/widgets/common/kawaii_badge.dart';
import '../../core/widgets/common/primary_button.dart';
import '../../data/models/customer.dart';
import '../../data/models/product.dart';
import '../../data/models/transaction.dart';
import '../../providers/customer_provider.dart';
import '../../providers/hpp_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/transaction_provider.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, this.transaction});

  final Transaction? transaction;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();

  Product? _selectedProduct;
  Customer? _selectedCustomer;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _hpp = 0;
  bool _loading = false;

  bool get _isEdit => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  Future<void> _loadInitialData() async {
    final products = context.read<ProductProvider>();
    final hppProvider = context.read<HppProvider>();

    if (_isEdit) {
      final tx = widget.transaction!;
      _selectedProduct = products.byId(tx.productId);
      _qtyController.text = tx.quantity.toString();
      _priceController.text = tx.unitPrice.toString();
      _noteController.text = tx.note ?? '';
      _selectedDate = tx.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(tx.dateTime);
      _hpp = tx.hppPerUnit;
      if (tx.customerId != null) {
        final customers = context.read<CustomerProvider>().items;
        try {
          _selectedCustomer = customers.firstWhere((c) => c.id == tx.customerId);
        } catch (_) {}
      }
    }

    if (_selectedProduct != null) {
      await hppProvider.load(_selectedProduct!.id);
      setState(() {
        _hpp = hppProvider.hppOf(_selectedProduct!.id);
      });
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu')),
      );
      return;
    }

    setState(() => _loading = true);

    final qty = int.parse(_qtyController.text);
    final price = int.parse(_priceController.text);
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final transaction = Transaction(
      id: _isEdit ? widget.transaction!.id : 0,
      productId: _selectedProduct!.id,
      productName: _selectedProduct!.name,
      productEmoji: _selectedProduct!.emoji,
      quantity: qty,
      unitPrice: price,
      hppPerUnit: _hpp,
      dateTime: dateTime,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      customerId: _selectedCustomer?.id,
      customerName: _selectedCustomer?.name,
    );

    try {
      final provider = context.read<TransactionProvider>();
      if (_isEdit) {
        await provider.update(transaction);
      } else {
        await provider.add(transaction);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaksi berhasil ${_isEdit ? 'diupdate' : 'ditambahkan'}')),
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

  int get _total {
    final qty = int.tryParse(_qtyController.text) ?? 0;
    final price = int.tryParse(_priceController.text) ?? 0;
    return qty * price;
  }

  int get _totalCost {
    final qty = int.tryParse(_qtyController.text) ?? 0;
    return qty * _hpp;
  }

  int get _profit => _total - _totalCost;

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
          _isEdit ? 'Edit Transaksi' : 'Transaksi Baru',
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
            _CustomerSelector(
              selectedCustomer: _selectedCustomer,
              onChanged: (c) => setState(() => _selectedCustomer = c),
            ),
            const SizedBox(height: AppDimens.lg),
            _DateTimeSelector(
              date: _selectedDate,
              time: _selectedTime,
              onDateTap: _selectDate,
              onTimeTap: _selectTime,
            ),
            const SizedBox(height: AppDimens.lg),
            _QuantityPriceInput(
              qtyController: _qtyController,
              priceController: _priceController,
            ),
            const SizedBox(height: AppDimens.lg),
            _NoteInput(controller: _noteController),
            const SizedBox(height: AppDimens.lg),
            _SummaryCard(
              hpp: _hpp,
              total: _total,
              totalCost: _totalCost,
              profit: _profit,
            ),
            const SizedBox(height: AppDimens.xxl),
            PrimaryButton(
              label: _isEdit ? 'Update Transaksi' : 'Simpan Transaksi',
              onPressed: _loading ? null : _save,
              icon: _isEdit ? Icons.check_rounded : Icons.add_rounded,
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
              const Icon(Icons.shopping_bag_rounded, color: AppColors.pinkAccent),
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
                  hintText: 'Pilih produk',
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
                                Format.rupiah(product.sellingPrice),
                                style: AppTextStyles.caption.copyWith(color: AppColors.pinkDeep),
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

class _CustomerSelector extends StatelessWidget {
  const _CustomerSelector({
    required this.selectedCustomer,
    required this.onChanged,
  });

  final Customer? selectedCustomer;
  final ValueChanged<Customer?> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_rounded, color: AppColors.pinkAccent),
              const SizedBox(width: AppDimens.sm),
              Text('Pelanggan', style: AppTextStyles.h3),
              const Spacer(),
              const KawaiiBadge(label: 'Opsional', variant: BadgeVariant.lavender),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Consumer<CustomerProvider>(
            builder: (context, provider, _) {
              return DropdownButtonFormField<Customer>(
                initialValue: selectedCustomer,
                decoration: const InputDecoration(
                  hintText: 'Pilih pelanggan (opsional)',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                items: provider.items.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        const Icon(Icons.person_rounded, size: 20, color: AppColors.pinkDeep),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(c.name, style: AppTextStyles.bodyBold),
                              if (c.whatsapp != null)
                                Text(c.whatsapp!, style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
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

class _QuantityPriceInput extends StatelessWidget {
  const _QuantityPriceInput({
    required this.qtyController,
    required this.priceController,
  });

  final TextEditingController qtyController;
  final TextEditingController priceController;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_rounded, color: AppColors.pinkAccent),
              const SizedBox(width: AppDimens.sm),
              Text('Kuantitas & Harga', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          TextFormField(
            controller: qtyController,
            decoration: const InputDecoration(
              labelText: 'Jumlah',
              hintText: 'Masukkan jumlah',
              prefixIcon: Icon(Icons.shopping_cart_rounded),
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
          const SizedBox(height: AppDimens.md),
          TextFormField(
            controller: priceController,
            decoration: const InputDecoration(
              labelText: 'Harga Satuan',
              hintText: 'Masukkan harga',
              prefixIcon: Icon(Icons.payments_rounded),
              prefixText: 'Rp ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) return 'Masukkan harga';
              final price = int.tryParse(value);
              if (price == null || price <= 0) return 'Harga harus lebih dari 0';
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
    required this.hpp,
    required this.total,
    required this.totalCost,
    required this.profit,
  });

  final int hpp;
  final int total;
  final int totalCost;
  final int profit;

  @override
  Widget build(BuildContext context) {
    final profitPositive = profit >= 0;
    final marginPercent = total > 0 ? ((profit / total) * 100) : 0.0;

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
          _SummaryRow(label: 'HPP per Unit', value: Format.rupiah(hpp)),
          const SizedBox(height: AppDimens.sm),
          _SummaryRow(label: 'Total HPP', value: Format.rupiah(totalCost)),
          const SizedBox(height: AppDimens.sm),
          const Divider(),
          const SizedBox(height: AppDimens.sm),
          _SummaryRow(
            label: 'Total Penjualan',
            value: Format.rupiah(total),
            bold: true,
            valueColor: AppColors.pinkDeep,
          ),
          const SizedBox(height: AppDimens.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Laba Bersih', style: AppTextStyles.h3.copyWith(fontSize: 16)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        profitPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        size: 18,
                        color: profitPositive ? AppColors.mintDeep : AppColors.coral,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Format.rupiah(profit.abs()),
                        style: AppTextStyles.h3.copyWith(
                          color: profitPositive ? AppColors.mintDeep : AppColors.coral,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (total > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Margin ${marginPercent.toStringAsFixed(1)}%',
                      style: AppTextStyles.caption.copyWith(
                        color: profitPositive ? AppColors.mintDeep : AppColors.coral,
                      ),
                    ),
                  ],
                ],
              ),
            ],
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
