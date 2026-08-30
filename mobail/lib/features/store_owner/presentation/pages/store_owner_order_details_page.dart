import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../data/models/models.dart';
import '../viewmodels/owner_order_viewmodel.dart';

// Store Owner Dashboard: order detail for one order in the selected store,
// with status-update controls. The backend (orderService.VALID_TRANSITIONS)
// is the sole authority on which status transitions are legal -- offering
// only the single valid next status here is a UX nicety, not the
// enforcement point; a stale/forged request is still rejected server-side.
class StoreOwnerOrderDetailsPage extends StatefulWidget {
  final int storeId;
  final int orderId;
  final OwnerOrderViewModel viewModel;

  const StoreOwnerOrderDetailsPage({
    super.key,
    required this.storeId,
    required this.orderId,
    required this.viewModel,
  });

  @override
  State<StoreOwnerOrderDetailsPage> createState() => _StoreOwnerOrderDetailsPageState();
}

class _StoreOwnerOrderDetailsPageState extends State<StoreOwnerOrderDetailsPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadOrderDetail(widget.storeId, widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, child) => _buildContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
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
              l10n.orderDetails,
              style: const TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final vm = widget.viewModel;
    final l10n = AppLocalizations.of(context);

    if (vm.isLoading && vm.selectedOrder == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (vm.isError && vm.selectedOrder == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                vm.errorMessage ?? l10n.failedToLoadOrder,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: l10n.retry,
                type: AppButtonType.primary,
                onPressed: () => vm.loadOrderDetail(widget.storeId, widget.orderId),
              ),
            ],
          ),
        ),
      );
    }

    final order = vm.selectedOrder;
    if (order == null) {
      return Center(child: Text(l10n.orderNotFound));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderInfo(context, order),
          const SizedBox(height: AppSpacing.lg),
          _buildCustomerInfo(context, order),
          const SizedBox(height: AppSpacing.lg),
          _buildOrderItems(context, order),
          const SizedBox(height: AppSpacing.lg),
          _buildOrderTotals(context, order),
          const SizedBox(height: AppSpacing.lg),
          _buildStatusUpdateControl(context, order),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context, Order order) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.orderInformation, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.darkNavy)),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(context, l10n.orderNumber, '#${order.id}'),
          const Divider(),
          _buildInfoRow(context, l10n.orderStatus, order.formattedStatus),
          const Divider(),
          _buildInfoRow(context, l10n.orderDate, _formatDate(order.createdAt)),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(BuildContext context, Order order) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.customerInformation, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.darkNavy)),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(context, l10n.name, order.customerName),
          const Divider(),
          _buildInfoRow(context, l10n.phone, order.customerPhone),
          const Divider(),
          _buildInfoRow(context, l10n.deliveryAddress, order.deliveryAddress),
        ],
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context, Order order) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.orderItems, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.darkNavy)),
          const SizedBox(height: AppSpacing.md),
          ...(order.items ?? []).map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkNavy, fontWeight: FontWeight.w600),
                        ),
                        if (item.variantName.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(item.variantName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray)),
                        ],
                      ],
                    ),
                  ),
                  Text(l10n.quantity(item.quantity), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    item.subtotal.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkNavy, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderTotals(BuildContext context, Order order) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.orderTotals, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.darkNavy)),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(context, l10n.subtotal, order.subtotal.toStringAsFixed(2)),
          const Divider(),
          _buildInfoRow(context, l10n.deliveryFee, order.deliveryFee.toStringAsFixed(2)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.total, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.darkNavy, fontWeight: FontWeight.bold)),
              Text(
                order.total.toStringAsFixed(2),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateControl(BuildContext context, Order order) {
    final l10n = AppLocalizations.of(context);
    final nextStatus = OwnerOrderViewModel.nextValidStatus(order.status);

    if (nextStatus == null) {
      return const SizedBox.shrink();
    }

    return AppButton(
      text: l10n.markOrderAs(_statusLabel(l10n, nextStatus)),
      type: AppButtonType.primary,
      isFullWidth: true,
      isLoading: widget.viewModel.isOperationInProgress,
      onPressed: widget.viewModel.isOperationInProgress
          ? null
          : () => _handleStatusUpdate(context, nextStatus),
    );
  }

  Future<void> _handleStatusUpdate(BuildContext context, String newStatus) async {
    final l10n = AppLocalizations.of(context);
    try {
      await widget.viewModel.updateStatus(widget.storeId, widget.orderId, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orderStatusUpdatedSuccess), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orderStatusUpdateFailed), backgroundColor: AppColors.error),
      );
    }
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'pending':
        return l10n.pending;
      case 'confirmed':
        return l10n.confirmed;
      case 'preparing':
        return l10n.preparing;
      case 'shipped':
        return l10n.shipped;
      case 'delivered':
        return l10n.delivered;
      case 'cancelled':
        return l10n.cancelled;
      default:
        return status;
    }
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray)),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkNavy, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
