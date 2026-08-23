import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../viewmodels/order_viewmodel.dart';
import '../../../../data/models/models.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final OrderViewModel _viewModel = OrderViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.loadOrderById(widget.orderId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            tooltip: l10n.goBack,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              l10n.orderDetails,
              style: const TextStyle(
                color: AppColors.darkNavy,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        if (_viewModel.isLoading) {
          return _buildLoadingState();
        }

        if (_viewModel.isError) {
          return _buildErrorState();
        }

        if (_viewModel.selectedOrder == null) {
          return _buildEmptyState();
        }

        return _buildOrderDetails(_viewModel.selectedOrder!);
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _viewModel.errorMessage ?? l10n.failedToLoadOrder,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: l10n.retry,
              type: AppButtonType.primary,
              onPressed: () => _viewModel.loadOrderById(widget.orderId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Text(
        l10n.orderNotFound,
        style: const TextStyle(
          color: AppColors.darkNavy,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderInfo(order),
          const SizedBox(height: AppSpacing.lg),
          _buildCustomerInfo(order),
          const SizedBox(height: AppSpacing.lg),
          _buildPaymentInfo(order),
          const SizedBox(height: AppSpacing.lg),
          _buildOrderItems(order),
          const SizedBox(height: AppSpacing.lg),
          _buildOrderTotals(order),
          if (order.isCancellable) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildCancelButton(order),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderInfo(Order order) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.orderInformation,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(l10n.orderNumber, '#${order.id}'),
          const Divider(),
          _buildInfoRow(l10n.orderStatus, order.formattedStatus),
          const Divider(),
          _buildInfoRow(l10n.orderDate, _formatDate(order.createdAt)),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(Order order) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.customerInformation,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(l10n.name, order.customerName),
          const Divider(),
          _buildInfoRow(l10n.phone, order.customerPhone),
          const Divider(),
          _buildInfoRow(l10n.deliveryAddress, order.deliveryAddress),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(Order order) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.paymentInformation,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(l10n.paymentMethod, order.formattedPaymentMethod),
          const Divider(),
          _buildInfoRow(l10n.paymentStatus, order.formattedPaymentStatus),
        ],
      ),
    );
  }

  Widget _buildOrderItems(Order order) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.orderItems,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...order.items!.map((item) {
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
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.darkNavy,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        if (item.variantName.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            item.variantName,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.gray,
                                    ),
                          ),
                        ],
                        if (item.storeName != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            item.storeName!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.gray,
                                      fontSize: 11,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    l10n.quantity(item.quantity),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray,
                        ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    item.subtotal.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkNavy,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderTotals(Order order) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.orderTotals,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darkNavy,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(l10n.subtotal, order.subtotal.toStringAsFixed(2)),
          const Divider(),
          _buildInfoRow(l10n.deliveryFee, order.deliveryFee.toStringAsFixed(2)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.total,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.darkNavy,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                order.total.toStringAsFixed(2),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(Order order) {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      text: l10n.cancelOrder,
      type: AppButtonType.secondary,
      isFullWidth: true,
      onPressed: _viewModel.isOperationInProgress
          ? null
          : () => _handleCancelOrder(order.id),
    );
  }

  Future<void> _handleCancelOrder(int orderId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelOrder),
        content: Text(l10n.cancelOrderConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.yesCancelOrder),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _viewModel.cancelOrder(orderId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context).orderCancelledSuccess),
              backgroundColor: AppColors.success,
            ),
          );
          // Reload order details
          _viewModel.loadOrderById(widget.orderId);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).cancelOrderFailed),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w500,
                  ),
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
