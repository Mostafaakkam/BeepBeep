import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../data/models/models.dart';
import '../viewmodels/store_owner_viewmodel.dart';
import '../viewmodels/owner_product_viewmodel.dart';
import '../viewmodels/owner_order_viewmodel.dart';
import 'store_owner_products_page.dart';
import 'store_owner_orders_page.dart';
import 'store_owner_stores_page.dart';
import 'store_owner_order_details_page.dart';

// Store Owner Dashboard: the dashboard's own navigation shell, entered only
// from ProfilePage's "Store Owner Dashboard" button (shown only when
// role == 'store_owner' -- see profile_page.dart). This does NOT replace the
// customer HomePage; a store owner can still back out to the regular
// marketplace experience at any time. Mirrors HomePage's own
// BottomNavigationBar / _selectedIndex shell pattern rather than introducing
// a new navigation convention.
//
// A single StoreOwnerViewModel instance is created here and passed down to
// every tab, so "which store am I managing" is one shared piece of state
// (switching stores on the Stores tab immediately updates what the
// Dashboard/Products/Orders tabs show).
class StoreOwnerHomePage extends StatefulWidget {
  const StoreOwnerHomePage({super.key});

  @override
  State<StoreOwnerHomePage> createState() => _StoreOwnerHomePageState();
}

class _StoreOwnerHomePageState extends State<StoreOwnerHomePage> {
  final StoreOwnerViewModel _storeOwnerViewModel = StoreOwnerViewModel();
  final OwnerProductViewModel _productViewModel = OwnerProductViewModel();
  final OwnerOrderViewModel _orderViewModel = OwnerOrderViewModel();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _storeOwnerViewModel.loadMyStores();
  }

  @override
  void dispose() {
    _storeOwnerViewModel.dispose();
    _productViewModel.dispose();
    _orderViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_selectedIndex) {
      case 0:
        body = _DashboardTab(
          viewModel: _storeOwnerViewModel,
          onManageProducts: () => setState(() => _selectedIndex = 1),
          onViewOrders: () => setState(() => _selectedIndex = 2),
          onSwitchStore: () => setState(() => _selectedIndex = 3),
          orderViewModel: _orderViewModel,
        );
        break;
      case 1:
        body = StoreOwnerProductsPage(
          storeOwnerViewModel: _storeOwnerViewModel,
          productViewModel: _productViewModel,
        );
        break;
      case 2:
        body = StoreOwnerOrdersPage(
          storeOwnerViewModel: _storeOwnerViewModel,
          orderViewModel: _orderViewModel,
        );
        break;
      case 3:
        body = StoreOwnerStoresPage(viewModel: _storeOwnerViewModel);
        break;
      default:
        body = const SizedBox.shrink();
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.gray.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: l10n.goBack,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              l10n.storeOwnerDashboard,
              style: const TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final l10n = AppLocalizations.of(context);
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.gray,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard_outlined),
          activeIcon: const Icon(Icons.dashboard),
          label: l10n.dashboard,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.inventory_2_outlined),
          activeIcon: const Icon(Icons.inventory_2),
          label: l10n.products,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long_outlined),
          activeIcon: const Icon(Icons.receipt_long),
          label: l10n.orders,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.store_outlined),
          activeIcon: const Icon(Icons.store),
          label: l10n.stores,
        ),
      ],
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final StoreOwnerViewModel viewModel;
  final OwnerOrderViewModel orderViewModel;
  final VoidCallback onManageProducts;
  final VoidCallback onViewOrders;
  final VoidCallback onSwitchStore;

  const _DashboardTab({
    required this.viewModel,
    required this.orderViewModel,
    required this.onManageProducts,
    required this.onViewOrders,
    required this.onSwitchStore,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        if (viewModel.isLoading && viewModel.myStores.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (viewModel.isError && viewModel.myStores.isEmpty) {
          return _buildError(context);
        }

        if (viewModel.myStores.isEmpty) {
          return _buildNoStores(context);
        }

        return RefreshIndicator(
          onRefresh: viewModel.loadMyStores,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcome(context),
                const SizedBox(height: AppSpacing.lg),
                _buildStoreSelector(context),
                const SizedBox(height: AppSpacing.lg),
                _buildSummaryCards(context),
                const SizedBox(height: AppSpacing.lg),
                _buildQuickActions(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              viewModel.errorMessage ?? l10n.failedToLoadStores,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(text: l10n.retry, type: AppButtonType.primary, onPressed: viewModel.retry),
          ],
        ),
      ),
    );
  }

  Widget _buildNoStores(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store_outlined, size: 64, color: AppColors.gray),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.noOwnedStores, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.darkNavy)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.noOwnedStoresMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Text(
      l10n.storeOwnerWelcome,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.darkNavy, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStoreSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = viewModel.selectedStore;
    if (store == null) return const SizedBox.shrink();

    return AppCard(
      onTap: viewModel.hasMultipleStores ? onSwitchStore : null,
      child: Row(
        children: [
          const Icon(Icons.store, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.currentlyManaging,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray),
                ),
                Text(
                  store.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkNavy, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (viewModel.hasMultipleStores)
            Text(l10n.switchStore, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = viewModel.dashboardStats;

    if (viewModel.isLoadingStats) {
      return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    if (stats == null) return const SizedBox.shrink();

    final cards = [
      (l10n.pending, stats.pendingCount, AppColors.warning),
      (l10n.confirmed, stats.confirmedCount, AppColors.primary),
      (l10n.preparing, stats.preparingCount, AppColors.primary),
      (l10n.shipped, stats.shippedCount, AppColors.primary),
      (l10n.delivered, stats.deliveredCount, AppColors.success),
      (l10n.totalProducts, stats.productCount, AppColors.lightBlue),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.3,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      children: cards.map((c) => _buildStatCard(context, c.$1, c.$2, c.$3)).toList(),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, int count, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.quickActions, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.darkNavy)),
        const SizedBox(height: AppSpacing.md),
        AppButton(text: l10n.manageProducts, type: AppButtonType.secondary, isFullWidth: true, onPressed: onManageProducts),
        const SizedBox(height: AppSpacing.sm),
        AppButton(text: l10n.viewOrders, type: AppButtonType.outline, isFullWidth: true, onPressed: onViewOrders),
      ],
    );
  }
}
