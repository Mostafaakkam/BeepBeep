import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_widgets.dart';
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
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Order Details',
              style: TextStyle(
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
              _viewModel.errorMessage ?? 'Failed to load order',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: 'Retry',
              type: AppButtonType.primary,
              onPressed: () => _viewModel.loadOrderById(widget.orderId),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Order not found',
        style: TextStyle(
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Information',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('Order Number', '#${order.id}'),
          const Divider(),
          _buildInfoRow('Status', order.formattedStatus),
          const Divider(),
          _buildInfoRow('Order Date', _formatDate(order.createdAt)),
        ],
      ),
    );
  }
  
  Widget _buildCustomerInfo(Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Information',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('Name', order.customerName),
          const Divider(),
          _buildInfoRow('Phone', order.customerPhone),
          const Divider(),
          _buildInfoRow('Delivery Address', order.deliveryAddress),
        ],
      ),
    );
  }
  
  Widget _buildPaymentInfo(Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Information',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('Payment Method', order.formattedPaymentMethod),
          const Divider(),
          _buildInfoRow('Payment Status', order.formattedPaymentStatus),
        ],
      ),
    );
  }
  
  Widget _buildOrderItems(Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items',
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
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.darkNavy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.variantName.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            item.variantName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray,
                            ),
                          ),
                        ],
                        if (item.storeName != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            item.storeName!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray,
                                fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    'x${item.quantity}',
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Totals',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('Subtotal', order.subtotal.toStringAsFixed(2)),
          const Divider(),
          _buildInfoRow('Delivery Fee', order.deliveryFee.toStringAsFixed(2)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
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
    return AppButton(
      text: 'Cancel Order',
      type: AppButtonType.secondary,
      isFullWidth: true,
      onPressed: _viewModel.isOperationInProgress
          ? null
          : () => _handleCancelOrder(order.id),
    );
  }
  
  Future<void> _handleCancelOrder(int orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await _viewModel.cancelOrder(orderId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order cancelled successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          // Reload order details
          _viewModel.loadOrderById(widget.orderId);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to cancel order'),
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
              textAlign: TextAlign.right,
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
