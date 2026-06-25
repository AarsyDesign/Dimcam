import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/debt_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/transaction_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../hpp/hpp_screen.dart';
import '../hutang/hutang_screen.dart';
import '../laporan/laporan_screen.dart';
import '../pelanggan/pelanggan_screen.dart';
import '../pengaturan/pengaturan_screen.dart';
import '../penjualan/penjualan_screen.dart';
import '../produksi/produksi_screen.dart';
import '../stok/stok_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  final _scrollController = ScrollController();

  static const List<_NavTab> _tabs = [
    _NavTab(icon: Icons.home_rounded, label: 'Dashboard', screen: DashboardScreen()),
    _NavTab(icon: Icons.sell_rounded, label: 'Penjualan', screen: PenjualanScreen()),
    _NavTab(icon: Icons.factory_rounded, label: 'Produksi', screen: ProduksiScreen()),
    _NavTab(icon: Icons.people_rounded, label: 'Pelanggan', screen: PelangganScreen()),
    _NavTab(icon: Icons.receipt_long_rounded, label: 'Hutang', screen: HutangScreen()),
    _NavTab(icon: Icons.calculate_rounded, label: 'HPP', screen: HppScreen()),
    _NavTab(icon: Icons.inventory_2_rounded, label: 'Stok', screen: StokScreen()),
    _NavTab(icon: Icons.bar_chart_rounded, label: 'Laporan', screen: LaporanScreen()),
    _NavTab(icon: Icons.settings_rounded, label: 'Pengaturan', screen: PengaturanScreen()),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshDashboard());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshDashboard() {
    final tx = context.read<TransactionProvider>();
    final stock = context.read<StockProvider>();
    final debts = context.read<DebtProvider>();
    context.read<DashboardProvider>().recompute(transactions: tx, stocks: stock, debts: debts);
  }

  void _onTap(int i) {
    setState(() => _index = i);
    if (i == 0) _refreshDashboard();
    _scrollToTab(i);
  }

  void _scrollToTab(int index) {
    const width = 72.0;
    final target = (index * width) - (MediaQuery.of(context).size.width / 2 - width);
    _scrollController.animateTo(
      target.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E2E) : AppColors.cream;
    final navBg = isDark ? const Color(0xFF252535) : AppColors.white;
    final navShadow = isDark
        ? const Color(0xFF000000).withValues(alpha: 0.3)
        : AppColors.pinkDeep.withValues(alpha: 0.1);

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _index,
        children: _tabs.map((t) => t.screen).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXxl)),
          boxShadow: [
            BoxShadow(
              color: navShadow,
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _tabs.length,
              itemBuilder: (context, i) {
                final tab = _tabs[i];
                final selected = i == _index;
                return _NavButton(
                  icon: tab.icon,
                  label: tab.label,
                  selected: selected,
                  onTap: () => _onTap(i),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({required this.icon, required this.label, required this.screen});
  final IconData icon;
  final String label;
  final Widget screen;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark ? AppColors.pinkDeep.withValues(alpha: 0.25) : AppColors.pinkSoft;
    const activeColor = AppColors.pinkDeep;
    final inactiveColor = isDark ? const Color(0xFF9E8E93) : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDimens.iconMd - 2,
              color: selected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: selected ? activeColor : inactiveColor,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
