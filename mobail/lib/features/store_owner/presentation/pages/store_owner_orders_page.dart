import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../data/models/models.dart';
import '../viewmodels/store_owner_viewmodel.dart';
import '../viewmodels/owner_order_viewmodel.dart';
import 'store_owner_order_details_page.dart';

// Store Owner Dashboard: order list for the currently selected store, via
// the pre-existing GET /api/stores/:storeId/orders endpoint (ownership
// already gated server-side).
class StoreOwnerOrdersPage extends StatefulWidget {
  final StoreOwnerViewModel storeOwnerViewModel;
  final OwnerOrderViewModel orderViewModel;

  const StoreOwnerOrdersPage({
    super.key,
    required this.storeOwnerViewModel,
    required this.orderViewModel,
  });

  @override
  State<StoreOwnerOrdersPage> createState() => _StoreOwnerOrdersPageState();
}

class _StoreOwnerOrdersPageState extends State<StoreOwnerOrdersPage> {
  int? _loadedForStoreId;

  @override
  Widget build(BuildContext context) {
    final store = widget.storeOwnerViewModel.selectedStore;
    final l10n = AppLocalizations.of(context);

    if (store == null) {
      return Center(
        child: Text(l10n.selectAStoreFirst, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray)),
      );
    }

    if (_loadedForStoreId != store.id) {
      _loadedForStoreId = store.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.orderViewModel.loadOrders(store.id);
      });
    }

    return ListenableBuilder(
      listenable: widget.orderViewModel,
      builder: (context, child) => _buildBody(context, store),
    );
  }

  Widget _buildBody(BuildContext context, Store store) {
    final vm = widget.orderViewModel;
    final l10n = AppLocalizations.of(context);

    if (vm.isLoading && vm.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (vm.isError && vm.orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                vm.errorMessage ?? l10n.failedToLoadOrders,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(text: l10n.retry, type: AppButtonType.primary, onPressed: vm.retry),
            ],
          ),
        ),
      );
    }

    if (vm.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.gray),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.noOwnedOrders, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.darkNavy)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.noOwnedOrdersMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.retry,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: vm.orders.length,
        itemBuilder: (context, index) => _buildOrderCard(context, store, vm.orders[index]),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Store store, Order order) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StoreOwnerOrderDetailsPage(
                storeId: store.id,
                orderId: order.id,
                viewModel: widget.orderViewModel,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.orderIdHeading(order.id),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkNavy, fontWeight: FontWeight.bold),
                  ),
                  _buildStatusChip(context, order.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(order.customerName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray)),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDate(order.createdAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray)),
                  Text(
                    order.total.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context);
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case 'pending':
        backgroundColor = AppColors.warning.withOpacity(0.2);
        textColor = AppColors.warning;
        label = l10n.pending;
        break;
      case 'confirmed':
      case 'preparing':
      case 'shipped':
        backgroundColor = AppColors.primary.withOpacity(0.2);
        textColor = AppColors.primary;
        label = status == 'confirmed' ? l10n.confirmed : (status == 'preparing' ? l10n.preparing : l10n.shipped);
        break;
      case 'delivered':
        backgroundColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        label = l10n.delivered;
        break;
      case 'cancelled':
        backgroundColor = AppColors.error.withOpacity(0.2);
        textColor = AppColors.error;
        label = l10n.cancelled;
        break;
      default:
        backgroundColor = AppColors.gray.withOpacity(0.2);
        textColor = AppColors.gray;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(AppBorderRadius.sm)),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor, fontWeight: FontWeight.w600)),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
