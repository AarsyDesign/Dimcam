import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/transaction_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../hpp/hpp_screen.dart';
import '../laporan/laporan_screen.dart';
import '../penjualan/penjualan_screen.dart';
import '../stok/stok_screen.dart';

/// 🏠 Cangkang navigasi utama dengan 5 menu bottom navigation.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  static const List<_NavTab> _tabs = [
    _NavTab(icon: Icons.home_rounded, label: 'Dashboard', screen: DashboardScreen()),
    _NavTab(icon: Icons.sell_rounded, label: 'Penjualan', screen: PenjualanScreen()),
    _NavTab(icon: Icons.calculate_rounded, label: 'HPP', screen: HppScreen()),
    _NavTab(icon: Icons.inventory_2_rounded, label: 'Stok', screen: StokScreen()),
    _NavTab(icon: Icons.bar_chart_rounded, label: 'Laporan', screen: LaporanScreen()),
  ];

  @override
  void initState() {
    super.initState();
    // Hitung ringkasan dashboard setelah frame pertama.
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshDashboard());
  }

  void _refreshDashboard() {
    final tx = context.read<TransactionProvider>();
    final stock = context.read<StockProvider>();
    context.read<DashboardProvider>().recompute(transactions: tx, stocks: stock);
  }

  void _onTap(int i) {
    setState(() => _index = i);
    // Dashboard perlu recompute tiap kali dibuka.
    if (i == 0) _refreshDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: IndexedStack(
        index: _index,
        children: _tabs.map((t) => t.screen).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXxl)),
          boxShadow: [
            BoxShadow(
              color: AppColors.pinkDeep.withValues(alpha: 0.1),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.sm, horizontal: AppDimens.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final selected = i == _index;
                return _NavButton(
                  icon: tab.icon,
                  label: tab.label,
                  selected: selected,
                  onTap: () => _onTap(i),
                );
              }),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? AppDimens.md : AppDimens.sm,
          vertical: AppDimens.xs + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.pinkSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDimens.iconMd - 2,
              color: selected ? AppColors.pinkDeep : AppColors.textMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: selected ? AppColors.pinkDeep : AppColors.textMuted,
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
